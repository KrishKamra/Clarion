import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/db_providers.dart';
import '../../../data/catalog.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/models/product_model.dart';
import '../../decision/application/impulse_risk.dart';

/// The Intent Cart. State starts from what was saved in SQLite and every
/// change is written back, so the cart (including each item's priority)
/// survives a restart.
class CartController extends Notifier<List<CartItem>> {
  Catalog get _catalog => ref.read(catalogProvider);

  @override
  List<CartItem> build() {
    final catalog = ref.watch(catalogProvider);
    final byId = {for (final p in catalog.products) p.id: p};
    final priorities = IntentPriority.values.asNameMap();
    return [
      for (final saved in ref.watch(initialCartProvider))
        // Skip anything no longer in the catalogue instead of crashing.
        if (byId[saved.productId] case final product?)
          CartItem(
            product,
            quantity: saved.quantity,
            priority: priorities[saved.priority] ?? IntentPriority.important,
          ),
    ];
  }

  /// Single place that changes the cart: update memory now, save to SQLite
  /// after. A failed save is logged but never crashes the app.
  void _set(List<CartItem> next) {
    state = next;
    final repo = ref.read(cartRepositoryProvider);
    if (repo == null) return;
    repo
        .replaceAll([
          for (final item in next)
            (
              productId: item.productId,
              quantity: item.quantity,
              priority: item.priority.name,
            ),
        ])
        .catchError(
          (Object error, StackTrace stack) => developer.log(
            'Could not save cart',
            error: error,
            stackTrace: stack,
          ),
        );
  }

  bool contains(String productId) =>
      state.any((item) => item.productId == productId);

  void add(String productId) {
    if (contains(productId)) return;
    final product = _catalog.byId(productId);
    _set([...state, CartItem(product)]);
    ref.read(impulseProvider.notifier).noteAdd(productId, product.price);
  }

  /// Removes an item and returns it with its index so callers can undo.
  (int, CartItem)? remove(String productId) {
    final index = state.indexWhere((i) => i.productId == productId);
    if (index < 0) return null;
    final item = state[index];
    _set([...state]..removeAt(index));
    return (index, item);
  }

  void restore(int index, CartItem item) {
    if (contains(item.productId)) return;
    _set([...state]..insert(index.clamp(0, state.length), item));
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

  void clear() => _set(const []);

  void _update(String productId, CartItem Function(CartItem) change) {
    _set([for (final i in state) i.productId == productId ? change(i) : i]);
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
