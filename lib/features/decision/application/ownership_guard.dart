import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/catalog.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/product_model.dart';
import '../../orders/application/orders_controller.dart';

/// A purchase the user already kept that overlaps the one they are considering.
@immutable
class OwnershipWarning {
  const OwnershipWarning({
    required this.owned,
    required this.ownedTitle,
    required this.exact,
  });

  final Product owned;
  final String ownedTitle;

  /// The same product, rather than a similar one.
  final bool exact;

  String get message => exact
      ? 'You already own the ${owned.title}.'
      : 'You already own something similar: ${owned.title}.';
}

/// Warns before a duplicate, using kept order lines and shared intent tags.
abstract final class OwnershipGuard {
  /// Tags so common they do not mean two products do the same job.
  static const genericTags = {
    'college',
    'setup',
    'study',
    'desk',
    'daily',
    'work',
    'durable',
    'edc',
  };

  static OwnershipWarning? find({
    required Product candidate,
    required List<Order> orders,
    required List<Product> catalog,
  }) {
    Product? productFor(String id) {
      for (final product in catalog) {
        if (product.id == id) return product;
      }
      return null;
    }

    OwnershipWarning? similar;
    for (final order in orders) {
      for (final line in order.lines) {
        if (line.returned != null) continue;
        final owned = productFor(line.productId);
        if (owned == null) continue;
        if (owned.id == candidate.id) {
          return OwnershipWarning(
            owned: owned,
            ownedTitle: line.title,
            exact: true,
          );
        }
        if (owned.category != candidate.category) continue;
        final shared = owned.intentTags.intersection(candidate.intentTags);
        final distinctive = shared.difference(genericTags);
        if (distinctive.isEmpty) continue;
        similar ??= OwnershipWarning(
          owned: owned,
          ownedTitle: line.title,
          exact: false,
        );
      }
    }
    return similar;
  }
}

final ownershipWarningProvider = Provider.family<OwnershipWarning?, String>((
  ref,
  productId,
) {
  final catalog = ref.watch(catalogProvider);
  return OwnershipGuard.find(
    candidate: catalog.byId(productId),
    orders: ref.watch(ordersProvider),
    catalog: catalog.products,
  );
});
