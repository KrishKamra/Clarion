import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/catalog.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/clarion_sheet.dart';
import '../../../../core/widgets/pressable.dart';
import '../../../budget/application/budget_controller.dart';
import '../../../budget/presentation/ceiling_sheet.dart';
import '../../../decision/application/cooldown_controller.dart';
import '../../../decision/presentation/product_decision_screen.dart';
import '../../../navigation/navigation_controller.dart';

/// Profile access: the envelope at a glance, plus the quiet signals Clarion
/// is tracking (price memory, items cooling off).
Future<void> showProfileSheet(BuildContext context) {
  return showClarionSheet<void>(
    context: context,
    eyebrow: 'Profile',
    title: 'Your envelope',
    builder: (_) => const _ProfileSheet(),
  );
}

class _ProfileSheet extends ConsumerWidget {
  const _ProfileSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budget = ref.watch(budgetProvider);
    final holds = ref.watch(cooldownProvider);
    final catalog = ref.watch(catalogProvider);
    final drop = catalog.priceMemoryPick;
    final navigator = Navigator.of(context);
    final rootContext = navigator.context;

    void goTo(AppTab tab) {
      ref.read(navigationProvider.notifier).select(tab);
      navigator.pop();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Row(
          label: 'Monthly ceiling',
          value: Fmt.inr(budget.monthlyLimit),
          trailing: 'Edit',
          onTap: () {
            navigator.pop();
            showCeilingSheet(rootContext);
          },
        ),
        _Row(
          label: 'Settled this month',
          value: Fmt.inr(budget.spentThisMonth),
          trailing: 'Memory',
          onTap: () => goTo(AppTab.memory),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('SIGNALS', style: AppTypography.overline),
        const SizedBox(height: AppSpacing.sm),
        _Signal(
          color: AppColors.emeraldGlow,
          title: 'Price memory · ${drop.title}',
          body:
              '${Fmt.percent(drop.discountVsAverage * 100)} below its 30-day '
              'average. No rush — Clarion keeps watching.',
          onTap: () {
            navigator.pop();
            ProductDecisionScreen.open(rootContext, drop.id);
          },
        ),
        for (final entry in holds.entries)
          _Signal(
            color: AppColors.amber,
            title: 'Cooling off · ${catalog.byId(entry.key).title}',
            body:
                '${Fmt.countdown(entry.value.difference(DateTime.now()))} '
                'before you decide.',
            onTap: () => goTo(AppTab.decisions),
          ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    required this.trailing,
    required this.onTap,
  });

  final String label;
  final String value;
  final String trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md + 2),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.hairline)),
        ),
        child: Row(
          children: [
            Expanded(child: Text(label, style: AppTypography.bodySmall)),
            Text(value, style: AppTypography.metric),
            const SizedBox(width: AppSpacing.md),
            Text(
              trailing,
              style: AppTypography.label.copyWith(color: AppColors.irisGlow),
            ),
          ],
        ),
      ),
    );
  }
}

class _Signal extends StatelessWidget {
  const _Signal({
    required this.color,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final Color color;
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 6),
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label,
                  ),
                  const SizedBox(height: 2),
                  Text(body, style: AppTypography.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
