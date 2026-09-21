enum EarningTaskType {
  watchContent,
  watchAd,
  checkIn,
  spin,
  notification,
  auxiliary,
}

class EarningTask {
  final String id;
  final EarningTaskType type;
  final String title;
  final int goal;
  final int reward;
  final int multiplier;
  final int progress;
  final bool claimed;
  final bool visible;
  const EarningTask({
    required this.id,
    required this.type,
    required this.title,
    required this.goal,
    required this.reward,
    this.multiplier = 0,
    this.progress = 0,
    this.claimed = false,
    this.visible = true,
  });
  bool get completed => progress >= goal;
  double get ratio => goal == 0 ? 0 : (progress / goal).clamp(0, 1);
  factory EarningTask.fromJson(Map<String, dynamic> json) => EarningTask(
    id: '${json['id'] ?? json['taskId'] ?? ''}',
    type: _type(json['type']),
    title: '${json['title'] ?? json['name'] ?? ''}',
    goal: (json['goal'] as num?)?.toInt() ?? 1,
    reward: (json['coins'] as num?)?.toInt() ?? 0,
    multiplier:
        (json['multiple'] as num? ?? json['multiplier'] as num?)?.toInt() ?? 0,
    progress: (json['progress'] as num?)?.toInt() ?? 0,
    claimed:
        json['claimed'] == true ||
        json['collected'] == true ||
        json['status'] == 'collected',
    visible: json['show'] != false && json['visible'] != false,
  );
  static EarningTaskType _type(dynamic value) =>
      switch ('$value'.toLowerCase()) {
        'showcontent' || 'watch' => EarningTaskType.watchContent,
        'showad' || 'ad' => EarningTaskType.watchAd,
        'login' || 'checkin' => EarningTaskType.checkIn,
        'circle' || 'spin' => EarningTaskType.spin,
        'notice' || 'notification' => EarningTaskType.notification,
        _ => EarningTaskType.auxiliary,
      };
}
