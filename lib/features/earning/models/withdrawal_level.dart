class WithdrawalLevel {
  final int regDays;
  final double amountUsd;
  final int requiredCoins;
  const WithdrawalLevel({
    required this.regDays,
    required this.amountUsd,
    required this.requiredCoins,
  });
  factory WithdrawalLevel.fromJson(Map<String, dynamic> j) => WithdrawalLevel(
    regDays: (j['regDays'] as num?)?.toInt() ?? 0,
    amountUsd: (j['amount'] as num?)?.toDouble() ?? 0,
    requiredCoins: (j['prizeCount'] as num?)?.toInt() ?? 0,
  );
}
