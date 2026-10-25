import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/chrome_header.dart';
import '../../../core/widgets/clarion_button.dart';
import '../../../core/widgets/dynamic_pill.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/catalog.dart';
import '../../../l10n/l10n.dart';
import '../application/compare_controller.dart';
import '../widgets/compare_matrix.dart';
import '../widgets/sticky_compare_header.dart';
import '../widgets/verdict_card.dart';
import 'product_decision_screen.dart';

/// Compare Matrix: a differential, side-by-side spec comparator.
///
/// The candidates stay pinned above the rows, only criteria that differ
/// are shown, and each row's winner is lit according to the priorities the
/// user stars — so the verdict is theirs, not the catalogue's.
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
    final pairs = ref.watch(catalogProvider).comparePairs;
    final state = ref.watch(compareProvider);
    final result = ref.watch(compareResultProvider);
    final controller = ref.read(compareProvider.notifier);
    final leader = switch (result.overall) {
      CompareWinner.left => result.left,
      CompareWinner.right => result.right,
      _ => null,
    };

    String labelFor(String key) {
      for (final row in result.rows) {
        if (row.key == key) return row.label;
      }
      return key;
    }

    Widget section(Widget child, {double top = AppSpacing.section}) =>
        SliverPadding(
          padding: AppSpacing.screenPadding.copyWith(top: top),
          sliver: SliverToBoxAdapter(child: child),
        );

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        ChromeSliverHeader(
          child: ScreenTitle(
            eyebrow: context.l10n.compareEyebrow,
            title: context.l10n.compareTitle,
          ),
        ),
        section(
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final (i, pair) in pairs.indexed)
                DynamicPill(
                  label: pair.label,
                  size: PillSize.regular,
                  color: AppColors.irisGlow,
                  selected: i == state.pairIndex,
                  onTap: () {
                    setState(() => _showIdentical = false);
                    controller.selectPair(i);
                  },
                ),
            ],
          ),
          top: AppSpacing.md,
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
        StickyCompareHeader(
          key: ValueKey(state.pairIndex),
          left: result.left,
          right: result.right,
          leader: leader,
        ),
        section(
          SectionHeader(
            eyebrow: context.l10n.comparePrioritiesEyebrow,
            title: context.l10n.comparePrioritiesTitle,
            caption: context.l10n.comparePrioritiesCaption,
          ),
          top: AppSpacing.xl,
        ),
        section(
          PriorityPicker(
            keys: state.pair.priorityKeys,
            selected: state.priorities,
            labelFor: labelFor,
            onToggle: controller.togglePriority,
          ),
          top: AppSpacing.md,
        ),
        section(VerdictCard(result: result), top: AppSpacing.lg),
        section(
          SectionHeader(
            eyebrow: context.l10n.compareDiffEyebrow,
            title: context.l10n.compareSpecMatrix,
            caption:
                '${result.differences.length} of ${result.rows.length} '
                'criteria differ',
          ),
        ),
        section(
          CompareMatrix(rows: result.differences, priorities: state.priorities),
          top: AppSpacing.md,
        ),
        if (result.identical.isNotEmpty)
          section(
            IdenticalSpecs(
              rows: result.identical,
              expanded: _showIdentical,
              onToggle: () => setState(() => _showIdentical = !_showIdentical),
            ),
            top: AppSpacing.sm,
          ),
        section(
          Row(
            children: [
              for (final (i, p) in [result.left, result.right].indexed) ...[
                if (i == 1) const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ClarionButton(
                    label: context.l10n.compareReview(p.brand),
                    tone: leader == p
                        ? ButtonTone.primary
                        : ButtonTone.secondary,
                    onPressed: () => ProductDecisionScreen.open(context, p.id),
                  ),
                ),
              ],
            ],
          ),
          top: AppSpacing.xl,
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: AppSpacing.navBarClearance(context) + AppSpacing.lg,
          ),
        ),
      ],
    );
  }
}
