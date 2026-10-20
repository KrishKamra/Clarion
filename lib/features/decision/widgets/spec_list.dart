import 'package:flutter/material.dart';

import '../../../core/models/product.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Specifications as a ruled two-column list — aligned on a shared baseline
/// and separated by hairlines rather than boxes.
class SpecList extends StatelessWidget {
  const SpecList({super.key, required this.specs});

  final List<ProductSpec> specs;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final (i, spec) in specs.indexed) ...[
          if (i > 0) const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(spec.label, style: AppTypography.bodySmall),
                ),
                Text(spec.display, style: AppTypography.metricSmall),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
