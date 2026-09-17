import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:talevra/app/theme/app_theme.dart';
import 'package:talevra/features/home/home_tab.dart';
import 'package:talevra/features/player/data/player_repository.dart';
import 'package:talevra/l10n/app_localizations.dart';
import 'package:flutter/services.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});
  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  int _tab = 0;
  final _repository = const PlayerRepository();

  Future<List<Drama>> _items() async {
    final result = <Drama>[];
    final language = Localizations.localeOf(context).languageCode;
    try {
      await DramaverseCatalog.channel.invokeMethod<void>('setDramaverseLanguage', {
        'language': language,
      });
    } on PlatformException {
      // Keep local history usable if SDK language sync is temporarily unavailable.
    }
    final dramas = await DramaverseCatalog.dramas();
    for (final drama in dramas) {
      final saved = await _repository.load(drama.id);
      if ((_tab == 0 && saved.lastWatchedAt != null) ||
          (_tab == 1 && (saved.liked || saved.saved))) {
        result.add(drama);
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppPalette.gradient),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l.libraryTab,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<int>(
                  segments: [
                    ButtonSegment(
                      value: 0,
                      icon: const Icon(Icons.history_rounded),
                      label: Text(l.history),
                    ),
                    ButtonSegment(
                      value: 1,
                      icon: const Icon(Icons.favorite_border_rounded),
                      label: Text(l.favorites),
                    ),
                  ],
                  selected: {_tab},
                  onSelectionChanged: (value) =>
                      setState(() => _tab = value.first),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<Drama>>(
                future: _items(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final items = snapshot.data!;
                  if (items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bookmark_border, size: 56),
                          const SizedBox(height: 12),
                          Text(_tab == 0 ? l.noWatchHistory : l.noFavorites),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: () => context.go('/'),
                            child: Text(l.exploreSeries),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => ListTile(
                      tileColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          width: 46,
                          height: 62,
                          child: items[i].coverImage.isEmpty
                              ? ColoredBox(
                                  color: items[i].color,
                                  child: const Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                  ),
                                )
                              : Image.network(
                                  items[i].coverImage,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => ColoredBox(
                                    color: items[i].color,
                                    child: const Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      title: Text(items[i].title),
                      subtitle: Text(
                        l.episodesLong(
                          localizedGenre(l, items[i].genre),
                          items[i].episodes,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        await context.push('/player/${items[i].id}');
                        if (mounted) setState(() {});
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
