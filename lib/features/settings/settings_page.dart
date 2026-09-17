import 'package:flutter/material.dart';
import 'package:talevra/app/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talevra/core/storage/local_storage.dart';
import 'package:talevra/core/tool/coin_tool.dart';
import 'package:talevra/features/earning/application/earning_controller.dart';
import 'package:talevra/l10n/app_localizations.dart';
import 'package:talevra/main.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});
  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  String _quality = 'auto';
  bool _autoplay = true;
  bool _wifiOnly = true;

  static const _languages = <String, String>{
    'en': 'English',
    'pt': 'Português',
    'es': 'Español',
    'id': 'Bahasa Indonesia',
    'ja': '日本語',
    'ko': '한국어',
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final coins = ref.watch(walletBalanceProvider)?.coins ?? 0;
    final locale =
        localeOverrideNotifier.value ?? Localizations.localeOf(context);
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppPalette.gradient),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 22),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.guestViewer,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ID 6A982FB5342F39D5DD4CBE8',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .65),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const CircleAvatar(
                    radius: 43,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: AppPalette.pink, size: 54),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE1EAF9), Color(0xFFFFE8D7)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.payments_rounded,
                  color: Color(0xFF43A52D),
                  size: 38,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        CoinTool.format(coins),
                        style: const TextStyle(
                          color: AppPalette.pink,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '${l.withdrawEarnings} · ${CoinTool.format(coins)} ${l.coins}',
                        style: const TextStyle(
                          color: AppPalette.pink,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton(onPressed: () {}, child: Text(l.withdraw)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 10),
            child: Text(
              l.settingsTab,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
          ),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            crossAxisCount: 3,
            childAspectRatio: 1.02,
            children: [
              _ProfileSetting(
                icon: Icons.cleaning_services_outlined,
                title: l.clearCache,
                subtitle: '15.71 MB',
                onTap: () => _message(l.cacheCleared),
              ),
              _ProfileSetting(
                icon: Icons.language,
                title: l.language,
                subtitle:
                    _languages[locale.languageCode] ?? locale.languageCode,
                onTap: _showLanguagePicker,
              ),
              _ProfileSetting(
                icon: Icons.high_quality_outlined,
                title: l.videoQuality,
                subtitle: _qualityLabel(l, _quality),
                onTap: _showQualityPicker,
              ),
              _ProfileSetting(
                icon: Icons.info_outline,
                title: l.aboutNova,
                subtitle: l.versionLabel,
                onTap: () {},
              ),
              _ProfileSetting(
                icon: Icons.privacy_tip_outlined,
                title: l.privacyPolicy,
                subtitle: '',
                onTap: () => _message(l.supportSoon),
              ),
              _ProfileSetting(
                icon: _autoplay
                    ? Icons.play_circle_fill
                    : Icons.play_circle_outline,
                title: l.autoplayNext,
                subtitle: _autoplay ? l.onLabel : l.offLabel,
                onTap: () => setState(() => _autoplay = !_autoplay),
              ),
              _ProfileSetting(
                icon: _wifiOnly ? Icons.wifi : Icons.network_cell,
                title: l.downloadWifiOnly,
                subtitle: _wifiOnly ? l.onLabel : l.offLabel,
                onTap: () => setState(() => _wifiOnly = !_wifiOnly),
              ),
              _ProfileSetting(
                icon: Icons.help_outline,
                title: l.helpSupport,
                subtitle: '',
                onTap: () => _message(l.supportSoon),
              ),
            ],
          ),
          const SizedBox(height: 34),
        ],
      ),
    );
  }

  Future<void> _showQualityPicker() async {
    final l = AppLocalizations.of(context)!;
    final options = <String, String>{
      'auto': l.autoLabel,
      'hd': 'HD',
      'dataSaver': l.dataSaver,
    };
    final value = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.entries
              .map(
                (entry) => ListTile(
                  title: Text(entry.value),
                  trailing: _quality == entry.key
                      ? const Icon(Icons.check, color: AppPalette.pink)
                      : null,
                  onTap: () => Navigator.pop(context, entry.key),
                ),
              )
              .toList(),
        ),
      ),
    );
    if (value != null) setState(() => _quality = value);
  }

  String _qualityLabel(AppLocalizations l, String value) => switch (value) {
    'hd' => 'HD',
    'dataSaver' => l.dataSaver,
    _ => l.autoLabel,
  };

  Future<void> _showLanguagePicker() async {
    final current =
        localeOverrideNotifier.value?.languageCode ??
        Localizations.localeOf(context).languageCode;
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: _languages.entries
              .map(
                (entry) => ListTile(
                  leading: Icon(
                    entry.key == current
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                  ),
                  title: Text(entry.value),
                  subtitle: Text(entry.key.toUpperCase()),
                  onTap: () => Navigator.pop(context, entry.key),
                ),
              )
              .toList(),
        ),
      ),
    );
    if (selected == null || !mounted) {
      return;
    }
    final locale = Locale(selected);
    localeOverrideNotifier.value = locale;
    if (LocalStorage.isInitialized) {
      await LocalStorage.I.setString('settings.locale', selected);
    }
  }

  void _message(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
}

class _ProfileSetting extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ProfileSetting({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 31),
          const SizedBox(height: 9),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 1,
              style: const TextStyle(fontSize: 11, color: AppPalette.muted),
            ),
          ],
        ],
      ),
    ),
  );
}
