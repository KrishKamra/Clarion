import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/catalog.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/models/product_model.dart';

class CartController extends Notifier<List<CartItem>> {
  Catalog get _catalog => ref.read(catalogProvider);

  @override
  List<CartItem> build() {
    final catalog = ref.watch(catalogProvider);
    return [
      CartItem(catalog.byId('lamp_halo'), priority: IntentPriority.essential),
      CartItem(catalog.byId('org_kova'), priority: IntentPriority.niceToHave),
    ];
  }

  bool contains(String productId) =>
      state.any((item) => item.productId == productId);

  void add(String productId) {
    if (contains(productId)) return;
    state = [...state, CartItem(_catalog.byId(productId))];
  }

  /// Removes an item and returns it with its index so callers can undo.
  (int, CartItem)? remove(String productId) {
    final index = state.indexWhere((i) => i.productId == productId);
    if (index < 0) return null;
    final item = state[index];
    state = [...state]..removeAt(index);
    return (index, item);
  }

  void restore(int index, CartItem item) {
    if (contains(item.productId)) return;
    state = [...state]..insert(index.clamp(0, state.length), item);
  }

  void setQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      remove(productId);
      return;
    }
    _update(productId, (i) => i.copyWith(quantity: quantity));
  }

  void cyclePriority(String productId) =>
      _update(productId, (i) => i.copyWith(priority: i.priority.next));

  /// Replaces [fromId] with [toId] in place, keeping position, quantity and
  /// priority.
  void swap(String fromId, String toId) {
    if (contains(toId)) {
      remove(fromId);
      return;
    }
    final to = _catalog.byId(toId);
    _update(fromId, (i) => i.copyWith(product: to));
  }

  void clear() => state = const [];

  void _update(String productId, CartItem Function(CartItem) change) {
    state = [for (final i in state) i.productId == productId ? change(i) : i];
  }
}

final cartProvider = NotifierProvider<CartController, List<CartItem>>(
  CartController.new,
);

final cartTotalProvider = Provider<double>((ref) {
  return ref
      .watch(cartProvider)
      .fold<double>(0, (sum, item) => sum + item.subtotal);
});

final cartCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).fold<int>(0, (sum, i) => sum + i.quantity);
});

/// A Guardian Swap Engine recommendation to replace a cart item.
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

  /// Spec parity of [to] relative to [from], 0–100.
  final int parity;
  final int quantity;

  double get savings => (from.price - to.price) * quantity;
}

/// Every swap available for items in the cart, biggest saving first.
final swapSuggestionsProvider = Provider<List<SwapSuggestion>>((ref) {
  final catalog = ref.watch(catalogProvider);
  final items = ref.watch(cartProvider);
  final inCart = {for (final i in items) i.productId};
  final suggestions = <SwapSuggestion>[];
  for (final item in items) {
    final altId = item.product.alternativeId;
    if (altId == null || inCart.contains(altId)) continue;
    final alt = catalog.byId(altId);
    if (alt.price >= item.product.price) continue;
    suggestions.add(
      SwapSuggestion(
        from: item.product,
        to: alt,
        parity: item.product.alternativeParity ?? 0,
        quantity: item.quantity,
      ),
    );
  }
  suggestions.sort((a, b) => b.savings.compareTo(a.savings));
  return suggestions;
});
