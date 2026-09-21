import 'check_in_status.dart';
import 'earning_task.dart';
import 'wallet_balance.dart';

class EarningSnapshot {
  final WalletBalance wallet;
  final List<EarningTask> tasks;
  final CheckInStatus checkIn;
  final int todayEpisodeCount;
  final int todayRewardedAdCount;
  final int todayInterstitialCount;
  final int todaySpinCount;

  const EarningSnapshot({
    required this.wallet,
    required this.tasks,
    required this.checkIn,
    this.todayEpisodeCount = 0,
    this.todayRewardedAdCount = 0,
    this.todayInterstitialCount = 0,
    this.todaySpinCount = 0,
  });
}
