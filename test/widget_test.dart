import 'package:clarion/core/theme/app_colors.dart';
import 'package:clarion/core/utils/formatters.dart';
import 'package:clarion/core/widgets/fit_score_gauge.dart';
import 'package:clarion/core/widgets/floating_nav_capsule.dart';
import 'package:clarion/data/catalog.dart';
import 'package:clarion/data/mock_catalog.dart';
import 'package:clarion/data/models/cart_item_model.dart';
import 'package:clarion/features/cart/application/budget_controller.dart';
import 'package:clarion/features/cart/application/cart_controller.dart';
import 'package:clarion/features/decision/application/cooldown_controller.dart';
import 'package:clarion/features/decision/application/fit_engine.dart';
import 'package:clarion/features/decision/presentation/product_decision_screen.dart';
import 'package:clarion/features/home/application/intent_controller.dart';
import 'package:clarion/features/home/presentation/widgets/fit_stream.dart';
import 'package:clarion/features/navigation/main_scaffold.dart';
import 'package:clarion/features/navigation/navigation_controller.dart';
import 'package:clarion/features/profile/presentation/spending_profile_screen.dart';
import 'package:clarion/features/tour/app_tour.dart';
import 'package:clarion/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'demo_scenario.dart';

void main() {
  group('Fmt', () {
    test('uses Indian digit grouping', () {
      expect(Fmt.inr(2199), '₹2,199');
      expect(Fmt.inr(123456), '₹1,23,456');
      expect(Fmt.inr(-400), '-₹400');
    });

    test('formats signed, zero-padded weights and short dates', () {
      expect(Fmt.points(35), '+35');
      expect(Fmt.points(-8), '−08');
      expect(Fmt.shortDate(DateTime(2026, 10, 7)), 'Oct 07');
    });
  });

  group('IntentQuery', () {
    test('parses a compact rupee ceiling and keywords', () {
      final q = IntentQuery.parse('College Setup < ₹2.5k');
      expect(q.budget, 2500);
      expect(q.keywords, containsAll(['college', 'setup']));
    });

    test('words that match nothing return no products', () {
      final q = IntentQuery.parse('Ball');
      expect(q.keywords, {'ball'});
      expect(q.rank(MockCatalog.products), isEmpty);
      expect(
        IntentQuery.parse('Ball under 2000').rank(MockCatalog.products),
        isEmpty,
      );
    });

    test('a goal with no words falls back to everything within budget', () {
      final ranked = IntentQuery.parse('under 1000').rank(MockCatalog.products);
      expect(ranked, isNotEmpty);
      expect(ranked.every((p) => p.price <= 1000), isTrue);
    });

    test('singular and plural words find the same products', () {
      final one = IntentQuery.parse('headphone').rank(MockCatalog.products);
      final many = IntentQuery.parse('headphones').rank(MockCatalog.products);
      expect(one, isNotEmpty);
      expect(one.map((p) => p.id), many.map((p) => p.id));
      expect(one.every((p) => p.category == 'Audio'), isTrue);
    });

    test('ranks only products within budget', () {
      final q = IntentQuery.parse('ANC for Focus under 1600');
      final ranked = q.rank(MockCatalog.products);
      expect(ranked, isNotEmpty);
      expect(ranked.every((p) => p.price <= 1600), isTrue);
      expect(ranked.first.id, 'hp_core');
    });
  });

  group('Catalogue integrity', () {
    final catalog = Catalog(MockCatalog.products, MockCatalog.comparePairs);

    test('trade-off weights sum to each fit score', () {
      for (final p in catalog.products) {
        final sum = p.tradeOffs.fold<int>(0, (s, t) => s + t.weight);
        expect(sum, p.fitScore, reason: p.id);
      }
    });

    test('price histories span 30 days and end at today\'s price', () {
      for (final p in catalog.products) {
        expect(p.priceHistory, hasLength(30), reason: p.id);
        expect(p.priceHistory.last.price, p.price, reason: p.id);
        final mean = p.priceHistory.fold<double>(0, (s, x) => s + x.price) / 30;
        expect(mean, closeTo(p.averagePrice30d, 0.01), reason: p.id);
      }
    });

    test('alternatives and compare pairs resolve', () {
      for (final p in catalog.products) {
        if (p.alternativeId != null) catalog.byId(p.alternativeId!);
      }
      for (final pair in catalog.comparePairs) {
        catalog
          ..byId(pair.leftId)
          ..byId(pair.rightId);
      }
    });

    test('the catalogue has a realistic mix of price positions', () {
      expect(catalog.products.length, greaterThanOrEqualTo(15));
      final ids = catalog.products.map((p) => p.id).toList();
      expect(ids.toSet(), hasLength(ids.length));
      final atLow = catalog.products.where((p) => p.bandPosition <= 0.25);
      final midBand = catalog.products.where(
        (p) => p.bandPosition > 0.25 && p.bandPosition < 0.75,
      );
      final atHigh = catalog.products.where((p) => p.bandPosition >= 0.75);
      expect(atLow, isNotEmpty);
      expect(midBand, isNotEmpty);
      expect(atHigh, isNotEmpty);
      // Not everything is a deal: some products cost more than usual.
      expect(
        catalog.products.where((p) => p.discountVsAverage < 0),
        isNotEmpty,
      );
      expect(atLow.length, lessThan(catalog.products.length ~/ 2 + 1));
    });

    test('price radar lists deep discounts, deepest first', () {
      final radar = catalog.priceRadar;
      expect(radar.map((p) => p.id), ['hp_pro', 'sling_field']);
      expect(radar.first.averagePrice30d, 2350);
    });
  });

  group('Budget Guardian', () {
    test('a new account starts empty', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(cartProvider), isEmpty);
      expect(container.read(cooldownProvider), isEmpty);
      final b = container.read(budgetSnapshotProvider);
      expect(b.committed, 0);
      expect(b.limit, 5000);
      expect(container.read(budgetProvider).impulseBuysAvoided, 0);
      expect(container.read(budgetProvider).savedViaCooldown, 0);
    });

    test('demo scenario matches the ₹3,200 / ₹5,000 envelope', () {
      final container = ProviderContainer(overrides: demoScenario());
      addTearDown(container.dispose);
      final b = container.read(budgetSnapshotProvider);
      expect(b.committed, 3200);
      expect(b.limit, 5000);
      expect(b.leftAfter(2199), 801);
    });

    test('checkout records each product by name, not a lump sum', () {
      final container = ProviderContainer(overrides: demoScenario());
      addTearDown(container.dispose);
      container.read(cartProvider.notifier).add('hp_pro');
      final total = container.read(cartTotalProvider);
      final title = MockCatalog.products
          .firstWhere((p) => p.id == 'hp_pro')
          .title;

      container
          .read(budgetProvider.notifier)
          .recordPurchase(container.read(cartProvider));

      final budget = container.read(budgetProvider);
      final labels = budget.categories.map((c) => c.label);
      expect(labels, contains(title));
      expect(labels, isNot(contains('Planned')));
      expect(budget.spentThisMonth, 2000 + total);
    });

    test('swap engine regains ₹400 by swapping Pro for Core Edition', () {
      final container = ProviderContainer(overrides: demoScenario());
      addTearDown(container.dispose);
      container.read(cartProvider.notifier).add('hp_pro');
      expect(container.read(budgetSnapshotProvider).overBy, 99);

      final swap = container.read(swapSuggestionsProvider).single;
      expect(swap.to.id, 'hp_core');
      expect(swap.savings, 400);
      expect(swap.parity, 94);

      container.read(cartProvider.notifier).swap(swap.from.id, swap.to.id);
      expect(container.read(budgetSnapshotProvider).isOver, isFalse);
    });

    test('intent priority cycles and survives a swap', () {
      final container = ProviderContainer(overrides: demoScenario());
      addTearDown(container.dispose);
      final cart = container.read(cartProvider.notifier)..add('hp_pro');
      cart.cyclePriority('hp_pro');
      cart.swap('hp_pro', 'hp_core');
      final item = container.read(cartProvider).last;
      expect(item.productId, 'hp_core');
      expect(item.priority, IntentPriority.niceToHave);
    });
  });

  Future<void> pumpApp(
    WidgetTester tester, {
    ProviderContainer? container,
  }) async {
    await tester.binding.setSurfaceSize(const Size(412, 915));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    const app = ClarionApp();
    await tester.pumpWidget(
      container == null
          ? ProviderScope(overrides: demoScenario(), child: app)
          : UncontrolledProviderScope(container: container, child: app),
    );
    await tester.pump(const Duration(seconds: 2));
  }

  /// Opens the Atlas backpack's decision canvas directly. Fit scores are now
  /// computed, so Atlas is no longer guaranteed to be the first card built in
  /// the horizontal stream.
  Future<void> openAtlas(WidgetTester tester) async {
    ProductDecisionScreen.open(
      tester.element(find.byType(MainScaffold)),
      'bp_atlas',
    );
  }

  Future<void> openTab(WidgetTester tester, String label) async {
    await tester.tap(
      find.descendant(
        of: find.byType(FloatingNavCapsule),
        matching: find.bySemanticsLabel(label),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
  }

  testWidgets('horizon renders header, intent field, stream and radar', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.bySemanticsLabel('Clarion'), findsOneWidget);
    expect(find.text('₹1,800 left'), findsOneWidget);
    expect(find.text('What are you seeking to accomplish?'), findsOneWidget);
    expect(find.text('College Setup < ₹2.5k'), findsOneWidget);
    expect(find.text('Personal Fit Stream'), findsOneWidget);
    expect(find.byType(FitScoreGauge), findsWidgets);

    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, -600),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Radar'), findsOneWidget);
  });

  testWidgets('a goal that matches nothing says so', (tester) async {
    final container = ProviderContainer(overrides: demoScenario());
    addTearDown(container.dispose);
    await pumpApp(tester, container: container);

    container.read(intentProvider.notifier).submit('Ball');
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('No matches found'), findsOneWidget);
    expect(find.byType(FitStreamCard), findsNothing);
  });

  testWidgets('every tab and the decision canvas render cleanly', (
    tester,
  ) async {
    await pumpApp(tester);
    for (final tab in ['Compare', 'Guardian', 'Profile', 'Horizon']) {
      await openTab(tester, tab);
    }

    await openAtlas(tester);
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Why We Recommend This'), findsOneWidget);
    for (final line in [
      FitEngine.intentTitle,
      FitEngine.budgetTitle,
      FitEngine.timingTitle,
      FitEngine.ratingTitle,
    ]) {
      expect(find.text(line), findsOneWidget, reason: line);
    }
    expect(
      find.text(
        'Leaves ₹801 safe buffer in your monthly limit',
        findRichText: true,
      ),
      findsOneWidget,
    );
    expect(find.text('24h Cooling Off'), findsOneWidget);
  });

  testWidgets('holding the cooling-off button parks the product', (
    tester,
  ) async {
    final container = ProviderContainer(overrides: demoScenario());
    addTearDown(container.dispose);
    await pumpApp(tester, container: container);

    await openAtlas(tester);
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    final hold = await tester.startGesture(
      tester.getCenter(find.text('24h Cooling Off')),
    );
    await tester.pump(); // first frame starts the hold ticker
    await tester.pump(const Duration(milliseconds: 600));
    expect(container.read(cooldownProvider).containsKey('bp_atlas'), isFalse);
    await tester.pump(const Duration(milliseconds: 800));
    await hold.up();
    await tester.pump(const Duration(seconds: 1));
    expect(container.read(cooldownProvider).containsKey('bp_atlas'), isTrue);
  });

  testWidgets('specifications open on demand', (tester) async {
    await pumpApp(tester);
    await openAtlas(tester);
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    final reveal = find.text('Show all 7 specifications');
    final canvas = find.byType(CustomScrollView).last;
    await tester.scrollUntilVisible(
      reveal,
      300,
      scrollable: find
          .descendant(of: canvas, matching: find.byType(Scrollable))
          .first,
    );
    // Lift it clear of the decision bar before tapping.
    await tester.drag(canvas, const Offset(0, -260));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Harness'), findsNothing);
    await tester.tap(reveal);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Harness'), findsOneWidget);
  });

  testWidgets('guardian swap engine resolves a breach in one tap', (
    tester,
  ) async {
    final container = ProviderContainer(overrides: demoScenario());
    addTearDown(container.dispose);
    container.read(cartProvider.notifier).add('hp_pro');
    await pumpApp(tester, container: container);
    await openTab(tester, 'Guardian');

    expect(find.text('₹99 over monthly limit.'), findsOneWidget);
    expect(find.text('Swap option available.'), findsOneWidget);
    await tester.tap(find.text('Swap · regain ₹400'));
    await tester.pump(const Duration(seconds: 2));
    expect(container.read(budgetSnapshotProvider).isOver, isFalse);
    expect(find.text('Swap option available.'), findsNothing);
  });

  testWidgets('the app tour is hands-on: it asks for a tap, then moves on', (
    tester,
  ) async {
    final container = ProviderContainer(overrides: demoScenario());
    addTearDown(container.dispose);
    await pumpApp(tester, container: container);

    container.read(appTourProvider.notifier).start();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('A quick hands-on tour'), findsOneWidget);

    await tester.tap(find.text('Begin tour'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Tap the highlighted goal'), findsOneWidget);

    // The tap passes through the spotlight to the real suggestion pill...
    await tester.tap(find.text('College Setup < ₹2.5k'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 700));
    expect(container.read(intentProvider), isNotNull);

    // ...and the tour moves on to the next thing to tap.
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Tap the top product to open it'), findsOneWidget);

    await tester.tap(find.text('Skip'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(container.read(appTourProvider), isNull);
    expect(container.read(navigationProvider), AppTab.horizon);
    expect(container.read(intentProvider), isNull); // tidied up
  });

  testWidgets('appearance switches live, including const subtrees', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await pumpApp(tester);
    // The test platform reports light, and the default follows the system.
    expect(AppColors.isDark, isFalse);

    await openTab(tester, 'Profile');
    await tester.scrollUntilVisible(
      find.text('Dark'),
      300,
      scrollable: find.descendant(
        of: find.byType(SpendingProfileScreen),
        matching: find.byType(Scrollable),
      ),
    );
    Color? titleInk() => tester
        .renderObject<RenderParagraph>(find.text('Appearance'))
        .text
        .style
        ?.color;
    final lightInk = titleInk();

    await tester.tap(find.text('Dark'));
    await tester.pump(const Duration(seconds: 1));
    expect(AppColors.isDark, isTrue);
    expect(titleInk(), isNot(lightInk));
    expect(titleInk(), AppColors.textPrimary);

    await tester.tap(find.text('Light'));
    await tester.pump(const Duration(seconds: 1));
    expect(titleInk(), lightInk);
  });
}
