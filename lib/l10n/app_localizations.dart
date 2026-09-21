import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('id'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
  ];

  /// Application display name shown on the home screen
  ///
  /// In en, this message translates to:
  /// **'Talevra'**
  String get appTitle;

  /// Bottom navigation tab: home
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTab;

  /// Bottom navigation tab: explore
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get exploreTab;

  /// Bottom navigation tab: library
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryTab;

  /// Bottom navigation tab: settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTab;

  /// Welcome line shown on the home tab, with the running brand code
  ///
  /// In en, this message translates to:
  /// **'Welcome to Talevra - {brand} edition'**
  String welcomeMessage(String brand);

  /// Shows the active locale code for debugging
  ///
  /// In en, this message translates to:
  /// **'Locale: {locale}'**
  String currentLocale(String locale);

  /// No description provided for @rewardsTab.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewardsTab;

  /// No description provided for @rewardsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Rewards are temporarily unavailable. Your other features still work.'**
  String get rewardsUnavailable;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @exclusivePremiere.
  ///
  /// In en, this message translates to:
  /// **'EXCLUSIVE PREMIERE'**
  String get exclusivePremiere;

  /// No description provided for @featuredTitle.
  ///
  /// In en, this message translates to:
  /// **'Winter Never Ends'**
  String get featuredTitle;

  /// No description provided for @featuredSubtitle.
  ///
  /// In en, this message translates to:
  /// **'She returned with one promise: take back everything.'**
  String get featuredSubtitle;

  /// No description provided for @watchNow.
  ///
  /// In en, this message translates to:
  /// **'Watch now'**
  String get watchNow;

  /// No description provided for @forYou.
  ///
  /// In en, this message translates to:
  /// **'For You'**
  String get forYou;

  /// No description provided for @newLabel.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newLabel;

  /// No description provided for @romance.
  ///
  /// In en, this message translates to:
  /// **'Romance'**
  String get romance;

  /// No description provided for @revenge.
  ///
  /// In en, this message translates to:
  /// **'Revenge'**
  String get revenge;

  /// No description provided for @fantasy.
  ///
  /// In en, this message translates to:
  /// **'Fantasy'**
  String get fantasy;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @trendingNow.
  ///
  /// In en, this message translates to:
  /// **'Trending now'**
  String get trendingNow;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search results'**
  String get searchResults;

  /// No description provided for @rankings.
  ///
  /// In en, this message translates to:
  /// **'Rankings'**
  String get rankings;

  /// No description provided for @noStoriesFound.
  ///
  /// In en, this message translates to:
  /// **'No stories found'**
  String get noStoriesFound;

  /// No description provided for @searchStories.
  ///
  /// In en, this message translates to:
  /// **'Search stories'**
  String get searchStories;

  /// No description provided for @titleOrGenre.
  ///
  /// In en, this message translates to:
  /// **'Title or genre'**
  String get titleOrGenre;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @noWatchHistory.
  ///
  /// In en, this message translates to:
  /// **'No watch history yet'**
  String get noWatchHistory;

  /// No description provided for @noFavorites.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavorites;

  /// No description provided for @exploreSeries.
  ///
  /// In en, this message translates to:
  /// **'Explore series'**
  String get exploreSeries;

  /// No description provided for @guestViewer.
  ///
  /// In en, this message translates to:
  /// **'Guest viewer'**
  String get guestViewer;

  /// No description provided for @signInSync.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync across devices'**
  String get signInSync;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @playback.
  ///
  /// In en, this message translates to:
  /// **'Playback'**
  String get playback;

  /// No description provided for @videoQuality.
  ///
  /// In en, this message translates to:
  /// **'Video quality'**
  String get videoQuality;

  /// No description provided for @autoplayNext.
  ///
  /// In en, this message translates to:
  /// **'Autoplay next episode'**
  String get autoplayNext;

  /// No description provided for @downloadWifiOnly.
  ///
  /// In en, this message translates to:
  /// **'Download on Wi-Fi only'**
  String get downloadWifiOnly;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get helpSupport;

  /// No description provided for @aboutNova.
  ///
  /// In en, this message translates to:
  /// **'About Talevra'**
  String get aboutNova;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version 0.1.0'**
  String get versionLabel;

  /// No description provided for @supportSoon.
  ///
  /// In en, this message translates to:
  /// **'Support center will be available soon'**
  String get supportSoon;

  /// No description provided for @availableBalance.
  ///
  /// In en, this message translates to:
  /// **'Available balance'**
  String get availableBalance;

  /// No description provided for @coins.
  ///
  /// In en, this message translates to:
  /// **'coins'**
  String get coins;

  /// No description provided for @checkedInToday.
  ///
  /// In en, this message translates to:
  /// **'Checked in today'**
  String get checkedInToday;

  /// No description provided for @dailyCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Daily check-in'**
  String get dailyCheckIn;

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'{count} day streak'**
  String dayStreak(Object count);

  /// No description provided for @checkIn.
  ///
  /// In en, this message translates to:
  /// **'Check in'**
  String get checkIn;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @withdrawalLevels.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal levels'**
  String get withdrawalLevels;

  /// No description provided for @daysCoins.
  ///
  /// In en, this message translates to:
  /// **'{days} days · {coins} coins'**
  String daysCoins(Object coins, Object days);

  /// No description provided for @episodesLabel.
  ///
  /// In en, this message translates to:
  /// **'{genre} · {count} eps'**
  String episodesLabel(Object count, Object genre);

  /// No description provided for @episodesLong.
  ///
  /// In en, this message translates to:
  /// **'{genre} · {count} episodes'**
  String episodesLong(Object count, Object genre);

  /// No description provided for @winterNeverEnds.
  ///
  /// In en, this message translates to:
  /// **'Winter Never Ends'**
  String get winterNeverEnds;

  /// No description provided for @lastPromise.
  ///
  /// In en, this message translates to:
  /// **'The Last Promise'**
  String get lastPromise;

  /// No description provided for @dealWithFate.
  ///
  /// In en, this message translates to:
  /// **'A Deal With Fate'**
  String get dealWithFate;

  /// No description provided for @empressReborn.
  ///
  /// In en, this message translates to:
  /// **'Empress Reborn'**
  String get empressReborn;

  /// No description provided for @hiddenHeir.
  ///
  /// In en, this message translates to:
  /// **'The Hidden Heir'**
  String get hiddenHeir;

  /// No description provided for @ceo.
  ///
  /// In en, this message translates to:
  /// **'CEO'**
  String get ceo;

  /// No description provided for @historical.
  ///
  /// In en, this message translates to:
  /// **'Historical'**
  String get historical;

  /// No description provided for @family.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get family;

  /// No description provided for @shortsTab.
  ///
  /// In en, this message translates to:
  /// **'Shorts'**
  String get shortsTab;

  /// No description provided for @profileTab.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTab;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @privacyOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the privacy policy. Please try again.'**
  String get privacyOpenFailed;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get clearCache;

  /// No description provided for @cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared'**
  String get cacheCleared;

  /// No description provided for @autoLabel.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get autoLabel;

  /// No description provided for @dataSaver.
  ///
  /// In en, this message translates to:
  /// **'Data saver'**
  String get dataSaver;

  /// No description provided for @withdrawEarnings.
  ///
  /// In en, this message translates to:
  /// **'Withdraw earnings'**
  String get withdrawEarnings;

  /// No description provided for @withdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdraw;

  /// No description provided for @onLabel.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get onLabel;

  /// No description provided for @offLabel.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get offLabel;

  /// No description provided for @playerLaunchFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to open the player'**
  String get playerLaunchFailed;

  /// No description provided for @videoLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Video couldn\'t load. Try again later.'**
  String get videoLoadFailed;

  /// No description provided for @catalogLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Series couldn\'t load. Check your connection and try again.'**
  String get catalogLoadFailed;

  /// No description provided for @maleCategory.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get maleCategory;

  /// No description provided for @femaleCategory.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get femaleCategory;

  /// No description provided for @suspense.
  ///
  /// In en, this message translates to:
  /// **'Suspense'**
  String get suspense;

  /// No description provided for @loadingSeries.
  ///
  /// In en, this message translates to:
  /// **'Loading series...'**
  String get loadingSeries;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @episodes.
  ///
  /// In en, this message translates to:
  /// **'Episodes'**
  String get episodes;

  /// No description provided for @speedLabel.
  ///
  /// In en, this message translates to:
  /// **'Speed {speed}'**
  String speedLabel(String speed);

  /// No description provided for @highDefinition.
  ///
  /// In en, this message translates to:
  /// **'HD'**
  String get highDefinition;

  /// No description provided for @episodeNumber.
  ///
  /// In en, this message translates to:
  /// **'Episode {number}'**
  String episodeNumber(int number);

  /// No description provided for @routeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page not found: {route}'**
  String routeNotFound(String route);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'en',
    'es',
    'id',
    'ja',
    'ko',
    'pt',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'id':
      return AppLocalizationsId();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
