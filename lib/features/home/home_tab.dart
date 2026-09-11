import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:talevra/core/config/brand_provider.dart';
import 'package:talevra/l10n/app_localizations.dart';

/// 首页 tab：展示当前品牌码与默认语种，点击进入播放页占位。
class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final brand = ref.watch(brandCodeProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l.welcomeMessage(brand),
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l.currentLocale(locale.toString()),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => context.push('/player/demo-001'),
            child: const Text('▶'),
          ),
        ],
      ),
    );
  }
}
