import 'package:flutter/material.dart';

import '../../../core/models/product.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Two-column grid of key specifications.
class SpecGrid extends StatelessWidget {
  const SpecGrid({super.key, required this.specs});

  final List<ProductSpec> specs;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = (constraints.maxWidth - AppSpacing.sm) / 2;
        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final spec in specs)
              Container(
                width: tileWidth,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.035),
                  borderRadius: AppRadii.mdAll,
                  border: Border.all(color: AppColors.hairline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(spec.label, style: AppTypography.caption),
                    const SizedBox(height: 4),
                    Text(
                      spec.display,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleSmall.copyWith(fontSize: 15),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
