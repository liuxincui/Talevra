class DateTimeTool {
  static int unixSeconds([DateTime? value]) =>
      (value ?? DateTime.now()).millisecondsSinceEpoch ~/ 1000;
  static int registrationDays(DateTime registeredAt, [DateTime? now]) {
    final today = now ?? DateTime.now();
    return DateTime(today.year, today.month, today.day)
        .difference(
          DateTime(registeredAt.year, registeredAt.month, registeredAt.day),
        )
        .inDays;
  }

  static bool isYesterday(DateTime date, [DateTime? now]) =>
      registrationDays(date, now) == 1;
  static String dayKey([DateTime? now]) {
    final d = now ?? DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
