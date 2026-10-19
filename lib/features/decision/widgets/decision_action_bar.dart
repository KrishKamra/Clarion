import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/mock_catalog.dart';
import '../../../core/models/product.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_glass.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../budget/application/budget_controller.dart';
import '../../cart/application/cart_controller.dart';
import '../../navigation/navigation_controller.dart';
import '../application/cooldown_controller.dart';
import '../presentation/product_decision_screen.dart';
import 'mindful_check_sheet.dart';

/// Sticky, true-glass decision bar: budget impact + Add / Hold actions.
class DecisionActionBar extends ConsumerStatefulWidget {
  const DecisionActionBar({super.key, required this.product});

  final Product product;

  @override
  ConsumerState<DecisionActionBar> createState() => _DecisionActionBarState();
}

class _DecisionActionBarState extends ConsumerState<DecisionActionBar> {
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
    if (budget.committed + product.price > budget.limit) {
      final altId = product.alternativeId;
      final choice = await showMindfulCheckSheet(
        context: context,
        product: product,
        budget: budget,
        alternative: altId == null ? null : MockCatalog.byId(altId),
      );
      if (!mounted || choice == null) return;
      switch (choice) {
        case MindfulChoice.hold:
          _hold();
          return;
        case MindfulChoice.alternative:
          ProductDecisionScreen.open(context, altId!, replace: true);
          return;
        case MindfulChoice.addAnyway:
          break;
      }
    }

    setState(() => _adding = true);
    // Brief, deliberate beat: confirms the action without feeling instant
    // and impulsive.
    await Future<void>.delayed(const Duration(milliseconds: 550));
    if (!mounted) return;
    ref.read(cartProvider.notifier).add(product.id);
    ref.read(cooldownProvider.notifier).release(product.id);
    HapticFeedback.lightImpact();
    setState(() => _adding = false);

    final after = ref.read(budgetSnapshotProvider);
    _snack(
      after.isOver
          ? 'Added. Your cart is now ${Fmt.inr(after.overBy)} over budget.'
          : 'Added. ${Fmt.inr(after.headroom)} of headroom left this month.',
    );
  }

  void _hold() {
    final cooldown = ref.read(cooldownProvider.notifier);
    if (cooldown.isHeld(product.id)) {
      cooldown.release(product.id);
      _snack('Hold released.');
      return;
    }
    cooldown.hold(product.id);
    HapticFeedback.mediumImpact();
    _snack('Parked for 24 h. Still want it tomorrow? It\'ll be right here.');
  }

  @override
  Widget build(BuildContext context) {
    final budget = ref.watch(budgetSnapshotProvider);
    final inCart = ref.watch(
      cartProvider.select(
        (lines) => lines.any((l) => l.productId == product.id),
      ),
    );
    final holdUntil = ref.watch(cooldownProvider.select((m) => m[product.id]));
    ref.watch(clockProvider); // refresh countdown

    final left = budget.leftAfter(product.price);
    final fitsEnvelope = left >= 0;
    final withCartOver = budget.committed + product.price - budget.limit;
    final impactColor = !fitsEnvelope
        ? AppColors.fitLow
        : (left < budget.limit * 0.15 ? AppColors.fitMid : AppColors.fitHigh);

    final String headline;
    final String? caption;
    if (inCart) {
      headline = 'In your Intent Cart';
      caption = budget.isOver
          ? 'Cart is ${Fmt.inr(budget.overBy)} over — Budget Guardian has ideas.'
          : '${Fmt.inr(budget.headroom)} headroom remaining this month.';
    } else {
      headline = fitsEnvelope
          ? 'Leaves ${Fmt.inr(left)} in your monthly envelope'
          : 'Exceeds your envelope by ${Fmt.inr(-left)}';
      caption = budget.cart > 0 && withCartOver > 0
          ? 'With your current cart (${Fmt.inr(budget.cart)}) you\'d be ${Fmt.inr(withCartOver)} over.'
          : null;
    }

    final bottom = MediaQuery.paddingOf(context).bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadii.xl),
      ),
      child: BackdropFilter(
        filter: AppGlass.blur(24),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            AppSpacing.lg,
            AppSpacing.gutter,
            AppSpacing.md + bottom,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.72),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadii.xl),
            ),
            border: const Border(top: BorderSide(color: AppColors.glassBorder)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    inCart
                        ? Icons.check_circle_rounded
                        : Icons.account_balance_wallet_rounded,
                    size: 18,
                    color: inCart ? AppColors.fitHigh : impactColor,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      headline,
                      style: AppTypography.label.copyWith(
                        color: inCart ? AppColors.textPrimary : impactColor,
                      ),
                    ),
                  ),
                ],
              ),
              if (caption != null) ...[
                const SizedBox(height: 3),
                Padding(
                  padding: const EdgeInsets.only(left: 26),
                  child: Text(
                    caption,
                    style: AppTypography.caption.copyWith(
                      color: inCart
                          ? AppColors.textSecondary
                          : AppColors.fitMid,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: GradientButton(
                      label: holdUntil == null ? 'Hold to Think' : 'On hold',
                      subtitle: holdUntil == null
                          ? '24h cooldown'
                          : '${Fmt.countdown(holdUntil.difference(DateTime.now()))} · tap to release',
                      variant: GradientButtonVariant.glass,
                      horizontalPadding: AppSpacing.md,
                      onPressed: inCart ? null : _hold,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm + 2),
                  Expanded(
                    flex: 3,
                    child: GradientButton(
                      label: inCart ? 'View Intent Cart' : 'Add to Intent Cart',
                      icon: inCart ? Icons.shield_rounded : Icons.add_rounded,
                      variant: inCart
                          ? GradientButtonVariant.success
                          : GradientButtonVariant.primary,
                      horizontalPadding: AppSpacing.md,
                      isLoading: _adding,
                      onPressed: _onAdd,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
