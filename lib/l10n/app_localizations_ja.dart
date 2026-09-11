// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Talevra';

  @override
  String get homeTab => 'ホーム';

  @override
  String get exploreTab => '発見';

  @override
  String get libraryTab => 'ライブラリ';

  @override
  String get settingsTab => '設定';

  @override
  String welcomeMessage(String brand) {
    return 'Talevra へようこそ - $brand 版';
  }

  @override
  String currentLocale(String locale) {
    return '言語：$locale';
  }
}
