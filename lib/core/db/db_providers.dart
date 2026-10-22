import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';
import 'budget_repository.dart';
import 'cart_repository.dart';
import 'cooldown_repository.dart';
import 'demo_seed.dart';
import 'price_watch_repository.dart';

/// The open database, or `null` when there isn't one (widget tests, web, or
/// if opening failed). Features treat `null` as "don't persist" so the app
/// keeps working in memory.
///
/// `main()` overrides this with the real database.
final appDatabaseProvider = Provider<AppDatabase?>((ref) => null);

// ── Repositories (null when there is no database) ────────────────────────

final cooldownRepositoryProvider = Provider<CooldownRepository?>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return database == null ? null : CooldownRepository(database);
});

final cartRepositoryProvider = Provider<CartRepository?>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return database == null ? null : CartRepository(database);
});

final budgetRepositoryProvider = Provider<BudgetRepository?>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return database == null ? null : BudgetRepository(database);
});

final priceWatchRepositoryProvider = Provider<PriceWatchRepository?>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return database == null ? null : PriceWatchRepository(database);
});

// ── Start-up state ───────────────────────────────────────────────────────
//
// `main()` loads these from SQLite before the first frame and overrides them.
// The defaults below are the demo scenario, so tests and the no-database
// fallback behave exactly like the original in-memory app.

final initialCooldownsProvider = Provider<Map<String, DateTime>>(
  (ref) => {'kb_loom': DateTime.now().add(const Duration(hours: 17, minutes: 42))},
);

final initialCartProvider = Provider<List<SavedCartLine>>(
  (ref) => [
    for (final (id, quantity, priority) in DemoSeed.cartLines)
      (productId: id, quantity: quantity, priority: priority),
  ],
);

final initialBudgetProvider = Provider<StoredBudget>(
  (ref) => StoredBudget(
    monthlyLimit: DemoSeed.monthlyLimit,
    impulseBuysAvoided: DemoSeed.impulseBuysAvoided,
    savedViaCooldown: DemoSeed.savedViaCooldown,
    spend: [
      for (final (label, amount) in DemoSeed.spend)
        (label: label, amount: amount),
    ],
  ),
);

/// Watched products (id -> target price) loaded from SQLite at start-up.
/// Empty by default: nothing is watched on a fresh install.
final initialWatchlistProvider = Provider<Map<String, double?>>((ref) => {});
