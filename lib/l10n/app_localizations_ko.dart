// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Talevra';

  @override
  String get homeTab => '홈';

  @override
  String get exploreTab => '탐색';

  @override
  String get libraryTab => '라이브러리';

  @override
  String get settingsTab => '설정';

  @override
  String welcomeMessage(String brand) {
    return 'Talevra에 오신 것을 환영합니다 - $brand 버전';
  }

  @override
  String currentLocale(String locale) {
    return '언어: $locale';
  }
}
