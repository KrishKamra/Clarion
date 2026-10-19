import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/glass_sheet.dart';
import '../../../core/widgets/glass_sliver_header.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/section_header.dart';
import '../../budget/application/budget_controller.dart';
import '../../decision/application/compare_controller.dart';
import '../../decision/presentation/product_decision_screen.dart';
import '../../navigation/navigation_controller.dart';
import '../application/cart_controller.dart';
import 'widgets/budget_barometer.dart';
import 'widgets/budget_optimization_card.dart';
import 'widgets/cart_item_tile.dart';

/// Budget Guardian: the cart, judged against the monthly envelope.
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
    HapticFeedback.mediumImpact();
    _cart.swap(s.from.id, s.to.id);
    _snack(
      'Swapped to ${s.to.brand}. Saved ${Fmt.inr(s.savings)}.',
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () => _cart.swap(s.to.id, s.from.id),
      ),
    );
  }

  void _remove(CartLine line) {
    final removed = _cart.remove(line.productId);
    if (removed == null) return;
    _snack(
      'Removed ${line.product.title}.',
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () => _cart.restore(removed.$1, removed.$2),
      ),
    );
  }

  void _compare(SwapSuggestion s) {
    ref.read(compareProvider.notifier).focusProduct(s.from.id);
    ref.read(navigationProvider.notifier).select(AppTab.compare);
  }

  Future<void> _checkout(BudgetSnapshot budget) async {
    if (budget.isOver) {
      final proceed = await showGlassSheet<bool>(
        context: context,
        title: 'Over budget by ${Fmt.inr(budget.overBy)}',
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Checking out now takes you past your ${Fmt.inr(budget.limit)} monthly limit. '
              'You can still go ahead — Clarion just wants it to be a choice, not a reflex.',
              style: AppTypography.bodySmall.copyWith(fontSize: 14),
            ),
            const SizedBox(height: AppSpacing.xl),
            GradientButton(
              label: 'Review swaps first',
              icon: Icons.auto_awesome_rounded,
              onPressed: () => Navigator.of(context).pop(false),
            ),
            const SizedBox(height: AppSpacing.sm),
            GradientButton(
              label: 'Proceed anyway',
              variant: GradientButtonVariant.glass,
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      );
      if (proceed != true || !mounted) return;
    }

    setState(() => _checkingOut = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final total = ref.read(cartTotalProvider);
    ref.read(budgetProvider.notifier).recordPurchase(total);
    _cart.clear();
    HapticFeedback.heavyImpact();
    setState(() => _checkingOut = false);

    final after = ref.read(budgetSnapshotProvider);
    _snack(
      after.isOver
          ? 'Order placed. You\'re ${Fmt.inr(after.overBy)} over this month.'
          : 'Order placed. ${Fmt.inr(after.headroom)} left this month.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final lines = ref.watch(cartProvider);
    final budget = ref.watch(budgetSnapshotProvider);
    final swaps = ref.watch(swapSuggestionsProvider);
    final count = ref.watch(cartCountProvider);

    SwapSuggestion? swapFor(String id) {
      for (final s in swaps) {
        if (s.from.id == id) return s;
      }
      return null;
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        GlassSliverHeader(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Budget Guardian', style: AppTypography.title),
                    Text(
                      count == 0
                          ? 'Intent Cart is empty'
                          : '$count ${count == 1 ? 'item' : 'items'} in your Intent Cart',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.shield_rounded, color: AppColors.textTertiary),
            ],
          ),
        ),
        SliverPadding(
          padding: AppSpacing.screenPadding.copyWith(top: AppSpacing.sm),
          sliver: SliverToBoxAdapter(child: BudgetBarometer(budget: budget)),
        ),
        SliverToBoxAdapter(
          child: AnimatedSize(
            duration: AppMotion.slow,
            curve: AppMotion.emphasized,
            alignment: Alignment.topCenter,
            child: budget.isOver
                ? Padding(
                    padding: AppSpacing.screenPadding.copyWith(
                      top: AppSpacing.lg,
                    ),
                    child: BudgetOptimizationCard(
                      budget: budget,
                      suggestion: swaps.isEmpty ? null : swaps.first,
                      onSwap: () => _swap(swaps.first),
                      onCompare: () => _compare(swaps.first),
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ),
        if (lines.isEmpty)
          SliverPadding(
            padding: AppSpacing.screenPadding.copyWith(top: AppSpacing.xxl),
            sliver: SliverToBoxAdapter(
              child: _EmptyCart(
                onExplore: () =>
                    ref.read(navigationProvider.notifier).select(AppTab.home),
              ),
            ),
          )
        else ...[
          SliverPadding(
            padding: AppSpacing.screenPadding.copyWith(
              top: AppSpacing.xxxl,
              bottom: AppSpacing.md,
            ),
            sliver: const SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Intent Cart',
                subtitle: 'Swipe left to remove · tap to revisit the decision',
              ),
            ),
          ),
          SliverPadding(
            padding: AppSpacing.screenPadding,
            sliver: SliverList.separated(
              itemCount: lines.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, i) {
                final line = lines[i];
                final swap = swapFor(line.productId);
                return _FadeIn(
                  key: ValueKey(line.productId),
                  child: CartItemTile(
                    line: line,
                    swap: swap,
                    onSwap: swap == null ? null : () => _swap(swap),
                    onTap: () => ProductDecisionScreen.open(
                      context,
                      line.productId,
                      heroTag: 'cart-${line.productId}',
                    ),
                    onRemove: () => _remove(line),
                    onQuantity: (q) => q <= 0
                        ? _remove(line)
                        : _cart.setQuantity(line.productId, q),
                  ),
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
    Widget row(
      String label,
      String value, {
      Color? color,
      bool strong = false,
    }) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: strong ? AppTypography.label : AppTypography.bodySmall,
            ),
          ),
          Text(
            value,
            style: (strong ? AppTypography.numeric : AppTypography.numericSmall)
                .copyWith(color: color),
          ),
        ],
      ),
    );

    return GlassContainer.card(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row('Cart total', Fmt.inr(budget.cart), strong: true),
          row('Delivery', 'Free · local pickup', color: AppColors.accent),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Divider(),
          ),
          row(
            budget.isOver
                ? 'Over monthly limit by'
                : 'Left this month after checkout',
            Fmt.inr(budget.isOver ? budget.overBy : budget.headroom),
            color: budget.isOver ? AppColors.fitLow : AppColors.fitHigh,
          ),
          const SizedBox(height: AppSpacing.lg),
          GradientButton(
            label: 'Checkout mindfully · ${Fmt.inr(budget.cart)}',
            icon: Icons.lock_outline_rounded,
            isLoading: loading,
            onPressed: onCheckout,
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.onExplore});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return GlassContainer.card(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.3),
                  AppColors.secondary.withValues(alpha: 0.15),
                ],
              ),
            ),
            child: const Icon(
              Icons.spa_rounded,
              color: AppColors.textPrimary,
              size: 28,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Nothing here — and that\'s fine',
            style: AppTypography.titleSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Add items only when they serve an intent. Your envelope is safe.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xl),
          GradientButton(
            label: 'Explore fit picks',
            icon: Icons.explore_rounded,
            expand: false,
            onPressed: onExplore,
          ),
        ],
      ),
    );
  }
}

/// Fades and lifts a cart row in when it first appears (e.g. after a swap).
class _FadeIn extends StatelessWidget {
  const _FadeIn({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.slow,
      curve: AppMotion.emphasized,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - t)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
