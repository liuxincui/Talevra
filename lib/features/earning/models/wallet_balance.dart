class WalletBalance {
  final int coins;
  final DateTime? registeredAt;
  const WalletBalance({required this.coins, this.registeredAt});
  factory WalletBalance.fromJson(Map<String, dynamic> j) {
    final value = j['coins'] ?? j['coin'] ?? j['balance'];
    return WalletBalance(
      coins: value is num ? value.toInt() : 0,
      registeredAt: DateTime.tryParse(
        '${j['registerTime'] ?? j['registeredAt'] ?? ''}',
      ),
    );
  }
}
