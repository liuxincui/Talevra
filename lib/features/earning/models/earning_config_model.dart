class EarningConfigModel {
  final int? coinCount;
  final int? videoDailyCap;
  final int? interstitialDailyCap;
  final Map<String, int>? starterCoins;

  const EarningConfigModel({
    this.coinCount,
    this.videoDailyCap,
    this.interstitialDailyCap,
    this.starterCoins,
  });

  factory EarningConfigModel.fromJson(Map<String, dynamic> json) {
    final frequency = json['frequencyInfo'] is Map
        ? Map<String, dynamic>.from(json['frequencyInfo'] as Map)
        : const <String, dynamic>{};
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
      coinCount: (json['coinCount'] as num?)?.toInt(),
      videoDailyCap:
          (frequency['videoCap'] as num? ?? json['videoDailyCap'] as num?)
              ?.toInt(),
      interstitialDailyCap:
          (frequency['interstitialCap'] as num? ??
                  json['interstitialDailyCap'] as num?)
              ?.toInt(),
      starterCoins: starter,
    );
  }

  Map<String, dynamic> toOverrides() => {
    if (coinCount != null) 'coinCount': coinCount,
    if (videoDailyCap != null) 'videoDailyCap': videoDailyCap,
    if (interstitialDailyCap != null)
      'interstitialDailyCap': interstitialDailyCap,
    if (starterCoins != null) 'starterCoins': starterCoins,
  };
}
