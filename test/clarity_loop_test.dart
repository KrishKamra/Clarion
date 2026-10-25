import 'package:clarion/core/links/deep_links.dart';
import 'package:clarion/data/mock_catalog.dart';
import 'package:clarion/data/models/clarity_models.dart';
import 'package:clarion/data/models/order_model.dart';
import 'package:clarion/data/models/product_model.dart';
import 'package:clarion/data/models/regret_checkin_model.dart';
import 'package:clarion/features/cart/application/budget_controller.dart';
import 'package:clarion/features/cart/application/value_alternatives.dart';
import 'package:clarion/features/decision/application/barcode_catalog.dart';
import 'package:clarion/features/decision/application/friend_ballot.dart';
import 'package:clarion/features/decision/application/impulse_risk.dart';
import 'package:clarion/features/decision/application/ownership_cost.dart';
import 'package:clarion/features/decision/application/ownership_guard.dart';
import 'package:clarion/features/home/application/bundle_planner.dart';
import 'package:clarion/features/home/application/goal_reader.dart';
import 'package:clarion/features/home/application/intent_controller.dart';
import 'package:clarion/features/orders/application/warranty_vault.dart';
import 'package:clarion/features/profile/application/clarity_report.dart';
import 'package:clarion/features/profile/application/opportunity_cost.dart';
import 'package:clarion/features/profile/application/regret_controller.dart';
import 'package:clarion/features/profile/application/regret_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final catalog = MockCatalog.products;
  Product product(String id) => catalog.firstWhere((item) => item.id == id);

  Order order({
    required String id,
    required DateTime placedAt,
    required List<OrderLine> lines,
    DateTime? collectedAt,
  }) =>
      Order(id: id, placedAt: placedAt, lines: lines, collectedAt: collectedAt);

  OrderLine line(Product item, {ReturnRequest? returned}) => OrderLine(
    productId: item.id,
    title: item.title,
    price: item.price,
    quantity: 1,
    returned: returned,
  );

  RegretCheckin checkin(
    String title, {
    required RegretRating rating,
    String? category,
  }) => RegretCheckin(
    productTitle: title,
    amount: 100,
    rating: rating,
    checkedInAt: DateTime(2026, 6, 1),
    category: category,
  );

  group('Regret window', () {
    final now = DateTime(2026, 6, 30);
    final atlas = product('bp_atlas');

    Order aged(int days) => order(
      id: 'CLR-$days',
      placedAt: now.subtract(Duration(days: days)),
      lines: [line(atlas)],
    );

    test('asks only between 14 and 30 days, and only once', () {
      expect(
        RegretWindow.due(
          orders: [aged(13), aged(14), aged(30), aged(31)],
          checkins: const [],
          now: now,
        ).map((due) => due.ageDays),
        [14, 30],
      );
      expect(
        RegretWindow.due(
          orders: [aged(20)],
          checkins: [checkin(atlas.title, rating: RegretRating.worthIt)],
          now: now,
        ),
        isEmpty,
      );
      final returned = order(
        id: 'CLR-back',
        placedAt: now.subtract(const Duration(days: 20)),
        lines: [
          line(
            atlas,
            returned: ReturnRequest(
              reason: ReturnReason.changedMind,
              requestedAt: now,
              beforePickup: true,
            ),
          ),
        ],
      );
      expect(
        RegretWindow.due(orders: [returned], checkins: const [], now: now),
        isEmpty,
      );
    });

    test('nudge moves fit within the category and clamps', () {
      final bags = product('bp_metro');
      int nudge(List<RegretCheckin> rows) =>
          RegretWindow.nudge(product: bags, checkins: rows, catalog: catalog);

      expect(nudge(const []), 0);
      expect(
        nudge([
          checkin(
            'Other bag',
            rating: RegretRating.regretted,
            category: 'Bags',
          ),
        ]),
        -4,
      );
      expect(
        nudge([
          checkin('A', rating: RegretRating.regretted, category: 'Bags'),
          checkin('B', rating: RegretRating.regretted, category: 'Bags'),
          checkin('C', rating: RegretRating.regretted, category: 'Bags'),
        ]),
        -8,
      );
      expect(
        nudge([
          for (var i = 0; i < 5; i++)
            checkin('Glad $i', rating: RegretRating.worthIt, category: 'Bags'),
        ]),
        6,
      );
      expect(
        nudge([
          checkin('Lamp', rating: RegretRating.regretted, category: 'Study'),
        ]),
        0,
      );
    });

    test('personal regret rate is the share of regretted check-ins', () {
      expect(regretRateOf(const []), 0);
      expect(
        regretRateOf([
          checkin('A', rating: RegretRating.regretted),
          checkin('B', rating: RegretRating.worthIt),
        ]),
        50,
      );
      expect(
        const RegretStats(
          totalCheckedIn: 0,
          worthItCount: 0,
          regrettedCount: 0,
          neutralCount: 0,
          regrettedAmount: 0,
          worthItAmount: 0,
        ).regretRate,
        0,
      );
    });
  });

  group('Cost per use', () {
    test('a daily bag is about ₹6 a use, with accessories', () {
      final cost = OwnershipCostEngine.of(product('bp_atlas'));
      expect(cost.usesPerYear, 365);
      expect(cost.perUseLabel, '₹6 per use over a year');
      expect(cost.accessories, 180);
      expect(cost.firstYearTotal, 2199 + 180);
    });

    test('headphones include a year of consumables', () {
      final cost = OwnershipCostEngine.of(product('hp_pro'));
      expect(cost.usesPerYear, 300);
      expect(cost.perUseLabel, '₹6 per use over a year');
      expect(cost.consumablesPerYear, 400);
    });
  });

  group('Impulse risk', () {
    final now = DateTime(2026, 6, 15, 14);
    final atlas = product('bp_atlas');

    ImpulseAssessment assess({
      List<ImpulseEvent> events = const [],
      double? price,
      double limit = 5000,
      DateTime? at,
    }) => ImpulseRiskEngine.assess(
      events: events,
      price: price ?? atlas.price,
      monthlyLimit: limit,
      now: at ?? now,
    );

    test('a calm mid-size purchase stays on a 24 hour hold', () {
      final result = assess();
      expect(atlas.price / 5000, lessThan(0.5));
      expect(result.hold, ImpulseRiskEngine.baseline);
      expect(result.holdLabel, '24h Cooling Off');
      // The clock hour alone is not a late-night signal.
      final overnight = assess(at: DateTime(2026, 6, 15, 2));
      expect(overnight.hold, ImpulseRiskEngine.baseline);
      expect(
        assess(
          events: [
            ImpulseEvent(
              kind: 'browse',
              productId: atlas.id,
              amount: 0,
              at: DateTime(2026, 6, 15, 1),
            ),
          ],
        ).hold,
        ImpulseRiskEngine.baseline,
      );
    });

    test('rapid adds, late nights and large amounts lengthen the hold', () {
      final rapid = assess(
        events: [
          ImpulseEvent(
            kind: 'add',
            amount: 100,
            at: now.subtract(const Duration(minutes: 2)),
          ),
          ImpulseEvent(
            kind: 'add',
            amount: 100,
            at: now.subtract(const Duration(minutes: 1)),
          ),
        ],
      );
      expect(rapid.hold, const Duration(hours: 48));

      final night = DateTime(2026, 6, 15, 23, 50);
      final late = assess(
        at: night,
        events: [
          ImpulseEvent(
            kind: 'browse',
            amount: 0,
            at: DateTime(2026, 6, 15, 23, 10),
          ),
          ImpulseEvent(
            kind: 'browse',
            amount: 0,
            at: DateTime(2026, 6, 15, 23, 30),
          ),
        ],
      );
      expect(late.hold, const Duration(hours: 48));

      expect(assess(price: 2500).hold, const Duration(hours: 48));
      expect(
        assess(
          price: 4000,
          events: [
            ImpulseEvent(
              kind: 'add',
              amount: 1,
              at: now.subtract(const Duration(minutes: 1)),
            ),
            ImpulseEvent(
              kind: 'add',
              amount: 1,
              at: now.subtract(const Duration(minutes: 2)),
            ),
            ImpulseEvent(
              kind: 'browse',
              amount: 0,
              at: DateTime(2026, 6, 15, 3),
            ),
            ImpulseEvent(
              kind: 'browse',
              amount: 0,
              at: DateTime(2026, 6, 15, 4),
            ),
          ],
        ).hold,
        const Duration(hours: 72),
      );
    });

    test('a small unhurried purchase shortens the hold', () {
      final result = assess(price: 400);
      expect(result.hold, const Duration(hours: 8));
      expect(result.holdLabel, '8h Cooling Off');
    });
  });

  group('Already owned', () {
    final now = DateTime(2026, 6, 1);
    OwnershipWarning? warn(Product candidate, List<Order> orders) =>
        OwnershipGuard.find(
          candidate: candidate,
          orders: orders,
          catalog: catalog,
        );

    test('warns for the same product and a distinctive similar one', () {
      final owned = order(
        id: 'CLR-own',
        placedAt: now,
        lines: [line(product('bp_atlas'))],
      );
      final exact = warn(product('bp_atlas'), [owned]);
      expect(exact?.exact, isTrue);
      final similar = warn(product('bp_metro'), [owned]);
      expect(similar?.exact, isFalse);
      expect(similar?.owned.id, 'bp_atlas');
    });

    test('study neighbours that only share generic tags stay quiet', () {
      final owned = order(
        id: 'CLR-keys',
        placedAt: now,
        lines: [line(product('kb_loom'))],
      );
      expect(warn(product('lamp_halo'), [owned]), isNull);
    });

    test('a returned line is not something you still own', () {
      final returned = order(
        id: 'CLR-back',
        placedAt: now,
        lines: [
          line(
            product('bp_atlas'),
            returned: ReturnRequest(
              reason: ReturnReason.changedMind,
              requestedAt: now,
              beforePickup: false,
            ),
          ),
        ],
      );
      expect(warn(product('bp_atlas'), [returned]), isNull);
    });
  });

  group('Budget-optimal set', () {
    test('college setup under ₹2.5k is a set, not a ranked list', () {
      final intent = IntentQuery.parse('College Setup < ₹2.5k');
      expect(intent.budget, 2500);
      final plan = BundlePlanner.plan(
        products: catalog,
        keywords: intent.keywords,
        ceiling: 2500,
        scoreOf: (item) => item.fitScore,
      );
      expect(plan, isNotNull);
      final set = plan!;
      expect(set.items.length, inInclusiveRange(2, 4));
      expect(
        set.items.map((item) => item.category).toSet(),
        hasLength(set.items.length),
      );
      expect(set.total, lessThanOrEqualTo(2500));
      expect(
        set.total,
        set.items.fold<double>(0, (sum, item) => sum + item.price),
      );
      expect(
        set.fit,
        set.items.fold<int>(0, (sum, item) => sum + item.fitScore),
      );
      expect(
        BundlePlanner.plan(
          products: catalog,
          keywords: intent.keywords,
          ceiling: 0,
          scoreOf: (item) => item.fitScore,
        ),
        isNull,
      );
    });
  });

  group('Opportunity cost', () {
    test('states the share of the laptop goal', () {
      final laptop = Product(
        id: 'laptop_goal',
        brand: 'Northpeak',
        title: 'Study Laptop',
        category: 'Study',
        price: 14400,
        averagePrice30d: 14400,
        fitScore: 80,
        rationale: 'test',
        icon: Icons.laptop_outlined,
        tone: const Color(0xFF6366F1),
        rating: 4.5,
        reviewCount: 10,
        specs: const [],
        tradeOffs: const [],
        priceHistory: const [],
        intentTags: const {'laptop'},
      );
      final cost = OpportunityCostEngine.of(
        product: laptop,
        goals: [
          SavingsGoal(
            id: 'laptop',
            name: 'Laptop',
            target: 80000,
            createdAt: DateTime(2026, 1, 1),
          ),
        ],
        categoryBudgets: const [
          CategoryBudget(category: 'Study', monthlyLimit: 20000),
        ],
        categorySpent: 1000,
      );
      expect(cost?.percent, 18);
      expect(cost?.sentence, 'This equals 18% of your laptop goal');
      expect(cost?.categorySentence, '₹1,000 of your ₹20,000 category budget');
    });
  });

  group('Refurbished and repair', () {
    test('hp_pro refurbished saves ₹600 at 92% parity', () {
      final paths = ValueAlternatives.forProduct(product('hp_pro'));
      final refurbished = paths.firstWhere(
        (path) => path.kind == ValuePathKind.refurbished,
      );
      expect(refurbished.savingsAgainst(1899), 600);
      expect(refurbished.parity, 92);
      expect(refurbished.sustainability, 84);
      expect(paths.any((path) => path.kind == ValuePathKind.repair), isTrue);
    });
  });

  group('Warranty vault', () {
    test('a collected order is inside the three-day return reminder', () {
      final now = DateTime(2026, 6, 20, 12);
      final collected = now.subtract(const Duration(days: 4));
      final placed = Order(
        id: 'CLR-vault',
        placedAt: collected.subtract(const Duration(hours: 3)),
        collectedAt: collected,
        lines: [line(product('bp_atlas'))],
      );
      final entry = WarrantyVault.entries(
        orders: [placed],
        catalog: catalog,
      ).single;
      expect(entry.returnClosesWithin(now, const Duration(days: 3)), isTrue);
      expect(
        WarrantyVault.returnReminderAt(placed),
        collected.add(const Duration(days: 4)),
      );
      expect(WarrantyVault.warrantyYears(product('bp_atlas')), 2);
      expect(WarrantyVault.warrantyYears(product('sling_field')), isNull);
    });
  });

  group('Clarity report', () {
    test('the share text recaps the month', () {
      final report = ClarityReportBuilder.build(
        budget: const BudgetState(
          monthlyLimit: 5000,
          categories: [],
          monthlyHistory: [],
          impulseBuysAvoided: 11,
          savedViaCooldown: 6240,
        ),
        stats: const RegretStats(
          totalCheckedIn: 4,
          worthItCount: 3,
          regrettedCount: 1,
          neutralCount: 0,
          regrettedAmount: 100,
          worthItAmount: 300,
        ),
        checkins: [
          checkin('Atlas 30L Commuter Daypack', rating: RegretRating.worthIt),
        ],
        now: DateTime(2026, 6, 15),
      );
      expect(report.monthLabel, 'June');
      expect(report.shareText, contains('11 impulse buys avoided'));
      expect(report.shareText, contains('Personal regret rate 25%'));
      expect(report.bestDecisions, ['Atlas 30L Commuter Daypack']);
    });
  });

  group('Goal reading', () {
    test('parses a model reply and falls back on the device', () {
      final local = GoalReader.local('College Setup < ₹2.5k');
      expect(local.fromModel, isFalse);
      expect(local.intent.budget, 2500);
      expect(local.explanation, isNotEmpty);

      final parsed = GoalReader.parseModelReply(
        'Here you go {"keywords":["college","laptop"],"budget":2500,'
        '"explanation":"Waiting keeps more of the ceiling, and a closer fit may be worth it."}',
        fallback: local.intent,
      );
      expect(parsed?.fromModel, isTrue);
      expect(parsed?.intent.budget, 2500);
      expect(parsed?.intent.keywords, contains('laptop'));
      expect(
        GoalReader.parseModelReply('no json', fallback: local.intent),
        isNull,
      );
    });
  });

  group('Barcode and links', () {
    test('a catalogue barcode resolves to its product', () {
      expect(BarcodeCatalog.lookup('8901234500018', catalog)?.id, 'bp_atlas');
      expect(BarcodeCatalog.lookup('000', catalog), isNull);
      expect(BarcodeCatalog.codeFor('bp_atlas'), '8901234500018');
    });

    test('compare, vote and scan links round-trip', () {
      final compare = CompareLink(
        'bp_atlas',
        'bp_metro',
        ballotId: 'bp_atlas~bp_metro',
      );
      final vote = VoteLink(
        ballotId: 'bp_atlas~bp_metro',
        choiceId: 'bp_atlas',
        leftId: 'bp_atlas',
        rightId: 'bp_metro',
      );
      final scan = BarcodeLink('8901234500018');
      for (final link in [compare, vote, scan]) {
        expect(DeepLink.parse(link.uri), link);
      }
      expect(DeepLink.parse(Uri.parse('clarion://scan')), isNull);
      expect(DeepLink.parse(Uri.parse('clarion://compare/only')), isNull);
      expect(FriendBallots.idFor('bp_metro', 'bp_atlas'), 'bp_atlas~bp_metro');
    });
  });
}
