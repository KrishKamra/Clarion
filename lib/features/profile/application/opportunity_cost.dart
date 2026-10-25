import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../data/catalog.dart';
import '../../../data/models/clarity_models.dart';
import '../../../data/models/product_model.dart';
import '../../orders/application/orders_controller.dart';
import 'savings_controller.dart';

/// What a purchase costs in progress toward a savings goal.
@immutable
class OpportunityCost {
  const OpportunityCost({
    required this.goal,
    required this.share,
    this.categoryLimit,
    this.categorySpent = 0,
  });

  final SavingsGoal goal;

  /// Share of the goal's target this price represents, 0–1 and beyond.
  final double share;
  final double? categoryLimit;
  final double categorySpent;

  int get percent => (share * 100).round();

  String get sentence =>
      'This equals $percent% of your ${goal.name.toLowerCase()} goal';

  String? get categorySentence {
    final limit = categoryLimit;
    if (limit == null || limit <= 0) return null;
    return '${Fmt.inr(categorySpent)} of your ${Fmt.inr(limit)} category budget';
  }
}

abstract final class OpportunityCostEngine {
  static OpportunityCost? of({
    required Product product,
    required List<SavingsGoal> goals,
    required List<CategoryBudget> categoryBudgets,
    double categorySpent = 0,
  }) {
    if (goals.isEmpty && categoryBudgets.isEmpty) return null;
    final words = product.category.toLowerCase().split(RegExp(r'[^a-z]+'));
    SavingsGoal? best;
    var bestScore = -1;
    for (final goal in goals) {
      if (goal.target <= 0) continue;
      final name = goal.name.toLowerCase();
      var score = 0;
      for (final word in words) {
        if (word.length > 2 && name.contains(word)) score += 2;
      }
      for (final tag in product.intentTags) {
        if (tag.length > 3 && name.contains(tag)) score += 3;
      }
      // With no name overlap, still surface the goal this purchase consumes
      // the largest share of, so the opportunity cost is never silent.
      if (score == 0) score = 1;
      if (score > bestScore) {
        best = goal;
        bestScore = score;
      }
    }
    CategoryBudget? category;
    for (final budget in categoryBudgets) {
      if (budget.category == product.category) category = budget;
    }
    if (best == null && category == null) return null;
    final goal =
        best ??
        SavingsGoal(
          id: 'category',
          name: product.category,
          target: category!.monthlyLimit,
          createdAt: DateTime.fromMillisecondsSinceEpoch(0),
        );
    return OpportunityCost(
      goal: goal,
      share: goal.target <= 0 ? 0 : product.price / goal.target,
      categoryLimit: category?.monthlyLimit,
      categorySpent: categorySpent,
    );
  }
}

final opportunityProvider = Provider.family<OpportunityCost?, String>((
  ref,
  productId,
) {
  final catalog = ref.watch(catalogProvider);
  final product = catalog.byId(productId);
  final now = DateTime.now();
  var spent = 0.0;
  for (final order in ref.watch(ordersProvider)) {
    if (order.placedAt.year != now.year || order.placedAt.month != now.month) {
      continue;
    }
    for (final line in order.lines) {
      if (line.returned != null) continue;
      Product? bought;
      for (final item in catalog.products) {
        if (item.id == line.productId) bought = item;
      }
      if (bought?.category == product.category) spent += line.subtotal;
    }
  }
  return OpportunityCostEngine.of(
    product: product,
    goals: ref.watch(savingsGoalsProvider),
    categoryBudgets: ref.watch(categoryBudgetsProvider),
    categorySpent: spent,
  );
});
