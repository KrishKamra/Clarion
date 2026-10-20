import 'package:flutter/material.dart';

import '../../../core/models/product.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/fit_dial.dart';
import '../../../core/widgets/pressable.dart';
import '../../../core/widgets/product_artwork.dart';
import '../../../core/widgets/tactile_card.dart';
import '../application/compare_controller.dart';
import '../presentation/product_decision_screen.dart';

/// The two candidates side by side, divided by a hairline.
class HeadToHead extends StatelessWidget {
  const HeadToHead({super.key, required this.result});

  final CompareResult result;

  @override
  Widget build(BuildContext context) {
    return TactileCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _Candidate(
                product: result.left,
                leads: result.overall == CompareWinner.left,
              ),
            ),
            const VerticalDivider(width: AppSpacing.xl),
            Expanded(
              child: _Candidate(
                product: result.right,
                leads: result.overall == CompareWinner.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Candidate extends StatelessWidget {
  const _Candidate({required this.product, required this.leads});

  final Product product;
  final bool leads;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () => ProductDecisionScreen.open(context, product.id),
      semanticLabel: 'Open ${product.title}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.25,
            child: ProductArtwork(product: product, glyphScale: 0.4),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  product.brand.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.overline.copyWith(
                    color: leads ? AppColors.emeraldGlow : null,
                  ),
                ),
              ),
              FitDial(score: product.fitScore, size: 34, animate: false),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            product.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.label,
          ),
          const Spacer(),
          const SizedBox(height: AppSpacing.sm),
          Text(Fmt.inr(product.price), style: AppTypography.metric),
          if (leads) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Leads on your priorities',
              style: AppTypography.caption.copyWith(
                color: AppColors.emeraldGlow,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
