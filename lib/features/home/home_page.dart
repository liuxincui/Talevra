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
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l.homeTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.smart_display_outlined),
            selectedIcon: const Icon(Icons.smart_display, color: Colors.white),
            label: l.shortsTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.paid_outlined),
            selectedIcon: const Icon(Icons.paid, color: Color(0xFFFFC72C)),
            label: l.rewardsTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_border_rounded),
            selectedIcon: const Icon(Icons.favorite, color: Colors.white),
            label: l.history,
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_circle_outlined),
            selectedIcon: const Icon(Icons.account_circle, color: Colors.white),
            label: l.profileTab,
          ),
        ],
      ),
    );
  }
}
