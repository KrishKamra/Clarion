import 'package:clarion/core/links/deep_links.dart';
import 'package:clarion/core/widgets/floating_nav_capsule.dart';
import 'package:clarion/data/catalog.dart';
import 'package:clarion/data/mock_catalog.dart';
import 'package:clarion/data/mock_reviews.dart';
import 'package:clarion/data/models/order_model.dart';
import 'package:clarion/data/models/product_model.dart';
import 'package:clarion/data/models/review_model.dart';
import 'package:clarion/features/browse/application/browse_controller.dart';
import 'package:clarion/features/browse/presentation/browse_screen.dart';
import 'package:clarion/features/cart/application/budget_controller.dart';
import 'package:clarion/features/cart/application/cart_controller.dart';
import 'package:clarion/features/decision/presentation/product_decision_screen.dart';
import 'package:clarion/features/navigation/main_scaffold.dart';
import 'package:clarion/features/orders/application/orders_controller.dart';
import 'package:clarion/features/orders/presentation/order_detail_screen.dart';
import 'package:clarion/features/reviews/application/reviews_controller.dart';
import 'package:clarion/core/theme/locale_controller.dart';
import 'package:clarion/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'demo_scenario.dart';

void main() {
  final catalog = Catalog(MockCatalog.products, MockCatalog.comparePairs);
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Order order({DateTime? placedAt, DateTime? collectedAt}) => Order(
    id: 'CLR-TEST',
    placedAt: placedAt ?? DateTime(2026, 10, 1, 10),
    collectedAt: collectedAt,
    pickupArea: 'Vile Parle',
    lines: const [
      OrderLine(productId: 'hp_pro', title: 'Q30', price: 1899, quantity: 1),
      OrderLine(productId: 'lamp_halo', title: 'Halo', price: 850, quantity: 2),
    ],
  );

  group('Order tracking', () {
    test('stages follow the clock until pickup is confirmed', () {
      final o = order();
      final t = o.placedAt;
      expect(o.stageAt(t), OrderStage.placed);
      expect(o.stageAt(t.add(Order.packedAfter)), OrderStage.packed);
      expect(o.stageAt(t.add(Order.readyAfter)), OrderStage.ready);
      expect(o.stageAt(t.add(const Duration(days: 9))), OrderStage.ready);
      final collected = o.copyWith(
        collectedAt: t.add(const Duration(hours: 2)),
      );
      expect(collected.stageAt(t), OrderStage.collected);
      expect(o.total, 1899 + 1700);
      expect(o.itemCount, 3);
    });

    test('items can be cancelled before pickup, returned within 7 days', () {
      final t = DateTime(2026, 10, 1, 10);
      expect(
        order(placedAt: t).canReturn(t.add(const Duration(days: 30))),
        isTrue,
      );
      final collected = order(placedAt: t, collectedAt: t);
      expect(collected.canReturn(t.add(const Duration(days: 6))), isTrue);
      expect(collected.canReturn(t.add(const Duration(days: 7))), isFalse);
    });

    test('a return is refunded a day later, a cancellation at once', () {
      final t = DateTime(2026, 10, 1);
      const reason = ReturnReason.changedMind;
      final returned = ReturnRequest(
        reason: reason,
        requestedAt: t,
        beforePickup: false,
      );
      expect(returned.isRefunded(t), isFalse);
      expect(returned.isRefunded(t.add(ReturnRequest.refundAfter)), isTrue);
      expect(
        ReturnRequest(
          reason: reason,
          requestedAt: t,
          beforePickup: true,
        ).isRefunded(t),
        isTrue,
      );
    });

    test('checkout places an order; cancelling refunds the envelope', () {
      final container = ProviderContainer(overrides: demoScenario());
      addTearDown(container.dispose);
      final lines = container.read(cartProvider);
      final spentBefore = container.read(budgetProvider).spentThisMonth;

      final placed = container.read(ordersProvider.notifier).place(lines);
      container.read(budgetProvider.notifier).recordPurchase(lines);
      expect(container.read(ordersProvider).single.id, placed.id);
      expect(placed.id, startsWith('CLR-'));
      expect(placed.pickupArea, isNotNull);
      final cartTotal = lines.fold<double>(0, (s, l) => s + l.subtotal);
      expect(
        container.read(budgetProvider).spentThisMonth,
        spentBefore + cartTotal,
      );

      final line = placed.lines.first;
      container
          .read(ordersProvider.notifier)
          .requestReturn(placed.id, line.productId, ReturnReason.foundBetter);
      final after = container.read(ordersProvider).single;
      expect(after.lines.first.returned?.beforePickup, isTrue);
      expect(after.refunded, line.subtotal);
      expect(
        container.read(budgetProvider).spentThisMonth,
        spentBefore + cartTotal - line.subtotal,
      );
      // Returned items are no longer a verified purchase.
      expect(
        container.read(purchasedProductIdsProvider),
        isNot(contains(line.productId)),
      );
    });
  });

  group('Browse', () {
    int fit(Product p) => p.fitScore;

    test('defaults to the whole catalogue, best fit first', () {
      final all = const BrowseFilters().apply(catalog.products, fit);
      expect(all, hasLength(catalog.products.length));
      for (var i = 1; i < all.length; i++) {
        expect(all[i - 1].fitScore, greaterThanOrEqualTo(all[i].fitScore));
      }
    });

    test('filters narrow by category, price, rating, pickup and dip', () {
      const f = BrowseFilters(
        category: 'Audio',
        maxPrice: 2000,
        minRating: 4.4,
        pickupOnly: true,
        belowAverageOnly: true,
      );
      final result = f.apply(catalog.products, fit);
      expect(result, isNotEmpty);
      for (final p in result) {
        expect(p.category, 'Audio');
        expect(p.price, lessThanOrEqualTo(2000));
        expect(p.rating, greaterThanOrEqualTo(4.4));
        expect(p.pickup, isNotNull);
        expect(p.discountVsAverage, greaterThan(0));
      }
      expect(f.activeCount, 4);
      expect(f.cleared().activeCount, 0);
      expect(f.cleared().category, 'Audio');
    });

    test('every sort order is honoured', () {
      List<double> prices(BrowseSort s) =>
          BrowseFilters(sort: s)
              .apply(catalog.products, fit)
              .map((p) => p.price)
              .toList();
      final low = prices(BrowseSort.priceLow);
      expect(low, [...low]..sort());
      expect(prices(BrowseSort.priceHigh), low.reversed.toList());
      final dips = const BrowseFilters(sort: BrowseSort.biggestDip)
          .apply(catalog.products, fit)
          .map((p) => p.discountVsAverage)
          .toList();
      expect(dips, [...dips]..sort((a, b) => b.compareTo(a)));
    });
  });

  group('Deep links', () {
    test('both link forms open the same places', () {
      for (final (uri, link) in [
        ('https://clarion-e08f0.web.app/p/bp_atlas', ProductLink('bp_atlas')),
        ('clarion://product/bp_atlas', ProductLink('bp_atlas')),
        ('clarion://orders/CLR-1', OrderLink('CLR-1')),
        ('https://clarion-e08f0.web.app/orders/CLR-1', OrderLink('CLR-1')),
        ('clarion://browse?category=Audio', BrowseLink('Audio')),
        ('https://clarion-e08f0.web.app/browse', BrowseLink()),
      ]) {
        expect(DeepLink.parse(Uri.parse(uri)), link, reason: uri);
      }
    });

    test('foreign hosts and unknown paths are ignored', () {
      for (final uri in [
        'https://evil.example/p/bp_atlas',
        'clarion://product',
        'clarion://settings/x',
        'https://clarion-e08f0.web.app/',
        'mailto:someone@example.com',
      ]) {
        expect(DeepLink.parse(Uri.parse(uri)), isNull, reason: uri);
      }
    });

    test('shared links round-trip', () {
      for (final link in [
        const ProductLink('hp_core'),
        const OrderLink('CLR-ABC'),
        const BrowseLink('Study'),
      ]) {
        expect(DeepLink.parse(link.uri), link);
      }
    });
  });

  group('Reviews', () {
    test('every product has owner reviews with real content', () {
      for (final p in catalog.products) {
        final reviews = MockReviews.forProduct(p.id);
        expect(reviews, isNotEmpty, reason: p.id);
        for (final r in reviews) {
          expect(r.rating, inInclusiveRange(1, 5));
          expect(r.body.length, greaterThan(40), reason: p.id);
        }
      }
    });

    test('the estimated spread matches the stated rating', () {
      for (final p in catalog.products) {
        final s = RatingSummary.estimate(p.rating, p.reviewCount);
        final total = s.histogram.fold<int>(0, (a, b) => a + b);
        expect(total, closeTo(p.reviewCount, 3), reason: p.id);
        final mean =
            [for (var i = 0; i < 5; i++) s.histogram[i] * (i + 1)]
                .fold<int>(0, (a, b) => a + b) /
            total;
        expect(mean, closeTo(p.rating, 0.02), reason: p.id);
      }
    });

    test('your review comes first and counts in the summary', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container
          .read(myReviewsProvider.notifier)
          .save('bp_atlas', rating: 1, body: 'Strap broke on day three.');
      final reviews = container.read(productReviewsProvider('bp_atlas'));
      expect(reviews.first.mine, isTrue);
      final summary = container.read(ratingSummaryProvider('bp_atlas'));
      final base = RatingSummary.estimate(4.6, 2184);
      expect(summary.count, base.count + 1);
      expect(summary.histogram.first, base.histogram.first + 1);
    });
  });

  Future<void> pumpApp(WidgetTester tester, ProviderContainer container) async {
    await tester.binding.setSurfaceSize(const Size(412, 915));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const ClarionApp(),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
  }

  BuildContext shell(WidgetTester tester) =>
      tester.element(find.byType(MainScaffold));

  testWidgets('browse filters by category and opens a product', (tester) async {
    final container = ProviderContainer(overrides: demoScenario());
    addTearDown(container.dispose);
    await pumpApp(tester, container);

    BrowseScreen.open(shell(tester), category: 'Audio');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    final audio = catalog.products.where((p) => p.category == 'Audio');
    expect(find.byType(BrowseRow), findsNWidgets(audio.length));

    await tester.tap(find.text('All'));
    await tester.pump(const Duration(seconds: 1));
    expect(container.read(browseProvider).category, isNull);

    await tester.tap(find.byType(BrowseRow).first);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(ProductDecisionScreen), findsOneWidget);
  });

  testWidgets('an order can be tracked and an item cancelled', (tester) async {
    final container = ProviderContainer(overrides: demoScenario());
    addTearDown(container.dispose);
    final placed = container
        .read(ordersProvider.notifier)
        .place(container.read(cartProvider));
    await pumpApp(tester, container);

    OrderDetailScreen.open(shell(tester), placed.id);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Order placed'), findsWidgets);
    expect(find.text('Cancel item'), findsNWidgets(placed.lines.length));

    await tester.tap(find.text('Cancel item').first);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    final confirm = find.text('Cancel this item');
    expect(tester.widget<Text>(confirm), isNotNull);
    await tester.tap(find.text('Changed my mind'));
    await tester.pump();
    await tester.tap(confirm);
    await tester.pump(const Duration(seconds: 1));

    final line = container.read(ordersProvider).single.lines.first;
    expect(line.returned?.reason, ReturnReason.changedMind);
    expect(find.textContaining('Refunded'), findsWidgets);
  });

  testWidgets('a deep link opens its product once the shell is up', (
    tester,
  ) async {
    final container = ProviderContainer(overrides: demoScenario());
    addTearDown(container.dispose);
    await pumpApp(tester, container);

    DeepLinks.open(Uri.parse('clarion://product/hp_core'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(ProductDecisionScreen), findsOneWidget);
    expect(DeepLinks.pending.value, isNull);

    // An unknown id is dropped rather than crashing.
    DeepLinks.open(Uri.parse('clarion://product/nope'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(ProductDecisionScreen), findsOneWidget);
  });

  testWidgets('the app speaks Hindi when chosen', (tester) async {
    final container = ProviderContainer(overrides: demoScenario());
    addTearDown(container.dispose);
    await pumpApp(tester, container);

    container.read(localeProvider.notifier).select(const Locale('hi'));
    await tester.pump(const Duration(seconds: 1));
    final nav = find.byType(FloatingNavCapsule);
    expect(
      find.descendant(of: nav, matching: find.bySemanticsLabel('तुलना')),
      findsOneWidget,
    );

    container.read(localeProvider.notifier).select(null);
    await tester.pump(const Duration(seconds: 1));
    expect(
      find.descendant(of: nav, matching: find.bySemanticsLabel('Compare')),
      findsOneWidget,
    );
  });
}
