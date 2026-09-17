import 'package:talevra/core/storage/local_storage.dart';

class PlayerPlaybackState {
  final bool liked;
  final bool saved;
  final int episode;
  final double speed;
  final Duration position;
  final DateTime? lastWatchedAt;

  const PlayerPlaybackState({
    this.liked = false,
    this.saved = false,
    this.episode = 1,
    this.speed = 1,
    this.position = Duration.zero,
    this.lastWatchedAt,
  });
}

/// 播放业务服务。切换到接口时替换本类实现，页面无需改动。
class PlayerRepository {
  const PlayerRepository();
  String _prefix(String dramaId) => 'player.$dramaId';

  Future<PlayerPlaybackState> load(
    String dramaId, {
    int defaultEpisode = 1,
  }) async {
    if (!LocalStorage.isInitialized) {
      return PlayerPlaybackState(episode: defaultEpisode);
    }
    final key = _prefix(dramaId);
    final storage = LocalStorage.I;
    final episode = storage.getInt('$key.episode') ?? defaultEpisode;
    final watched = storage.getString('$key.lastWatchedAt');
    return PlayerPlaybackState(
      liked: storage.getBool('$key.liked') ?? false,
      saved: storage.getBool('$key.saved') ?? false,
      episode: episode,
      speed: storage.getDouble('$key.speed') ?? 1,
      position: Duration(
        milliseconds: storage.getInt('$key.position.episode$episode') ?? 0,
      ),
      lastWatchedAt: watched == null ? null : DateTime.tryParse(watched),
    );
  }

  Future<Duration> loadEpisodePosition(String dramaId, int episode) async {
    if (!LocalStorage.isInitialized) return Duration.zero;
    return Duration(
      milliseconds:
          LocalStorage.I.getInt(
            '${_prefix(dramaId)}.position.episode$episode',
          ) ??
          0,
    );
  }

  Future<void> save({
    required String dramaId,
    required PlayerPlaybackState state,
  }) async {
    if (!LocalStorage.isInitialized) return;
    final key = _prefix(dramaId);
    LocalStorage.I
      ..setBool('$key.liked', state.liked)
      ..setBool('$key.saved', state.saved)
      ..setInt('$key.episode', state.episode)
      ..setDouble('$key.speed', state.speed)
      ..setInt(
        '$key.position.episode${state.episode}',
        state.position.inMilliseconds,
      )
      ..setString(
        '$key.lastWatchedAt',
        (state.lastWatchedAt ?? DateTime.now()).toIso8601String(),
      );
  }
}
