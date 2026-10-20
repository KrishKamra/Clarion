import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/intent_input.dart';
import '../../../core/widgets/tactile_card.dart';
import '../application/compare_controller.dart';

/// "What matters most?" — starred criteria count double toward the verdict.
class PriorityPicker extends StatelessWidget {
  const PriorityPicker({
    super.key,
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
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final k in keys)
              IntentCapsule(
                label: '${selected.contains(k) ? '★' : '☆'}  ${labelFor(k)}',
                selected: selected.contains(k),
                onTap: () => onToggle(k),
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

/// The weighted outcome, as a split bar and one plain sentence.
class VerdictCard extends StatelessWidget {
  const VerdictCard({super.key, required this.result});

  final CompareResult result;

  static String _score(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final total = result.leftScore + result.rightScore;
    final leftShare = total == 0 ? 0.5 : result.leftScore / total;
    final winner = switch (result.overall) {
      CompareWinner.left => result.left,
      CompareWinner.right => result.right,
      _ => null,
    };
    final leftLeads = result.overall == CompareWinner.left;
    final rightLeads = result.overall == CompareWinner.right;

    return TactileCard(
      tint: winner == null ? AppColors.amber : AppColors.emerald,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('VERDICT', style: AppTypography.overline),
          const SizedBox(height: AppSpacing.xs),
          Text(
            winner == null
                ? 'Dead even on your priorities'
                : '${winner.brand} fits your priorities better',
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.lg),
          TweenAnimationBuilder<double>(
            tween: Tween(end: leftShare),
            duration: AppMotion.slow,
            curve: AppMotion.standard,
            builder: (context, share, _) => ClipRRect(
              borderRadius: AppRadii.pillAll,
              child: SizedBox(
                height: 4,
                child: Row(
                  children: [
                    Expanded(
                      flex: (share * 1000).round().clamp(1, 999),
                      child: ColoredBox(
                        color: leftLeads
                            ? AppColors.emeraldGlow
                            : AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      flex: ((1 - share) * 1000).round().clamp(1, 999),
                      child: ColoredBox(
                        color: rightLeads
                            ? AppColors.emeraldGlow
                            : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Text(
                '${result.left.brand} ${_score(result.leftScore)}',
                style: AppTypography.metricSmall,
              ),
              const Spacer(),
              Text(
                '${_score(result.rightScore)} ${result.right.brand}',
                style: AppTypography.metricSmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            winner == null
                ? 'Neither is objectively better for you. Choose on what '
                      'you’ll notice day to day.'
                : 'Weighted criterion wins. Price gap: '
                      '${Fmt.inr((result.left.price - result.right.price).abs())}.',
            style: AppTypography.bodySmall,
          ),
        ],
      ),
    );
  }
}
