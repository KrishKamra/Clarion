import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

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
  /// v3: accounts start empty; clears the demo cart, hold and spend that
  ///     v1/v2 databases were seeded with.
  /// v4: checkout records each product by name instead of a lump "Planned".
  /// v5: post-purchase Regret Check-ins (`regret_checkins`).
  static const int schemaVersion = 5;

  // Table names, kept in one place so repositories never mistype them.
  static const String cartItemsTable = 'cart_items';
  static const String cooldownHoldsTable = 'cooldown_holds';
  static const String budgetProfileTable = 'budget_profile';
  static const String spendEntriesTable = 'spend_entries';
  static const String priceObservationsTable = 'price_observations';
  static const String watchlistTable = 'watchlist';
  static const String regretCheckinsTable = 'regret_checkins';

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

    // Post-purchase Regret Check-ins.
    batch.execute('''
      CREATE TABLE $regretCheckinsTable (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        spend_id      INTEGER,
        product_title TEXT    NOT NULL,
        amount        REAL    NOT NULL CHECK (amount >= 0),
        rating        TEXT    NOT NULL,
        tag           TEXT,
        note          TEXT,
        checked_in_at INTEGER NOT NULL
      )
    ''');

    await batch.commit(noResult: true);
  }

  static Future<void> _onUpgrade(Database db, int oldV, int newV) async {
    if (oldV < 2) {
      await db.execute(
        "ALTER TABLE $cartItemsTable "
        "ADD COLUMN priority TEXT NOT NULL DEFAULT 'important'",
      );
    }
    if (oldV < 3) {
      // Earlier builds seeded every account with a demo cart, cooling-off
      // hold, spend and stats. Wipe them once; the budget row is recreated
      // from the (now empty) defaults the next time it is loaded.
      final batch = db.batch();
      for (final table in const [
        cartItemsTable,
        cooldownHoldsTable,
        budgetProfileTable,
        spendEntriesTable,
        watchlistTable,
      ]) {
        batch.delete(table);
      }
      await batch.commit(noResult: true);
    }
    if (oldV < 4) {
      // Old lump-sum checkouts have no product names to recover.
      await db.update(
        spendEntriesTable,
        {'category': 'Earlier order'},
        where: 'category = ?',
        whereArgs: ['Planned'],
      );
    }
    if (oldV < 5) {
      await db.execute('''
        CREATE TABLE $regretCheckinsTable (
          id            INTEGER PRIMARY KEY AUTOINCREMENT,
          spend_id      INTEGER,
          product_title TEXT    NOT NULL,
          amount        REAL    NOT NULL CHECK (amount >= 0),
          rating        TEXT    NOT NULL,
          tag           TEXT,
          note          TEXT,
          checked_in_at INTEGER NOT NULL
        )
      ''');
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
      regretCheckinsTable,
    ]) {
      batch.delete(table);
    }
    await batch.commit(noResult: true);
  }

  Future<void> close() => db.close();
}
