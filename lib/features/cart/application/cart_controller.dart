import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/mock_catalog.dart';
import '../../../core/models/product.dart';

/// One product line in the Intent Cart.
@immutable
class CartLine {
  const CartLine(this.productId, {this.quantity = 1});

  final String productId;
  final int quantity;

  Product get product => MockCatalog.byId(productId);
  double get subtotal => product.price * quantity;

  CartLine copyWith({String? productId, int? quantity}) => CartLine(
    productId ?? this.productId,
    quantity: quantity ?? this.quantity,
  );
}

class CartController extends Notifier<List<CartLine>> {
  @override
  List<CartLine> build() => const [
    CartLine('hp_q30'),
    CartLine('lamp_halo'),
    CartLine('org_kova'),
  ];

  bool contains(String productId) =>
      state.any((line) => line.productId == productId);

  void add(String productId) {
    if (contains(productId)) return;
    state = [...state, CartLine(productId)];
  }

  /// Removes a line and returns it with its index so callers can undo.
  (int, CartLine)? remove(String productId) {
    final index = state.indexWhere((l) => l.productId == productId);
    if (index < 0) return null;
    final line = state[index];
    state = [...state]..removeAt(index);
    return (index, line);
  }

  void restore(int index, CartLine line) {
    if (contains(line.productId)) return;
    final next = [...state]..insert(index.clamp(0, state.length), line);
    state = next;
  }

  void setQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      remove(productId);
      return;
    }
    state = [
      for (final l in state)
        l.productId == productId ? l.copyWith(quantity: quantity) : l,
    ];
  }

  /// Replaces [fromId] with [toId] in place, preserving position & quantity.
  void swap(String fromId, String toId) {
    if (contains(toId)) {
      remove(fromId);
      return;
    }
    state = [
      for (final l in state)
        l.productId == fromId ? l.copyWith(productId: toId) : l,
    ];
  }

  void clear() => state = const [];
}

final cartProvider = NotifierProvider<CartController, List<CartLine>>(
  CartController.new,
);

final cartTotalProvider = Provider<double>((ref) {
  return ref
      .watch(cartProvider)
      .fold<double>(0, (sum, line) => sum + line.subtotal);
});

final cartCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).fold<int>(0, (sum, l) => sum + l.quantity);
});

/// A Budget Guardian recommendation to replace a cart item.
@immutable
class SwapSuggestion {
  const SwapSuggestion({
    required this.from,
    required this.to,
    required this.parity,
    required this.quantity,
  });

  final Product from;
  final Product to;
  final int parity;
  final int quantity;

  double get savings => (from.price - to.price) * quantity;
}

/// Every swap currently available for items in the cart, biggest saving first.
final swapSuggestionsProvider = Provider<List<SwapSuggestion>>((ref) {
  final lines = ref.watch(cartProvider);
  final inCart = {for (final l in lines) l.productId};
  final suggestions = <SwapSuggestion>[];
  for (final line in lines) {
    final product = line.product;
    final altId = product.alternativeId;
    if (altId == null || inCart.contains(altId)) continue;
    final alt = MockCatalog.byId(altId);
    if (alt.price >= product.price) continue;
    suggestions.add(
      SwapSuggestion(
        from: product,
        to: alt,
        parity: product.alternativeParity ?? 0,
        quantity: line.quantity,
      ),
    );
  }
  suggestions.sort((a, b) => b.savings.compareTo(a.savings));
  return suggestions;
});
