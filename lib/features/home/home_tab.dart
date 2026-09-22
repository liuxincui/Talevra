import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:talevra/app/theme/app_theme.dart';
import 'package:talevra/l10n/app_localizations.dart';
import 'package:flutter/services.dart';

class Drama {
  final String id;
  final String title;
  final String genre;
  final List<String> tags;
  final int episodes;
  final Color color;
  final String coverImage;
  const Drama(
    this.id,
    this.title,
    this.genre,
    this.episodes,
    this.color, {
    this.coverImage = '',
    this.tags = const [],
  });

  factory Drama.fromMap(Map<Object?, Object?> map) => Drama(
    map['id']?.toString() ?? '',
    map['title']?.toString() ?? '',
    map['category']?.toString() ?? '',
    (map['episodes'] as num?)?.toInt() ?? 0,
    const Color(0xFF263B42),
    coverImage: map['coverImage']?.toString() ?? '',
    tags:
        (map['tags'] as List<Object?>?)?.whereType<String>().toList() ??
        const [],
  );
}

String localizedGenre(AppLocalizations l, String genre) =>
    switch (genre.trim().toLowerCase()) {
      'recommend' || 'recommended' || 'popular' || 'for you' => l.forYou,
      'new' => l.newLabel,
      'romance' => l.romance,
      'revenge' => l.revenge,
      'fantasy' => l.fantasy,
      'ceo' => l.ceo,
      'historical' => l.historical,
      'family' => l.family,
      'male category' || 'male' => l.maleCategory,
      'female category' || 'female' => l.femaleCategory,
      'suspense' => l.suspense,
      _ => genre,
    };

class DramaverseCatalog {
  static const channel = MethodChannel('talevra/dramaverse');

