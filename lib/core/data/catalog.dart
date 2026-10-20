import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import 'mock_catalog.dart';

/// Read-only product catalogue — the raw domain state, kept apart from the
/// volatile interaction state (intent, cart, holds) that features own.
class Catalog {
  Catalog(List<Product> products, this.comparePairs)
    : products = List.unmodifiable(products),
      _byId = {for (final p in products) p.id: p};

  final List<Product> products;
  final List<ComparePair> comparePairs;
  final Map<String, Product> _byId;

  Product byId(String id) {
    final product = _byId[id];
    if (product == null) throw ArgumentError.value(id, 'id', 'Unknown product');
    return product;
  }

  /// Products ranked by fit, best first.
  List<Product> get rankedByFit =>
      [...products]..sort((a, b) => b.fitScore.compareTo(a.fitScore));

  /// The strongest price-memory signal in the catalogue.
  Product get priceMemoryPick => products.reduce(
    (a, b) => a.discountVsAverage >= b.discountVsAverage ? a : b,
  );

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
