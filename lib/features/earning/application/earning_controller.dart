import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talevra/core/tool/idempotency.dart';
import '../config/earning_config.dart';
import '../data/earning_repository.dart';
import '../models/check_in_status.dart';
import '../models/earning_task.dart';
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
  final String? error;
  const EarningState({
    this.phase = EarningPhase.loading,
    this.config = EarningConfig.local,
    this.tasks = const [],
    this.wallet,
    this.checkIn = const CheckInStatus(),
    this.levels = const [],
    this.todayAdCount = 0,
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
  @override
  EarningState build() => const EarningState();
  Future<void> load({String uid = '', String country = 'US'}) async {
    state = state.copy(
      phase: state.wallet == null
          ? EarningPhase.loading
          : EarningPhase.refreshing,
      clearError: true,
    );
    try {
      final config = await repository.loadConfig(country);
      final tasks = await repository.loadTasks(uid);
      final wallet = await repository.loadBalance(uid);
      final levels = await repository.loadLevels(country);
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
    try {
      await repository.collect(uid, task.id, key);
      await load(uid: uid);
    } catch (e) {
      state = state.copy(error: '$e');
    } finally {
      Idempotency.end(actionKey);
    }
  }

  Future<void> submitAd({
    String uid = '',
    String event = 'rewarded_complete',
  }) async {
    final actionKey = 'ad:$event';
    if (!Idempotency.begin(actionKey)) return;
    final key = Idempotency.create('ad', event);
    try {
      await repository.reportAd(uid, event, key);
      state = state.copy(todayAdCount: state.todayAdCount + 1);
    } catch (e) {
      state = state.copy(error: '$e');
    } finally {
      Idempotency.end(actionKey);
    }
  }

  Future<void> performCheckIn({String uid = ''}) async {
    const actionKey = 'check-in';
    if (!Idempotency.begin(actionKey)) return;
    try {
      final value = await repository.checkIn(uid);
      state = state.copy(checkIn: value);
    } catch (e) {
      state = state.copy(error: '$e');
    } finally {
      Idempotency.end(actionKey);
    }
  }
}
