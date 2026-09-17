import 'package:flutter_test/flutter_test.dart';
import 'package:talevra/core/tool/api_result.dart';
import 'package:talevra/core/tool/coin_tool.dart';
import 'package:talevra/core/tool/date_time_tool.dart';
import 'package:talevra/core/tool/request_signer.dart';
import 'package:talevra/features/earning/config/earning_config.dart';
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
