import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:talevra/features/home/home_tab.dart';
import 'package:talevra/features/earning/earning_page.dart';
import 'package:talevra/features/library/library_page.dart';
import 'package:talevra/features/settings/settings_page.dart';
import 'package:talevra/l10n/app_localizations.dart';

/// Consumer shell with a dedicated full-screen feed and rewards destination.
class HomePage extends StatefulWidget {
  final int initialTab;

  const HomePage({super.key, this.initialTab = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _index;
  int _rewardsRevision = 0;

  List<Widget> get _tabs => [
    const HomeTab(),
    EarningPage(key: ValueKey(_rewardsRevision)),
    const LibraryPage(),
    const SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _index = widget.initialTab.clamp(0, _tabs.length - 1);
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      _index = widget.initialTab.clamp(0, _tabs.length - 1);
    }
  }

  void _select(int index) {
    if (index == 1) {
      context.push('/player/feed?mode=feed');
      return;
    }
    setState(() {
      if (index == 2) _rewardsRevision += 1;
      _index = index > 1 ? index - 1 : index;
    });
  }

  int get _selectedDestination => _index == 0 ? 0 : _index + 1;

  Widget _sliceIcon(String path) => Image.asset(
    path,
    width: 24,
    height: 24,
    fit: BoxFit.contain,
    errorBuilder: (_, __, ___) => const Icon(Icons.circle_outlined),
  );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedDestination,
        onDestinationSelected: _select,
        destinations: [
          NavigationDestination(
            icon: _sliceIcon(
              'assets/ui_slices/控件状态/mipmap-xhdpi/icon_nav_home_off.png',
            ),
            selectedIcon: _sliceIcon(
              'assets/ui_slices/主页_展示_slices/mipmap-xhdpi/icon_nav_home_on.png',
            ),
            label: l.homeTab,
          ),
          NavigationDestination(
            icon: _sliceIcon(
              'assets/ui_slices/主页_展示_slices/mipmap-xhdpi/icon_nav_watch_off.png',
            ),
            selectedIcon: _sliceIcon(
              'assets/ui_slices/主页_观看_slices/mipmap-xhdpi/icon_nav_watch_on.png',
            ),
            label: l.shortsTab,
          ),
          NavigationDestination(
            icon: _sliceIcon(
              'assets/ui_slices/主页_展示_slices/mipmap-xhdpi/icon_nav_gift_off.png',
            ),
            selectedIcon: _sliceIcon(
              'assets/ui_slices/主页_活动_slices/mipmap-xhdpi/icon_nav_gift_on.png',
            ),
            label: l.rewardsTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_border_rounded),
            selectedIcon: const Icon(Icons.favorite, color: Colors.white),
            label: l.history,
          ),
          NavigationDestination(
            icon: _sliceIcon(
              'assets/ui_slices/主页_展示_slices/mipmap-xhdpi/icon_nav_mine_off.png',
            ),
            selectedIcon: _sliceIcon(
              'assets/ui_slices/主页_我的_slices/mipmap-xhdpi/icon_nav_mine_on.png',
            ),
            label: l.profileTab,
          ),
        ],
      ),
    );
  }
}
