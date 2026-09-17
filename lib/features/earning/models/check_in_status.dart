class CheckInStatus {
  final int streak;
  final bool checkedToday;
  const CheckInStatus({this.streak = 0, this.checkedToday = false});
  factory CheckInStatus.fromJson(Map<String, dynamic> j) => CheckInStatus(
    streak: (j['streak'] as num?)?.toInt() ?? 0,
    checkedToday: j['checkedToday'] == true,
  );
}
