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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment(0.45, 1),
          colors: [Color(0xFF0A0B0F), Color(0xFF7B5024)],
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(15, 83, 15, 24),
        children: [
          _CoinAssetCard(
            coins: wallet?.coins ?? 0,
            onTap: () => context.push('/earning'),
          ),
          const SizedBox(height: 22),
          _HistoryPreview(onTap: () => context.push('/player/feed?mode=feed')),
          _ProfileRow(
            asset:
                'assets/ui_slices/主页_我的_slices/mipmap-mdpi/icon_mine_folder.png',
            label: l.favorites,
            onTap: () => context.push('/library?tab=favorites'),
          ),
          _ProfileRow(
            icon: Icons.help_outline,
            label: l.helpSupport,
            onTap: _showHelp,
          ),
          _ProfileRow(
            icon: Icons.language,
            label: l.language,
            trailing: _languages[locale.languageCode] ?? locale.languageCode,
            onTap: _showLanguagePicker,
          ),
          _ProfileRow(
            icon: Icons.cleaning_services_outlined,
            label: l.clearCache,
            trailing: _cacheSize,
            onTap: _clearCache,
          ),
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

class _HistoryPreview extends StatelessWidget {
  final VoidCallback onTap;
  const _HistoryPreview({required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/ui_slices/主页_我的_slices/mipmap-mdpi/icon_mine_history.png',
                width: 28,
                height: 28,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '观看历史',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              Image.asset(
                'assets/ui_slices/主页_我的_slices/mipmap-mdpi/icon_mine_sidemenu.png',
                width: 22,
                height: 22,
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 125,
            child: Row(
              children: List.generate(
                3,
                (index) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: index == 2 ? 0 : 7),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: DecoratedBox(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFE51C75),
                                    Color(0xFF5E25A5),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.auto_stories_rounded,
                                  size: 42,
                                  color: Colors.white.withValues(alpha: .78),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'No Longer the ...',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: .8),
                          ),
                        ),
                        const Text(
                          'Episode 1',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppPalette.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String? asset;
  final String label;
  final String? trailing;
  final VoidCallback onTap;
  const _ProfileRow({
    this.icon = Icons.chevron_right,
    required this.label,
    required this.onTap,
    this.trailing,
    this.asset,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 60,
    child: ListTile(
      contentPadding: const EdgeInsets.only(left: 20, right: 20),
      leading: asset == null
          ? Icon(icon, size: 28)
          : Image.asset(asset!, width: 28, height: 28),
      title: Text(label, style: const TextStyle(fontSize: 16)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null)
            Text(
              trailing!,
              style: const TextStyle(fontSize: 12, color: Color(0xFFB5B8BE)),
            ),
          const SizedBox(width: 8),
          Image.asset(
            'assets/ui_slices/主页_我的_slices/mipmap-mdpi/icon_mine_sidemenu.png',
            width: 22,
            height: 22,
          ),
        ],
      ),
      onTap: onTap,
    ),
  );
}

class _CoinAssetCard extends StatelessWidget {
  final int coins;
  final VoidCallback onTap;

  const _CoinAssetCard({required this.coins, required this.onTap});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 180,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Ink(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFE35B), Color(0xFFFFCB2D)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Color(0xFFFFFC66), offset: Offset(0, 1)),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 24,
                    top: 17,
                    child: Text(
                      AppLocalizations.of(context)!.availableBalance,
                      style: const TextStyle(
                        color: Color(0xFFC16945),
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 24,
                    top: 55.5,
                    child: Text(
                      'Rp ${CoinTool.format(coins)}',
                      style: const TextStyle(
                        color: Color(0xFF682204),
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 21,
                    right: 21,
                    bottom: 12,
                    height: 56,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF3D82), Color(0xFFFF6567)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)!.withdraw,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 12,
          top: -34,
          child: Image.asset(
            'assets/ui_slices/主页_我的_slices/mipmap-mdpi/icon_wallet.png',
            width: 91,
            height: 91,
          ),
        ),
      ],
    ),
  );
}
