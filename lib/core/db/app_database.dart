import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'demo_seed.dart';

/// Clarion's local SQLite database (Local SQLite Layer).
///
/// One file on the device (`clarion.db`) holds everything that must survive an
/// app restart: the cart, 24h cooling-off holds, the monthly budget envelope,
/// settled spending, and the price memory (observations + watchlist).
///
/// Times are stored as Unix epoch milliseconds (INTEGER); money as REAL rupees.
class AppDatabase {
  AppDatabase._(this.db);

  /// The open SQLite connection. Repositories use this directly.
  final Database db;

  static const String fileName = 'clarion.db';

  /// Bump this and add a branch in [_onUpgrade] whenever the schema changes.
  ///
  /// v1: initial schema.
  /// v2: cart lines remember their intent priority (`cart_items.priority`).
  static const int schemaVersion = 2;

  // Table names, kept in one place so repositories never mistype them.
  static const String cartItemsTable = 'cart_items';
  static const String cooldownHoldsTable = 'cooldown_holds';
  static const String budgetProfileTable = 'budget_profile';
  static const String spendEntriesTable = 'spend_entries';
  static const String priceObservationsTable = 'price_observations';
  static const String watchlistTable = 'watchlist';

  /// Opens (creating on first launch) the database.
  ///
  /// Pass [userId] to open that account's own file (`clarion_<uid>.db`), so
  /// accounts sharing a device never see each other's data. Pass [path]
  /// (e.g. `inMemoryDatabasePath`) in tests to avoid touching the real file.
  static Future<AppDatabase> open({String? path, String? userId}) async {
    final name = userId == null ? fileName : 'clarion_$userId.db';
    final resolved = path ?? p.join(await getDatabasesPath(), name);
    final db = await openDatabase(
      resolved,
      version: schemaVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return AppDatabase._(db);
  }

  static Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();

    // Items in the Intent Cart. `position` keeps the on-screen order stable;
    // `priority` is the IntentPriority name (essential/important/niceToHave).
    batch.execute('''
      CREATE TABLE $cartItemsTable (
        product_id TEXT    PRIMARY KEY,
        quantity   INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
        priority   TEXT    NOT NULL DEFAULT 'important',
        position   INTEGER NOT NULL,
        added_at   INTEGER NOT NULL
      )
    ''');

    // Products parked for 24h Cooling Off.
    batch.execute('''
      CREATE TABLE $cooldownHoldsTable (
        product_id TEXT    PRIMARY KEY,
        started_at INTEGER NOT NULL,
        expires_at INTEGER NOT NULL
      )
    ''');

    // Exactly one row (id = 1): the user's monthly envelope and mindful stats.
    batch.execute('''
      CREATE TABLE $budgetProfileTable (
        id                   INTEGER PRIMARY KEY CHECK (id = 1),
        monthly_limit        REAL    NOT NULL CHECK (monthly_limit >= 0),
        impulse_buys_avoided INTEGER NOT NULL DEFAULT 0,
        saved_via_cooldown   REAL    NOT NULL DEFAULT 0
      )
    ''');

    // Settled purchases; summed per category and month for Spending Memory.
    batch.execute('''
      CREATE TABLE $spendEntriesTable (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT    NOT NULL,
        amount   REAL    NOT NULL CHECK (amount >= 0),
        spent_at INTEGER NOT NULL
      )
    ''');
    batch.execute(
      'CREATE INDEX idx_spend_spent_at ON $spendEntriesTable (spent_at)',
    );

    // Price Memory: one observed price per product per day.
    batch.execute('''
      CREATE TABLE $priceObservationsTable (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id  TEXT NOT NULL,
        price       REAL NOT NULL CHECK (price >= 0),
        observed_on TEXT NOT NULL,
        UNIQUE (product_id, observed_on)
      )
    ''');
    batch.execute(
      'CREATE INDEX idx_price_product ON $priceObservationsTable '
      '(product_id, observed_on)',
    );

    // Products the Price Memory Watcher is tracking.
    batch.execute('''
      CREATE TABLE $watchlistTable (
        product_id   TEXT    PRIMARY KEY,
        target_price REAL,
        added_at     INTEGER NOT NULL
      )
    ''');

    await batch.commit(noResult: true);

    // First-launch demo data (runs once, when the database file is created).
    final now = DateTime.now();
    // The Loom 75 keyboard is mid-way through its 24h cooling-off period.
    await db.insert(cooldownHoldsTable, {
      'product_id': 'kb_loom',
      'started_at': now
          .subtract(const Duration(hours: 6, minutes: 18))
          .millisecondsSinceEpoch,
      'expires_at': now
          .add(const Duration(hours: 17, minutes: 42))
          .millisecondsSinceEpoch,
    });
    await _seedStarterData(db, now);
  }

  static Future<void> _onUpgrade(Database db, int oldV, int newV) async {
    if (oldV < 2) {
      // v1 had no cart priority and only seeded the cooldown hold.
      await db.execute(
        "ALTER TABLE $cartItemsTable "
        "ADD COLUMN priority TEXT NOT NULL DEFAULT 'important'",
      );
      await _seedStarterData(db, DateTime.now());
    }
  }

  /// Inserts the demo cart, budget envelope and this month's settled spend,
  /// so a fresh install shows "₹3,200 / ₹5,000". Each table is only seeded
  /// when it is empty, so running this twice never duplicates anything.
  static Future<void> _seedStarterData(
    DatabaseExecutor db,
    DateTime now,
  ) async {
    Future<bool> isEmpty(String table) async =>
        (Sqflite.firstIntValue(
              await db.rawQuery('SELECT COUNT(*) FROM $table'),
            ) ??
            0) ==
        0;

    final nowMs = now.millisecondsSinceEpoch;

    if (await isEmpty(cartItemsTable)) {
      for (var i = 0; i < DemoSeed.cartLines.length; i++) {
        final (productId, quantity, priority) = DemoSeed.cartLines[i];
        await db.insert(cartItemsTable, {
          'product_id': productId,
          'quantity': quantity,
          'priority': priority,
          'position': i,
          'added_at': nowMs,
        });
      }
    }

    if (await isEmpty(budgetProfileTable)) {
      await db.insert(budgetProfileTable, {
        'id': 1,
        'monthly_limit': DemoSeed.monthlyLimit,
        'impulse_buys_avoided': DemoSeed.impulseBuysAvoided,
        'saved_via_cooldown': DemoSeed.savedViaCooldown,
      });
    }

    if (await isEmpty(spendEntriesTable)) {
      for (final (category, amount) in DemoSeed.spend) {
        await db.insert(spendEntriesTable, {
          'category': category,
          'amount': amount,
          'spent_at': nowMs,
        });
      }
    }
  }

  /// Deletes every row (keeps the tables). Handy for resetting a demo.
  Future<void> resetAll() async {
    final batch = db.batch();
    for (final table in const [
      cartItemsTable,
      cooldownHoldsTable,
      budgetProfileTable,
      spendEntriesTable,
      priceObservationsTable,
      watchlistTable,
    ]) {
      batch.delete(table);
    }
    await batch.commit(noResult: true);
  }

  Future<void> close() => db.close();
}
