// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Talevra';

  @override
  String get homeTab => 'Inicio';

  @override
  String get exploreTab => 'Explorar';

  @override
  String get libraryTab => 'Biblioteca';

  @override
  String get settingsTab => 'Ajustes';

  @override
  String welcomeMessage(String brand) {
    return 'Bienvenido a Talevra - edición $brand';
  }

  @override
  String currentLocale(String locale) {
    return 'Idioma: $locale';
  }
}
