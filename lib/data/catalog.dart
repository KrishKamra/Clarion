import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'mock_catalog.dart';
import 'models/product_model.dart';

/// Read-only product catalogue — raw domain state, kept apart from the
/// volatile interaction state (intent, cart, holds) that features own.
class Catalog {
  Catalog(List<Product> products, this.comparePairs)
    : products = List.unmodifiable(products),
      _byId = {for (final p in products) p.id: p};

  final List<Product> products;
  final List<ComparePair> comparePairs;
  final Map<String, Product> _byId;

  /// The Price Memory Radar only flags a discount that is both relative
  /// (vs the 30-day average) and large enough in rupees to matter.
  static const double radarThreshold = 0.10;
  static const double radarMinSaving = 150;

  Product byId(String id) {
    final product = _byId[id];
    if (product == null) throw ArgumentError.value(id, 'id', 'Unknown product');
    return product;
  }

  /// Products ranked by fit, best first.
  List<Product> get rankedByFit =>
      [...products]..sort((a, b) => b.fitScore.compareTo(a.fitScore));

  /// Items trading meaningfully below their 30-day average, deepest first.
  List<Product> get priceRadar =>
      products
          .where(
            (p) =>
                p.discountVsAverage >= radarThreshold &&
                p.averagePrice30d - p.price >= radarMinSaving,
          )
          .toList()
        ..sort((a, b) => b.discountVsAverage.compareTo(a.discountVsAverage));

  ComparePair? pairFor(String productId) {
    for (final pair in comparePairs) {
      if (pair.contains(productId)) return pair;
    }
    return null;
  }
}

/// Swap for a repository-backed provider when a backend lands; every
/// consumer reads products through here.
final catalogProvider = Provider<Catalog>(
  (ref) => Catalog(MockCatalog.products, MockCatalog.comparePairs),
);
