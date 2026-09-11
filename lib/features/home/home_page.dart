import 'package:flutter/material.dart';
import 'package:talevra/features/home/home_tab.dart';
import 'package:talevra/features/library/library_page.dart';
import 'package:talevra/features/settings/settings_page.dart';
import 'package:talevra/l10n/app_localizations.dart';

/// 首页外壳：底部三 tab（首页 / 书库 / 设置），各 tab 子页内嵌。
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;
  final List<Widget> _tabs = const [HomeTab(), LibraryPage(), SettingsPage()];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.appTitle)),
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l.homeTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.library_books_outlined),
            selectedIcon: const Icon(Icons.library_books),
            label: l.libraryTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l.settingsTab,
          ),
        ],
      ),
    );
  }
}
