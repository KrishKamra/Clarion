import 'package:flutter/foundation.dart';

import 'product_model.dart';

/// How central an item is to the intent it was added for. The Guardian
/// reads this when the cart breaches the ceiling: nice-to-haves are the
/// first candidates to defer.
enum IntentPriority {
  essential('Essential'),
  important('Important'),
  niceToHave('Nice to have');

  const IntentPriority(this.label);
  final String label;

  /// The next priority when the user taps to cycle.
  IntentPriority get next =>
      IntentPriority.values[(index + 1) % IntentPriority.values.length];
}

/// One line in the Intent Cart.
@immutable
class CartItem {
  const CartItem(
    this.product, {
    this.quantity = 1,
    this.priority = IntentPriority.important,
  });

  final Product product;
  final int quantity;
  final IntentPriority priority;

  String get productId => product.id;
  double get subtotal => product.price * quantity;

  CartItem copyWith({
    Product? product,
    int? quantity,
    IntentPriority? priority,
  }) => CartItem(
    product ?? this.product,
    quantity: quantity ?? this.quantity,
    priority: priority ?? this.priority,
  );
}
