import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/clarion_button.dart';
import '../../../../core/widgets/product_artwork.dart';
import '../../../../core/widgets/tactile_card.dart';
import '../../../cart/application/budget_controller.dart';
import '../../application/cart_controller.dart';

/// Guardian Swap Engine: appears only when the cart breaches the ceiling,
/// and offers verified, cheaper equivalents with their spec parity shown —
/// an observation, not an alarm.
class GuardianSwapCard extends StatelessWidget {
  const GuardianSwapCard({
    super.key,
    required this.budget,
    required this.suggestions,
    required this.onSwap,
    required this.onCompare,
  });

  final BudgetSnapshot budget;
  final List<SwapSuggestion> suggestions;
  final ValueChanged<SwapSuggestion> onSwap;
  final ValueChanged<SwapSuggestion> onCompare;

  @override
  Widget build(BuildContext context) {
    return TactileCard(
      tint: AppColors.rose,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'GUARDIAN SWAP ENGINE',
            style: AppTypography.overline.copyWith(color: AppColors.rose),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${Fmt.inr(budget.overBy)} over monthly limit.',
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            suggestions.isEmpty
                ? 'No verified equivalents for these items. Consider a 24h '
                      'cooling-off period for the least essential one.'
                : 'Swap option available.',
            style: AppTypography.bodySmall,
          ),
          for (final s in suggestions.take(2)) ...[
            const SizedBox(height: AppSpacing.lg),
            const Divider(),
            const SizedBox(height: AppSpacing.lg),
            _Suggestion(
              suggestion: s,
              remainingOver: budget.overBy - s.savings,
              onSwap: () => onSwap(s),
              onCompare: () => onCompare(s),
            ),
          ],
        ],
      ),
    );
  }
}

class _Suggestion extends StatelessWidget {
  const _Suggestion({
    required this.suggestion,
    required this.remainingOver,
    required this.onSwap,
    required this.onCompare,
  });

  final SwapSuggestion suggestion;
  final double remainingOver;
  final VoidCallback onSwap;
  final VoidCallback onCompare;

  @override
  Widget build(BuildContext context) {
    final s = suggestion;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            ProductArtwork(product: s.from, size: 44),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: AppColors.textTertiary,
              ),
            ),
            ProductArtwork(product: s.to, size: 44),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${s.to.brand} ${s.to.title}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.label,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'instead of ${s.from.brand} · ${Fmt.inr(s.from.price)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            _Figure('Saves', Fmt.inr(s.savings), AppColors.emeraldGlow),
            _Figure('Spec parity', '${s.parity}%', AppColors.textPrimary),
            _Figure(
              'After swap',
              remainingOver <= 0
                  ? '${Fmt.inr(-remainingOver)} left'
                  : '${Fmt.inr(remainingOver)} over',
              remainingOver <= 0 ? AppColors.emeraldGlow : AppColors.amber,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'Swap '),
              _strong('${s.from.title} (${Fmt.inr(s.from.price)})'),
              const TextSpan(text: ' with '),
              _strong('${s.to.title} (${Fmt.inr(s.to.price)})'),
              TextSpan(
                text:
                    ' to regain ${Fmt.inr(s.savings)} with ${s.parity}% spec parity.',
              ),
            ],
          ),
          style: AppTypography.bodySmall,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: ClarionButton(
                label: 'Swap · regain ${Fmt.inr(s.savings)}',
                tone: ButtonTone.positive,
                height: 46,
                onPressed: onSwap,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              flex: 2,
              child: ClarionButton(
                label: 'Compare',
                tone: ButtonTone.secondary,
                height: 46,
                onPressed: onCompare,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure(this.label, this.value, this.color);

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppTypography.overline),
          const SizedBox(height: 3),
          Text(value, style: AppTypography.metricSmall.copyWith(color: color)),
        ],
      ),
    );
  }
}

TextSpan _strong(String text) => TextSpan(
  text: text,
  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
);
