import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/clarion_button.dart';
import '../../../core/widgets/tactile_card.dart';
import '../application/ownership_guard.dart';
import '../presentation/product_decision_screen.dart';

/// Shown before a duplicate or a near-duplicate of something already kept.
class OwnershipWarningCard extends StatelessWidget {
  const OwnershipWarningCard({super.key, required this.warning});

  final OwnershipWarning warning;

  @override
  Widget build(BuildContext context) {
    return TactileCard(
      tint: AppColors.amber,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ALREADY YOURS',
            style: AppTypography.overline.copyWith(color: AppColors.amber),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(warning.message, style: AppTypography.title),
          const SizedBox(height: AppSpacing.md),
          ClarionButton(
            label: 'Open what you own',
            tone: ButtonTone.secondary,
            onPressed: () =>
                ProductDecisionScreen.open(context, warning.owned.id),
          ),
        ],
      ),
    );
  }
}
