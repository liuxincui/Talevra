import '../models/withdrawal_level.dart';

class EarningConfig {
  final String productId;
  final String version;
  final int coinCount;
  final List<int> watchGoals;
  final List<int> adGoals;
  final List<int> checkInCoins;
  final List<int> withdrawalCoins;
  final int videoDailyCap;
  final int interstitialDailyCap;
  final Map<String, int> starterCoins;
  const EarningConfig({
    this.productId = '69f06ba5b804f96d16376f07',
    this.version = '1.1.37',
    this.coinCount = 1000000,
    this.watchGoals = const [5, 10, 20, 30, 50],
    this.adGoals = const [3, 5, 10, 20, 30, 50],
    this.checkInCoins = const [500, 800, 1000, 1200, 1500, 2000, 3000],
    this.withdrawalCoins = const [
      1990000,
      5000000,
      12000000,
      60000000,
      120000000,
      240000000,
    ],
    this.videoDailyCap = 50,
    this.interstitialDailyCap = 100,
    this.starterCoins = const {
      'default': 12000,
      'BR': 20000,
      'ID': 80000,
      'KR': 15000,
    },
  });
  static const local = EarningConfig();
  EarningConfig merge(Map<String, dynamic> json) => EarningConfig(
    productId: json['productId'] as String? ?? productId,
    version: json['version'] as String? ?? version,
    coinCount: (json['coinCount'] as num?)?.toInt() ?? coinCount,
    watchGoals: _ints(json['watchGoals'], watchGoals),
    adGoals: _ints(json['adGoals'], adGoals),
    checkInCoins: _ints(json['checkInCoins'], checkInCoins),
    withdrawalCoins: withdrawalCoins,
    videoDailyCap: (json['videoDailyCap'] as num?)?.toInt() ?? videoDailyCap,
    interstitialDailyCap:
        (json['interstitialDailyCap'] as num?)?.toInt() ?? interstitialDailyCap,
    starterCoins: _safeStarter(json['starterCoins']),
  );
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
  Map<String, int> _safeStarter(dynamic value) {
    final source = value is Map
        ? value.map((k, v) => MapEntry('$k', (v as num).toInt()))
        : starterCoins;
    return source.map(
      (k, v) => MapEntry(
        k,
        v > 1000000 ? (starterCoins[k] ?? starterCoins['default']!) : v,
      ),
    );
  }
}
