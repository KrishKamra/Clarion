import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/db_providers.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../data/catalog.dart';
import '../../../data/models/product_model.dart';

/// Price Memory Watcher: the products the user is watching.
///
/// Maps product id → target price (`null` when watching without a target).
/// State starts from what was saved in SQLite and every change is written
/// back, so the watchlist survives a restart.
class WatchlistController extends Notifier<Map<String, double?>> {
  @override
  Map<String, double?> build() => ref.watch(initialWatchlistProvider);

  bool isWatching(String productId) => state.containsKey(productId);

  /// Starts watching [productId], optionally with a [target] price.
  void watch(String productId, {double? target}) {
    state = {...state, productId: target};
    _persist(ref.read(priceWatchRepositoryProvider)?.upsert(productId, target));
    // A target is a request to be told; ask for permission right then.
    if (target != null) NotificationService.requestPermission();
  }

  /// Changes the target of an already-watched product (`null` clears it).
  void setTarget(String productId, double? target) =>
      watch(productId, target: target);

  void unwatch(String productId) {
    state = {...state}..remove(productId);
    _persist(ref.read(priceWatchRepositoryProvider)?.remove(productId));
  }

  /// The UI updates instantly from memory; the database write happens after.
  /// A failed write is logged but never crashes the app.
  void _persist(Future<void>? write) {
    write?.catchError(
      (Object error, StackTrace stack) => developer.log(
        'Could not save watchlist change',
        error: error,
        stackTrace: stack,
      ),
    );
  }
}

final watchlistProvider =
    NotifierProvider<WatchlistController, Map<String, double?>>(
      WatchlistController.new,
    );

/// The price history shown for a product id: read from the Price Memory table
/// when there is a database, otherwise the catalogue's built-in history.
final priceHistoryProvider = FutureProvider.family<List<PricePoint>, String>((
  ref,
  productId,
) async {
  final fallback = ref.read(catalogProvider).byId(productId).priceHistory;
  final repository = ref.watch(priceWatchRepositoryProvider);
  if (repository == null) return fallback;
  try {
    final saved = await repository.historyFor(productId);
    return saved.isEmpty ? fallback : saved;
  } catch (error, stack) {
    developer.log(
      'Could not read price history',
      error: error,
      stackTrace: stack,
    );
    return fallback;
  }
});
