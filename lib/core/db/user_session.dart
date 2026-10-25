import 'dart:developer' as developer;

import 'package:flutter_riverpod/misc.dart' show Override;

import '../../data/mock_catalog.dart';
import '../notifications/notification_service.dart';
import 'app_database.dart';
import 'budget_repository.dart';
import 'cart_repository.dart';
import 'cooldown_repository.dart';
import 'db_providers.dart';
import 'price_watch_repository.dart';

/// One signed-in account's local state: its database (if it opened) and the
/// provider overrides that seed the app from it.
typedef UserSession = ({AppDatabase? db, List<Override> overrides});

/// Opens [userId]'s database and loads its saved state. If anything fails
/// (e.g. running on web), the session carries on with in-memory defaults.
Future<UserSession> openUserSession(String userId) async {
  try {
    final db = await AppDatabase.open(userId: userId);
    // Price Memory: record today's prices (and back-fill the 30-day history
    // on first launch) before the watchlist is read.
    final priceWatch = PriceWatchRepository(db);
    try {
      await priceWatch.recordPrices(MockCatalog.products);
    } catch (error, stack) {
      developer.log(
        'Could not record price memory',
        error: error,
        stackTrace: stack,
      );
    }
    final holds = await CooldownRepository(db).loadAll();
    final watchlist = await priceWatch.loadWatchlist();
    // Fire-and-forget: reminders must never delay the app opening.
    NotificationService.syncSession(
      userId: userId,
      holds: holds,
      watchlist: watchlist,
      products: {for (final p in MockCatalog.products) p.id: p},
    );
    return (
      db: db,
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        initialCooldownsProvider.overrideWithValue(holds),
        initialCartProvider.overrideWithValue(
          await CartRepository(db).loadAll(),
        ),
        initialBudgetProvider.overrideWithValue(
          await BudgetRepository(db).load(),
        ),
        initialWatchlistProvider.overrideWithValue(watchlist),
      ],
    );
  } catch (error, stack) {
    developer.log(
      'Local database unavailable; running without persistence',
      error: error,
      stackTrace: stack,
    );
    return (db: null, overrides: <Override>[]);
  }
}
