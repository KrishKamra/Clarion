import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/catalog.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/chrome_header.dart';
import '../../../core/widgets/clarion_button.dart';
import '../../../core/widgets/intent_input.dart';
import '../../../core/widgets/section_header.dart';
import '../application/compare_controller.dart';
import '../application/cooldown_controller.dart';
import '../widgets/compare_matrix.dart';
import '../widgets/head_to_head.dart';
import '../widgets/pending_hold_tile.dart';
import '../widgets/verdict_card.dart';
import 'product_decision_screen.dart';

/// Decision Node: everything still undecided — items cooling off, and
/// head-to-head comparisons that show only what differs.
class DecisionNodeScreen extends ConsumerStatefulWidget {
  const DecisionNodeScreen({super.key});

  @override
  ConsumerState<DecisionNodeScreen> createState() => _DecisionNodeState();
}

class _DecisionNodeState extends ConsumerState<DecisionNodeScreen> {
  bool _showIdentical = false;

  @override
  Widget build(BuildContext context) {
    final pairs = ref.watch(catalogProvider).comparePairs;
    final state = ref.watch(compareProvider);
    final result = ref.watch(compareResultProvider);
    final holds = ref.watch(cooldownProvider);
    ref.watch(clockProvider);
    final controller = ref.read(compareProvider.notifier);

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
        const ChromeSliverHeader(
          child: ScreenTitle(eyebrow: 'Decision node', title: 'Weigh it out'),
        ),
        if (holds.isNotEmpty) ...[
          section(
            const SectionHeader(
              label: 'Cooling off',
              caption: 'Parked for 24h. Decide once the urge has passed.',
            ),
            top: AppSpacing.lg,
          ),
          for (final entry in holds.entries)
            section(
              PendingHoldTile(productId: entry.key, until: entry.value),
              top: AppSpacing.md,
            ),
        ],
        section(
          const SectionHeader(
            label: 'Head to head',
            caption: 'Only the differences. Star what matters to you.',
          ),
          top: holds.isEmpty ? AppSpacing.lg : AppSpacing.section,
        ),
        section(
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final (i, pair) in pairs.indexed)
                IntentCapsule(
                  label: pair.label,
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
        section(
          AnimatedSwitcher(
            duration: AppMotion.medium,
            child: HeadToHead(key: ValueKey(state.pairIndex), result: result),
          ),
          top: AppSpacing.lg,
        ),
        section(
          PriorityPicker(
            keys: state.pair.priorityKeys,
            selected: state.priorities,
            labelFor: labelFor,
            onToggle: controller.togglePriority,
          ),
          top: AppSpacing.xl,
        ),
        section(VerdictCard(result: result), top: AppSpacing.lg),
        section(
          SectionHeader(
            label: 'What differs',
            caption:
                '${result.differences.length} of ${result.rows.length} criteria',
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
                    label: 'Review ${p.brand}',
                    tone: _leads(result, i)
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

  static bool _leads(CompareResult r, int side) =>
      (side == 0 && r.overall == CompareWinner.left) ||
      (side == 1 && r.overall == CompareWinner.right);
}
