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

  @override
  String get rewardsTab => '보상';

  @override
  String get rewardsUnavailable =>
      '보상 기능을 일시적으로 사용할 수 없습니다. 다른 기능은 계속 이용할 수 있습니다.';

  @override
  String get retry => '다시 시도';

  @override
  String get exclusivePremiere => '독점 공개';

  @override
  String get featuredTitle => '끝나지 않는 겨울';

  @override
  String get featuredSubtitle => '그녀는 모든 것을 되찾겠다는 약속과 함께 돌아왔다.';

  @override
  String get watchNow => '지금 보기';

  @override
  String get forYou => '추천';

  @override
  String get newLabel => '신작';

  @override
  String get romance => '로맨스';

  @override
  String get revenge => '복수';

  @override
  String get fantasy => '판타지';

  @override
  String get more => '더 보기';

  @override
  String get trendingNow => '지금 인기';

  @override
  String get searchResults => '검색 결과';

  @override
  String get rankings => '랭킹';

  @override
  String get noStoriesFound => '스토리를 찾을 수 없습니다';

  @override
  String get searchStories => '스토리 검색';

  @override
  String get titleOrGenre => '제목 또는 장르';

  @override
  String get cancel => '취소';

  @override
  String get search => '검색';

  @override
  String get history => '시청 기록';

  @override
  String get favorites => '즐겨찾기';

  @override
  String get noWatchHistory => '아직 시청 기록이 없습니다';

  @override
  String get noFavorites => '즐겨찾기가 없습니다';

  @override
  String get exploreSeries => '시리즈 탐색';

  @override
  String get guestViewer => '게스트 시청자';

  @override
  String get signInSync => '로그인하여 기기 간 동기화';

  @override
  String get language => '언어';

  @override
  String get playback => '재생';

  @override
  String get videoQuality => '화질';

  @override
  String get autoplayNext => '다음 에피소드 자동 재생';

  @override
  String get downloadWifiOnly => 'Wi-Fi에서만 다운로드';

  @override
  String get support => '지원';

  @override
  String get helpSupport => '도움말 및 지원';

  @override
  String get aboutNova => 'Talevra 정보';

  @override
  String get versionLabel => '버전 0.1.0';

  @override
  String get supportSoon => '지원 센터가 곧 제공됩니다';

  @override
  String get availableBalance => '사용 가능 잔액';

  @override
  String get coins => '코인';

  @override
  String get checkedInToday => '오늘 체크인 완료';

  @override
  String get dailyCheckIn => '매일 체크인';

  @override
  String dayStreak(Object count) {
    return '$count일 연속';
  }

  @override
  String get checkIn => '체크인';

  @override
  String get tasks => '미션';

  @override
  String get withdrawalLevels => '출금 단계';

  @override
  String daysCoins(Object coins, Object days) {
    return '$days일 · $coins코인';
  }

  @override
  String episodesLabel(Object count, Object genre) {
    return '$genre · $count화';
  }

  @override
  String episodesLong(Object count, Object genre) {
    return '$genre · $count화';
  }

  @override
  String get winterNeverEnds => '끝나지 않는 겨울';

  @override
  String get lastPromise => '마지막 약속';

  @override
  String get dealWithFate => '운명과의 거래';

  @override
  String get empressReborn => '다시 태어난 여제';

  @override
  String get hiddenHeir => '숨겨진 후계자';

  @override
  String get ceo => 'CEO';

  @override
  String get historical => '시대극';

  @override
  String get family => '가족';

  @override
  String get shortsTab => '숏폼';

  @override
  String get profileTab => '프로필';

  @override
  String get privacyPolicy => '개인정보 처리방침';

  @override
  String get clearCache => '캐시 삭제';

  @override
  String get cacheCleared => '캐시를 삭제했습니다';

  @override
  String get autoLabel => '자동';

  @override
  String get dataSaver => '데이터 절약';

  @override
  String get withdrawEarnings => '수익 출금';

  @override
  String get withdraw => '출금';

  @override
  String get onLabel => '켜짐';

  @override
  String get offLabel => '꺼짐';

  @override
  String get playerLaunchFailed => '플레이어를 열 수 없습니다';

  @override
  String get videoLoadFailed => '동영상을 불러올 수 없습니다. 나중에 다시 시도해 주세요.';

  @override
  String get catalogLoadFailed => '시리즈를 불러오지 못했습니다. 연결을 확인하고 다시 시도해 주세요.';

  @override
  String get maleCategory => '남성';

  @override
  String get femaleCategory => '여성';

  @override
  String get suspense => '서스펜스';

  @override
  String get loadingSeries => '시리즈를 불러오는 중...';

  @override
  String get save => '저장';

  @override
  String get episodes => '회차';

  @override
  String speedLabel(String speed) {
    return '속도 $speed';
  }

  @override
  String get highDefinition => 'HD';

  @override
  String episodeNumber(int number) {
    return '$number화';
  }

  @override
  String routeNotFound(String route) {
    return '페이지를 찾을 수 없습니다: $route';
  }
}
