import 'package:clarion/data/mock_catalog.dart';
import 'package:clarion/data/models/order_model.dart';
import 'package:clarion/features/decision/application/compare_names.dart';
import 'package:clarion/features/home/application/attention.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final products = {for (final p in MockCatalog.products) p.id: p};
  final now = DateTime(2026, 11, 2, 12);

  group('distinctNames', () {
    test('different brands are named by brand', () {
      final a = products['hp_pro']!;
      final b = MockCatalog.products.firstWhere((p) => p.brand != a.brand);
      expect(distinctNames(a, b), (a.brand, b.brand));
    });

    test('same brand falls back to the model words that differ', () {
      final (pro, core) = distinctNames(
        products['hp_pro']!,
        products['hp_core']!,
      );
      expect(pro, 'Q30 Pro');
      expect(core, 'Q30 Core');
    });
  });

  group('Attention', () {
    List<AttentionItem> collect({
      Map<String, DateTime> holds = const {},
      Map<String, double?> watchlist = const {},
      List<Order> orders = const [],
    }) => Attention.collect(
      holds: holds,
      watchlist: watchlist,
      orders: orders,
      checkins: const [],
      products: products,
      now: now,
    );

    test(
      'nothing pending means an empty list, so the app can say "All clear"',
      () {
        expect(collect(), isEmpty);
      },
    );

    test('only holds that have ended need a decision', () {
      final items = collect(
        holds: {
          'hp_pro': now.subtract(const Duration(minutes: 1)),
          'hp_core': now.add(const Duration(hours: 3)),
        },
      );
      expect(items.map((i) => i.productId), ['hp_pro']);
      expect(items.single.kind, AttentionKind.holdReady);
    });

    test('a watched price counts only once it reaches the target', () {
      final p = products['hp_pro']!;
      expect(collect(watchlist: {p.id: p.price - 1}), isEmpty);
      expect(collect(watchlist: {p.id: null}), isEmpty);
      expect(
        collect(watchlist: {p.id: p.price}).single.kind,
        AttentionKind.targetHit,
      );
    });

    test('a return window is flagged in its last three days, not before', () {
      Order collectedDaysAgo(int days) => Order(
        id: 'CLR-$days',
        placedAt: now.subtract(Duration(days: days + 1)),
        collectedAt: now.subtract(Duration(days: days)),
        lines: const [
          OrderLine(productId: 'hp_pro', title: 'Q30', price: 1, quantity: 1),
        ],
      );
      expect(collect(orders: [collectedDaysAgo(2)]), isEmpty);
      final item = collect(orders: [collectedDaysAgo(5)]).single;
      expect(item.kind, AttentionKind.returnClosing);
      expect(item.detail, 'Return window closes in 2 days.');
      expect(collect(orders: [collectedDaysAgo(8)]), isEmpty);
    });

    test('ready decisions come before good prices', () {
      final p = products['hp_core']!;
      final items = collect(
        watchlist: {p.id: p.price},
        holds: {'hp_pro': now.subtract(const Duration(hours: 1))},
      );
      expect(items.map((i) => i.kind), [
        AttentionKind.holdReady,
        AttentionKind.targetHit,
      ]);
    });
  });
}
