import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:talevra/app/theme/app_theme.dart';
import 'package:talevra/core/config/brand_provider.dart';
import 'package:talevra/core/tool/coin_tool.dart';
import 'application/earning_controller.dart';
import 'models/earning_task.dart';
import 'models/withdrawal_level.dart';
import 'package:talevra/l10n/app_localizations.dart';

class EarningPage extends ConsumerStatefulWidget {
  const EarningPage({super.key});
  @override
  ConsumerState<EarningPage> createState() => _EarningPageState();
}

class _EarningPageState extends ConsumerState<EarningPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final brand = ref.read(brandCodeProvider);
      ref
          .read(earningControllerProvider.notifier)
          .load(country: _countryFromBrand(brand));
    });
  }

  String _countryFromBrand(String brand) => switch (brand) {
    'brand_br' => 'BR',
    'brand_mx' => 'MX',
    'brand_id' => 'ID',
    'brand_jp' => 'JP',
    'brand_kr' => 'KR',
    _ => 'US',
  };

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(earningControllerProvider);
    final l = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppPalette.gradient),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 18, 14, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l?.rewardsTab ?? 'Rewards',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () =>
                    ref.read(earningControllerProvider.notifier).load(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ActivityHero(
                        coins: state.wallet?.coins ?? 955580,
                        onWatch: () => context.push('/player/feed?mode=feed'),
                      ),
                      const SizedBox(height: 12),
                      _CashoutCard(
                        coins: state.wallet?.coins ?? 0,
                        label: l?.availableBalance ?? 'Available balance',
                        minimum: state.levels.isEmpty
                            ? 1990000
                            : state.levels.first.requiredCoins,
                        minimumAmount: state.levels.isEmpty
                            ? 1
                            : state.levels.first.amountUsd,
                        onWithdraw: () => _showWithdrawalLevels(state),
                      ),
                      const SizedBox(height: 16),
                      _DailyProgress(
                        episodes: state.todayEpisodeCount,
                        episodeCap: state.config.watchGoals.last,
                        ads: state.todayAdCount,
                        adCap: state.config.videoDailyCap,
                      ),
                      const SizedBox(height: 16),
                      _CheckInCard(
                        streak: state.checkIn.streak,
                        checked: state.checkIn.checkedToday,
                        rewards: state.config.checkInCoins,
                        onClaim: state.checkIn.checkedToday
                            ? null
                            : () => ref
                                  .read(earningControllerProvider.notifier)
                                  .performCheckIn(),
                        label: l?.checkIn ?? 'Claim',
                      ),
                      const SizedBox(height: 16),
                      _SpinCard(
                        used: state.todaySpinCount,
                        rewards: state.config.spinRewards,
                        lastReward: state.lastSpinReward,
                        busy: state.actionInProgress,
                        onSpin: () =>
                            ref.read(earningControllerProvider.notifier).spin(),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l?.tasks ?? 'Tasks',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...state.tasks
                          .where((task) => task.visible)
                          .map(
                            (task) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _TaskCard(
                                title: task.title,
                                reward: task.reward,
                                ratio: task.ratio,
                                progress: task.progress,
                                goal: task.goal,
                                multiplier: task.multiplier,
                                type: task.type,
                                claimed: task.claimed,
                                onPressed: _taskAction(state, task),
                              ),
                            ),
                          ),
                      if (state.loading)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      if (state.error != null)
                        _RewardsUnavailableBanner(
                          message:
                              l?.rewardsUnavailable ??
                              'Rewards are temporarily unavailable. Your other features still work.',
                          retryLabel: l?.retry ?? 'Retry',
                          onRetry: () => ref
                              .read(earningControllerProvider.notifier)
                              .load(),
                        ),
                      if (state.tasks.isEmpty && !state.loading) ...[
                        const SizedBox(height: 12),
                        const _TaskCard(
                          title: 'Watch episodes & earn rewards',
                          reward: 500,
                          ratio: .4,
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (state.levels.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Text(
                          l?.withdrawalLevels ?? 'Withdrawal levels',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: state.levels
                              .map(
                                (level) => _WithdrawalLevelChip(
                                  amount: level.amountUsd,
                                  requirement:
                                      l?.daysCoins(
                                        level.regDays,
                                        CoinTool.format(level.requiredCoins),
                                      ) ??
                                      '${level.regDays} days · ${CoinTool.format(level.requiredCoins)} coins',
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  VoidCallback? _taskAction(EarningState state, EarningTask task) {
    if (state.actionInProgress || task.claimed) return null;
    if (task.completed) {
      return () => ref.read(earningControllerProvider.notifier).collect(task);
    }
    return switch (task.type) {
      EarningTaskType.watchContent => () => context.push(
        '/player/feed?mode=feed',
      ),
      EarningTaskType.watchAd => () => _message(
        'Rewarded ads are credited only after a verified completion.',
      ),
      EarningTaskType.notification => _requestNotificationReward,
      _ => null,
    };
  }

  Future<void> _requestNotificationReward() async {
    try {
      final granted =
          await const MethodChannel(
            'talevra/dramaverse',
          ).invokeMethod<bool>('requestNotificationPermission') ??
          false;
      await ref
          .read(earningControllerProvider.notifier)
          .confirmNotificationPermission(granted);
      if (!mounted) return;
      _message(
        granted
            ? 'Notification reward credited.'
            : 'Notification permission was not granted.',
      );
    } on PlatformException {
      if (mounted) _message('Unable to request notification permission.');
    }
  }

  Future<void> _showWithdrawalLevels(
    EarningState state,
  ) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Withdrawal levels',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            for (final level in state.levels)
              _WithdrawalRow(
                level: level,
                eligible: state.eligibleLevels.contains(level),
                coins: state.wallet?.coins ?? 0,
              ),
            const SizedBox(height: 8),
            const Text(
              'Payout requests remain unavailable until the verified order-create contract is configured.',
              style: TextStyle(color: AppPalette.muted, fontSize: 12),
            ),
          ],
        ),
      ),
    ),
  );

  void _message(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
}

class _ActivityHero extends StatelessWidget {
  final int coins;
  final VoidCallback onWatch;
  const _ActivityHero({required this.coins, required this.onWatch});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
    decoration: BoxDecoration(
      color: const Color(0xFF211B20),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.white10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Falling For my ESTRANGED WIFE',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          'Title ABCD',
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withValues(alpha: .65),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(
            6,
            (index) => Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index == 5 ? 0 : 4),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: index == 0
                      ? const Color(0xFFFF4F72)
                      : const Color(0xFF3D3338),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.savings_rounded,
                      size: 15,
                      color: Color(0xFFB7F57B),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      index == 0 ? '10,000' : '0',
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 36,
          child: FilledButton(
            onPressed: onWatch,
            child: const Text('Ambit Ganda'),
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'Rp ${CoinTool.format(coins)}',
          style: const TextStyle(
            color: Color(0xFFFFD65A),
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );
}

class _DailyProgress extends StatelessWidget {
  final int episodes;
  final int episodeCap;
  final int ads;
  final int adCap;

  const _DailyProgress({
    required this.episodes,
    required this.episodeCap,
    required this.ads,
    required this.adCap,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _Metric(
          icon: Icons.movie_filter_outlined,
          value: '$episodes/$episodeCap',
          label: 'Episodes today',
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: _Metric(
          icon: Icons.play_circle_outline,
          value: '$ads/$adCap',
          label: 'Verified ads',
        ),
      ),
    ],
  );
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _Metric({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    height: 82,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      color: AppPalette.card,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.white10),
    ),
    child: Row(
      children: [
        Icon(icon, color: AppPalette.yellow),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: AppPalette.muted),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SpinCard extends StatelessWidget {
  final int used;
  final List<int> rewards;
  final int? lastReward;
  final bool busy;
  final VoidCallback onSpin;

  const _SpinCard({
    required this.used,
    required this.rewards,
    required this.lastReward,
    required this.busy,
    required this.onSpin,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = (rewards.length - used).clamp(0, rewards.length);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          const Icon(Icons.casino_outlined, color: AppPalette.yellow, size: 34),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily lucky draw',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  lastReward == null
                      ? '$remaining attempts remaining'
                      : '+${CoinTool.format(lastReward!)} coins · $remaining remaining',
                  style: const TextStyle(color: AppPalette.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: remaining > 0 && !busy ? onSpin : null,
            child: Text(remaining > 0 ? 'Draw' : 'Done'),
          ),
        ],
      ),
    );
  }
}

class _WithdrawalRow extends StatelessWidget {
  final WithdrawalLevel level;
  final bool eligible;
  final int coins;

  const _WithdrawalRow({
    required this.level,
    required this.eligible,
    required this.coins,
  });

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(
      eligible ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
      color: eligible ? AppPalette.yellow : AppPalette.muted,
    ),
    title: Text(
      '\$${level.amountUsd.toStringAsFixed(2)} USD / USDT',
      style: const TextStyle(fontWeight: FontWeight.w800),
    ),
    subtitle: Text(
      '${level.regDays} days · ${CoinTool.format(level.requiredCoins)} coins',
    ),
    trailing: Text(
      eligible
          ? 'Eligible'
          : '${((coins / level.requiredCoins).clamp(0, 1) * 100).floor()}%',
      style: TextStyle(
        color: eligible ? AppPalette.yellow : AppPalette.muted,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _WithdrawalLevelChip extends StatelessWidget {
  final double amount;
  final String requirement;

  const _WithdrawalLevelChip({required this.amount, required this.requirement});

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minWidth: 132),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppPalette.card,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.white12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(
          requirement,
          style: const TextStyle(fontSize: 11, color: AppPalette.muted),
        ),
      ],
    ),
  );
}

class _RewardsUnavailableBanner extends StatelessWidget {
  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  const _RewardsUnavailableBanner({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 4),
    padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
    decoration: BoxDecoration(
      color: AppPalette.card.withValues(alpha: .92),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.white12),
    ),
    child: Row(
      children: [
        const Icon(Icons.cloud_off_outlined, color: AppPalette.muted),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(color: Color(0xFFE4DDEA), height: 1.35),
          ),
        ),
        TextButton(onPressed: onRetry, child: Text(retryLabel)),
      ],
    ),
  );
}

