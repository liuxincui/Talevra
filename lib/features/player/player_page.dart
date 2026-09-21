import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:talevra/l10n/app_localizations.dart';
import 'package:video_player/video_player.dart';
import 'data/player_repository.dart';
import 'package:talevra/features/earning/data/earning_repository.dart';

/// 沉浸式短剧播放器。视频地址由后端返回时替换 [_demoVideoUrl] 即可。
class PlayerPage extends StatefulWidget {
  final String dramaId;
  final bool isFeed;

  const PlayerPage({super.key, required this.dramaId, this.isFeed = false});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  static const _demoVideoUrl =
      'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4';
  late final VideoPlayerController _controller;
  bool _ready = false;
  bool _liked = false;
  bool _saved = false;
  bool _showControls = true;
  int _episode = 1;
  double _speed = 1;
  Duration _resumePosition = Duration.zero;
  Duration _lastSavedPosition = Duration.zero;
  bool _completionHandled = false;

  final PlayerRepository _repository = const PlayerRepository();

  final _episodes = List<int>.generate(8, (index) => index + 1);

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(_demoVideoUrl));
    if (defaultTargetPlatform == TargetPlatform.android) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _restoreState().then((_) => _openNativeDramaversePlayer());
      });
      return;
    }
    _restoreState().then((_) => _initializeController());
  }

  Future<void> _openNativeDramaversePlayer() async {
    final l = AppLocalizations.of(context)!;
    final language = Localizations.localeOf(context).languageCode;
    try {
      if (!widget.isFeed) {
        await _repository.save(
          dramaId: widget.dramaId,
          state: PlayerPlaybackState(
            liked: _liked,
            saved: _saved,
            episode: _episode,
            speed: _speed,
            position: _resumePosition,
          ),
        );
      }
      final result = await const MethodChannel('talevra/dramaverse')
          .invokeMapMethod<Object?, Object?>('openPlayer', {
            'dramaId': widget.dramaId,
            'mode': widget.isFeed ? 'feed' : 'detail',
            'liked': _liked,
            'episode': _episode,
            'language': language,
          });
      final liked = result?['liked'] == true;
      final episode = (result?['episode'] as num?)?.toInt() ?? _episode;
      final positionMs = (result?['positionMs'] as num?)?.toInt() ?? 0;
      final returnedDramaId = result?['dramaId']?.toString();
      final completedEpisodes =
          (result?['completedEpisodes'] as List<Object?>?)
              ?.map((value) => '$value')
              .toList() ??
          const <String>[];
      final resultDramaId = returnedDramaId == null || returnedDramaId == '-1'
          ? widget.dramaId
          : returnedDramaId;
      if (resultDramaId != 'feed') {
        await _repository.save(
          dramaId: resultDramaId,
          state: PlayerPlaybackState(
            liked: liked,
            saved: _saved,
            episode: episode < 1 ? 1 : episode,
            speed: _speed,
            position: Duration(milliseconds: positionMs),
          ),
        );
      }
      if (completedEpisodes.isNotEmpty) {
        await EarningRepository(useRemoteConfig: false).recordWatchedEpisodes(
          completedEpisodes,
          country: _countryForLanguage(language),
        );
      }
      if (!mounted) return;
      context.pop();
    } on PlatformException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${l.playerLaunchFailed}: ${error.message ?? error.code}',
            ),
          ),
        );
      }
    }
  }

  String _countryForLanguage(String language) => switch (language) {
    'pt' => 'BR',
    'es' => 'MX',
    'id' => 'ID',
    'ja' => 'JP',
    'ko' => 'KR',
    _ => 'US',
  };

  Future<void> _restoreState() async {
    if (widget.isFeed) return;
    final state = await _repository.load(
      widget.dramaId,
      defaultEpisode: _episode,
    );
    if (!mounted) return;
    setState(() {
      _liked = state.liked;
      _saved = state.saved;
      _episode = state.episode.clamp(1, _episodes.length);
      _speed = state.speed;
      _resumePosition = state.position;
    });
  }

  void _initializeController() {
    _controller
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _ready = true);
        if (_resumePosition > Duration.zero &&
            _resumePosition < _controller.value.duration) {
          _controller.seekTo(_resumePosition);
        }
        _controller.play();
      })
      ..addListener(() {
        if (!mounted) return;
        final value = _controller.value;
        if (value.hasError) setState(() {});
        if (value.isInitialized &&
            value.position - _lastSavedPosition > const Duration(seconds: 5)) {
          _persistProgress(value.position);
        }
        if (value.isInitialized &&
            value.position >= value.duration &&
            !_completionHandled) {
          _completionHandled = true;
          _persistProgress(Duration.zero);
          if (_episode < _episodes.length) {
            _selectEpisode(_episode + 1);
          }
        }
      });
  }

  @override
  void dispose() {
    if (_controller.value.isInitialized) {
      _persistProgress(_controller.value.position);
    }
    _controller.dispose();
    super.dispose();
  }

  void _persistProgress(Duration position) {
    _lastSavedPosition = position;
    _repository.save(
      dramaId: widget.dramaId,
      state: PlayerPlaybackState(
        liked: _liked,
        saved: _saved,
        episode: _episode,
        speed: _speed,
        position: position,
      ),
    );
  }

  Future<void> _selectEpisode(int episode) async {
    if (episode < 1 || episode > _episodes.length) return;
    _persistProgress(_controller.value.position);
    final saved = await _repository.loadEpisodePosition(
      widget.dramaId,
      episode,
    );
    setState(() {
      _episode = episode;
      _resumePosition = saved;
      _completionHandled = false;
    });
    if (_controller.value.isInitialized) {
      await _controller.seekTo(
        _resumePosition < _controller.value.duration
            ? _resumePosition
            : Duration.zero,
      );
      await _controller.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F1014),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFF1B56B)),
        ),
      );
    }
    final value = _controller.value;
    return Scaffold(
      backgroundColor: const Color(0xFF090A0D),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: _videoSurface(value)),
            Positioned.fill(
              child: IgnorePointer(
                ignoring: !_showControls,
                child: AnimatedOpacity(
                  opacity: _showControls ? 1 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: _controls(value),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _videoSurface(VideoPlayerValue value) {
    if (_ready && value.isInitialized) {
      return GestureDetector(
        onTap: () => setState(() => _showControls = !_showControls),
        child: Center(
          child: AspectRatio(
            aspectRatio: value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: () => setState(() => _showControls = !_showControls),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF41231D), Color(0xFF111319)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: value.hasError
              ? Text(
                  AppLocalizations.of(context)!.videoLoadFailed,
                  style: const TextStyle(color: Colors.white70),
                )
              : const CircularProgressIndicator(color: Color(0xFFF1B56B)),
        ),
      ),
    );
  }

  Widget _controls(VideoPlayerValue value) {
    final l = AppLocalizations.of(context)!;
    final position = value.position;
    final duration = value.duration;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 10, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  l.episodeNumber(_episode),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _topAction(Icons.more_horiz, () {}),
            ],
          ),
        ),
        const Spacer(),
        if (_ready && value.isInitialized)
          IconButton(
            onPressed: () => setState(() {
              value.isPlaying ? _controller.pause() : _controller.play();
            }),
            icon: Icon(
              value.isPlaying
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_filled,
              color: Colors.white,
              size: 68,
            ),
          ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: _bottomInfo()),
            Padding(
              padding: const EdgeInsets.only(right: 12, bottom: 18),
              child: Column(
                children: [
                  _railAction(
                    _liked ? Icons.favorite : Icons.favorite_border,
                    '12.8k',
                    () {
                      setState(() => _liked = !_liked);
                      _persistProgress(_controller.value.position);
                    },
                    active: _liked,
                  ),
                  _railAction(
                    _saved ? Icons.bookmark : Icons.bookmark_border,
                    l.save,
                    () {
                      setState(() => _saved = !_saved);
                      _persistProgress(_controller.value.position);
                    },
                    active: _saved,
                  ),
                  _railAction(Icons.list_alt, l.episodes, _showEpisodeSheet),
                ],
              ),
            ),
          ],
        ),
        if (_ready && value.isInitialized)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: Row(
              children: [
                Text(
                  _format(position),
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
                Expanded(
                  child: VideoProgressIndicator(
                    _controller,
                    allowScrubbing: true,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    colors: const VideoProgressColors(
                      playedColor: Color(0xFFF1B56B),
                      bufferedColor: Colors.white38,
                      backgroundColor: Colors.white24,
                    ),
                  ),
                ),
                Text(
                  _format(duration),
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _bottomInfo() {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 0, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l.episodeNumber(_episode),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          const SizedBox(height: 10),
          Row(
            children: [
              _pill(l.speedLabel('${_speed}x'), () => _showSpeedSheet()),
              const SizedBox(width: 8),
              _pill(l.highDefinition, () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, VoidCallback onTap) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
  Widget _topAction(IconData icon, VoidCallback onTap) => IconButton(
    onPressed: onTap,
    icon: Icon(icon, color: Colors.white),
  );
  Widget _railAction(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool active = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            icon,
            color: active ? const Color(0xFFFF7777) : Colors.white,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    ),
  );
  String _format(Duration d) =>
      '${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';

  void _showEpisodeSheet() {
    final l = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF17191F),
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.episodes,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 9,
                runSpacing: 9,
                children: _episodes
                    .map(
                      (e) => ChoiceChip(
                        label: Text(e.toString().padLeft(2, '0')),
                        selected: _episode == e,
                        onSelected: (_) {
                          _selectEpisode(e).then((_) {
                            if (context.mounted) Navigator.pop(context);
                          });
                          setSheetState(() {});
                        },
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSpeedSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF17191F),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final speed in [0.75, 1.0, 1.25, 1.5, 2.0])
            ListTile(
              title: Text(
                '${speed}x',
                style: const TextStyle(color: Colors.white),
              ),
              trailing: _speed == speed
                  ? const Icon(Icons.check, color: Color(0xFFF1B56B))
                  : null,
              onTap: () {
                setState(() {
                  _speed = speed;
                  _controller.setPlaybackSpeed(speed);
                });
                Navigator.pop(context);
              },
            ),
        ],
      ),
    );
  }
}
