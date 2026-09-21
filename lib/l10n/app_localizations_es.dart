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

  @override
  String get rewardsTab => 'Recompensas';

  @override
  String get rewardsUnavailable =>
      'Las recompensas no están disponibles temporalmente. Las demás funciones siguen activas.';

  @override
  String get retry => 'Reintentar';

  @override
  String get exclusivePremiere => 'ESTRENO EXCLUSIVO';

  @override
  String get featuredTitle => 'El invierno nunca termina';

  @override
  String get featuredSubtitle => 'Regresó con una promesa: recuperarlo todo.';

  @override
  String get watchNow => 'Ver ahora';

  @override
  String get forYou => 'Para ti';

  @override
  String get newLabel => 'Nuevo';

  @override
  String get romance => 'Romance';

  @override
  String get revenge => 'Venganza';

  @override
  String get fantasy => 'Fantasía';

  @override
  String get more => 'Más';

  @override
  String get trendingNow => 'Tendencias';

  @override
  String get searchResults => 'Resultados de búsqueda';

  @override
  String get rankings => 'Clasificación';

  @override
  String get noStoriesFound => 'No se encontraron historias';

  @override
  String get searchStories => 'Buscar historias';

  @override
  String get titleOrGenre => 'Título o género';

  @override
  String get cancel => 'Cancelar';

  @override
  String get search => 'Buscar';

  @override
  String get history => 'Historial';

  @override
  String get favorites => 'Favoritos';

  @override
  String get noWatchHistory => 'Aún no hay historial';

  @override
  String get noFavorites => 'Aún no hay favoritos';

  @override
  String get exploreSeries => 'Explorar series';

  @override
  String get guestViewer => 'Visitante';

  @override
  String get signInSync => 'Inicia sesión para sincronizar tus dispositivos';

  @override
  String get language => 'Idioma';

  @override
  String get playback => 'Reproducción';

  @override
  String get videoQuality => 'Calidad de video';

  @override
  String get autoplayNext => 'Reproducir automáticamente el próximo episodio';

  @override
  String get downloadWifiOnly => 'Descargar solo con Wi-Fi';

  @override
  String get support => 'Ayuda';

  @override
  String get helpSupport => 'Ayuda y soporte';

  @override
  String get aboutNova => 'Sobre Talevra';

  @override
  String get versionLabel => 'Versión 0.1.0';

  @override
  String get supportSoon => 'El centro de ayuda estará disponible pronto';

  @override
  String get availableBalance => 'Saldo disponible';

  @override
  String get coins => 'monedas';

  @override
  String get checkedInToday => 'Registro completado hoy';

  @override
  String get dailyCheckIn => 'Registro diario';

  @override
  String dayStreak(Object count) {
    return 'Racha de $count días';
  }

  @override
  String get checkIn => 'Registrarse';

  @override
  String get tasks => 'Tareas';

  @override
  String get withdrawalLevels => 'Niveles de retiro';

  @override
  String daysCoins(Object coins, Object days) {
    return '$days días · $coins monedas';
  }

  @override
  String episodesLabel(Object count, Object genre) {
    return '$genre · $count eps';
  }

  @override
  String episodesLong(Object count, Object genre) {
    return '$genre · $count episodios';
  }

  @override
  String get winterNeverEnds => 'El invierno nunca termina';

  @override
  String get lastPromise => 'La última promesa';

  @override
  String get dealWithFate => 'Un trato con el destino';

  @override
  String get empressReborn => 'Emperatriz renacida';

  @override
  String get hiddenHeir => 'El heredero oculto';

  @override
  String get ceo => 'CEO';

  @override
  String get historical => 'Histórico';

  @override
  String get family => 'Familia';

  @override
  String get shortsTab => 'Cortos';

  @override
  String get profileTab => 'Perfil';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get privacyOpenFailed =>
      'No se pudo abrir la política de privacidad. Inténtalo de nuevo.';

  @override
  String get clearCache => 'Borrar caché';

  @override
  String get cacheCleared => 'Caché borrada';

  @override
  String get autoLabel => 'Automático';

  @override
  String get dataSaver => 'Ahorro de datos';

  @override
  String get withdrawEarnings => 'Retirar ganancias';

  @override
  String get withdraw => 'Retirar';

  @override
  String get onLabel => 'Activado';

  @override
  String get offLabel => 'Desactivado';

  @override
  String get playerLaunchFailed => 'No se pudo abrir el reproductor';

  @override
  String get videoLoadFailed =>
      'No se pudo cargar el video. Inténtalo más tarde.';

  @override
  String get catalogLoadFailed =>
      'No se pudieron cargar las series. Comprueba la conexión e inténtalo de nuevo.';

  @override
  String get maleCategory => 'Hombres';

  @override
  String get femaleCategory => 'Mujeres';

  @override
  String get suspense => 'Suspenso';

  @override
  String get loadingSeries => 'Cargando series...';

  @override
  String get save => 'Guardar';

  @override
  String get episodes => 'Episodios';

  @override
  String speedLabel(String speed) {
    return 'Velocidad $speed';
  }

  @override
  String get highDefinition => 'HD';

  @override
  String episodeNumber(int number) {
    return 'Episodio $number';
  }

  @override
  String routeNotFound(String route) {
    return 'Página no encontrada: $route';
  }
}
