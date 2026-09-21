import '../models/withdrawal_level.dart';

class EarningConfig {
  final String productId;
  final String version;
  final int coinCount;
  final List<int> watchGoals;
  final List<int> watchRewards;
  final List<int> watchMultipliers;
  final List<int> adGoals;
  final List<int> adRewards;
  final List<int> checkInCoins;
  final List<int> checkInMultipliers;
  final List<int> spinRewards;
  final List<int> spinMultipliers;
  final int videoDailyCap;
  final int interstitialDailyCap;
  final int adDailyCap;
  final double defaultAdRevenueUsd;
  final double ecpmCapUsd;
  final double newUserRatio;
  final double oldUserRatio;
  final double userDayCapUsd;
  final double deviceDayCapUsd;
  final double ipDayCapUsd;
  final Map<String, double> adTypeRates;
  final Map<String, double> adTypeCoinCaps;
  final Map<String, double> currencyRates;
  final Set<String> enabledCurrencies;
  final Map<String, int> starterCoins;
  final int cashbackAdGoal;
  final int cashbackReward;
  final int notificationReward;
  final int notificationMultiplier;
  const EarningConfig({
    this.productId = '69f06ba5b804f96d16376f07',
    this.version = '1.1.37',
    this.coinCount = 1000000,
    this.watchGoals = const [5, 10, 20, 30, 50],
    this.watchRewards = const [500, 1000, 2000, 3000, 4000],
    this.watchMultipliers = const [2, 2, 2, 2, 2],
    this.adGoals = const [3, 5, 10, 20, 30, 50],
    this.adRewards = const [2000, 3000, 4000, 5000, 8000, 10000],
    this.checkInCoins = const [500, 800, 1000, 1200, 1500, 2000, 3000],
    this.checkInMultipliers = const [5, 2, 2, 2, 2, 2, 2],
    this.spinRewards = const [50, 100, 150],
    this.spinMultipliers = const [0, 0, 10],
    this.videoDailyCap = 50,
    this.interstitialDailyCap = 100,
    this.adDailyCap = 3,
    this.defaultAdRevenueUsd = .0005,
    this.ecpmCapUsd = .06,
    this.newUserRatio = .2,
    this.oldUserRatio = .1,
    this.userDayCapUsd = 4,
    this.deviceDayCapUsd = 4,
    this.ipDayCapUsd = 4,
    this.adTypeRates = const {
      'rewarded': 1,
      'native': 1,
      'interstitial': 1,
      'splash': 1,
      'banner': 1,
    },
    this.adTypeCoinCaps = const {'rewarded': .06, 'interstitial': .06},
    this.currencyRates = const {'USDT': 1, 'USD': 1, 'BRL': 4, 'IDR': 17000},
    this.enabledCurrencies = const {'USDT', 'USD'},
    this.starterCoins = const {
      'default': 12000,
      'BR': 20000,
      'ID': 80000,
      'KR': 15000,
    },
    this.cashbackAdGoal = 100,
    this.cashbackReward = 100000,
    this.notificationReward = 100,
    this.notificationMultiplier = 10,
  });
  static const local = EarningConfig();
  EarningConfig merge(Map<String, dynamic> json) => EarningConfig(
    productId: json['productId'] as String? ?? productId,
    version: json['version'] as String? ?? version,
    coinCount: (json['coinCount'] as num?)?.toInt() ?? coinCount,
    watchGoals: _ints(json['watchGoals'], watchGoals),
    watchRewards: _ints(json['watchRewards'], watchRewards),
    watchMultipliers: _ints(json['watchMultipliers'], watchMultipliers),
    adGoals: _ints(json['adGoals'], adGoals),
    adRewards: _ints(json['adRewards'], adRewards),
    checkInCoins: _ints(json['checkInCoins'], checkInCoins),
    checkInMultipliers: _ints(json['checkInMultipliers'], checkInMultipliers),
    spinRewards: _ints(json['spinRewards'], spinRewards),
    spinMultipliers: _ints(json['spinMultipliers'], spinMultipliers),
    videoDailyCap: (json['videoDailyCap'] as num?)?.toInt() ?? videoDailyCap,
    interstitialDailyCap:
        (json['interstitialDailyCap'] as num?)?.toInt() ?? interstitialDailyCap,
    adDailyCap: (json['adDailyCap'] as num?)?.toInt() ?? adDailyCap,
    defaultAdRevenueUsd:
        (json['defaultAdRevenueUsd'] as num?)?.toDouble() ??
        defaultAdRevenueUsd,
    ecpmCapUsd: (json['ecpmCapUsd'] as num?)?.toDouble() ?? ecpmCapUsd,
    newUserRatio: (json['newUserRatio'] as num?)?.toDouble() ?? newUserRatio,
    oldUserRatio: (json['oldUserRatio'] as num?)?.toDouble() ?? oldUserRatio,
    userDayCapUsd: (json['userDayCapUsd'] as num?)?.toDouble() ?? userDayCapUsd,
    deviceDayCapUsd:
        (json['deviceDayCapUsd'] as num?)?.toDouble() ?? deviceDayCapUsd,
    ipDayCapUsd: (json['ipDayCapUsd'] as num?)?.toDouble() ?? ipDayCapUsd,
    adTypeRates: _doubles(json['adTypeRates'], adTypeRates),
    adTypeCoinCaps: _doubles(json['adTypeCoinCaps'], adTypeCoinCaps),
    currencyRates: _doubles(json['currencyRates'], currencyRates),
    enabledCurrencies: _strings(json['enabledCurrencies'], enabledCurrencies),
    starterCoins: _safeStarter(json['starterCoins']),
    cashbackAdGoal: (json['cashbackAdGoal'] as num?)?.toInt() ?? cashbackAdGoal,
    cashbackReward: (json['cashbackReward'] as num?)?.toInt() ?? cashbackReward,
    notificationReward:
        (json['notificationReward'] as num?)?.toInt() ?? notificationReward,
    notificationMultiplier:
        (json['notificationMultiplier'] as num?)?.toInt() ??
        notificationMultiplier,
  );

