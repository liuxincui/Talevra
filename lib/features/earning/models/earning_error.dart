class EarningError implements Exception {
  final String message;
  final int? status;
  const EarningError(this.message, [this.status]);
  @override
  String toString() => message;
}
