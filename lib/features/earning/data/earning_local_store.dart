import 'dart:convert';

import 'package:talevra/core/storage/local_storage.dart';
import 'package:talevra/core/tool/date_time_tool.dart';

import '../config/earning_config.dart';
import '../models/check_in_status.dart';
import '../models/earning_snapshot.dart';
import '../models/earning_task.dart';
import '../models/wallet_balance.dart';

class EarningLocalStore {
  static const _storageKey = 'earning.ledger.v2';

  Future<EarningSnapshot> load(EarningConfig config, String country) async {
    final ledger = _read()..rollover();
    if (!ledger.starterGranted) {
      ledger.coins += config.starterRewardFor(country);
      ledger.starterGranted = true;
    }
    await _write(ledger);
    return _snapshot(ledger, config);
  }

  Future<EarningSnapshot> collectTask(
    String taskId,
    EarningConfig config,
    String country,
  ) async {
    final ledger = _read()..rollover();
    final task = _tasks(
      ledger,
      config,
    ).where((item) => item.id == taskId).firstOrNull;
    if (task == null || !task.completed || task.claimed) {
      throw StateError('Task is not ready to collect');
    }
    ledger
      ..coins += task.reward
      ..claimedTaskIds.add(task.id);
    await _write(ledger);
    return _snapshot(ledger, config);
  }

  Future<EarningSnapshot> checkIn(EarningConfig config, String country) async {
    final ledger = _read()..rollover();
    final today = DateTimeTool.dayKey();
    if (ledger.lastCheckInDay == today) return _snapshot(ledger, config);
    final last = DateTime.tryParse(ledger.lastCheckInDay ?? '');
    ledger.checkInStreak = last != null && DateTimeTool.isYesterday(last)
        ? ledger.checkInStreak % 7 + 1
        : 1;
    ledger
      ..lastCheckInDay = today
      ..coins += config.checkInCoins[ledger.checkInStreak - 1];
    await _write(ledger);
    return _snapshot(ledger, config);
  }

  Future<EarningSnapshot> recordEpisodes(
    Iterable<String> episodeKeys,
    EarningConfig config,
    String country,
  ) async {
    final ledger = _read()..rollover();
    ledger.watchedEpisodeKeys.addAll(
      episodeKeys.where((key) => key.trim().isNotEmpty),
    );
    await _write(ledger);
    return _snapshot(ledger, config);
  }

  Future<EarningSnapshot> recordVerifiedAd({
    required EarningConfig config,
    required String country,
    required String eventId,
    required String adType,
    required double revenueUsd,
  }) async {
    final ledger = _read()..rollover();
    if (eventId.isEmpty || ledger.settledAdEventIds.contains(eventId)) {
      return _snapshot(ledger, config);
    }
    final isRewarded = adType == 'rewarded';
    final cap = isRewarded ? config.videoDailyCap : config.interstitialDailyCap;
    final current = isRewarded
        ? ledger.rewardedAdCount
        : ledger.interstitialCount;
    if (current >= cap) {
      throw StateError('Daily ad reward limit reached');
    }
    final effectiveDayCap = [
      config.userDayCapUsd,
      config.deviceDayCapUsd,
      config.ipDayCapUsd,
    ].reduce((a, b) => a < b ? a : b);
    final remainingUsd = (effectiveDayCap - ledger.todayAdRewardUsd)
        .clamp(0, effectiveDayCap)
        .toDouble();
    if (remainingUsd <= 0) throw StateError('Daily earning limit reached');
    final acceptedRevenue = revenueUsd <= 0
        ? config.defaultAdRevenueUsd
        : revenueUsd;
    final cappedRevenue = acceptedRevenue
        .clamp(0, config.adTypeCoinCaps[adType] ?? config.ecpmCapUsd)
        .toDouble();
    final ratio = DateTimeTool.registrationDays(ledger.registeredAt) < 7
        ? config.newUserRatio
        : config.oldUserRatio;
    final rewardUsd = (cappedRevenue * ratio).clamp(0, remainingUsd).toDouble();
    ledger
      ..settledAdEventIds.add(eventId)
      ..todayAdRewardUsd += rewardUsd
      ..coins += (rewardUsd * config.coinCount).round();
    if (isRewarded) {
      ledger.rewardedAdCount += 1;
    } else {
      ledger.interstitialCount += 1;
    }
    await _write(ledger);
    return _snapshot(ledger, config);
  }

