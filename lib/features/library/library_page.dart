import 'package:flutter/material.dart';
import 'package:talevra/l10n/app_localizations.dart';

/// 书库 tab：占位，后续接短剧列表。
class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Center(
      child: Text(
        l.libraryTab,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}