  static Future<List<Drama>> dramas({int categoryId = -2}) async {
    final raw = await channel.invokeMethod<List<Object?>>(
      'getDramaverseDramas',
      {'categoryId': categoryId},
    );
    return raw
            ?.whereType<Map<Object?, Object?>>()
            .map(Drama.fromMap)
            .toList() ??
        const [];
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});
  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  static const _channel = MethodChannel('talevra/dramaverse');
  List<Map<Object?, Object?>> _categories = const [];
  List<Drama> _dramas = const [];
  Map<String, List<Drama>> _categoryDramas = const {};
  int _categoryId = -2;
  bool _loading = true;
  String? _error;
  String _query = '';
  String? _lastSdkLanguage;
  final _search = TextEditingController();

  String _currencyValue(BuildContext context) {
    return switch (Localizations.localeOf(context).languageCode) {
      'pt' => 'R\$ 955,58',
      'es' => 'MX\$ 955.58',
      'id' => 'Rp 955.580',
      'ja' => '¥955',
      'ko' => '₩955',
      _ => '\$955.58',
    };
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final language = Localizations.localeOf(context).languageCode;
    if (_lastSdkLanguage != language) {
      _lastSdkLanguage = language;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _syncSdkLanguage(language);
      });
    }
  }

  Future<void> _syncSdkLanguage(String language) async {
    try {
      await _channel.invokeMethod<void>('setDramaverseLanguage', {
        'language': language,
      });
      await _loadCategories();
    } on PlatformException catch (error) {
      if (mounted) {
        setState(() => _error = '${error.code}: ${error.message}');
      }
    }
  }

  Future<void> _loadCategories() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final raw = await _channel.invokeMethod<List<Object?>>(
        'getDramaverseCategories',
      );
      _categories =
          raw?.whereType<Map<Object?, Object?>>().toList() ?? const [];
      await _loadDramas(_categoryId);
      final categoryEntries = _categories.where((item) {
        final id = (item['id'] as num?)?.toInt() ?? 0;
        return id > 0;
      }).toList();
      final loaded = await Future.wait(
        categoryEntries.map((item) async {
          final id = (item['id'] as num?)?.toInt() ?? 0;
          final name = '${item['name'] ?? ''}'.trim();
          return MapEntry(name, await DramaverseCatalog.dramas(categoryId: id));
        }),
      );
      if (mounted) {
        setState(
          () => _categoryDramas = {
            for (final entry in loaded)
              if (entry.key.isNotEmpty && entry.value.isNotEmpty)
                entry.key: entry.value,
          },
        );
      }
    } on PlatformException catch (error) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = '${error.code}: ${error.message}';
        });
      }
    }
  }

  Future<void> _loadDramas(int categoryId) async {
    setState(() {
      _categoryId = categoryId;
      _loading = true;
      _error = null;
    });
    try {
      final dramas = await DramaverseCatalog.dramas(categoryId: categoryId);
      if (!mounted) return;
      setState(() {
        _dramas = dramas;
        _loading = false;
      });
    } on PlatformException catch (error) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = '${error.code}: ${error.message}';
        });
      }
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final visible = _dramas
        .where(
          (d) =>
              _query.isEmpty ||
              '${d.title} ${d.genre}'.toLowerCase().contains(
                _query.toLowerCase(),
              ),
        )
        .toList();
    final categorySections = <String, List<Drama>>{};
    if (_categoryId == -2) {
      for (final category in _categories) {
        final name = '${category['name'] ?? ''}'.trim();
        final dramas = _categoryDramas[name]
            ?.where(
              (d) =>
                  _query.isEmpty ||
                  '${d.title} ${d.genre}'.toLowerCase().contains(
                    _query.toLowerCase(),
                  ),
            )
            .toList();
        if (name.isNotEmpty && dramas != null && dramas.isNotEmpty) {
          categorySections[name] = dramas;
        }
      }
    } else {
      final selectedName = _categories
          .where((item) => (item['id'] as num?)?.toInt() == _categoryId)
          .map((item) => '${item['name'] ?? ''}'.trim())
          .firstWhere((name) => name.isNotEmpty, orElse: () => 'All');
      categorySections[selectedName] = visible;
    }
    if (categorySections.isEmpty && visible.isNotEmpty) {
      categorySections['All'] = visible;
    }
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppPalette.gradient),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _HomeHeader(
              onSearch: _showSearch,
              currency: _currencyValue(context),
              categories: _categories,
              selectedId: _categoryId,
              onSelected: (id) {
                _loadDramas(id);
              },
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (_loading)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 48),
                    child: Column(
                      children: [
                        const CircularProgressIndicator(color: Colors.white),
                        const SizedBox(height: 14),
                        Text(
                          l.loadingSeries,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  )
                else if (_error != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 42, 24, 24),
                    child: Column(
                      children: [
                        Text(
                          l.catalogLoadFailed,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 14),
                        FilledButton.icon(
                          onPressed: _loadCategories,
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(l.retry),
                        ),
                      ],
                    ),
                  )
                else if (visible.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(28),
                    child: Center(child: Text(l.noStoriesFound)),
                  )
                else
                  _DramaSections(dramas: visible, sections: categorySections),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSearch() async {
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.searchStories),
        content: TextField(
          controller: _search,
          autofocus: true,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.titleOrGenre,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, _search.text),
            child: Text(AppLocalizations.of(context)!.search),
          ),
        ],
      ),
    );
    if (value != null) setState(() => _query = value.trim());
  }
}

class _DramaCard extends StatelessWidget {
  final Drama drama;
  final int index;
  const _DramaCard({required this.drama, this.index = 0});

