import 'package:talevra/core/tool/api_result.dart';
import '../config/earning_config.dart';
import '../models/check_in_status.dart';
import '../models/earning_config_model.dart';
import '../models/earning_task.dart';
import '../models/wallet_balance.dart';
import '../models/withdrawal_level.dart';
import 'earning_api.dart';

class EarningRepository {
  final EarningApi api;
  final EarningConfig local;
  EarningRepository({EarningApi? api, this.local = EarningConfig.local})
    : api = api ?? EarningApi();
  Future<EarningConfig> loadConfig(String country) async {
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

  Future<List<EarningTask>> loadTasks(String uid) async {
    final r = ApiResult.fromJson(
      await api.tasks(uid, local.productId),
      (d) => d as Map<String, dynamic>,
    );
    final data = r.requireData();
    final raw = data['tasks'] ?? data['taskList'] ?? [];
    return (raw is List ? raw : [])
        .whereType<Map>()
        .map((e) => EarningTask.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<WalletBalance> loadBalance(String uid) async {
    final r = ApiResult.fromJson(
      await api.userInfo(uid, local.productId),
      (d) => d as Map<String, dynamic>,
    );
    return WalletBalance.fromJson(r.requireData());
  }

  Future<List<WithdrawalLevel>> loadLevels(String country) async {
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
}
