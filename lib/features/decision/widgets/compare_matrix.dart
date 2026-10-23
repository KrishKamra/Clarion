import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/pressable.dart';
import '../../../core/widgets/tactile_card.dart';
import '../application/compare_controller.dart';

/// Differences-only matrix: one ruled row per differing criterion, the
/// winning value lit in emerald, starred priorities marked in amber.
class CompareMatrix extends StatelessWidget {
  const CompareMatrix({
    super.key,
    required this.rows,
    required this.priorities,
  });

  final List<CompareRow> rows;
  final Set<String> priorities;

  @override
  Widget build(BuildContext context) {
    return TactileCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          for (final (i, row) in rows.indexed) ...[
            if (i > 0) const Divider(),
            _MatrixRow(row: row, starred: priorities.contains(row.key)),
          ],
        ],
      ),
    );
  }
}

class _MatrixRow extends StatelessWidget {
  const _MatrixRow({required this.row, required this.starred});

  final CompareRow row;
  final bool starred;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md + 2),
      child: Row(
        children: [
          Expanded(
            child: _Value(
              value: row.left,
              wins: row.winner == CompareWinner.left,
              neutral: row.winner == CompareWinner.none,
              align: TextAlign.left,
            ),
          ),
          SizedBox(
            width: 112,
            child: Text(
              '${starred ? '★ ' : ''}${row.label}'.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 2,
              style: AppTypography.overline.copyWith(
                fontSize: 10.5,
                color: starred ? AppColors.amber : AppColors.textTertiary,
              ),
            ),
          ),
          Expanded(
            child: _Value(
              value: row.right,
              wins: row.winner == CompareWinner.right,
              neutral: row.winner == CompareWinner.none,
              align: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _Value extends StatelessWidget {
  const _Value({
    required this.value,
    required this.wins,
    required this.neutral,
    required this.align,
  });

  final String value;
  final bool wins;
  final bool neutral;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return AnimatedDefaultTextStyle(
      duration: AppMotion.medium,
      style: AppTypography.metric.copyWith(
        fontSize: 14,
        color: wins
            ? AppColors.emeraldGlow
            : neutral
            ? AppColors.textSecondary
            : AppColors.textPrimary,
      ),
      child: Text(
        value,
        textAlign: align,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Collapsible note listing the criteria on which both are identical.
class IdenticalSpecs extends StatelessWidget {
  const IdenticalSpecs({
    super.key,
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
                  child: Icon(
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
              ? Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Text(
                    rows.map((r) => '${r.label}: ${r.left}').join('   ·   '),
                    style: AppTypography.caption,
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
