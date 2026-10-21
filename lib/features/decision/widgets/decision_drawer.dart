import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/catalog.dart';
import '../../../data/models/product_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/clarion_button.dart';
import '../../../core/widgets/frosted_chrome.dart';
import '../../../core/widgets/hold_button.dart';
import '../../../core/widgets/pressable.dart';
import '../../cart/application/budget_controller.dart';
import '../../cart/application/cart_controller.dart';
import '../../navigation/navigation_controller.dart';
import '../application/cooldown_controller.dart';
import '../presentation/product_decision_screen.dart';
import 'mindful_check_sheet.dart';

/// Friction-by-design action drawer pinned to the Decision screen.
///
/// Shows the live budget impact first, then two deliberate actions: adding
/// to the Intent Cart, or a press-and-hold 24h cooling-off period. It is
/// fixed chrome, so it may use real frosted glass.
class DecisionDrawer extends ConsumerStatefulWidget {
  const DecisionDrawer({super.key, required this.product});

  final Product product;

  @override
  ConsumerState<DecisionDrawer> createState() => _DecisionDrawerState();
}

class _DecisionDrawerState extends ConsumerState<DecisionDrawer> {
  bool _adding = false;

  Product get product => widget.product;

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _goToCart() {
    ref.read(navigationProvider.notifier).select(AppTab.cart);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _onAdd() async {
    if (ref.read(cartProvider.notifier).contains(product.id)) {
      _goToCart();
      return;
    }

    final budget = ref.read(budgetSnapshotProvider);
    if (budget.leftAfterWithCart(product.price) < 0) {
      final altId = product.alternativeId;
      final choice = await showMindfulCheckSheet(
        context: context,
        product: product,
        budget: budget,
        alternative: altId == null
            ? null
            : ref.read(catalogProvider).byId(altId),
      );
      if (!mounted || choice == null) return;
      switch (choice) {
        case MindfulChoice.coolOff:
          _coolOff();
          return;
        case MindfulChoice.alternative:
          ProductDecisionScreen.open(context, altId!, replace: true);
          return;
        case MindfulChoice.addAnyway:
          break;
      }
    }

    setState(() => _adding = true);
    // A brief, deliberate beat: the add registers as a decision, not a reflex.
    await Future<void>.delayed(const Duration(milliseconds: 480));
    if (!mounted) return;
    ref.read(cartProvider.notifier).add(product.id);
    ref.read(cooldownProvider.notifier).release(product.id);
    HapticFeedback.lightImpact();
    setState(() => _adding = false);

    final after = ref.read(budgetSnapshotProvider);
    _snack(
      after.isOver
          ? 'Added. The Guardian has a swap for the ${Fmt.inr(after.overBy)} overage.'
          : 'Added. ${Fmt.inr(after.headroom)} of headroom left this month.',
    );
  }

  void _coolOff() {
    ref.read(cooldownProvider.notifier).hold(product.id);
    _snack('Cooling off for 24h. If you still want it tomorrow, it’s here.');
  }

  void _release() {
    ref.read(cooldownProvider.notifier).release(product.id);
    _snack('Cooling-off period ended early.');
  }

  @override
  Widget build(BuildContext context) {
    final budget = ref.watch(budgetSnapshotProvider);
    final inCart = ref.watch(
      cartProvider.select((l) => l.any((x) => x.productId == product.id)),
    );
    final holdUntil = ref.watch(cooldownProvider.select((m) => m[product.id]));
    ref.watch(clockProvider); // refresh the countdown

    final bottom = MediaQuery.paddingOf(context).bottom;

    return FrostedChrome(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadii.xl),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.lg,
          AppSpacing.gutter,
          AppSpacing.md + bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _BudgetImpact(product: product, budget: budget, inCart: inCart),
            const SizedBox(height: AppSpacing.md + 2),
            Row(
              children: [
                Expanded(
                  child: holdUntil == null
                      ? HoldButton(
                          label: '24h Cooling Off',
                          onConfirmed: inCart ? null : _coolOff,
                        )
                      : _CoolingOffStatus(until: holdUntil, onEnd: _release),
                ),
                const SizedBox(width: AppSpacing.sm + 2),
                Expanded(
                  child: ClarionButton(
                    label: inCart ? 'View Intent Cart' : 'Add to Intent Cart',
                    tone: inCart ? ButtonTone.positive : ButtonTone.primary,
                    isLoading: _adding,
                    onPressed: _onAdd,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetImpact extends StatelessWidget {
  const _BudgetImpact({
    required this.product,
    required this.budget,
    required this.inCart,
  });

  final Product product;
  final BudgetSnapshot budget;
  final bool inCart;

  @override
  Widget build(BuildContext context) {
    final String lead;
    final double amount;
    final String tail;
    final Color color;
    String? note;
    Color noteColor = AppColors.textSecondary;

    if (inCart) {
      lead = budget.isOver ? 'Cart is ' : 'In your cart · ';
      amount = budget.isOver ? budget.overBy : budget.headroom;
      tail = budget.isOver ? ' over the ceiling' : ' headroom left';
      color = budget.isOver ? AppColors.rose : AppColors.emeraldGlow;
    } else {
      final alone = budget.leftAfter(product.price);
      final withCart = budget.leftAfterWithCart(product.price);
      final fits = alone >= 0;
      lead = fits ? 'Leaves ' : 'Exceeds your envelope by ';
      amount = alone.abs();
      tail = fits ? ' safe buffer in your monthly limit' : '';
      color = !fits
          ? AppColors.rose
          : alone < budget.limit * 0.1
          ? AppColors.amber
          : AppColors.emeraldGlow;
      if (fits && budget.cart > 0) {
        if (withCart < 0) {
          note =
              '${Fmt.inr(-withCart)} over once your ${Fmt.inr(budget.cart)} cart is included';
          noteColor = AppColors.amber;
        } else {
          note = '${Fmt.inr(withCart)} left including your cart';
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('BUDGET IMPACT', style: AppTypography.overline),
        const SizedBox(height: AppSpacing.xs + 2),
        Text.rich(
          TextSpan(
            text: lead,
            children: [
              TextSpan(
                text: Fmt.inr(amount),
                style: AppTypography.metric.copyWith(color: color),
              ),
              TextSpan(text: tail),
            ],
          ),
          style: AppTypography.titleSmall,
        ),
        if (note != null) ...[
          const SizedBox(height: 2),
          Text(note, style: AppTypography.caption.copyWith(color: noteColor)),
        ],
      ],
    );
  }
}

/// The cooling-off period in progress: a live countdown over a thin rose
/// timeline of the 24 hours. Tapping ends it early.
class _CoolingOffStatus extends StatelessWidget {
  const _CoolingOffStatus({required this.until, required this.onEnd});

  final DateTime until;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    final remaining = until.difference(DateTime.now());
    final elapsed =
        (1 - remaining.inSeconds / CooldownController.period.inSeconds).clamp(
          0.0,
          1.0,
        );
    const radius = AppRadii.mdAll;

    return Pressable(
      onTap: onEnd,
      semanticLabel:
          'Cooling off, ${Fmt.countdown(remaining)} left. Tap to end early.',
      child: CustomPaint(
        foregroundPainter: const RimLightPainter(borderRadius: radius),
        child: ClipRRect(
          borderRadius: radius,
          child: Container(
            height: 52,
            color: AppColors.rose.withValues(alpha: 0.08),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Cooling off · ${Fmt.countdown(remaining)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.metricSmall.copyWith(
                          color: AppColors.rose,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Tap to end early',
                        style: AppTypography.caption.copyWith(
                          fontSize: 10.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: LinearProgressIndicator(
                    value: elapsed,
                    minHeight: 2,
                    backgroundColor: AppColors.hairline,
                    color: AppColors.rose,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
