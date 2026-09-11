// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Talevra';

  @override
  String get homeTab => 'Beranda';

  @override
  String get exploreTab => 'Jelajahi';

  @override
  String get libraryTab => 'Pustaka';

  @override
  String get settingsTab => 'Pengaturan';

  @override
  String welcomeMessage(String brand) {
    return 'Selamat datang di Talevra - edisi $brand';
  }

  @override
  String currentLocale(String locale) {
    return 'Bahasa: $locale';
  }
}
