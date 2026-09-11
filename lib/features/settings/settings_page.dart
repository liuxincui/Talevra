import 'package:flutter/material.dart';
import 'package:talevra/l10n/app_localizations.dart';

/// 设置 tab：占位，后续接语言切换、账号、播放偏好等。
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Center(
      child: Text(
        l.settingsTab,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}