class _CashoutCard extends StatelessWidget {
  final int coins;
  final int minimum;
  final double minimumAmount;
  final String label;
  final VoidCallback onWithdraw;
  const _CashoutCard({
    required this.coins,
    required this.minimum,
    required this.minimumAmount,
    required this.label,
    required this.onWithdraw,
  });
  @override
  Widget build(BuildContext context) {
    final ratio = (coins / minimum).clamp(0, 1).toDouble();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3A1746), Color(0xFF25252A)],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppPalette.muted)),
          const SizedBox(height: 5),
          Row(
            children: [
              Text(
                CoinTool.format(coins),
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: onWithdraw,
                child: const Text('Withdraw'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${(ratio * 100).toStringAsFixed(0)}% to minimum cashout',
                style: const TextStyle(fontSize: 12, color: AppPalette.muted),
              ),
              const Spacer(),
              Text(
                '\$${minimumAmount.toStringAsFixed(2)}',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: ratio,
            minHeight: 7,
            borderRadius: BorderRadius.circular(8),
            color: AppPalette.pink,
          ),
        ],
      ),
    );
  }
}

class _CheckInCard extends StatelessWidget {
  final int streak;
  final bool checked;
  final VoidCallback? onClaim;
  final String label;
  final List<int> rewards;
  const _CheckInCard({
    required this.streak,
    required this.checked,
    required this.onClaim,
    required this.label,
    required this.rewards,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppPalette.card,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Consecutive Check-in Rewards',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
            ),
            Text(
              '${streak.clamp(0, 7)}/7 days',
              style: const TextStyle(color: AppPalette.muted),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: List.generate(
            7,
            (i) => Expanded(
              child: Column(
                children: [
                  Text(
                    'Day ${i + 1}',
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppPalette.muted,
                    ),
                  ),
                  const SizedBox(height: 5),
                  CircleAvatar(
                    radius: 17,
                    backgroundColor: i < streak
                        ? const Color(0xFF5B562C)
                        : const Color(0xFF454349),
                    child: Icon(
                      i == 6 ? Icons.card_giftcard : Icons.payments_rounded,
                      size: 18,
                      color: AppPalette.yellow,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    CoinTool.format(rewards[i]),
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: onClaim,
            style: FilledButton.styleFrom(
              backgroundColor: checked ? Colors.white24 : Colors.white,
              foregroundColor: Colors.black,
            ),
            child: Text(checked ? 'Claimed' : label),
          ),
        ),
      ],
    ),
  );
}

class _TaskCard extends StatelessWidget {
  final String title;
  final int reward;
  final double ratio;
  final int progress;
  final int goal;
  final int multiplier;
  final EarningTaskType type;
  final bool claimed;
  final VoidCallback? onPressed;
  const _TaskCard({
    required this.title,
    required this.reward,
    required this.ratio,
    this.progress = 0,
    this.goal = 1,
    this.multiplier = 0,
    this.type = EarningTaskType.watchContent,
    this.claimed = false,
    this.onPressed,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppPalette.card,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF494627),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(switch (type) {
            EarningTaskType.watchAd => Icons.smart_display_rounded,
            EarningTaskType.notification => Icons.notifications_active,
            EarningTaskType.spin => Icons.casino,
            _ => Icons.ondemand_video_rounded,
          }, color: AppPalette.yellow),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '+${CoinTool.format(reward)} coins${multiplier > 0 ? ' · up to ${multiplier}x' : ''}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppPalette.yellow,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                '${progress.clamp(0, goal)}/$goal',
                style: const TextStyle(fontSize: 10, color: AppPalette.muted),
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: ratio,
                minHeight: 6,
                borderRadius: BorderRadius.circular(5),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppPalette.yellow,
            foregroundColor: Colors.black,
            minimumSize: const Size(64, 46),
          ),
          child: Text(
            claimed
                ? 'Done'
                : ratio >= 1
                ? 'Claim'
                : 'Go',
          ),
        ),
      ],
    ),
  );
}