  Widget _posterFallback() => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          drama.color.withValues(alpha: .55),
          drama.color,
          const Color(0xFF140A18),
        ],
      ),
    ),
    child: Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          right: -24,
          top: 20,
          child: Icon(
            Icons.auto_awesome,
            size: 108,
            color: Colors.white.withValues(alpha: .12),
          ),
        ),
        Align(
          alignment: const Alignment(0, .28),
          child: Icon(
            Icons.theater_comedy_rounded,
            size: 48,
            color: Colors.white.withValues(alpha: .55),
          ),
        ),
        Positioned(
          left: 8,
          right: 8,
          bottom: 10,
          child: Text(
            drama.title.toUpperCase(),
            maxLines: 3,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              height: 1,
              fontWeight: FontWeight.w900,
              shadows: [Shadow(blurRadius: 8, color: Colors.black)],
            ),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => context.push('/player/${drama.id}'),
    borderRadius: BorderRadius.circular(7),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          height: 168,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              fit: StackFit.expand,
              children: [
                drama.coverImage.isNotEmpty
                    ? Image.network(
                        drama.coverImage,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _posterFallback(),
                      )
                    : _posterFallback(),
                if (index % 3 == 1)
                  Positioned(
                    left: 0,
                    top: 0,
                    child: _CornerBadge(
                      label: AppLocalizations.of(
                        context,
                      )!.newLabel.toUpperCase(),
                    ),
                  ),
                if (drama.tags.any((tag) => tag.trim().toLowerCase() == 'hot'))
                  Positioned(
                    right: 3,
                    top: 3,
                    child: Container(
                      width: 39,
                      height: 12,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFA0194),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '🔥HOT',
                          style: TextStyle(
                            fontSize: 10,
                            height: 1,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  right: 6,
                  bottom: 6,
                  child: Text(
                    '● ${(33 + index * 84)}k',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      shadows: [Shadow(blurRadius: 5, color: Colors.black)],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          drama.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12.5,
            height: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _TaskProgress extends StatelessWidget {
  final String reward;
  final String dramaTitle;
  final String currency;
  const _TaskProgress({
    required this.reward,
    required this.dramaTitle,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 180,
    height: 48,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: 139,
            height: 12,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0x0FFFFFFF), Color(0x54FFFFFF)],
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  reward,
                  style: const TextStyle(
                    fontSize: 9,
                    height: 1,
                    color: Color(0xFF60E7FF),
                  ),
                ),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    dramaTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 9,
                      height: 1,
                      color: Color(0xFFECEBF0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 2),
        SizedBox(
          height: 30,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: const Color(0x73100F18),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0x40B2B2B2), width: .5),
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/ui_slices/主页_展示_slices/mipmap-mdpi/icon_cash.png',
                  width: 34,
                  height: 34,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'assets/icons/cash.png',
                    width: 34,
                    height: 34,
                  ),
                ),
                const Spacer(),
                Text(
                  currency,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _HomeHeader extends StatelessWidget {
  final VoidCallback onSearch;
  final String currency;
  final List<Map<Object?, Object?>> categories;
  final int selectedId;
  final ValueChanged<int> onSelected;

  const _HomeHeader({
    required this.onSearch,
    required this.currency,
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 21.81, 12, 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _TaskProgress(
                reward: 'Rp 37.520',
                dramaTitle: 'Title ABCD ABAG',
                currency: currency,
              ),
              SizedBox(width: 8),
              _TaskProgress(
                reward: 'Rp 37.520',
                dramaTitle: 'Title ABCD ABAG',
                currency: currency,
              ),
            ],
          ),
        ),
        _ChannelBar(
          categories: categories,
          selectedId: selectedId,
          onSelected: onSelected,
          onSearch: onSearch,
        ),
      ],
    ),
  );
}

