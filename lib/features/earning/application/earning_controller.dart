import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talevra/core/tool/idempotency.dart';
import '../config/earning_config.dart';
import '../data/earning_repository.dart';
import '../models/check_in_status.dart';
import '../models/earning_task.dart';
import '../models/earning_snapshot.dart';
import '../models/wallet_balance.dart';
import '../models/withdrawal_level.dart';

enum EarningPhase { loading, ready, refreshing, error }

class EarningState {
  final EarningPhase phase;
  final EarningConfig config;
  final List<EarningTask> tasks;
  final WalletBalance? wallet;
  final CheckInStatus checkIn;
  final List<WithdrawalLevel> levels;
  final int todayAdCount;
  final int todayEpisodeCount;
  final int todayInterstitialCount;
  final int todaySpinCount;
  final int? lastSpinReward;
  final bool actionInProgress;
  final String? error;
  const EarningState({
    this.phase = EarningPhase.loading,
    this.config = EarningConfig.local,
    this.tasks = const [],
    this.wallet,
    this.checkIn = const CheckInStatus(),
    this.levels = const [],
    this.todayAdCount = 0,
    this.todayEpisodeCount = 0,
    this.todayInterstitialCount = 0,
    this.todaySpinCount = 0,
    this.lastSpinReward,
    this.actionInProgress = false,
    this.error,
  });
  EarningState copy({
    EarningPhase? phase,
    EarningConfig? config,
    List<EarningTask>? tasks,
    WalletBalance? wallet,
    CheckInStatus? checkIn,
    List<WithdrawalLevel>? levels,
    int? todayAdCount,
    int? todayEpisodeCount,
    int? todayInterstitialCount,
    int? todaySpinCount,
    int? lastSpinReward,
    bool clearSpinReward = false,
    bool? actionInProgress,
    String? error,
    bool clearError = false,
  }) => EarningState(
    phase: phase ?? this.phase,
    config: config ?? this.config,
    tasks: tasks ?? this.tasks,
    wallet: wallet ?? this.wallet,
    checkIn: checkIn ?? this.checkIn,
    levels: levels ?? this.levels,
    todayAdCount: todayAdCount ?? this.todayAdCount,
    todayEpisodeCount: todayEpisodeCount ?? this.todayEpisodeCount,
    todayInterstitialCount:
        todayInterstitialCount ?? this.todayInterstitialCount,
    todaySpinCount: todaySpinCount ?? this.todaySpinCount,
    lastSpinReward: clearSpinReward
        ? null
        : (lastSpinReward ?? this.lastSpinReward),
    actionInProgress: actionInProgress ?? this.actionInProgress,
    error: clearError ? null : (error ?? this.error),
  );

  bool get loading =>
      phase == EarningPhase.loading || phase == EarningPhase.refreshing;
  List<WithdrawalLevel> get eligibleLevels {
    final balance = wallet?.coins ?? 0;
    final registeredAt = wallet?.registeredAt;
    final days = registeredAt == null
        ? 0
        : DateTime.now().difference(registeredAt).inDays;
    return levels
        .where(
          (level) => balance >= level.requiredCoins && days >= level.regDays,
        )
        .toList();
  }
}

final earningRepositoryProvider = Provider((ref) => EarningRepository());
final earningControllerProvider =
    NotifierProvider<EarningController, EarningState>(EarningController.new);
final earningConfigProvider = Provider(
  (ref) => ref.watch(earningControllerProvider).config,
);
final earningTasksProvider = Provider(
  (ref) => ref.watch(earningControllerProvider).tasks,
);
final walletBalanceProvider = Provider(
  (ref) => ref.watch(earningControllerProvider).wallet,
);
final checkInProvider = Provider(
  (ref) => ref.watch(earningControllerProvider).checkIn,
);

class EarningController extends Notifier<EarningState> {
  EarningRepository get repository => ref.read(earningRepositoryProvider);
  String _uid = '';
  String _country = 'US';

  @override
  EarningState build() => const EarningState();
  Future<void> load({String uid = '', String country = 'US'}) async {
    _uid = uid;
    _country = country;
    state = state.copy(
      phase: state.wallet == null
          ? EarningPhase.loading
          : EarningPhase.refreshing,
      clearError: true,
    );
    try {
      final config = await repository.loadConfig(country);
      final levels = await repository.loadLevels(country);
      if (uid.isEmpty) {
        final snapshot = await repository.loadLocalSnapshot(config, country);
        state = _withSnapshot(
          snapshot,
          config: config,
          levels: levels,
          phase: EarningPhase.ready,
        );
        return;
      }
      final tasks = await repository.loadTasks(
        uid,
        config: config,
        country: country,
      );
      final wallet = await repository.loadBalance(
        uid,
        config: config,
        country: country,
      );
      state = state.copy(
        phase: EarningPhase.ready,
        config: config,
        tasks: tasks,
        wallet: wallet,
        levels: levels,
      );
    } catch (e) {
      state = state.copy(phase: EarningPhase.error, error: '$e');
    }
  }