  Future<({int reward, EarningSnapshot snapshot})> spin(
    EarningConfig config,
    String country,
  ) async {
    final ledger = _read()..rollover();
    if (ledger.spinCount >= config.spinRewards.length) {
      throw StateError('No spins remaining today');
    }
    final reward = config.spinRewards[ledger.spinCount];
    ledger
      ..spinCount += 1
      ..coins += reward;
    await _write(ledger);
    return (reward: reward, snapshot: _snapshot(ledger, config));
  }

  Future<EarningSnapshot> rewardNotificationPermission(
    EarningConfig config,
    String country, {
    required bool permissionGranted,
  }) async {
    final ledger = _read()..rollover();
    if (permissionGranted && !ledger.notificationRewardClaimed) {
      ledger
        ..notificationRewardClaimed = true
        ..coins += config.notificationReward;
    }
    await _write(ledger);
    return _snapshot(ledger, config);
  }

  EarningSnapshot _snapshot(_Ledger ledger, EarningConfig config) =>
      EarningSnapshot(
        wallet: WalletBalance(
          coins: ledger.coins,
          registeredAt: ledger.registeredAt,
        ),
        tasks: _tasks(ledger, config),
        checkIn: CheckInStatus(
          streak: ledger.checkInStreak,
          checkedToday: ledger.lastCheckInDay == DateTimeTool.dayKey(),
        ),
        todayEpisodeCount: ledger.watchedEpisodeKeys.length,
        todayRewardedAdCount: ledger.rewardedAdCount,
        todayInterstitialCount: ledger.interstitialCount,
        todaySpinCount: ledger.spinCount,
      );

  List<EarningTask> _tasks(_Ledger ledger, EarningConfig config) => [
    for (var i = 0; i < config.watchGoals.length; i++)
      EarningTask(
        id: 'watch-${config.watchGoals[i]}',
        type: EarningTaskType.watchContent,
        title: 'Watch ${config.watchGoals[i]} episodes',
        goal: config.watchGoals[i],
        reward: config.watchRewards[i],
        multiplier: config.watchMultipliers[i],
        progress: ledger.watchedEpisodeKeys.length,
        claimed: ledger.claimedTaskIds.contains(
          'watch-${config.watchGoals[i]}',
        ),
      ),
    for (var i = 0; i < config.adGoals.length; i++)
      EarningTask(
        id: 'ad-${config.adGoals[i]}',
        type: EarningTaskType.watchAd,
        title: 'Watch ${config.adGoals[i]} rewarded ads',
        goal: config.adGoals[i],
        reward: config.adRewards[i],
        progress: ledger.rewardedAdCount,
        claimed: ledger.claimedTaskIds.contains('ad-${config.adGoals[i]}'),
      ),
    EarningTask(
      id: 'notification',
      type: EarningTaskType.notification,
      title: 'Enable notifications',
      goal: 1,
      reward: config.notificationReward,
      multiplier: config.notificationMultiplier,
      progress: ledger.notificationRewardClaimed ? 1 : 0,
      claimed: ledger.notificationRewardClaimed,
    ),
    EarningTask(
      id: 'ad-cashback-${config.cashbackAdGoal}',
      type: EarningTaskType.auxiliary,
      title: 'Ad milestone bonus',
      goal: config.cashbackAdGoal,
      reward: config.cashbackReward,
      progress: ledger.rewardedAdCount,
      claimed: ledger.claimedTaskIds.contains(
        'ad-cashback-${config.cashbackAdGoal}',
      ),
      visible: false,
    ),
  ];

  _Ledger _read() {
    if (!LocalStorage.isInitialized) return _Ledger.fresh();
    final value = LocalStorage.I.getString(_storageKey);
    if (value == null) return _Ledger.fresh();
    try {
      return _Ledger.fromJson(jsonDecode(value) as Map<String, dynamic>);
    } catch (_) {
      return _Ledger.fresh();
    }
  }

