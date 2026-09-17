import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talevra/app/theme/app_theme.dart';
import 'package:talevra/core/tool/coin_tool.dart';
import 'application/earning_controller.dart';
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
    Future.microtask(() => ref.read(earningControllerProvider.notifier).load());
  }

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
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 18),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l?.rewardsTab ?? 'Rewards',
                  style: const TextStyle(
                    fontSize: 26,
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
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CashoutCard(
                        coins: state.wallet?.coins ?? 0,
                        label: l?.availableBalance ?? 'Available balance',
                      ),
                      const SizedBox(height: 16),
                      _CheckInCard(
                        streak: state.checkIn.streak,
                        checked: state.checkIn.checkedToday,
                        onClaim: state.checkIn.checkedToday
                            ? null
                            : () => ref
                                  .read(earningControllerProvider.notifier)
                                  .performCheckIn(),
                        label: l?.checkIn ?? 'Claim',
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l?.tasks ?? 'Tasks',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...state.tasks.map(
                        (task) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _TaskCard(
                            title: task.title,
                            reward: task.reward,
                            ratio: task.ratio,
                            claimed: task.claimed,
                            onPressed: task.completed && !task.claimed
                                ? () => ref
                                      .read(earningControllerProvider.notifier)
                                      .collect(task)
                                : null,
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
                              .take(3)
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
  final String label;
  const _CashoutCard({required this.coins, required this.label});
  @override
  Widget build(BuildContext context) {
    final ratio = (coins / 100000).clamp(0, 1).toDouble();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3A1746), Color(0xFF25252A)],
        ),
        borderRadius: BorderRadius.circular(20),
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
              FilledButton(onPressed: () {}, child: const Text('Withdraw')),
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
              const Text(
                r'$0.10',
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
  const _CheckInCard({
    required this.streak,
    required this.checked,
    required this.onClaim,
    required this.label,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppPalette.card,
      borderRadius: BorderRadius.circular(20),
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
                    i == 6 ? '???' : '${500 + i * 300}',
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
  final bool claimed;
  final VoidCallback? onPressed;
  const _TaskCard({
    required this.title,
    required this.reward,
    required this.ratio,
    this.claimed = false,
    this.onPressed,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppPalette.card,
      borderRadius: BorderRadius.circular(20),
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
          child: const Icon(
            Icons.ondemand_video_rounded,
            color: AppPalette.yellow,
          ),
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
                '+${CoinTool.format(reward)} coins toward cashout',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppPalette.yellow,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 9),
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
