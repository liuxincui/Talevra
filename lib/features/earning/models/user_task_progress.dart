class UserTaskProgress {
  final String taskId;
  final int progress;
  final bool claimed;
  const UserTaskProgress({
    required this.taskId,
    this.progress = 0,
    this.claimed = false,
  });
}