  Future<void> collect(EarningTask task, {String uid = ''}) async {
    if (!task.completed || task.claimed) return;
    final actionKey = 'collect:${task.id}';
    if (!Idempotency.begin(actionKey)) return;
    final key = Idempotency.create('collect', task.id);
    state = state.copy(actionInProgress: true, clearError: true);
    try {
      final activeUid = uid.isEmpty ? _uid : uid;
      if (activeUid.isEmpty) {
        final snapshot = await repository.collectLocal(
          task.id,
          state.config,
          _country,
        );
        state = _withSnapshot(snapshot);
      } else {
        await repository.collect(activeUid, task.id, key);
        await load(uid: activeUid, country: _country);
      }
    } catch (e) {
      state = state.copy(error: '$e');
    } finally {
      state = state.copy(actionInProgress: false);
      Idempotency.end(actionKey);
    }
  }

  Future<void> settleVerifiedAd({
    required String eventId,
    String uid = '',
    String adType = 'rewarded',
    double revenueUsd = 0,
  }) async {
    final actionKey = 'ad:$eventId';
    if (!Idempotency.begin(actionKey)) return;
    state = state.copy(actionInProgress: true, clearError: true);
    try {
      final snapshot = await repository.settleVerifiedAd(
        uid: uid.isEmpty ? _uid : uid,
        country: _country,
        config: state.config,
        eventId: eventId,
        adType: adType,
        revenueUsd: revenueUsd,
      );
      state = _withSnapshot(snapshot);
    } catch (e) {
      state = state.copy(error: '$e');
    } finally {
      state = state.copy(actionInProgress: false);
      Idempotency.end(actionKey);
    }
  }

  Future<void> performCheckIn({String uid = ''}) async {
    const actionKey = 'check-in';
    if (!Idempotency.begin(actionKey)) return;
    state = state.copy(actionInProgress: true, clearError: true);
    try {
      final activeUid = uid.isEmpty ? _uid : uid;
      if (activeUid.isEmpty) {
        final snapshot = await repository.checkInLocal(state.config, _country);
        state = _withSnapshot(snapshot);
      } else {
        final value = await repository.checkIn(activeUid);
        state = state.copy(checkIn: value);
        await load(uid: activeUid, country: _country);
      }
    } catch (e) {
      state = state.copy(error: '$e');
    } finally {
      state = state.copy(actionInProgress: false);
      Idempotency.end(actionKey);
    }
  }

  Future<void> spin() async {
    const actionKey = 'spin';
    if (!Idempotency.begin(actionKey)) return;
    state = state.copy(
      actionInProgress: true,
      clearError: true,
      clearSpinReward: true,
    );
    try {
      final result = await repository.spinLocal(state.config, _country);
      state = _withSnapshot(result.snapshot, lastSpinReward: result.reward);
    } catch (e) {
      state = state.copy(error: '$e');
    } finally {
      state = state.copy(actionInProgress: false);
      Idempotency.end(actionKey);
    }
  }

  Future<void> confirmNotificationPermission(bool granted) async {
    if (!granted) return;
    try {
      final snapshot = await repository.rewardNotificationPermission(
        state.config,
        _country,
        permissionGranted: true,
      );
      state = _withSnapshot(snapshot);
    } catch (e) {
      state = state.copy(error: '$e');
    }
  }

  EarningState _withSnapshot(
    EarningSnapshot snapshot, {
    EarningConfig? config,
    List<WithdrawalLevel>? levels,
    EarningPhase? phase,
    int? lastSpinReward,
  }) => state.copy(
    phase: phase ?? EarningPhase.ready,
    config: config,
    tasks: snapshot.tasks,
    wallet: snapshot.wallet,
    checkIn: snapshot.checkIn,
    levels: levels,
    todayAdCount: snapshot.todayRewardedAdCount,
    todayEpisodeCount: snapshot.todayEpisodeCount,
    todayInterstitialCount: snapshot.todayInterstitialCount,
    todaySpinCount: snapshot.todaySpinCount,
    lastSpinReward: lastSpinReward,
    clearError: true,
  );
}
