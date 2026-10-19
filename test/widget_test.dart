import 'package:clarion/core/widgets/frosted_bottom_bar.dart';
import 'package:clarion/core/utils/formatters.dart';
import 'package:clarion/features/home/application/intent_controller.dart';
import 'package:clarion/core/data/mock_catalog.dart';
import 'package:clarion/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Fmt.inr', () {
    test('uses Indian digit grouping', () {
      expect(Fmt.inr(2299), '₹2,299');
      expect(Fmt.inr(123456), '₹1,23,456');
      expect(Fmt.inr(-400), '-₹400');
    });
  });

  group('IntentQuery', () {
    test('parses a budget ceiling and keywords', () {
      final q = IntentQuery.parse('College Setup < ₹3k');
      expect(q.budget, 3000);
      expect(q.keywords, containsAll(['college', 'setup']));
    });

    test('ranks only products within budget', () {
      final q = IntentQuery.parse('Noise-Canceling for Study under 1600');
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

  testWidgets('home renders intent hero and fit picks', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ProviderScope(child: ClarionApp()));
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Clarion'), findsOneWidget);
    expect(find.text('Personal Fit Picks'), findsOneWidget);
    expect(find.text('College Setup < ₹3k'), findsOneWidget);
    expect(find.text('₹5,397 / ₹5,000', findRichText: true), findsOneWidget);
  });

  testWidgets('every tab and the decision view render cleanly', (tester) async {
    await tester.binding.setSurfaceSize(const Size(412, 915));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ProviderScope(child: ClarionApp()));
    await tester.pump(const Duration(seconds: 2));

    for (final tab in ['Compare', 'Guardian', 'Insights', 'Intent']) {
      await tester.tap(
        find.descendant(
          of: find.byType(FrostedBottomBar),
          matching: find.bySemanticsLabel(tab),
        ),
      );
      await tester.pump(const Duration(seconds: 2));
    }

    await tester.tap(find.text('Atlas 30L Commuter Daypack').first);
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Why we recommend this'), findsOneWidget);
    expect(find.text('Leaves ₹701 in your monthly envelope'), findsOneWidget);
  });
}
