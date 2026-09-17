// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Talevra';

  @override
  String get homeTab => 'ホーム';

  @override
  String get exploreTab => '発見';

  @override
  String get libraryTab => 'ライブラリ';

  @override
  String get settingsTab => '設定';

  @override
  String welcomeMessage(String brand) {
    return 'Talevra へようこそ - $brand 版';
  }

  @override
  String currentLocale(String locale) {
    return '言語：$locale';
  }

  @override
  String get rewardsTab => '報酬';

  @override
  String get rewardsUnavailable => '報酬は一時的に利用できません。その他の機能は引き続き利用できます。';

  @override
  String get retry => '再試行';

  @override
  String get exclusivePremiere => '独占プレミア';

  @override
  String get featuredTitle => '終わらない冬';

  @override
  String get featuredSubtitle => '彼女はすべてを取り戻すという約束とともに帰ってきた。';

  @override
  String get watchNow => '今すぐ見る';

  @override
  String get forYou => 'おすすめ';

  @override
  String get newLabel => '新着';

  @override
  String get romance => 'ロマンス';

  @override
  String get revenge => '復讐';

  @override
  String get fantasy => 'ファンタジー';

  @override
  String get more => 'もっと見る';

  @override
  String get trendingNow => '人気作品';

  @override
  String get searchResults => '検索結果';

  @override
  String get rankings => 'ランキング';

  @override
  String get noStoriesFound => '作品が見つかりません';

  @override
  String get searchStories => '作品を検索';

  @override
  String get titleOrGenre => 'タイトルまたはジャンル';

  @override
  String get cancel => 'キャンセル';

  @override
  String get search => '検索';

  @override
  String get history => '履歴';

  @override
  String get favorites => 'お気に入り';

  @override
  String get noWatchHistory => '視聴履歴はありません';

  @override
  String get noFavorites => 'お気に入りはありません';

  @override
  String get exploreSeries => 'シリーズを探す';

  @override
  String get guestViewer => 'ゲスト視聴者';

  @override
  String get signInSync => 'サインインして端末間で同期';

  @override
  String get language => '言語';

  @override
  String get playback => '再生';

  @override
  String get videoQuality => '画質';

  @override
  String get autoplayNext => '次のエピソードを自動再生';

  @override
  String get downloadWifiOnly => 'Wi-Fi 接続時のみダウンロード';

  @override
  String get support => 'サポート';

  @override
  String get helpSupport => 'ヘルプとサポート';

  @override
  String get aboutNova => 'Talevra について';

  @override
  String get versionLabel => 'バージョン 0.1.0';

  @override
  String get supportSoon => 'サポートセンターは近日公開予定です';

  @override
  String get availableBalance => '利用可能残高';

  @override
  String get coins => 'コイン';

  @override
  String get checkedInToday => '本日のチェックイン済み';

  @override
  String get dailyCheckIn => 'デイリーチェックイン';

  @override
  String dayStreak(Object count) {
    return '$count日連続';
  }

  @override
  String get checkIn => 'チェックイン';

  @override
  String get tasks => 'タスク';

  @override
  String get withdrawalLevels => '出金レベル';

  @override
  String daysCoins(Object coins, Object days) {
    return '$days日 · $coinsコイン';
  }

  @override
  String episodesLabel(Object count, Object genre) {
    return '$genre · $count話';
  }

  @override
  String episodesLong(Object count, Object genre) {
    return '$genre · $count話';
  }

  @override
  String get winterNeverEnds => '終わらない冬';

  @override
  String get lastPromise => '最後の約束';

  @override
  String get dealWithFate => '運命との取引';

  @override
  String get empressReborn => '蘇る女帝';

  @override
  String get hiddenHeir => '隠された後継者';

  @override
  String get ceo => 'CEO';

  @override
  String get historical => '時代劇';

  @override
  String get family => '家族';

  @override
  String get shortsTab => 'ショート';

  @override
  String get profileTab => 'プロフィール';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get clearCache => 'キャッシュを削除';

  @override
  String get cacheCleared => 'キャッシュを削除しました';

  @override
  String get autoLabel => '自動';

  @override
  String get dataSaver => 'データ節約';

  @override
  String get withdrawEarnings => '収益を出金';

  @override
  String get withdraw => '出金';

  @override
  String get onLabel => 'オン';

  @override
  String get offLabel => 'オフ';

  @override
  String get playerLaunchFailed => 'プレーヤーを開けませんでした';

  @override
  String get videoLoadFailed => '動画を読み込めませんでした。しばらくしてからもう一度お試しください。';

  @override
  String get catalogLoadFailed => '作品を読み込めませんでした。接続を確認して、もう一度お試しください。';

  @override
  String get maleCategory => '男性向け';

  @override
  String get femaleCategory => '女性向け';

  @override
  String get suspense => 'サスペンス';

  @override
  String get loadingSeries => '作品を読み込んでいます...';

  @override
  String get save => 'お気に入り';

  @override
  String get episodes => 'エピソード';

  @override
  String speedLabel(String speed) {
    return '速度 $speed';
  }

  @override
  String get highDefinition => 'HD';

  @override
  String episodeNumber(int number) {
    return '第$number話';
  }

  @override
  String routeNotFound(String route) {
    return 'ページが見つかりません: $route';
  }
}
