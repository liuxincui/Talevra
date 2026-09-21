import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talevra/app/bootstrap/app_initializer.dart';
import 'package:talevra/app/router/app_router.dart';
import 'package:talevra/app/theme/app_theme.dart';
import 'package:talevra/core/config/brand_provider.dart';
import 'package:talevra/l10n/app_localizations.dart';

/// 通用品牌 App：由各品牌入口（main_brand_*.dart）注入
/// [brandCode] + [supportedLocales] + [defaultLocale]，实现"不同品牌启用不同语种"。
/// 内部接入路由、主题、本地化、provider。
class TalevraApp extends StatelessWidget {
  final String brandCode;
  final Iterable<Locale> supportedLocales;
  final Locale? defaultLocale;

  const TalevraApp({
    super.key,
    required this.brandCode,
    required this.supportedLocales,
    this.defaultLocale,
  });

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<Locale?>(
    valueListenable: localeOverrideNotifier,
    builder: (context, selectedLocale, _) => ProviderScope(
      overrides: [brandCodeProvider.overrideWithValue(brandCode)],
      child: MaterialApp.router(
        title: 'Talevra',
        debugShowCheckedModeBanner: false,
        locale: selectedLocale ?? defaultLocale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        routerConfig: AppRouter.config,
      ),
    ),
  );
}
