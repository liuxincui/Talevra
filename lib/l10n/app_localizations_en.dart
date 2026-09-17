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

  @override
  String get rewardsTab => 'Rewards';

  @override
  String get rewardsUnavailable =>
      'Rewards are temporarily unavailable. Your other features still work.';

  @override
  String get retry => 'Retry';

  @override
  String get exclusivePremiere => 'EXCLUSIVE PREMIERE';

  @override
  String get featuredTitle => 'Winter Never Ends';

  @override
  String get featuredSubtitle =>
      'She returned with one promise: take back everything.';

  @override
  String get watchNow => 'Watch now';

  @override
  String get forYou => 'For You';

  @override
  String get newLabel => 'New';

  @override
  String get romance => 'Romance';

  @override
  String get revenge => 'Revenge';

  @override
  String get fantasy => 'Fantasy';

  @override
  String get more => 'More';

  @override
  String get trendingNow => 'Trending now';

  @override
  String get searchResults => 'Search results';

  @override
  String get rankings => 'Rankings';

  @override
  String get noStoriesFound => 'No stories found';

  @override
  String get searchStories => 'Search stories';

  @override
  String get titleOrGenre => 'Title or genre';

  @override
  String get cancel => 'Cancel';

  @override
  String get search => 'Search';

  @override
  String get history => 'History';

  @override
  String get favorites => 'Favorites';

  @override
  String get noWatchHistory => 'No watch history yet';

  @override
  String get noFavorites => 'No favorites yet';

  @override
  String get exploreSeries => 'Explore series';

  @override
  String get guestViewer => 'Guest viewer';

  @override
  String get signInSync => 'Sign in to sync across devices';

  @override
  String get language => 'Language';

  @override
  String get playback => 'Playback';

  @override
  String get videoQuality => 'Video quality';

  @override
  String get autoplayNext => 'Autoplay next episode';

  @override
  String get downloadWifiOnly => 'Download on Wi-Fi only';

  @override
  String get support => 'Support';

  @override
  String get helpSupport => 'Help & support';

  @override
  String get aboutNova => 'About Talevra';

  @override
  String get versionLabel => 'Version 0.1.0';

  @override
  String get supportSoon => 'Support center will be available soon';

  @override
  String get availableBalance => 'Available balance';

  @override
  String get coins => 'coins';

  @override
  String get checkedInToday => 'Checked in today';

  @override
  String get dailyCheckIn => 'Daily check-in';

  @override
  String dayStreak(Object count) {
    return '$count day streak';
  }

  @override
  String get checkIn => 'Check in';

  @override
  String get tasks => 'Tasks';

  @override
  String get withdrawalLevels => 'Withdrawal levels';

  @override
  String daysCoins(Object coins, Object days) {
    return '$days days · $coins coins';
  }

  @override
  String episodesLabel(Object count, Object genre) {
    return '$genre · $count eps';
  }

  @override
  String episodesLong(Object count, Object genre) {
    return '$genre · $count episodes';
  }

  @override
  String get winterNeverEnds => 'Winter Never Ends';

  @override
  String get lastPromise => 'The Last Promise';

  @override
  String get dealWithFate => 'A Deal With Fate';

  @override
  String get empressReborn => 'Empress Reborn';

  @override
  String get hiddenHeir => 'The Hidden Heir';

  @override
  String get ceo => 'CEO';

  @override
  String get historical => 'Historical';

  @override
  String get family => 'Family';

  @override
  String get shortsTab => 'Shorts';

  @override
  String get profileTab => 'Profile';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get clearCache => 'Clear cache';

  @override
  String get cacheCleared => 'Cache cleared';

  @override
  String get autoLabel => 'Auto';

  @override
  String get dataSaver => 'Data saver';

  @override
  String get withdrawEarnings => 'Withdraw earnings';

  @override
  String get withdraw => 'Withdraw';

  @override
  String get onLabel => 'On';

  @override
  String get offLabel => 'Off';

  @override
  String get playerLaunchFailed => 'Unable to open the player';

  @override
  String get videoLoadFailed => 'Video couldn\'t load. Try again later.';

  @override
  String get catalogLoadFailed =>
      'Series couldn\'t load. Check your connection and try again.';

  @override
  String get maleCategory => 'Male';

  @override
  String get femaleCategory => 'Female';

  @override
  String get suspense => 'Suspense';

  @override
  String get loadingSeries => 'Loading series...';

  @override
  String get save => 'Save';

  @override
  String get episodes => 'Episodes';

  @override
  String speedLabel(String speed) {
    return 'Speed $speed';
  }

  @override
  String get highDefinition => 'HD';

  @override
  String episodeNumber(int number) {
    return 'Episode $number';
  }

  @override
  String routeNotFound(String route) {
    return 'Page not found: $route';
  }
}
