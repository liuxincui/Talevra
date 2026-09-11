// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Talevra';

  @override
  String get homeTab => 'Home';

  @override
  String get exploreTab => 'Explore';

  @override
  String get libraryTab => 'Library';

  @override
  String get settingsTab => 'Settings';

  @override
  String welcomeMessage(String brand) {
    return 'Welcome to Talevra - $brand edition';
  }

  @override
  String currentLocale(String locale) {
    return 'Locale: $locale';
  }
}
