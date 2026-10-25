import 'package:clarion/data/catalog.dart';
import 'package:clarion/data/mock_catalog.dart';
import 'package:clarion/data/models/product_model.dart';
import 'package:clarion/features/cart/application/budget_controller.dart';
import 'package:clarion/features/decision/application/fit_engine.dart';
import 'package:clarion/features/home/application/intent_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'demo_scenario.dart';

void main() {
  final catalog = Catalog(MockCatalog.products, MockCatalog.comparePairs);
  Product product(String id) => catalog.byId(id);

  int line(FitResult r, String title) =>
      r.items.firstWhere((t) => t.title == title).weight;

  const noGoal = FitContext(monthlyLimit: 5000, spentThisMonth: 2000);

  group('Heuristic Fit Engine', () {
    test('score is 0-100 and equals the sum of its lines', () {
      const contexts = [
        noGoal,
        FitContext(
          keywords: {'college', 'setup'},
          intentBudget: 2500,
          monthlyLimit: 5000,
          spentThisMonth: 2000,
        ),
        FitContext(monthlyLimit: 1000, spentThisMonth: 2000), // overspent
        FitContext(monthlyLimit: 0, spentThisMonth: 0), // no envelope
      ];
      for (final c in contexts) {
        for (final p in catalog.products) {
          final r = FitEngine.evaluate(p, c);
          expect(r.score, inInclusiveRange(0, 100), reason: p.id);
          final sum = r.items.fold<int>(0, (s, t) => s + t.weight);
          expect(sum, r.score, reason: p.id);
          expect(r.reasons, isNotEmpty, reason: p.id);
        }
      }
    });

    test('no stated goal gives neutral goal match', () {
      final r = FitEngine.evaluate(product('bp_atlas'), noGoal);
      expect(line(r, FitEngine.intentTitle), FitEngine.neutralIntent);
    });

    test('matching goal words raise the goal match', () {
      const goal = FitContext(
        keywords: {'backpack', 'commute'},
        monthlyLimit: 5000,
        spentThisMonth: 2000,
      );
      final atlas = FitEngine.evaluate(product('bp_atlas'), goal);
      final headphones = FitEngine.evaluate(product('hp_pro'), goal);
      expect(line(atlas, FitEngine.intentTitle), FitEngine.maxIntent);
      expect(line(headphones, FitEngine.intentTitle), 0);
      expect(atlas.score, greaterThan(headphones.score));
    });

    test('every line has a plain-language verdict', () {
      for (final p in catalog.products) {
        final r = FitEngine.evaluate(p, noGoal);
        for (final item in r.items) {
          expect(item.verdict, isNotNull, reason: '${p.id} ${item.title}');
        }
        expect([
          'Great fit',
          'Good fit',
          'Fair fit',
          'Poor fit',
        ], contains(r.headline));
      }
      final neutral = FitEngine.evaluate(product('bp_atlas'), noGoal);
      expect(
        neutral.items
            .firstWhere((t) => t.title == FitEngine.intentTitle)
            .verdict,
        'Neutral',
      );
    });

    test('card highlights never lead with the budget line', () {
      for (final p in catalog.products) {
        final h = FitEngine.evaluate(p, noGoal).highlights;
        expect(h, isNotEmpty, reason: p.id);
        expect(h.length, lessThanOrEqualTo(2), reason: p.id);
        expect(h.first.isPositive, isTrue, reason: p.id);
        expect(h.first.title, isNot(FitEngine.budgetTitle), reason: p.id);
      }
    });

    test('a stated goal leads the highlights when it matches', () {
      const goal = FitContext(
        keywords: {'backpack', 'commute'},
        monthlyLimit: 5000,
        spentThisMonth: 2000,
      );
      final h = FitEngine.evaluate(product('bp_atlas'), goal).highlights;
      expect(h.first.title, FitEngine.intentTitle);
    });

    test('a concern is surfaced as the second highlight', () {
      const tight = FitContext(monthlyLimit: 3000, spentThisMonth: 2000);
      final h = FitEngine.evaluate(product('bp_atlas'), tight).highlights;
      expect(h.last.title, FitEngine.overBudgetTitle);
    });

    test('headline words follow the score', () {
      expect(FitEngine.headline(90), 'Great fit');
      expect(FitEngine.headline(70), 'Good fit');
      expect(FitEngine.headline(50), 'Fair fit');
      expect(FitEngine.headline(20), 'Poor fit');
    });

    test('a product outside the remaining envelope is penalised', () {
      const tight = FitContext(monthlyLimit: 3000, spentThisMonth: 2000);
      final roomy = FitEngine.evaluate(product('bp_atlas'), noGoal);
      final squeezed = FitEngine.evaluate(product('bp_atlas'), tight);
      expect(line(squeezed, FitEngine.budgetTitle), 0);
      expect(line(squeezed, FitEngine.overBudgetTitle), isNegative);
      expect(squeezed.score, lessThan(roomy.score));
    });

    test('exceeding the goal ceiling is penalised', () {
      const goal = FitContext(
        keywords: {'anc', 'focus'},
        intentBudget: 1600,
        monthlyLimit: 5000,
        spentThisMonth: 2000,
      );
      final pro = FitEngine.evaluate(product('hp_pro'), goal); // ₹1,899
      final core = FitEngine.evaluate(product('hp_core'), goal); // ₹1,499
      expect(line(pro, FitEngine.overCeilingTitle), isNegative);
      expect(core.compromises, isEmpty);
      expect(core.score, greaterThan(pro.score));
    });

    test('every change to the ceiling changes the score', () {
      // Roomy ceilings used to saturate the budget line, so raising or
      // lowering the ceiling made no visible difference.
      for (final p in catalog.products) {
        var previous = -1;
        for (final limit in [
          3000.0,
          4000.0,
          5000.0,
          7500.0,
          10000.0,
          20000.0,
        ]) {
          final r = FitEngine.evaluate(
            p,
            FitContext(monthlyLimit: limit, spentThisMonth: 0),
          );
          if (previous >= 0) {
            expect(r.score, greaterThanOrEqualTo(previous), reason: p.id);
          }
          previous = r.score;
        }
        final low = FitEngine.evaluate(
          p,
          const FitContext(monthlyLimit: 4000, spentThisMonth: 0),
        );
        final high = FitEngine.evaluate(
          p,
          const FitContext(monthlyLimit: 12000, spentThisMonth: 0),
        );
        expect(high.score, greaterThan(low.score), reason: p.id);
      }
    });

    test('a bigger discount scores higher on price', () {
      final deep = FitEngine.evaluate(product('hp_pro'), noGoal); // ~19% off
      final shallow = FitEngine.evaluate(product('bp_metro'), noGoal); // ~4%
      expect(
        line(deep, FitEngine.timingTitle),
        greaterThan(line(shallow, FitEngine.timingTitle)),
      );
    });
  });

  group('Fit providers', () {
    test('score reacts to the monthly limit', () {
      final container = ProviderContainer(overrides: demoScenario());
      addTearDown(container.dispose);

      final before = container.read(fitProvider('bp_atlas')).score;
      container.read(budgetProvider.notifier).setMonthlyLimit(3000);
      final after = container.read(fitProvider('bp_atlas')).score;
      expect(after, lessThan(before));
      container.read(budgetProvider.notifier).setMonthlyLimit(9000);
      expect(
        container.read(fitProvider('bp_atlas')).score,
        greaterThan(before),
      );
    });

    test('score reacts to the stated goal', () {
      final container = ProviderContainer(overrides: demoScenario());
      addTearDown(container.dispose);

      final before = container.read(fitProvider('bp_atlas')).score;
      container.read(intentProvider.notifier).submit('backpack commute');
      final after = container.read(fitProvider('bp_atlas')).score;
      expect(after, greaterThan(before));
    });

    test('the stream is ranked by computed fit and respects the ceiling', () {
      final container = ProviderContainer(overrides: demoScenario());
      addTearDown(container.dispose);

      container
          .read(intentProvider.notifier)
          .submit('ANC for Focus under 1600');
      final picks = container.read(fitPicksProvider);
      expect(picks, isNotEmpty);
      expect(picks.first.id, 'hp_core');
      expect(picks.every((p) => p.price <= 1600), isTrue);
    });
  });
}