class _ChannelBar extends StatelessWidget {
  final List<Map<Object?, Object?>> categories;
  final int selectedId;
  final ValueChanged<int> onSelected;
  final VoidCallback onSearch;
  const _ChannelBar({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = <Map<Object?, Object?>>[
      {'id': -2, 'name': 'Recommend'},
      {'id': -1, 'name': 'New'},
      {'id': -4, 'name': 'Male Category'},
      {'id': -5, 'name': 'Female Category'},
      {'id': -6, 'name': 'Suspense'},
    ];
    final items = categories.isEmpty ? fallback : categories;
    return SizedBox(
      height: 35,
      child: Row(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(left: 16),
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 24),
              itemBuilder: (_, i) {
                final id = (items[i]['id'] as num?)?.toInt() ?? -2;
                final active = id == selectedId;
                final label = switch (id) {
                  -2 => AppLocalizations.of(context)!.forYou,
                  -1 => AppLocalizations.of(context)!.newLabel,
                  _ => localizedGenre(
                    AppLocalizations.of(context)!,
                    '${items[i]['name'] ?? ''}',
                  ),
                };
                return InkWell(
                  onTap: () => onSelected(id),
                  child: SizedBox(
                    height: 35,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: active
                                ? FontWeight.w900
                                : FontWeight.w500,
                            color: active
                                ? Colors.white
                                : const Color(0xFF8D919B),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          width: active ? 30 : 0,
                          height: 2,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF3D9E),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          IconButton(
            tooltip: 'Search',
            onPressed: onSearch,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 40, height: 35),
            icon: const Icon(Icons.search_rounded, size: 27),
          ),
        ],
      ),
    );
  }
}

class _DramaSections extends StatelessWidget {
  final List<Drama> dramas;
  final Map<String, List<Drama>> sections;
  const _DramaSections({required this.dramas, this.sections = const {}});

  @override
  Widget build(BuildContext context) {
    final grouped = <({String name, List<Drama> dramas})>[];
    if (sections.isNotEmpty) {
      for (final entry in sections.entries) {
        grouped.add((name: entry.key, dramas: entry.value.take(8).toList()));
      }
    }
    if (grouped.isEmpty) {
      grouped.add((name: 'For You', dramas: dramas.take(8).toList()));
    }
    return Column(
      children: [
        for (final section in grouped)
          _DramaSection(name: section.name, dramas: section.dramas),
      ],
    );
  }
}

class _DramaSection extends StatelessWidget {
  final String name;
  final List<Drama> dramas;
  const _DramaSection({required this.name, required this.dramas});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => _DramaListPage(title: name, dramas: dramas),
            ),
          ),
          child: SizedBox(
            height: 29,
            child: Row(
              children: [
                Text(
                  '🔥$name',
                  style: const TextStyle(fontSize: 17, color: Colors.white),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right_rounded, color: Colors.white70),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 203,
          child: ListView.separated(
            key: PageStorageKey<String>('home-category-$name'),
            scrollDirection: Axis.horizontal,
            itemCount: dramas.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, index) => SizedBox(
              width: 120,
              child: _DramaCard(drama: dramas[index], index: index),
            ),
          ),
        ),
      ],
    ),
  );
}

class _DramaListPage extends StatelessWidget {
  final String title;
  final List<Drama> dramas;
  const _DramaListPage({required this.title, required this.dramas});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: DecoratedBox(
      decoration: const BoxDecoration(gradient: AppPalette.gradient),
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
        itemCount: dramas.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 12,
          childAspectRatio: .49,
        ),
        itemBuilder: (_, index) =>
            _DramaCard(drama: dramas[index], index: index),
      ),
    ),
  );
}

class _CornerBadge extends StatelessWidget {
  final String label;
  const _CornerBadge({required this.label});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
    decoration: const BoxDecoration(
      color: AppPalette.purple,
      borderRadius: BorderRadius.only(bottomRight: Radius.circular(5)),
    ),
    child: Text(
      label,
      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900),
    ),
  );
}

class RankingsPage extends StatelessWidget {
  const RankingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.rankings)),
      body: FutureBuilder<List<Drama>>(
        future: DramaverseCatalog.dramas(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final dramas = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: dramas.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (_, i) => ListTile(
              leading: CircleAvatar(child: Text('${i + 1}')),
              title: Text(dramas[i].title),
              subtitle: Text(
                l.episodesLong(
                  localizedGenre(l, dramas[i].genre),
                  dramas[i].episodes,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/player/${dramas[i].id}'),
            ),
          );
        },
      ),
    );
  }
}
