// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Talevra';

  @override
  String get homeTab => 'Início';

  @override
  String get exploreTab => 'Explorar';

  @override
  String get libraryTab => 'Biblioteca';

  @override
  String get settingsTab => 'Configurações';

  @override
  String welcomeMessage(String brand) {
    return 'Bem-vindo ao Talevra - edição $brand';
  }

  @override
  String currentLocale(String locale) {
    return 'Idioma: $locale';
  }
}
