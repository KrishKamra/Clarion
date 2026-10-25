import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/chrome_header.dart';
import '../../../core/widgets/clarion_button.dart';
import '../../../core/widgets/clarion_sheet.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/tactile_card.dart';
import '../../../data/models/cart_item_model.dart';
import '../application/budget_controller.dart';
import '../../decision/application/compare_controller.dart';
import '../../decision/presentation/product_decision_screen.dart';
import '../../../l10n/l10n.dart';
import '../../navigation/navigation_controller.dart';
import '../../orders/application/orders_controller.dart';
import '../../orders/presentation/order_detail_screen.dart';
import '../application/cart_controller.dart';
import 'widgets/cart_item_tile.dart';
import 'widgets/guardian_swap_card.dart';
import 'widgets/spending_barometer.dart';

/// Smart Cart — the Budget Guardian. The cart, always read against the
/// monthly ceiling.
class SmartCartScreen extends ConsumerStatefulWidget {
  const SmartCartScreen({super.key});

  @override
  ConsumerState<SmartCartScreen> createState() => _SmartCartScreenState();
}

class _SmartCartScreenState extends ConsumerState<SmartCartScreen> {
  bool _checkingOut = false;

  CartController get _cart => ref.read(cartProvider.notifier);

  void _snack(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), action: action));
  }

  void _swap(SwapSuggestion s) {
    _cart.swap(s.from.id, s.to.id);
    _snack(
      context.l10n.swappedTo(s.to.brand, Fmt.inr(s.savings)),
      action: SnackBarAction(
        label: context.l10n.undo,
        onPressed: () => _cart.swap(s.to.id, s.from.id),
      ),
    );
  }

  void _remove(CartItem line) {
    final removed = _cart.remove(line.productId);
    if (removed == null) return;
    _snack(
      context.l10n.removedItem(line.product.title),
      action: SnackBarAction(
        label: context.l10n.undo,
        onPressed: () => _cart.restore(removed.$1, removed.$2),
      ),
    );
  }

  void _compare(SwapSuggestion s) {
    ref.read(compareProvider.notifier).focusProduct(s.from.id);
    ref.read(navigationProvider.notifier).select(AppTab.compare);
  }

  Future<void> _checkout(BudgetSnapshot budget) async {
    final l10n = context.l10n;
    if (budget.isOver) {
      final proceed = await showClarionSheet<bool>(
        context: context,
        eyebrow: l10n.mindfulCheckoutEyebrow,
        title: l10n.pastCeilingTitle(Fmt.inr(budget.overBy)),
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.mindfulCheckoutBody(Fmt.inr(budget.limit)),
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: AppSpacing.xxl),
            ClarionButton(
              label: l10n.reviewSwapsFirst,
              onPressed: () => Navigator.of(context).pop(false),
            ),
            const SizedBox(height: AppSpacing.sm),
            ClarionButton(
              label: l10n.proceedAnyway,
              tone: ButtonTone.secondary,
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      );
      if (proceed != true || !mounted) return;
    }

    setState(() => _checkingOut = true);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final lines = ref.read(cartProvider);
    final order = ref.read(ordersProvider.notifier).place(lines);
    ref.read(budgetProvider.notifier).recordPurchase(lines);
    _cart.clear();
    HapticFeedback.mediumImpact();
    setState(() => _checkingOut = false);

    final after = ref.read(budgetSnapshotProvider);
    _snack(
      after.isOver
          ? l10n.orderPlacedOver(Fmt.inr(after.overBy))
          : l10n.orderPlacedLeft(Fmt.inr(after.headroom)),
      action: SnackBarAction(
        label: l10n.track,
        onPressed: () => OrderDetailScreen.open(context, order.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lines = ref.watch(cartProvider);
    final budget = ref.watch(budgetSnapshotProvider);
    final swaps = ref.watch(swapSuggestionsProvider);
    final count = ref.watch(cartCountProvider);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        ChromeSliverHeader(
          child: ScreenTitle(
            eyebrow: context.l10n.cartEyebrow,
            title: context.l10n.cartTitle,
            trailing: Text(
              context.l10n.itemCount(count),
              style: AppTypography.metricSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: AppSpacing.screenPadding.copyWith(top: AppSpacing.lg),
          sliver: SliverToBoxAdapter(
            child: SpendingBarometer(budget: budget, items: lines),
          ),
        ),
        SliverToBoxAdapter(
          child: AnimatedSize(
            duration: AppMotion.slow,
            curve: AppMotion.standard,
            alignment: Alignment.topCenter,
            child: budget.isOver
                ? Padding(
                    padding: AppSpacing.screenPadding.copyWith(
                      top: AppSpacing.md,
                    ),
                    child: GuardianSwapCard(
                      budget: budget,
                      suggestions: swaps,
                      onSwap: _swap,
                      onCompare: _compare,
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ),
        SliverPadding(
          padding: AppSpacing.screenPadding.copyWith(
            top: AppSpacing.section,
            bottom: AppSpacing.md,
          ),
          sliver: SliverToBoxAdapter(
            child: SectionHeader(
              title: context.l10n.intentCart,
              caption: lines.isEmpty ? null : context.l10n.cartHint,
            ),
          ),
        ),
        if (lines.isEmpty)
          SliverPadding(
            padding: AppSpacing.screenPadding,
            sliver: SliverToBoxAdapter(
              child: _EmptyCart(
                onExplore: () => ref
                    .read(navigationProvider.notifier)
                    .select(AppTab.horizon),
              ),
            ),
          )
        else ...[
          SliverPadding(
            padding: AppSpacing.screenPadding,
            sliver: SliverList.separated(
              itemCount: lines.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) {
                final line = lines[i];
                return CartItemTile(
                  key: ValueKey(line.productId),
                  line: line,
                  onTap: () => ProductDecisionScreen.open(
                    context,
                    line.productId,
                    heroTag: 'cart-${line.productId}',
                  ),
                  onRemove: () => _remove(line),
                  onQuantity: (q) => q <= 0
                      ? _remove(line)
                      : _cart.setQuantity(line.productId, q),
                  onPriority: () => _cart.cyclePriority(line.productId),
                );
              },
            ),
          ),
          SliverPadding(
            padding: AppSpacing.screenPadding.copyWith(top: AppSpacing.xl),
            sliver: SliverToBoxAdapter(
              child: _Summary(
                budget: budget,
                loading: _checkingOut,
                onCheckout: () => _checkout(budget),
              ),
            ),
          ),
        ],
        SliverToBoxAdapter(
          child: SizedBox(
            height: AppSpacing.navBarClearance(context) + AppSpacing.lg,
          ),
        ),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.budget,
    required this.loading,
    required this.onCheckout,
  });

  final BudgetSnapshot budget;
  final bool loading;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Widget row(String label, String value, {Color? color}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 1),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTypography.bodySmall)),
          Text(value, style: AppTypography.metricSmall.copyWith(color: color)),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        row(l10n.cartTotal, Fmt.inr(budget.cart)),
        row(l10n.pickupLabel, l10n.pickupFree, color: AppColors.textSecondary),
        row(
          budget.isOver ? l10n.pastCeilingBy : l10n.leftAfterCheckout,
          Fmt.inr(budget.isOver ? budget.overBy : budget.headroom),
          color: budget.isOver ? AppColors.rose : AppColors.emeraldGlow,
        ),
        const SizedBox(height: AppSpacing.lg),
        ClarionButton(
          label: l10n.checkoutMindfully(Fmt.inr(budget.cart)),
          icon: Icons.lock_outline_rounded,
          isLoading: loading,
          onPressed: onCheckout,
        ),
      ],
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.onExplore});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return TactileCard(
      material: CardMaterial.vellum,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        children: [
          Text(context.l10n.emptyCartTitle, style: AppTypography.titleSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.l10n.emptyCartBody,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xl),
          ClarionButton(
            label: context.l10n.returnToHorizon,
            tone: ButtonTone.secondary,
            onPressed: onExplore,
          ),
        ],
      ),
    );
  }
}
