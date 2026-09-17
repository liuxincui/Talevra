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

  @override
  String get rewardsTab => 'Recompensas';

  @override
  String get rewardsUnavailable =>
      'As recompensas estão temporariamente indisponíveis. Os outros recursos continuam funcionando.';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get exclusivePremiere => 'ESTREIA EXCLUSIVA';

  @override
  String get featuredTitle => 'O Inverno Nunca Acaba';

  @override
  String get featuredSubtitle => 'Ela voltou com uma promessa: recuperar tudo.';

  @override
  String get watchNow => 'Assistir agora';

  @override
  String get forYou => 'Para você';

  @override
  String get newLabel => 'Novo';

  @override
  String get romance => 'Romance';

  @override
  String get revenge => 'Vingança';

  @override
  String get fantasy => 'Fantasia';

  @override
  String get more => 'Mais';

  @override
  String get trendingNow => 'Em alta agora';

  @override
  String get searchResults => 'Resultados da busca';

  @override
  String get rankings => 'Classificação';

  @override
  String get noStoriesFound => 'Nenhuma história encontrada';

  @override
  String get searchStories => 'Buscar histórias';

  @override
  String get titleOrGenre => 'Título ou gênero';

  @override
  String get cancel => 'Cancelar';

  @override
  String get search => 'Buscar';

  @override
  String get history => 'Histórico';

  @override
  String get favorites => 'Favoritos';

  @override
  String get noWatchHistory => 'Ainda não há histórico';

  @override
  String get noFavorites => 'Ainda não há favoritos';

  @override
  String get exploreSeries => 'Explorar séries';

  @override
  String get guestViewer => 'Visitante';

  @override
  String get signInSync => 'Entre para sincronizar seus dispositivos';

  @override
  String get language => 'Idioma';

  @override
  String get playback => 'Reprodução';

  @override
  String get videoQuality => 'Qualidade do vídeo';

  @override
  String get autoplayNext => 'Reproduzir próximo episódio automaticamente';

  @override
  String get downloadWifiOnly => 'Baixar somente no Wi-Fi';

  @override
  String get support => 'Suporte';

  @override
  String get helpSupport => 'Ajuda e suporte';

  @override
  String get aboutNova => 'Sobre a Talevra';

  @override
  String get versionLabel => 'Versão 0.1.0';

  @override
  String get supportSoon => 'A central de suporte estará disponível em breve';

  @override
  String get availableBalance => 'Saldo disponível';

  @override
  String get coins => 'moedas';

  @override
  String get checkedInToday => 'Check-in feito hoje';

  @override
  String get dailyCheckIn => 'Check-in diário';

  @override
  String dayStreak(Object count) {
    return 'Sequência de $count dias';
  }

  @override
  String get checkIn => 'Fazer check-in';

  @override
  String get tasks => 'Tarefas';

  @override
  String get withdrawalLevels => 'Níveis de saque';

  @override
  String daysCoins(Object coins, Object days) {
    return '$days dias · $coins moedas';
  }

  @override
  String episodesLabel(Object count, Object genre) {
    return '$genre · $count eps';
  }

  @override
  String episodesLong(Object count, Object genre) {
    return '$genre · $count episódios';
  }

  @override
  String get winterNeverEnds => 'O Inverno Nunca Acaba';

  @override
  String get lastPromise => 'A Última Promessa';

  @override
  String get dealWithFate => 'Um Acordo com o Destino';

  @override
  String get empressReborn => 'Imperatriz Renascida';

  @override
  String get hiddenHeir => 'O Herdeiro Oculto';

  @override
  String get ceo => 'CEO';

  @override
  String get historical => 'Histórico';

  @override
  String get family => 'Família';

  @override
  String get shortsTab => 'Curtas';

  @override
  String get profileTab => 'Perfil';

  @override
  String get privacyPolicy => 'Política de privacidade';

  @override
  String get clearCache => 'Limpar cache';

  @override
  String get cacheCleared => 'Cache limpo';

  @override
  String get autoLabel => 'Automático';

  @override
  String get dataSaver => 'Economia de dados';

  @override
  String get withdrawEarnings => 'Sacar ganhos';

  @override
  String get withdraw => 'Sacar';

  @override
  String get onLabel => 'Ativado';

  @override
  String get offLabel => 'Desativado';

  @override
  String get playerLaunchFailed => 'Não foi possível abrir o player';

  @override
  String get videoLoadFailed =>
      'Não foi possível carregar o vídeo. Tente novamente mais tarde.';

  @override
  String get catalogLoadFailed =>
      'Não foi possível carregar as séries. Verifique a conexão e tente novamente.';

  @override
  String get maleCategory => 'Masculino';

  @override
  String get femaleCategory => 'Feminino';

  @override
  String get suspense => 'Suspense';

  @override
  String get loadingSeries => 'Carregando séries...';

  @override
  String get save => 'Salvar';

  @override
  String get episodes => 'Episódios';

  @override
  String speedLabel(String speed) {
    return 'Velocidade $speed';
  }

  @override
  String get highDefinition => 'HD';

  @override
  String episodeNumber(int number) {
    return 'Episódio $number';
  }

  @override
  String routeNotFound(String route) {
    return 'Página não encontrada: $route';
  }
}
