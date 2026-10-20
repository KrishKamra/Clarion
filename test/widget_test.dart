import 'package:clarion/core/data/catalog.dart';
import 'package:clarion/core/data/mock_catalog.dart';
import 'package:clarion/core/utils/formatters.dart';
import 'package:clarion/core/widgets/floating_nav_bar.dart';
import 'package:clarion/features/budget/application/budget_controller.dart';
import 'package:clarion/features/cart/application/cart_controller.dart';
import 'package:clarion/features/home/application/intent_controller.dart';
import 'package:clarion/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Fmt', () {
    test('uses Indian digit grouping', () {
      expect(Fmt.inr(2199), '₹2,199');
      expect(Fmt.inr(123456), '₹1,23,456');
      expect(Fmt.inr(-400), '-₹400');
    });

    test('formats signed, zero-padded fit points', () {
      expect(Fmt.points(35), '+35');
      expect(Fmt.points(-8), '−08');
    });
  });

  group('IntentQuery', () {
    test('parses a rupee ceiling and keywords', () {
      final q = IntentQuery.parse('Daily EDC for College < ₹2,500');
      expect(q.budget, 2500);
      expect(q.keywords, containsAll(['daily', 'edc', 'college']));
    });

    test('ranks only products within budget', () {
      final q = IntentQuery.parse('Active Noise Cancellation under 1600');
      final ranked = q.rank(MockCatalog.products);
      expect(ranked, isNotEmpty);
      expect(ranked.every((p) => p.price <= 1600), isTrue);
      expect(ranked.first.id, 'hp_flow');
    });
  });

  test('fit factors sum to each fit score', () {
    for (final p in MockCatalog.products) {
      final sum = p.fitFactors.fold<int>(0, (s, f) => s + f.points);
      expect(sum, p.fitScore, reason: p.id);
    }
  });

  group('Budget Guardian', () {
    test('seed state matches the ₹3,200 / ₹5,000 envelope', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final b = container.read(budgetSnapshotProvider);
      expect(b.committed, 3200);
      expect(b.limit, 5000);
      expect(b.leftAfter(2199), 801);
    });

    test('swap engine brings an over-budget cart back within the ceiling', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(cartProvider.notifier).add('bp_atlas');
      expect(container.read(budgetSnapshotProvider).overBy, 399);

      final swap = container.read(swapSuggestionsProvider).first;
      expect(swap.to.id, 'bp_metro');
      container.read(cartProvider.notifier).swap(swap.from.id, swap.to.id);
      expect(container.read(budgetSnapshotProvider).isOver, isFalse);
      expect(container.read(budgetSnapshotProvider).headroom, 51);
    });
  });

  test('catalogue resolves every alternative and compare pair', () {
    final catalog = Catalog(MockCatalog.products, MockCatalog.comparePairs);
    for (final p in catalog.products) {
      if (p.alternativeId != null) catalog.byId(p.alternativeId!);
    }
    for (final pair in catalog.comparePairs) {
      catalog
        ..byId(pair.leftId)
        ..byId(pair.rightId);
    }
  });

  testWidgets('horizon renders header metric, intent canvas and stream', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ProviderScope(child: ClarionApp()));
    await tester.pump(const Duration(seconds: 2));

    expect(find.bySemanticsLabel('Clarion'), findsOneWidget);
    expect(find.text('₹3,200 / ₹5,000', findRichText: true), findsOneWidget);
    expect(find.text('What are you seeking to accomplish?'), findsOneWidget);
    expect(find.text('Daily EDC for College < ₹2,500'), findsOneWidget);
    expect(find.text('CURATED FIT STREAM'), findsOneWidget);
  });

  testWidgets('guardian swap engine renders when the cart breaches', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(412, 915));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(cartProvider.notifier).add('bp_atlas');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const ClarionApp(),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(
      find.descendant(
        of: find.byType(FloatingNavBar),
        matching: find.bySemanticsLabel('Guardian'),
      ),
    );
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('GUARDIAN SWAP ENGINE'), findsOneWidget);
    await tester.tap(find.text('Swap · save ₹450'));
    await tester.pump(const Duration(seconds: 2));
    expect(container.read(budgetSnapshotProvider).isOver, isFalse);
    expect(find.text('GUARDIAN SWAP ENGINE'), findsNothing);
  });

  testWidgets('every tab and the decision canvas render cleanly', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(412, 915));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ProviderScope(child: ClarionApp()));
    await tester.pump(const Duration(seconds: 2));

    for (final tab in ['Decide', 'Guardian', 'Memory', 'Horizon']) {
      await tester.tap(
        find.descendant(
          of: find.byType(FloatingNavBar),
          matching: find.bySemanticsLabel(tab),
        ),
      );
      await tester.pump(const Duration(seconds: 2));
    }

    await tester.tap(find.text('Atlas 30L Commuter Daypack').first);
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('WHY THIS FITS YOU'), findsOneWidget);
    expect(find.text('+35'), findsOneWidget);
    expect(find.text('−08'), findsOneWidget);
    expect(
      find.text('Leaves ₹801 safe buffer', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('24h Cooling Off'), findsOneWidget);
  });
}
