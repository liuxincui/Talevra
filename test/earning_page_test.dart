import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talevra/features/earning/application/earning_controller.dart';
import 'package:talevra/features/earning/config/earning_config.dart';
import 'package:talevra/features/earning/data/earning_repository.dart';
import 'package:talevra/features/earning/data/earning_api.dart';
import 'package:talevra/features/earning/earning_page.dart';
import 'package:talevra/features/earning/models/earning_task.dart';
import 'package:talevra/features/earning/models/earning_snapshot.dart';
import 'package:talevra/features/earning/models/check_in_status.dart';
import 'package:talevra/features/earning/models/wallet_balance.dart';
import 'package:talevra/features/earning/models/withdrawal_level.dart';

class FakeEarningRepository extends EarningRepository {
  FakeEarningRepository() : super(api: EarningApi(Dio()));
  @override
  Future<EarningConfig> loadConfig(String country) async => EarningConfig.local;
  @override
  Future<List<EarningTask>> loadTasks(
    String uid, {
    EarningConfig config = EarningConfig.local,
    String country = 'US',
  }) async => const [
    EarningTask(
      id: 'watch-5',
      type: EarningTaskType.watchContent,
      title: 'Watch 5 episodes',
      goal: 5,
      reward: 500,
      progress: 3,
    ),
  ];
  @override
  Future<WalletBalance> loadBalance(
    String uid, {
    EarningConfig config = EarningConfig.local,
    String country = 'US',
  }) async => const WalletBalance(coins: 72500);
  @override
  Future<List<WithdrawalLevel>> loadLevels(String country) async =>
      EarningConfig.local.defaultLevels;

  @override
  Future<EarningSnapshot> loadLocalSnapshot(
    EarningConfig config,
    String country,
  ) async => EarningSnapshot(
    wallet: const WalletBalance(coins: 72500),
    tasks: await loadTasks(''),
    checkIn: const CheckInStatus(),
  );
}

void main() {
  testWidgets('earning page renders loaded task and wallet states', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          earningRepositoryProvider.overrideWithValue(FakeEarningRepository()),
        ],
        child: const MaterialApp(home: EarningPage()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('72,500'), findsOneWidget);
    expect(find.text('Watch 5 episodes'), findsOneWidget);
    expect(find.text('Withdrawal levels'), findsOneWidget);
  });
}
