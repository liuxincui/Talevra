enum EarningTaskType { watchContent, watchAd, checkIn, spin, auxiliary }

class EarningTask {
  final String id;
  final EarningTaskType type;
  final String title;
  final int goal;
  final int reward;
  final int progress;
  final bool claimed;
  const EarningTask({
    required this.id,
    required this.type,
    required this.title,
    required this.goal,
    required this.reward,
    this.progress = 0,
    this.claimed = false,
  });
  bool get completed => progress >= goal;
  double get ratio => goal == 0 ? 0 : (progress / goal).clamp(0, 1);
  factory EarningTask.fromJson(Map<String, dynamic> json) => EarningTask(
    id: '${json['id'] ?? json['taskId'] ?? ''}',
    type: _type(json['type']),
    title: '${json['title'] ?? json['name'] ?? ''}',
    goal: (json['goal'] as num?)?.toInt() ?? 1,
    reward: (json['coins'] as num?)?.toInt() ?? 0,
    progress: (json['progress'] as num?)?.toInt() ?? 0,
    claimed: json['claimed'] == true,
  );
  static EarningTaskType _type(dynamic value) =>
      switch ('$value'.toLowerCase()) {
        'showcontent' || 'watch' => EarningTaskType.watchContent,
        'showad' || 'ad' => EarningTaskType.watchAd,
        'login' || 'checkin' => EarningTaskType.checkIn,
        'circle' || 'spin' => EarningTaskType.spin,
        _ => EarningTaskType.auxiliary,
      };
}
