import 'package:talevra/core/tool/api_result.dart';
import 'package:talevra/core/config/app_env.dart';
import '../config/earning_config.dart';
import '../models/check_in_status.dart';
import '../models/earning_config_model.dart';
import '../models/earning_snapshot.dart';
import '../models/earning_task.dart';
import '../models/wallet_balance.dart';
import '../models/withdrawal_level.dart';
import 'earning_api.dart';
import 'earning_local_store.dart';

class EarningRepository {
  final EarningApi api;
  final EarningConfig local;
  final EarningLocalStore localStore;
  final bool useRemoteConfig;
  EarningRepository({
    EarningApi? api,
    this.local = EarningConfig.local,
    EarningLocalStore? localStore,
    bool? useRemoteConfig,
  }) : api = api ?? EarningApi(),
       localStore = localStore ?? EarningLocalStore(),
       useRemoteConfig = useRemoteConfig ?? !AppEnvConfig.current.isDev;

  Future<EarningConfig> loadConfig(String country) async {
    if (!useRemoteConfig) return local;
    try {
      final r = ApiResult.fromJson(
        await api.config(local.productId, country),
        (d) => d as Map<String, dynamic>,
      );
      return local.merge(
        EarningConfigModel.fromJson(r.requireData()).toOverrides(),
      );
    } catch (_) {
      return local;
    }
  }

  Future<List<EarningTask>> loadTasks(
    String uid, {
    EarningConfig config = EarningConfig.local,
    String country = 'US',
  }) async {
    if (uid.isEmpty) return (await localStore.load(config, country)).tasks;
    final r = ApiResult.fromJson(
      await api.tasks(uid, local.productId),
      (d) => d as Map<String, dynamic>,
    );
    final data = r.requireData();
    final raw = data['tasks'] ?? data['taskList'] ?? [];
    final progressRaw = data['userTasks'] ?? data['userTaskList'] ?? [];
    final progressById = <String, Map<String, dynamic>>{
      for (final value in (progressRaw is List ? progressRaw : const []))
        if (value is Map)
          '${value['taskId'] ?? value['id'] ?? ''}': Map<String, dynamic>.from(
            value,
          ),
    };
    return (raw is List ? raw : const []).whereType<Map>().map((item) {
      final task = Map<String, dynamic>.from(item);
      final id = '${task['taskId'] ?? task['id'] ?? ''}';
      return EarningTask.fromJson({...task, ...?progressById[id]});
    }).toList();
  }

  Future<WalletBalance> loadBalance(
    String uid, {
    EarningConfig config = EarningConfig.local,
    String country = 'US',
  }) async {
    if (uid.isEmpty) return (await localStore.load(config, country)).wallet;
    final r = ApiResult.fromJson(
      await api.userInfo(uid, local.productId),
      (d) => d as Map<String, dynamic>,
    );
    return WalletBalance.fromJson(r.requireData());
  }

  Future<List<WithdrawalLevel>> loadLevels(String country) async {
    if (!useRemoteConfig) return local.defaultLevels;
    try {
      final r = ApiResult.fromJson(
        await api.levels(local.productId, country),
        (d) => d as Map<String, dynamic>,
      );
      final raw =
          r.requireData()['withdraws'] ?? r.requireData()['levels'] ?? [];
      return (raw is List ? raw : [])
          .whereType<Map>()
          .map((e) => WithdrawalLevel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return local.defaultLevels;
    }
  }

  Future<void> collect(String uid, String taskId, String key) async {
    if (uid.isEmpty) {
      throw StateError('Use collectLocal for anonymous earning accounts');
    }
    final r = ApiResult.fromJson(
      await api.action('/api/rc/task/collect', {
        'haloUid': uid,
        'productId': local.productId,
        'taskId': taskId,
        'idempotencyKey': key,
      }),
      null,
    );
    if (!r.isSuccess) throw ApiException(r.status, r.message);
  }

  Future<void> reportAd(String uid, String event, String key) async {
    if (uid.isEmpty) {
      throw StateError('Verified ad settlement requires a local event payload');
    }
    final r = ApiResult.fromJson(
      await api.action('/api/rc/ad/getCoins', {
        'haloUid': uid,
        'productId': local.productId,
        'event': event,
        'idempotencyKey': key,
      }),
      null,
    );
    if (!r.isSuccess) throw ApiException(r.status, r.message);
  }

  Future<CheckInStatus> checkIn(String uid) async {
    if (uid.isEmpty) {
      throw StateError('Use checkInLocal for anonymous earning accounts');
    }
    final r = ApiResult.fromJson(
      await api.action('/api/rc/task/do', {
        'haloUid': uid,
        'productId': local.productId,
        'taskType': 'login',
      }),
      (d) => CheckInStatus.fromJson(Map<String, dynamic>.from(d as Map)),
    );
    return r.requireData();
  }

  Future<EarningSnapshot> loadLocalSnapshot(
    EarningConfig config,
    String country,
  ) => localStore.load(config, country);

  Future<EarningSnapshot> collectLocal(
    String taskId,
    EarningConfig config,
    String country,
  ) => localStore.collectTask(taskId, config, country);

  Future<EarningSnapshot> checkInLocal(EarningConfig config, String country) =>
      localStore.checkIn(config, country);

  Future<EarningSnapshot> recordWatchedEpisodes(
    Iterable<String> episodeKeys, {
    EarningConfig config = EarningConfig.local,
    String country = 'US',
  }) => localStore.recordEpisodes(episodeKeys, config, country);

  Future<EarningSnapshot> settleVerifiedAd({
    required String uid,
    required String country,
    required EarningConfig config,
    required String eventId,
    required String adType,
    required double revenueUsd,
  }) async {
    if (uid.isEmpty) {
      return localStore.recordVerifiedAd(
        config: config,
        country: country,
        eventId: eventId,
        adType: adType,
        revenueUsd: revenueUsd,
      );
    }
    final r = ApiResult.fromJson(
      await api.reportAdEvent({
        'haloUid': uid,
        'productId': local.productId,
        'eventId': eventId,
        'event': 'completed',
        'adType': adType,
        'revenue': revenueUsd,
      }),
      null,
    );
    if (!r.isSuccess) throw ApiException(r.status, r.message);
    final settlement = ApiResult.fromJson(
      await api.settleAd({
        'haloUid': uid,
        'productId': local.productId,
        'eventId': eventId,
        'adType': adType,
      }),
      null,
    );
    if (!settlement.isSuccess) {
      throw ApiException(settlement.status, settlement.message);
    }
    final tasks = await loadTasks(uid, config: config, country: country);
    final wallet = await loadBalance(uid, config: config, country: country);
    return EarningSnapshot(
      wallet: wallet,
      tasks: tasks,
      checkIn: const CheckInStatus(),
    );
  }

  Future<({int reward, EarningSnapshot snapshot})> spinLocal(
    EarningConfig config,
    String country,
  ) => localStore.spin(config, country);

  Future<EarningSnapshot> rewardNotificationPermission(
    EarningConfig config,
    String country, {
    required bool permissionGranted,
  }) => localStore.rewardNotificationPermission(
    config,
    country,
    permissionGranted: permissionGranted,
  );
}
