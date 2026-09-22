import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:talevra/features/home/home_tab.dart';
import 'package:talevra/features/earning/earning_page.dart';
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
      _index = switch (index) {
        2 => 1,
        3 => 2,
        _ => 0,
      };
    });
  }

  int get _selectedDestination => switch (_index) {
    1 => 2,
    2 => 3,
    _ => 0,
  };

  Widget _sliceIcon(String path) => Image.asset(
    path,
    width: 24,
    height: 24,
    fit: BoxFit.contain,
    errorBuilder: (_, __, ___) => const Icon(Icons.circle_outlined),
  );

  Widget _navIcon(String path, bool selected) => Container(
    width: selected ? 58 : 48,
    height: 34,
    decoration: BoxDecoration(
      color: selected ? const Color(0xFFFF00B8) : Colors.transparent,
      borderRadius: BorderRadius.circular(18),
    ),
    alignment: Alignment.center,
    child: _sliceIcon(path),
  );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: ColoredBox(
        color: const Color(0xFF19002E),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 72,
            child: Row(
              children: [
                _navItem(
                  0,
                  l.homeTab,
                  'assets/icons/home_off.png',
                  'assets/icons/home_on.png',
                ),
                _navItem(
                  1,
                  l.shortsTab,
                  'assets/icons/watch_off.png',
                  'assets/icons/watch_on.png',
                ),
                _navItem(
                  2,
                  l.rewardsTab,
                  'assets/icons/gift_off.png',
                  'assets/icons/gift_on.png',
                ),
                _navItem(
                  3,
                  l.profileTab,
                  'assets/icons/mine_off.png',
                  'assets/icons/mine_on.png',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, String label, String off, String on) {
    final selected = _selectedDestination == index;
    return Expanded(
      child: InkWell(
        onTap: () => _select(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _navIcon(selected ? on : off, selected),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: selected ? Colors.white : Colors.white70,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
