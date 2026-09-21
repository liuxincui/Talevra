import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:talevra/app/bootstrap/app_initializer.dart';
import 'package:talevra/app/theme/app_theme.dart';
import 'package:talevra/core/tool/coin_tool.dart';
import 'package:talevra/features/earning/application/earning_controller.dart';
import 'package:talevra/core/storage/local_storage.dart';
import 'package:talevra/features/settings/privacy_policy_page.dart';
import 'package:talevra/l10n/app_localizations.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});
  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  String _quality = 'auto';
  String _cacheSize = '15.71 MB';
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
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      ref.read(earningControllerProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale =
        localeOverrideNotifier.value ?? Localizations.localeOf(context);
    final wallet = ref.watch(earningControllerProvider).wallet;
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: _CoinAssetCard(
              coins: wallet?.coins ?? 0,
              onTap: () => context.push('/earning'),
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
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: .94,
            children: [
              _ProfileSetting(
                icon: Icons.cleaning_services_outlined,
                title: l.clearCache,
                subtitle: _cacheSize,
                onTap: _clearCache,
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
                onTap: _showAbout,
              ),
              _ProfileSetting(
                icon: Icons.privacy_tip_outlined,
                title: l.privacyPolicy,
                subtitle: '',
                onTap: _openPrivacyPolicy,
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
                onTap: _showHelp,
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

  Future<void> _openPrivacyPolicy() => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const PrivacyPolicyPage()));

  Future<void> _clearCache() async {
    PaintingBinding.instance.imageCache
      ..clear()
      ..clearLiveImages();
    if (!mounted) return;
    setState(() => _cacheSize = '0 B');
    _message(AppLocalizations.of(context)!.cacheCleared);
  }

  Future<void> _showAbout() => _showInfoSheet(
    icon: Icons.info_outline,
    title: AppLocalizations.of(context)!.aboutNova,
    children: [
      _InfoRow(
        icon: Icons.auto_stories_outlined,
        title: AppLocalizations.of(context)!.appTitle,
        detail: AppLocalizations.of(context)!.versionLabel,
      ),
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.privacy_tip_outlined),
        title: Text(AppLocalizations.of(context)!.privacyPolicy),
        subtitle: Text(PrivacyPolicyPage.uri.host),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.pop(context);
          _openPrivacyPolicy();
        },
      ),
    ],
  );

  Future<void> _showHelp() => _showInfoSheet(
    icon: Icons.help_outline,
    title: AppLocalizations.of(context)!.helpSupport,
    children: [
      _InfoRow(
        icon: Icons.play_circle_outline,
        title: AppLocalizations.of(context)!.playback,
        detail: AppLocalizations.of(context)!.videoLoadFailed,
      ),
      _InfoRow(
        icon: Icons.language,
        title: AppLocalizations.of(context)!.language,
        detail: AppLocalizations.of(context)!.catalogLoadFailed,
      ),
      _InfoRow(
        icon: Icons.cleaning_services_outlined,
        title: AppLocalizations.of(context)!.clearCache,
        detail: AppLocalizations.of(context)!.cacheCleared,
      ),
    ],
  );

  Future<void> _showInfoSheet({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppPalette.pink),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    ),
  );

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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon),
    title: Text(title),
    subtitle: Text(detail),
  );
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
    child: Container(
      padding: const EdgeInsets.fromLTRB(6, 12, 6, 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .055),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: .07)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 36, child: Center(child: Icon(icon, size: 29))),
          const SizedBox(height: 7),
          SizedBox(
            height: 32,
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 3),
          SizedBox(
            height: 16,
            child: subtitle.isEmpty
                ? const SizedBox.shrink()
                : Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppPalette.muted,
                    ),
                  ),
          ),
        ],
      ),
    ),
  );
}

class _CoinAssetCard extends StatelessWidget {
  final int coins;
  final VoidCallback onTap;

  const _CoinAssetCard({required this.coins, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE21BB7), Color(0xFF7B12D1)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x44000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.monetization_on_rounded,
                color: AppPalette.yellow,
                size: 29,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.availableBalance,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .74),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    CoinTool.format(coins),
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white70),
          ],
        ),
      ),
    ),
  );
}