  int starterRewardFor(String country) {
    final value =
        starterCoins[country.toUpperCase()] ?? starterCoins['default']!;
    return value.clamp(0, 1000000).toInt();
  }

  List<WithdrawalLevel> get defaultLevels => const [
    WithdrawalLevel(regDays: 3, amountUsd: 1, requiredCoins: 1990000),
    WithdrawalLevel(regDays: 7, amountUsd: 5, requiredCoins: 5000000),
    WithdrawalLevel(regDays: 30, amountUsd: 10, requiredCoins: 12000000),
    WithdrawalLevel(regDays: 30, amountUsd: 50, requiredCoins: 60000000),
    WithdrawalLevel(regDays: 60, amountUsd: 100, requiredCoins: 120000000),
    WithdrawalLevel(regDays: 180, amountUsd: 200, requiredCoins: 240000000),
  ];
  static List<int> _ints(dynamic value, List<int> fallback) => value is List
      ? value.whereType<num>().map((e) => e.toInt()).toList()
      : fallback;

  static Map<String, double> _doubles(
    dynamic value,
    Map<String, double> fallback,
  ) => value is Map
      ? Map<String, double>.fromEntries(
          value.entries
              .where((entry) => entry.value is num)
              .map(
                (entry) =>
                    MapEntry('${entry.key}', (entry.value as num).toDouble()),
              ),
        )
      : fallback;

  static Set<String> _strings(dynamic value, Set<String> fallback) =>
      value is Iterable ? value.map((item) => '$item').toSet() : fallback;
  Map<String, int> _safeStarter(dynamic value) {
    final source = value is Map
        ? Map<String, int>.fromEntries(
            value.entries
                .where((entry) => entry.value is num)
                .map(
                  (entry) =>
                      MapEntry('${entry.key}', (entry.value as num).toInt()),
                ),
          )
        : starterCoins;
    return source.map(
      (k, v) => MapEntry(
        k,
        v > 1000000 ? (starterCoins[k] ?? starterCoins['default']!) : v,
      ),
    );
  }
}
