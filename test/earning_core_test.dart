import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talevra/core/storage/local_storage.dart';
import 'package:talevra/core/tool/api_result.dart';
import 'package:talevra/core/tool/coin_tool.dart';
import 'package:talevra/core/tool/date_time_tool.dart';
import 'package:talevra/core/tool/request_signer.dart';
import 'package:talevra/features/earning/config/earning_config.dart';
import 'package:talevra/features/earning/data/earning_local_store.dart';
import 'package:talevra/features/earning/models/earning_config_model.dart';
import 'package:talevra/features/earning/models/earning_task.dart';

void main() {
  group('RequestSigner', () {
    test('fixed body and timestamp produce a stable token', () {
      final first = RequestSigner.sign('{"a":1}', timestamp: 1700000000);
      final second = RequestSigner.sign('{"a":1}', timestamp: 1700000000);
      expect(first, second);
      expect(first['RequestTime'], '1700000000');
      expect(first['Token'], hasLength(32));
    });

    test('signing is bound to the original json field order', () {
      final first = RequestSigner.sign('{"a":1,"b":2}', timestamp: 1700000000);
      final second = RequestSigner.sign('{"b":2,"a":1}', timestamp: 1700000000);
      expect(first['Token'], isNot(second['Token']));
    });
  });

  group('EarningConfig', () {
    test('contains all local task ladders', () {
      expect(EarningConfig.local.watchGoals, [5, 10, 20, 30, 50]);
      expect(EarningConfig.local.adGoals, [3, 5, 10, 20, 30, 50]);
      expect(EarningConfig.local.checkInCoins, hasLength(7));
      expect(EarningConfig.local.defaultLevels, hasLength(6));
      expect(EarningConfig.local.watchRewards, [500, 1000, 2000, 3000, 4000]);
      expect(EarningConfig.local.adRewards, [
        2000,
        3000,
        4000,
        5000,
        8000,
        10000,
      ]);
      expect(EarningConfig.local.spinRewards, [50, 100, 150]);
      expect(EarningConfig.local.defaultAdRevenueUsd, .0005);
      expect(EarningConfig.local.ecpmCapUsd, .06);
    });

    test('accepts safe remote values and rejects abnormal starter grants', () {
      final merged = EarningConfig.local.merge({
        'videoDailyCap': 25,
        'starterCoins': {'US': 740666666, 'BR': 30000},
      });
      expect(merged.videoDailyCap, 25);
      expect(merged.starterCoins['US'], 12000);
      expect(merged.starterCoins['BR'], 30000);
    });

    test('parses captured nested economy and frequency fields', () {
      final parsed = EarningConfigModel.fromJson({
        'baseInfo': {'coinCount': 1000000},
        'defaultAdRevenue': {'general': 0.0005},
        'sendCoinInfo': {
          'ecpmCap': 0.06,
          'ratioNew': 0.2,
          'ratioOld': 0.1,
          'userDayCap': 4,
          'deviceDayCap': 4,
          'ipDayCap': 4,
        },
        'frequencyInfo': {'videoCap': 50, 'interstitialCap': 100},
        'adFrequencyInfo': {'adCap': 3},
        'adTypeCoinCap': {'rewarded': 0.06, 'interstitial': 0.06},
      });
      final merged = EarningConfig.local.merge(parsed.toOverrides());
      expect(merged.coinCount, 1000000);
      expect(merged.videoDailyCap, 50);
      expect(merged.interstitialDailyCap, 100);
      expect(merged.adDailyCap, 3);
      expect(merged.newUserRatio, .2);
      expect(merged.oldUserRatio, .1);
      expect(merged.adTypeCoinCaps['rewarded'], .06);
    });
  });

  group('Local earning ledger', () {
    late EarningLocalStore store;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await LocalStorage.init();
      store = EarningLocalStore();
    });

    test('grants the safe starter reward exactly once', () async {
      final first = await store.load(EarningConfig.local, 'US');
      final second = await store.load(EarningConfig.local, 'US');
      expect(first.wallet.coins, 12000);
      expect(second.wallet.coins, 12000);
    });

    test(
      'deduplicates watched episodes and collects a completed task',
      () async {
        await store.load(EarningConfig.local, 'US');
        final progress = await store.recordEpisodes(
          ['1:1', '1:1', '1:2', '1:3', '1:4', '1:5'],
          EarningConfig.local,
          'US',
        );
        final task = progress.tasks.firstWhere((item) => item.id == 'watch-5');
        expect(task.progress, 5);
        expect(task.completed, isTrue);

        final claimed = await store.collectTask(
          task.id,
          EarningConfig.local,
          'US',
        );
        expect(claimed.wallet.coins, 12500);
        expect(
          claimed.tasks.firstWhere((item) => item.id == 'watch-5').claimed,
          isTrue,
        );
      },
    );

    test('settles verified ads once and applies the new-user ratio', () async {
      await store.load(EarningConfig.local, 'US');
      final settled = await store.recordVerifiedAd(
        config: EarningConfig.local,
        country: 'US',
        eventId: 'verified-ad-1',
        adType: 'rewarded',
        revenueUsd: 0,
      );
      final duplicate = await store.recordVerifiedAd(
        config: EarningConfig.local,
        country: 'US',
        eventId: 'verified-ad-1',
        adType: 'rewarded',
        revenueUsd: 0,
      );
      expect(settled.todayRewardedAdCount, 1);
      expect(settled.wallet.coins, 12100);
      expect(duplicate.todayRewardedAdCount, 1);
      expect(duplicate.wallet.coins, 12100);
    });

    test(
      'check-in and draw rewards cannot be repeated beyond limits',
      () async {
        await store.load(EarningConfig.local, 'US');
        final checked = await store.checkIn(EarningConfig.local, 'US');
        final checkedAgain = await store.checkIn(EarningConfig.local, 'US');
        expect(checked.checkIn.checkedToday, isTrue);
        expect(checkedAgain.wallet.coins, 12500);

        await store.spin(EarningConfig.local, 'US');
        await store.spin(EarningConfig.local, 'US');
        final third = await store.spin(EarningConfig.local, 'US');
        expect(third.reward, 150);
        expect(third.snapshot.todaySpinCount, 3);
        expect(
          () => store.spin(EarningConfig.local, 'US'),
          throwsA(isA<StateError>()),
        );
      },
    );
  });

  group('Earning tools and models', () {
    test('formats and values integer coins', () {
      expect(CoinTool.format(1990000), '1,990,000');
      expect(CoinTool.toUsd(500000), 0.5);
      expect(CoinTool.canWithdraw(100, 100), isTrue);
    });

    test('uses local calendar days for registration and check-in', () {
      final now = DateTime(2026, 9, 12, 0, 5);
      expect(
        DateTimeTool.registrationDays(DateTime(2026, 9, 11, 23, 59), now),
        1,
      );
      expect(
        DateTimeTool.isYesterday(DateTime(2026, 9, 11, 23, 59), now),
        isTrue,
      );
      expect(DateTimeTool.dayKey(now), '2026-09-12');
    });

    test('task progress is capped and claimed tasks stay claimed', () {
      final complete = EarningTask.fromJson({
        'taskId': 'watch-5',
        'type': 'showContent',
        'goal': 5,
        'progress': 7,
        'coins': 500,
        'claimed': true,
      });
      expect(complete.type, EarningTaskType.watchContent);
      expect(complete.completed, isTrue);
      expect(complete.ratio, 1);
      expect(complete.claimed, isTrue);
    });

    test('non-zero API status throws a business exception', () {
      final result = ApiResult<Map<String, dynamic>>.fromJson({
        'status': 20000,
        'msg': 'invalid user',
        'data': <String, dynamic>{},
      }, (data) => data as Map<String, dynamic>);
      expect(result.requireData, throwsA(isA<ApiException>()));
    });
  });
}
