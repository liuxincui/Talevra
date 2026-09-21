class EarningConfigModel {
  final int? coinCount;
  final int? videoDailyCap;
  final int? interstitialDailyCap;
  final int? adDailyCap;
  final double? defaultAdRevenueUsd;
  final double? ecpmCapUsd;
  final double? newUserRatio;
  final double? oldUserRatio;
  final double? userDayCapUsd;
  final double? deviceDayCapUsd;
  final double? ipDayCapUsd;
  final Map<String, double>? adTypeRates;
  final Map<String, double>? adTypeCoinCaps;
  final Map<String, double>? currencyRates;
  final Set<String>? enabledCurrencies;
  final Map<String, int>? starterCoins;

  const EarningConfigModel({
    this.coinCount,
    this.videoDailyCap,
    this.interstitialDailyCap,
    this.adDailyCap,
    this.defaultAdRevenueUsd,
    this.ecpmCapUsd,
    this.newUserRatio,
    this.oldUserRatio,
    this.userDayCapUsd,
    this.deviceDayCapUsd,
    this.ipDayCapUsd,
    this.adTypeRates,
    this.adTypeCoinCaps,
    this.currencyRates,
    this.enabledCurrencies,
    this.starterCoins,
  });

  factory EarningConfigModel.fromJson(Map<String, dynamic> json) {
    final frequency = json['frequencyInfo'] is Map
        ? Map<String, dynamic>.from(json['frequencyInfo'] as Map)
        : const <String, dynamic>{};
    final baseInfo = _map(json['baseInfo']);
    final revenue = _map(json['defaultAdRevenue']);
    final sendCoin = _map(json['sendCoinInfo']);
    final adFrequency = _map(json['adFrequencyInfo']);
    final rawStarter = json['starterCoins'];
    final starter = rawStarter is Map
        ? Map<String, int>.fromEntries(
            rawStarter.entries
                .where((entry) => entry.value is num)
                .map(
                  (entry) =>
                      MapEntry('${entry.key}', (entry.value as num).toInt()),
                ),
          )
        : null;
    return EarningConfigModel(
      coinCount: (baseInfo['coinCount'] as num? ?? json['coinCount'] as num?)
          ?.toInt(),
      videoDailyCap:
          (frequency['videoCap'] as num? ?? json['videoDailyCap'] as num?)
              ?.toInt(),
      interstitialDailyCap:
          (frequency['interstitialCap'] as num? ??
                  json['interstitialDailyCap'] as num?)
              ?.toInt(),
      adDailyCap: (adFrequency['adCap'] as num?)?.toInt(),
      defaultAdRevenueUsd: (revenue['general'] as num?)?.toDouble(),
      ecpmCapUsd: (sendCoin['ecpmCap'] as num?)?.toDouble(),
      newUserRatio: (sendCoin['ratioNew'] as num?)?.toDouble(),
      oldUserRatio: (sendCoin['ratioOld'] as num?)?.toDouble(),
      userDayCapUsd: (sendCoin['userDayCap'] as num?)?.toDouble(),
      deviceDayCapUsd: (sendCoin['deviceDayCap'] as num?)?.toDouble(),
      ipDayCapUsd: (sendCoin['ipDayCap'] as num?)?.toDouble(),
      adTypeRates: _numberMap(json['adTypeRate']),
      adTypeCoinCaps: _numberMap(json['adTypeCoinCap']),
      currencyRates: _currencyRates(json['currencyList'] ?? json['coinTypes']),
      enabledCurrencies: _enabledCurrencies(
        json['currencyList'] ?? json['coinTypes'],
      ),
      starterCoins: starter,
    );
  }

  Map<String, dynamic> toOverrides() => {
    if (coinCount != null) 'coinCount': coinCount,
    if (videoDailyCap != null) 'videoDailyCap': videoDailyCap,
    if (interstitialDailyCap != null)
      'interstitialDailyCap': interstitialDailyCap,
    if (adDailyCap != null) 'adDailyCap': adDailyCap,
    if (defaultAdRevenueUsd != null) 'defaultAdRevenueUsd': defaultAdRevenueUsd,
    if (ecpmCapUsd != null) 'ecpmCapUsd': ecpmCapUsd,
    if (newUserRatio != null) 'newUserRatio': newUserRatio,
    if (oldUserRatio != null) 'oldUserRatio': oldUserRatio,
    if (userDayCapUsd != null) 'userDayCapUsd': userDayCapUsd,
    if (deviceDayCapUsd != null) 'deviceDayCapUsd': deviceDayCapUsd,
    if (ipDayCapUsd != null) 'ipDayCapUsd': ipDayCapUsd,
    if (adTypeRates != null) 'adTypeRates': adTypeRates,
    if (adTypeCoinCaps != null) 'adTypeCoinCaps': adTypeCoinCaps,
    if (currencyRates != null) 'currencyRates': currencyRates,
    if (enabledCurrencies != null)
      'enabledCurrencies': enabledCurrencies!.toList(),
    if (starterCoins != null) 'starterCoins': starterCoins,
  };

  static Map<String, dynamic> _map(dynamic value) => value is Map
      ? Map<String, dynamic>.from(value)
      : const <String, dynamic>{};

  static Map<String, double>? _numberMap(dynamic value) => value is Map
      ? Map<String, double>.fromEntries(
          value.entries
              .where((e) => e.value is num)
              .map((e) => MapEntry('${e.key}', (e.value as num).toDouble())),
        )
      : null;

  static Map<String, double>? _currencyRates(dynamic value) {
    if (value is! List) return null;
    return Map.fromEntries(
      value
          .whereType<Map>()
          .map((item) {
            final currency = '${item['currency'] ?? item['code'] ?? ''}';
            final rate = (item['rate'] as num?)?.toDouble() ?? 1;
            return MapEntry(currency, rate);
          })
          .where((entry) => entry.key.isNotEmpty),
    );
  }

  static Set<String>? _enabledCurrencies(dynamic value) {
    if (value is! List) return null;
    return value
        .whereType<Map>()
        .where((item) => item['enable'] == true || item['enabled'] == true)
        .map((item) => '${item['currency'] ?? item['code'] ?? ''}')
        .where((code) => code.isNotEmpty)
        .toSet();
  }
}
