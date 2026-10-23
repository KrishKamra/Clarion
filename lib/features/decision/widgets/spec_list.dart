import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/pressable.dart';
import '../../../data/models/product_model.dart';

/// Specifications as a ruled two-column list behind progressive disclosure:
/// the [preview] most decision-relevant rows are visible, the rest open on
/// an intentional tap. Rows align on a shared baseline, separated by
/// hairlines rather than boxes.
class SpecList extends StatefulWidget {
  const SpecList({super.key, required this.specs, this.preview = 3});

  final List<ProductSpec> specs;
  final int preview;

  @override
  State<SpecList> createState() => _SpecListState();
}

class _SpecListState extends State<SpecList> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final specs = widget.specs;
    final hidden = specs.length - widget.preview;
    final visible = _expanded || hidden <= 0
        ? specs
        : specs.take(widget.preview).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedSize(
          duration: AppMotion.slow,
          curve: AppMotion.standard,
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              for (final (i, spec) in visible.indexed) ...[
                if (i > 0) const Divider(),
                _Row(spec: spec),
              ],
            ],
          ),
        ),
        if (hidden > 0) ...[
          const Divider(),
          Pressable(
            onTap: () => setState(() => _expanded = !_expanded),
            semanticLabel: _expanded
                ? 'Show fewer specifications'
                : 'Show all specifications',
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Row(
                children: [
                  Text(
                    _expanded
                        ? 'Show fewer'
                        : 'Show all ${specs.length} specifications',
                    style: AppTypography.label.copyWith(
                      color: AppColors.irisGlow,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: AppMotion.medium,
                    curve: AppMotion.standard,
                    child: Icon(
                      Icons.expand_more_rounded,
                      size: 18,
                      color: AppColors.irisGlow,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.spec});

  final ProductSpec spec;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(child: Text(spec.label, style: AppTypography.bodySmall)),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(
              spec.display,
              textAlign: TextAlign.right,
              style: AppTypography.metricSmall,
            ),
          ),
        ],
      ),
    );
  }
}
