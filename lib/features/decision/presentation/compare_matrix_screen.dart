import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/mock_catalog.dart';
import '../../../core/models/product.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/fit_score_dial.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/glass_sliver_header.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/pressable.dart';
import '../../../core/widgets/product_thumbnail.dart';
import '../../../core/widgets/section_header.dart';
import '../application/compare_controller.dart';
import 'product_decision_screen.dart';

/// Differential side-by-side comparison.
///
/// Shows only what differs, marks the winner of each criterion, and lets the
/// user elevate priorities (counted double) to see how the verdict shifts.
class CompareMatrixScreen extends ConsumerStatefulWidget {
  const CompareMatrixScreen({super.key});

  @override
  ConsumerState<CompareMatrixScreen> createState() =>
      _CompareMatrixScreenState();
}

class _CompareMatrixScreenState extends ConsumerState<CompareMatrixScreen> {
  bool _showIdentical = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(compareProvider);
    final result = ref.watch(compareResultProvider);
    final controller = ref.read(compareProvider.notifier);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        GlassSliverHeader(
          child: Row(
            children: [
              Expanded(child: Text('Compare', style: AppTypography.title)),
              TagPill(
                label: 'Differences only',
                icon: Icons.filter_alt_outlined,
                color: AppColors.textSecondary,
                dense: true,
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: AppSpacing.screenPadding,
              itemCount: MockCatalog.comparePairs.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, i) => _SegmentPill(
                label: MockCatalog.comparePairs[i].label,
                selected: i == state.pairIndex,
                onTap: () {
                  setState(() => _showIdentical = false);
                  controller.selectPair(i);
                },
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: AppSpacing.screenPadding.copyWith(top: AppSpacing.lg),
          sliver: SliverToBoxAdapter(
            child: AnimatedSwitcher(
              duration: AppMotion.medium,
              child: _HeadToHead(
                key: ValueKey(state.pairIndex),
                result: result,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: AppSpacing.screenPadding.copyWith(top: AppSpacing.xxl),
          sliver: SliverToBoxAdapter(
            child: _PriorityPicker(
              keys: state.pair.priorityKeys,
              selected: state.priorities,
              labelFor: (k) => _labelFor(k, result),
              onToggle: controller.togglePriority,
            ),
          ),
        ),
        SliverPadding(
          padding: AppSpacing.screenPadding.copyWith(top: AppSpacing.lg),
          sliver: SliverToBoxAdapter(child: _VerdictCard(result: result)),
        ),
        SliverPadding(
          padding: AppSpacing.screenPadding.copyWith(
            top: AppSpacing.xxxl,
            bottom: AppSpacing.md,
          ),
          sliver: SliverToBoxAdapter(
            child: SectionHeader(
              title: "What's different",
              subtitle:
                  '${result.differences.length} of ${result.rows.length} criteria differ',
            ),
          ),
        ),
        SliverPadding(
          padding: AppSpacing.screenPadding,
          sliver: SliverList.separated(
            itemCount: result.differences.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, i) {
              final row = result.differences[i];
              return _DiffRow(
                row: row,
                prioritised: state.priorities.contains(row.key),
              );
            },
          ),
        ),
        if (result.identical.isNotEmpty)
          SliverPadding(
            padding: AppSpacing.screenPadding.copyWith(top: AppSpacing.md),
            sliver: SliverToBoxAdapter(
              child: _IdenticalSpecs(
                rows: result.identical,
                expanded: _showIdentical,
                onToggle: () =>
                    setState(() => _showIdentical = !_showIdentical),
              ),
            ),
          ),
        SliverPadding(
          padding: AppSpacing.screenPadding.copyWith(top: AppSpacing.xxl),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                for (final (i, p) in [result.left, result.right].indexed) ...[
                  if (i == 1) const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: GradientButton(
                      label: 'Review ${p.brand}',
                      variant: _isWinner(result, i)
                          ? GradientButtonVariant.primary
                          : GradientButtonVariant.glass,
                      horizontalPadding: AppSpacing.md,
                      onPressed: () =>
                          ProductDecisionScreen.open(context, p.id),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: AppSpacing.navBarClearance(context) + AppSpacing.lg,
          ),
        ),
      ],
    );
  }

  static bool _isWinner(CompareResult r, int side) =>
      (side == 0 && r.overall == CompareWinner.left) ||
      (side == 1 && r.overall == CompareWinner.right);

  static String _labelFor(String key, CompareResult result) {
    for (final row in result.rows) {
      if (row.key == key) return row.label;
    }
    return key;
  }
}

class _SegmentPill extends StatelessWidget {
  const _SegmentPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.medium,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: AppRadii.pillAll,
          gradient: selected ? AppColors.brandGradient : null,
          color: selected ? null : Colors.white.withValues(alpha: 0.05),
          border: Border.all(
            color: selected ? Colors.transparent : AppColors.glassBorderFaint,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.label.copyWith(
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _HeadToHead extends StatelessWidget {
  const _HeadToHead({super.key, required this.result});

  final CompareResult result;

  @override
  Widget build(BuildContext context) {
    return GlassContainer.card(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: AppRadii.xl,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _Candidate(
                product: result.left,
                winner: result.overall == CompareWinner.left,
              ),
            ),
            SizedBox(
              width: 28,
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Container(width: 1, color: AppColors.hairline),
                    ),
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surfaceHigh,
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Text(
                      'VS',
                      style: AppTypography.overline.copyWith(
                        fontSize: 9,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Container(width: 1, color: AppColors.hairline),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _Candidate(
                product: result.right,
                winner: result.overall == CompareWinner.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Candidate extends StatelessWidget {
  const _Candidate({required this.product, required this.winner});

  final Product product;
  final bool winner;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () => ProductDecisionScreen.open(context, product.id),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Column(
          children: [
            SizedBox(
              height: 112,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: ProductThumbnail(
                      product: product,
                      borderRadius: AppRadii.lg,
                    ),
                  ),
                  Positioned(
                    right: -4,
                    bottom: -10,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.backgroundDeep,
                      ),
                      child: FitScoreDial(
                        score: product.fitScore,
                        size: 46,
                        showLabel: false,
                      ),
                    ),
                  ),
                  if (winner)
                    const Positioned(
                      top: AppSpacing.sm,
                      left: AppSpacing.sm,
                      child: TagPill(
                        label: 'Best for you',
                        icon: Icons.workspace_premium_rounded,
                        color: AppColors.fitHigh,
                        filled: true,
                        dense: true,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(product.brand.toUpperCase(), style: AppTypography.overline),
            const SizedBox(height: 3),
            Text(
              product.title,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(Fmt.inr(product.price), style: AppTypography.numeric),
          ],
        ),
      ),
    );
  }
}

class _PriorityPicker extends StatelessWidget {
  const _PriorityPicker({
    required this.keys,
    required this.selected,
    required this.labelFor,
    required this.onToggle,
  });

  final List<String> keys;
  final Set<String> selected;
  final String Function(String) labelFor;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('WHAT MATTERS MOST?', style: AppTypography.overline),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final k in keys)
              Pressable(
                onTap: () => onToggle(k),
                child: AnimatedContainer(
                  duration: AppMotion.medium,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: AppRadii.pillAll,
                    color: selected.contains(k)
                        ? AppColors.fitMid.withValues(alpha: 0.16)
                        : Colors.white.withValues(alpha: 0.04),
                    border: Border.all(
                      color: selected.contains(k)
                          ? AppColors.fitMid.withValues(alpha: 0.6)
                          : AppColors.glassBorderFaint,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        selected.contains(k)
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 15,
                        color: selected.contains(k)
                            ? AppColors.fitMid
                            : AppColors.textTertiary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        labelFor(k),
                        style: AppTypography.label.copyWith(
                          color: selected.contains(k)
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Starred criteria count double toward the verdict.',
          style: AppTypography.caption,
        ),
      ],
    );
  }
}

class _VerdictCard extends StatelessWidget {
  const _VerdictCard({required this.result});

  final CompareResult result;

  @override
  Widget build(BuildContext context) {
    final total = result.leftScore + result.rightScore;
    final leftShare = total == 0 ? 0.5 : result.leftScore / total;
    final winner = switch (result.overall) {
      CompareWinner.left => result.left,
      CompareWinner.right => result.right,
      _ => null,
    };

    String fmt(double v) =>
        v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

    return GlassContainer.card(
      tint: winner == null ? AppColors.fitMid : AppColors.fitHigh,
      opacity: 0.06,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                winner == null ? Icons.balance_rounded : Icons.verified_rounded,
                color: winner == null ? AppColors.fitMid : AppColors.fitHigh,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  winner == null
                      ? 'Dead even on your priorities'
                      : '${winner.brand} wins on your priorities',
                  style: AppTypography.titleSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TweenAnimationBuilder<double>(
            tween: Tween(end: leftShare),
            duration: AppMotion.slow,
            curve: AppMotion.standard,
            builder: (context, share, _) => ClipRRect(
              borderRadius: AppRadii.pillAll,
              child: SizedBox(
                height: 8,
                child: Row(
                  children: [
                    Expanded(
                      flex: (share * 1000).round().clamp(1, 999),
                      child: Container(color: AppColors.primary),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      flex: ((1 - share) * 1000).round().clamp(1, 999),
                      child: Container(color: AppColors.accent),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _Legend(
                color: AppColors.primary,
                label: '${result.left.brand} · ${fmt(result.leftScore)}',
              ),
              const Spacer(),
              _Legend(
                color: AppColors.accent,
                label: '${result.right.brand} · ${fmt(result.rightScore)}',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            winner == null
                ? 'Neither option is objectively better for you. Pick on what you\'ll notice day to day.'
                : 'Weighted criterion wins. Price difference: ${Fmt.inr((result.left.price - result.right.price).abs())}.',
            style: AppTypography.bodySmall.copyWith(fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.caption.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

class _DiffRow extends StatelessWidget {
  const _DiffRow({required this.row, required this.prioritised});

  final CompareRow row;
  final bool prioritised;

  @override
  Widget build(BuildContext context) {
    return GlassContainer.card(
      borderRadius: AppRadii.md,
      opacity: prioritised ? 0.07 : 0.045,
      tint: prioritised ? AppColors.fitMid : null,
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (prioritised) ...[
                  const Icon(
                    Icons.star_rounded,
                    size: 13,
                    color: AppColors.fitMid,
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  row.label.toUpperCase(),
                  style: AppTypography.overline.copyWith(
                    color: prioritised
                        ? AppColors.fitMid
                        : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _Cell(
                  value: row.left,
                  wins: row.winner == CompareWinner.left,
                  neutral: row.winner == CompareWinner.none,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _Cell(
                  value: row.right,
                  wins: row.winner == CompareWinner.right,
                  neutral: row.winner == CompareWinner.none,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.value, required this.wins, required this.neutral});

  final String value;
  final bool wins;
  final bool neutral;

  @override
  Widget build(BuildContext context) {
    final color = wins ? AppColors.fitHigh : AppColors.textPrimary;
    return AnimatedContainer(
      duration: AppMotion.medium,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: AppRadii.smAll,
        color: wins
            ? AppColors.fitHigh.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.025),
        border: Border.all(
          color: wins
              ? AppColors.fitHigh.withValues(alpha: 0.4)
              : Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (wins) ...[
            const Icon(
              Icons.check_circle_rounded,
              size: 15,
              color: AppColors.fitHigh,
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.numericSmall.copyWith(
                fontSize: 14,
                color: neutral ? AppColors.textSecondary : color,
                fontWeight: wins ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IdenticalSpecs extends StatelessWidget {
  const _IdenticalSpecs({
    required this.rows,
    required this.expanded,
    required this.onToggle,
  });

  final List<CompareRow> rows;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Pressable(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              children: [
                const Icon(
                  Icons.drag_handle_rounded,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Identical on ${rows.length} ${rows.length == 1 ? 'spec' : 'specs'}',
                  style: AppTypography.label.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: AppMotion.medium,
                  child: const Icon(
                    Icons.expand_more_rounded,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: AppMotion.medium,
          curve: AppMotion.standard,
          child: expanded
              ? Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final r in rows)
                      TagPill(
                        label: '${r.label}: ${r.left}',
                        color: AppColors.textSecondary,
                      ),
                  ],
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
