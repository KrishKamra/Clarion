import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/mock_catalog.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/glass_sheet.dart';
import '../../../core/widgets/glass_sliver_header.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/pressable.dart';
import '../../../core/widgets/product_thumbnail.dart';
import '../../../core/widgets/progress_ring.dart';
import '../../../core/widgets/section_header.dart';
import '../../budget/application/budget_controller.dart';
import '../../cart/application/cart_controller.dart';
import '../../decision/application/cooldown_controller.dart';
import '../../decision/presentation/product_decision_screen.dart';

/// Profile & spending analytics: the envelope, mindful wins, trends and
/// items currently cooling off.
class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budget = ref.watch(budgetProvider);
    final snapshot = ref.watch(budgetSnapshotProvider);
    final holds = ref.watch(cooldownProvider);
    ref.watch(clockProvider);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        GlassSliverHeader(
          child: Row(
            children: [
              Expanded(child: Text('Insights', style: AppTypography.title)),
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.brandGradient,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        SliverPadding(
          padding: AppSpacing.screenPadding.copyWith(top: AppSpacing.sm),
          sliver: SliverList.list(
            children: [
              _EnvelopeCard(
                snapshot: snapshot,
                onEditLimit: () =>
                    _editLimit(context, ref, budget.monthlyLimit),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      icon: Icons.block_rounded,
                      color: AppColors.secondary,
                      value: '${budget.impulseBuysAvoided}',
                      label: 'Impulse buys avoided',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _StatTile(
                      icon: Icons.savings_rounded,
                      color: AppColors.fitHigh,
                      value: Fmt.inrCompact(budget.savedViaCooldown),
                      label: 'Saved via cooldowns',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxxl),
              const SectionHeader(
                title: 'Six-month trend',
                subtitle: 'Settled spend vs your monthly limit',
              ),
              const SizedBox(height: AppSpacing.md),
              _TrendChart(
                history: [...budget.monthlyHistory, budget.spentThisMonth],
                limit: budget.monthlyLimit,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              const SectionHeader(
                title: 'Where it went',
                subtitle: 'This month by category',
              ),
              const SizedBox(height: AppSpacing.md),
              _CategoryBreakdown(budget: budget),
              const SizedBox(height: AppSpacing.xxxl),
              SectionHeader(
                title: 'Cooling off',
                subtitle: holds.isEmpty
                    ? 'Nothing on hold right now'
                    : 'Items parked with Hold to Think',
              ),
              const SizedBox(height: AppSpacing.md),
              for (final entry in holds.entries) ...[
                _HoldTile(productId: entry.key, until: entry.value),
                const SizedBox(height: AppSpacing.md),
              ],
              SizedBox(height: AppSpacing.navBarClearance(context)),
            ],
          ),
        ),
      ],
    );
  }

  void _editLimit(BuildContext context, WidgetRef ref, double current) {
    var value = current;
    showGlassSheet<void>(
      context: context,
      title: 'Monthly limit',
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Set the envelope Clarion protects. Changes apply from today.',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: AppSpacing.xl),
            Center(
              child: Text(Fmt.inr(value), style: AppTypography.numericLarge),
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                thumbColor: Colors.white,
                overlayColor: AppColors.primary.withValues(alpha: 0.2),
              ),
              child: Slider(
                value: value,
                min: 2000,
                max: 20000,
                divisions: 36,
                label: Fmt.inr(value),
                onChanged: (v) => setState(() => value = v),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            GradientButton(
              label: 'Save limit',
              onPressed: () {
                ref.read(budgetProvider.notifier).setMonthlyLimit(value);
                Navigator.of(sheetContext).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EnvelopeCard extends StatelessWidget {
  const _EnvelopeCard({required this.snapshot, required this.onEditLimit});

  final BudgetSnapshot snapshot;
  final VoidCallback onEditLimit;

  @override
  Widget build(BuildContext context) {
    final s = snapshot;
    final settledRatio = s.spent / s.limit;
    final color = AppColors.forBudgetRatio(s.ratio);

    return GlassContainer.card(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppRadii.xl,
      child: Row(
        children: [
          SizedBox.square(
            dimension: 116,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer ring: committed (incl. cart). Inner: settled only.
                ProgressRing(
                  value: s.ratio,
                  color: color,
                  size: 116,
                  strokeWidth: 9,
                ),
                ProgressRing(
                  value: settledRatio,
                  color: AppColors.primary,
                  size: 88,
                  strokeWidth: 6,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      Fmt.percent(s.ratio * 100),
                      style: AppTypography.numeric.copyWith(color: color),
                    ),
                    Text(
                      'committed',
                      style: AppTypography.caption.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Pressable(
                  onTap: onEditLimit,
                  child: Row(
                    children: [
                      Text('MONTHLY LIMIT', style: AppTypography.overline),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.edit_rounded,
                        size: 12,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  Fmt.inr(s.limit),
                  style: AppTypography.numericLarge.copyWith(fontSize: 26),
                ),
                const SizedBox(height: AppSpacing.md),
                _Legend(
                  color: AppColors.primary,
                  label: 'Settled',
                  value: Fmt.inr(s.spent),
                ),
                const SizedBox(height: 4),
                _Legend(
                  color: color,
                  label: 'With cart',
                  value: Fmt.inr(s.committed),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Expanded(child: Text(label, style: AppTypography.caption)),
        Text(value, style: AppTypography.numericSmall),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GlassContainer.card(
      tint: color,
      opacity: 0.06,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: AppSpacing.md),
          Text(value, style: AppTypography.numericLarge.copyWith(fontSize: 26)),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.caption),
        ],
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.history, required this.limit});

  final List<double> history;
  final double limit;

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final peak = math.max(history.reduce(math.max), limit) * 1.1;
    const chartH = 120.0;

    return GlassContainer.card(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: SizedBox(
        height: chartH + 36,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: chartH * (1 - limit / peak),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Limit',
                    style: AppTypography.caption.copyWith(fontSize: 10),
                  ),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < history.length; i++)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          Fmt.inrCompact(history[i]),
                          style: AppTypography.caption.copyWith(fontSize: 9.5),
                        ),
                        const SizedBox(height: 4),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: history[i] / peak),
                          duration: Duration(milliseconds: 600 + i * 90),
                          curve: AppMotion.emphasized,
                          builder: (context, t, _) => Container(
                            width: 22,
                            height: math.max(4, (chartH - 18) * t),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                                bottom: Radius.circular(3),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: history[i] > limit
                                    ? [
                                        AppColors.fitLow,
                                        AppColors.fitLow.withValues(alpha: 0.3),
                                      ]
                                    : i == history.length - 1
                                    ? [
                                        AppColors.accent,
                                        AppColors.primary.withValues(
                                          alpha: 0.3,
                                        ),
                                      ]
                                    : [
                                        AppColors.primary,
                                        AppColors.primary.withValues(
                                          alpha: 0.2,
                                        ),
                                      ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _months[(now.month - history.length + i) % 12],
                          style: AppTypography.caption.copyWith(
                            fontSize: 10.5,
                            color: i == history.length - 1
                                ? AppColors.textPrimary
                                : AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBreakdown extends StatelessWidget {
  const _CategoryBreakdown({required this.budget});

  final BudgetState budget;

  static const _colors = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.accent,
    AppColors.fitHigh,
  ];

  @override
  Widget build(BuildContext context) {
    final total = math.max(budget.spentThisMonth, 1.0);
    return GlassContainer.card(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          for (final (i, c) in budget.categories.indexed)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : AppSpacing.md),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(c.label, style: AppTypography.label),
                      ),
                      Text(
                        Fmt.inr(c.amount),
                        style: AppTypography.numericSmall,
                      ),
                      SizedBox(
                        width: 44,
                        child: Text(
                          Fmt.percent(c.amount / total * 100),
                          textAlign: TextAlign.right,
                          style: AppTypography.caption,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: AppRadii.pillAll,
                    child: LinearProgressIndicator(
                      value: c.amount / total,
                      minHeight: 6,
                      backgroundColor: Colors.white.withValues(alpha: 0.06),
                      color: _colors[i % _colors.length],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _HoldTile extends ConsumerWidget {
  const _HoldTile({required this.productId, required this.until});

  final String productId;
  final DateTime until;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = MockCatalog.byId(productId);
    final remaining = until.difference(DateTime.now());
    final elapsed =
        1 - remaining.inSeconds / CooldownController.period.inSeconds;

    void snack(String m) => ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(m)));

    return GlassContainer.card(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: () => ProductDecisionScreen.open(context, productId),
      child: Column(
        children: [
          Row(
            children: [
              ProductThumbnail(product: product, size: 56),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.label,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${Fmt.inr(product.price)} · ${remaining.isNegative ? 'Ready to decide' : '${Fmt.countdown(remaining)} left'}',
                      style: AppTypography.caption,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ClipRRect(
                      borderRadius: AppRadii.pillAll,
                      child: LinearProgressIndicator(
                        value: elapsed.clamp(0.0, 1.0),
                        minHeight: 4,
                        backgroundColor: Colors.white.withValues(alpha: 0.06),
                        color: AppColors.fitMid,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: GradientButton(
                  label: 'Let it go',
                  height: 42,
                  variant: GradientButtonVariant.glass,
                  horizontalPadding: AppSpacing.sm,
                  onPressed: () {
                    ref.read(cooldownProvider.notifier).release(productId);
                    ref
                        .read(budgetProvider.notifier)
                        .recordImpulseAvoided(product.price);
                    snack(
                      'Nice. ${Fmt.inr(product.price)} stays in your envelope.',
                    );
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: GradientButton(
                  label: 'Still want it',
                  height: 42,
                  horizontalPadding: AppSpacing.sm,
                  onPressed: () {
                    ref.read(cooldownProvider.notifier).release(productId);
                    ref.read(cartProvider.notifier).add(productId);
                    snack('Moved to your Intent Cart.');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
