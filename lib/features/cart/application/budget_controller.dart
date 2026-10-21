import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cart_controller.dart';

/// A month's settled spending within one category.
@immutable
class CategorySpend {
  const CategorySpend(this.label, this.amount);
  final String label;
  final double amount;
}

/// The user's monthly envelope and what has already been settled against it.
@immutable
class BudgetState {
  const BudgetState({
    required this.monthlyLimit,
    required this.categories,
    required this.monthlyHistory,
    required this.impulseBuysAvoided,
    required this.savedViaCooldown,
  });

  final double monthlyLimit;
  final List<CategorySpend> categories;

  /// Settled totals for previous months, oldest first.
  final List<double> monthlyHistory;
  final int impulseBuysAvoided;
  final double savedViaCooldown;

  double get spentThisMonth =>
      categories.fold<double>(0, (sum, c) => sum + c.amount);

  BudgetState copyWith({
    double? monthlyLimit,
    List<CategorySpend>? categories,
    int? impulseBuysAvoided,
    double? savedViaCooldown,
  }) => BudgetState(
    monthlyLimit: monthlyLimit ?? this.monthlyLimit,
    categories: categories ?? this.categories,
    monthlyHistory: monthlyHistory,
    impulseBuysAvoided: impulseBuysAvoided ?? this.impulseBuysAvoided,
    savedViaCooldown: savedViaCooldown ?? this.savedViaCooldown,
  );
}

class BudgetController extends Notifier<BudgetState> {
  @override
  BudgetState build() => const BudgetState(
    monthlyLimit: 5000,
    categories: [
      CategorySpend('Electronics', 1200),
      CategorySpend('Books', 450),
      CategorySpend('Essentials', 350),
    ],
    monthlyHistory: [4620, 5340, 4180, 3950, 4410],
    impulseBuysAvoided: 11,
    savedViaCooldown: 6240,
  );

  void setMonthlyLimit(double limit) {
    state = state.copyWith(monthlyLimit: limit);
  }

  /// Settles a checkout against the envelope under a "Planned" category.
  void recordPurchase(double amount) {
    const label = 'Planned';
    final existing = state.categories.where((c) => c.label == label);
    final updated = existing.isEmpty
        ? [...state.categories, CategorySpend(label, amount)]
        : [
            for (final c in state.categories)
              c.label == label ? CategorySpend(label, c.amount + amount) : c,
          ];
    state = state.copyWith(categories: updated);
  }

  /// Credits a product the user decided against after a cooldown.
  void recordImpulseAvoided(double amount) {
    state = state.copyWith(
      impulseBuysAvoided: state.impulseBuysAvoided + 1,
      savedViaCooldown: state.savedViaCooldown + amount,
    );
  }
}

final budgetProvider = NotifierProvider<BudgetController, BudgetState>(
  BudgetController.new,
);

/// Point-in-time view combining settled spend with the live cart.
@immutable
class BudgetSnapshot {
  const BudgetSnapshot({
    required this.limit,
    required this.spent,
    required this.cart,
  });

  final double limit;
  final double spent;
  final double cart;

  double get committed => spent + cart;
  double get envelopeBeforeCart => limit - spent;
  double get headroom => limit - committed;
  double get overBy => committed > limit ? committed - limit : 0;
  bool get isOver => committed > limit;
  double get ratio => limit == 0 ? 0 : committed / limit;

  /// What would remain if [price] were bought on top of settled spend only.
  double leftAfter(double price) => envelopeBeforeCart - price;

  /// What would remain if [price] joined everything already in the cart.
  double leftAfterWithCart(double price) => headroom - price;
}

final budgetSnapshotProvider = Provider<BudgetSnapshot>((ref) {
  final budget = ref.watch(budgetProvider);
  return BudgetSnapshot(
    limit: budget.monthlyLimit,
    spent: budget.spentThisMonth,
    cart: ref.watch(cartTotalProvider),
  );
});
