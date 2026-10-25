import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/catalog.dart';
import '../../../data/models/product_model.dart';
import 'intent_controller.dart';

/// A set of products that fit a goal's ceiling, chosen as a whole.
@immutable
class BundlePlan {
  const BundlePlan({
    required this.items,
    required this.total,
    required this.ceiling,
    required this.fit,
  });

  final List<Product> items;
  final double total;
  final double ceiling;
  final int fit;

  double get left => ceiling - total;
}

/// Picks the best-fitting set under a ceiling: up to four items, one per
/// category, highest combined fit, then the cheaper set when fits tie.
abstract final class BundlePlanner {
  static const int maxItems = 4;

  static BundlePlan? plan({
    required List<Product> products,
    required Set<String> keywords,
    required double ceiling,
    required int Function(Product product) scoreOf,
  }) {
    if (ceiling <= 0) return null;
    final pool = [
      for (final product in products)
        if (product.price > 0 && product.price <= ceiling)
          if (keywords.isEmpty || keywords.any(product.matchesKeyword)) product,
    ];
    if (pool.length < 2) return null;

    BundlePlan? best;
    void consider(List<Product> chosen) {
      if (chosen.length < 2) return;
      final categories = chosen.map((product) => product.category).toSet();
      if (categories.length != chosen.length) return;
      final total = chosen.fold<double>(
        0,
        (sum, product) => sum + product.price,
      );
      if (total > ceiling) return;
      final fit = chosen.fold<int>(0, (sum, product) => sum + scoreOf(product));
      final ordered = [...chosen]
        ..sort((a, b) => scoreOf(b).compareTo(scoreOf(a)));
      final candidate = BundlePlan(
        items: ordered,
        total: total,
        ceiling: ceiling,
        fit: fit,
      );
      final current = best;
      if (current == null ||
          candidate.fit > current.fit ||
          (candidate.fit == current.fit && candidate.total < current.total)) {
        best = candidate;
      }
    }

    void walk(int start, List<Product> chosen) {
      if (chosen.length >= 2) consider(chosen);
      if (chosen.length == maxItems) return;
      for (var i = start; i < pool.length; i++) {
        chosen.add(pool[i]);
        walk(i + 1, chosen);
        chosen.removeLast();
      }
    }

    walk(0, []);
    return best;
  }
}

/// The set for the active goal, when that goal names a ceiling.
final bundlePlanProvider = Provider<BundlePlan?>((ref) {
  final intent = ref.watch(intentProvider);
  final ceiling = intent?.budget;
  if (intent == null || ceiling == null) return null;
  final products = ref.watch(catalogProvider).products;
  return BundlePlanner.plan(
    products: products,
    keywords: intent.keywords,
    ceiling: ceiling,
    scoreOf: (product) => ref.watch(fitProvider(product.id)).score,
  );
});
