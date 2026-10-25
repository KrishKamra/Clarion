import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/db_providers.dart';
import '../../../core/db/demo_seed.dart';
import '../../../data/models/cart_item_model.dart';
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

/// The monthly envelope. State starts from SQLite (limit, mindful stats and
/// this month's spend) and every change is written back.
class BudgetController extends Notifier<BudgetState> {
  @override
  BudgetState build() {
    final stored = ref.watch(initialBudgetProvider);
    return BudgetState(
      monthlyLimit: stored.monthlyLimit,
      categories: [
        for (final s in stored.spend) CategorySpend(s.label, s.amount),
      ],
      // Previous-month totals are still demo data (not yet derived from SQL).
      monthlyHistory: DemoSeed.monthlyHistory,
      impulseBuysAvoided: stored.impulseBuysAvoided,
      savedViaCooldown: stored.savedViaCooldown,
    );
  }

  /// The UI updates instantly from memory; the database write happens after.
  /// A failed write is logged but never crashes the app.
  void _persist(Future<void>? write) {
    write?.catchError(
      (Object error, StackTrace stack) => developer.log(
        'Could not save budget change',
        error: error,
        stackTrace: stack,
      ),
    );
  }

  void setMonthlyLimit(double limit) {
    state = state.copyWith(monthlyLimit: limit);
    _persist(ref.read(budgetRepositoryProvider)?.setMonthlyLimit(limit));
  }

  /// Settles a checkout against the envelope, one entry per product bought,
  /// so "Where it went" lists exactly what the money was spent on.
  void recordPurchase(List<CartItem> lines) {
    var categories = state.categories;
    final repo = ref.read(budgetRepositoryProvider);
    for (final line in lines) {
      final label = line.quantity > 1
          ? '${line.product.title} × ${line.quantity}'
          : line.product.title;
      final amount = line.subtotal;
      categories = categories.any((c) => c.label == label)
          ? [
              for (final c in categories)
                c.label == label ? CategorySpend(label, c.amount + amount) : c,
            ]
          : [...categories, CategorySpend(label, amount)];
      _persist(repo?.addSpend(label, amount));
    }
    state = state.copyWith(categories: categories);
  }

  /// Gives a returned or cancelled purchase back to the envelope. Only a
  /// purchase made this month was counted against it.
  void recordRefund(String label, double amount, {required DateTime boughtAt}) {
    final now = DateTime.now();
    if (boughtAt.year != now.year || boughtAt.month != now.month) return;
    state = state.copyWith(
      categories: [
        for (final c in state.categories)
          if (c.label != label)
            c
          else if (c.amount - amount > 0)
            CategorySpend(label, c.amount - amount),
      ],
    );
    _persist(ref.read(budgetRepositoryProvider)?.refund(label, amount));
  }

  /// Credits a product the user decided against after a cooldown.
  void recordImpulseAvoided(double amount) {
    state = state.copyWith(
      impulseBuysAvoided: state.impulseBuysAvoided + 1,
      savedViaCooldown: state.savedViaCooldown + amount,
    );
    _persist(ref.read(budgetRepositoryProvider)?.recordImpulseAvoided(amount));
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