  Future<void> _write(_Ledger ledger) async {
    if (!LocalStorage.isInitialized) return;
    await LocalStorage.I.setString(_storageKey, jsonEncode(ledger.toJson()));
  }
}

class _Ledger {
  int coins;
  DateTime registeredAt;
  bool starterGranted;
  String day;
  Set<String> watchedEpisodeKeys;
  int rewardedAdCount;
  int interstitialCount;
  int spinCount;
  double todayAdRewardUsd;
  Set<String> settledAdEventIds;
  Set<String> claimedTaskIds;
  int checkInStreak;
  String? lastCheckInDay;
  bool notificationRewardClaimed;

  _Ledger({
    required this.coins,
    required this.registeredAt,
    required this.starterGranted,
    required this.day,
    required this.watchedEpisodeKeys,
    required this.rewardedAdCount,
    required this.interstitialCount,
    required this.spinCount,
    required this.todayAdRewardUsd,
    required this.settledAdEventIds,
    required this.claimedTaskIds,
    required this.checkInStreak,
    required this.lastCheckInDay,
    required this.notificationRewardClaimed,
  });

  factory _Ledger.fresh() => _Ledger(
    coins: 0,
    registeredAt: DateTime.now(),
    starterGranted: false,
    day: DateTimeTool.dayKey(),
    watchedEpisodeKeys: <String>{},
    rewardedAdCount: 0,
    interstitialCount: 0,
    spinCount: 0,
    todayAdRewardUsd: 0,
    settledAdEventIds: <String>{},
    claimedTaskIds: <String>{},
    checkInStreak: 0,
    lastCheckInDay: null,
    notificationRewardClaimed: false,
  );

  factory _Ledger.fromJson(Map<String, dynamic> json) => _Ledger(
    coins: (json['coins'] as num?)?.toInt() ?? 0,
    registeredAt:
        DateTime.tryParse('${json['registeredAt'] ?? ''}') ?? DateTime.now(),
    starterGranted: json['starterGranted'] == true,
    day: '${json['day'] ?? DateTimeTool.dayKey()}',
    watchedEpisodeKeys: _strings(json['watchedEpisodeKeys']),
    rewardedAdCount: (json['rewardedAdCount'] as num?)?.toInt() ?? 0,
    interstitialCount: (json['interstitialCount'] as num?)?.toInt() ?? 0,
    spinCount: (json['spinCount'] as num?)?.toInt() ?? 0,
    todayAdRewardUsd: (json['todayAdRewardUsd'] as num?)?.toDouble() ?? 0,
    settledAdEventIds: _strings(json['settledAdEventIds']),
    claimedTaskIds: _strings(json['claimedTaskIds']),
    checkInStreak: (json['checkInStreak'] as num?)?.toInt() ?? 0,
    lastCheckInDay: json['lastCheckInDay'] as String?,
    notificationRewardClaimed: json['notificationRewardClaimed'] == true,
  );

  void rollover() {
    final today = DateTimeTool.dayKey();
    if (day == today) return;
    day = today;
    watchedEpisodeKeys.clear();
    rewardedAdCount = 0;
    interstitialCount = 0;
    spinCount = 0;
    todayAdRewardUsd = 0;
    settledAdEventIds.clear();
    claimedTaskIds.clear();
  }

  Map<String, dynamic> toJson() => {
    'coins': coins,
    'registeredAt': registeredAt.toIso8601String(),
    'starterGranted': starterGranted,
    'day': day,
    'watchedEpisodeKeys': watchedEpisodeKeys.toList(),
    'rewardedAdCount': rewardedAdCount,
    'interstitialCount': interstitialCount,
    'spinCount': spinCount,
    'todayAdRewardUsd': todayAdRewardUsd,
    'settledAdEventIds': settledAdEventIds.toList(),
    'claimedTaskIds': claimedTaskIds.toList(),
    'checkInStreak': checkInStreak,
    'lastCheckInDay': lastCheckInDay,
    'notificationRewardClaimed': notificationRewardClaimed,
  };

  static Set<String> _strings(dynamic value) =>
      value is List ? value.map((item) => '$item').toSet() : <String>{};
}
