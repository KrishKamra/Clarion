import 'package:clarion/core/db/db_providers.dart';
import 'package:clarion/core/db/regret_repository.dart';
import 'package:clarion/data/models/regret_checkin_model.dart';
import 'package:clarion/features/profile/application/regret_controller.dart';
import 'package:clarion/features/profile/presentation/widgets/regret_barometer_card.dart';
import 'package:clarion/features/profile/presentation/widgets/regret_checkin_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeRegretRepository implements RegretRepository {
  final List<RegretCheckin> _storage = [];
  int _nextId = 1;

  @override
  Future<List<RegretCheckin>> loadAll() async => List.unmodifiable(_storage);

  @override
  Future<RegretCheckin> addCheckin(RegretCheckin checkin) async {
    final id = checkin.id ?? _nextId++;
    final saved = checkin.copyWith(id: id);
    _storage.removeWhere((c) => c.productTitle == checkin.productTitle);
    _storage.add(saved);
    return saved;
  }

  @override
  Future<void> removeCheckin(int id) async {
    _storage.removeWhere((c) => c.id == id);
  }
}

void main() {
  group('RegretCheckin model', () {
    test('computes rating helpers correctly', () {
      final worthIt = RegretCheckin(
        productTitle: 'Desk Lamp',
        amount: 800,
        rating: RegretRating.worthIt,
        checkedInAt: DateTime.now(),
      );
      expect(worthIt.isWorthIt, isTrue);
      expect(worthIt.isRegretted, isFalse);

      final regretted = RegretCheckin(
        productTitle: 'Cable Kit',
        amount: 400,
        rating: RegretRating.regretted,
        tag: RegretTag.impulseBuy,
        checkedInAt: DateTime.now(),
      );
      expect(regretted.isRegretted, isTrue);
      expect(regretted.isWorthIt, isFalse);
    });
  });

  group('RegretRepository', () {
    late FakeRegretRepository repository;

    setUp(() {
      repository = FakeRegretRepository();
    });

    test('saves and loads regret check-ins', () async {
      final checkin = RegretCheckin(
        productTitle: 'Wireless Headphones',
        amount: 2199,
        rating: RegretRating.worthIt,
        tag: RegretTag.greatValue,
        note: 'Daily driver for work and music.',
        checkedInAt: DateTime(2026, 10, 25),
      );

      final saved = await repository.addCheckin(checkin);
      expect(saved.id, isNotNull);

      final loaded = await repository.loadAll();
      expect(loaded, hasLength(1));
      expect(loaded.first.productTitle, 'Wireless Headphones');
      expect(loaded.first.amount, 2199);
      expect(loaded.first.rating, RegretRating.worthIt);
      expect(loaded.first.tag, RegretTag.greatValue);
      expect(loaded.first.note, 'Daily driver for work and music.');
    });

    test('deletes regret check-in by id', () async {
      final checkin = await repository.addCheckin(
        RegretCheckin(
          productTitle: 'Ergonomic Mouse',
          amount: 1200,
          rating: RegretRating.regretted,
          checkedInAt: DateTime.now(),
        ),
      );

      expect(await repository.loadAll(), hasLength(1));
      await repository.removeCheckin(checkin.id!);
      expect(await repository.loadAll(), isEmpty);
    });
  });

  group('RegretController & regretStatsProvider', () {
    test('calculates stats and mindful score accurately', () async {
      final container = ProviderContainer(
        overrides: [
          initialRegretCheckinsProvider.overrideWithValue([
            RegretCheckin(
              productTitle: 'Item A',
              amount: 1000,
              rating: RegretRating.worthIt,
              checkedInAt: DateTime.now(),
            ),
            RegretCheckin(
              productTitle: 'Item B',
              amount: 2000,
              rating: RegretRating.worthIt,
              checkedInAt: DateTime.now(),
            ),
            RegretCheckin(
              productTitle: 'Item C',
              amount: 500,
              rating: RegretRating.regretted,
              checkedInAt: DateTime.now(),
            ),
          ]),
        ],
      );
      addTearDown(container.dispose);

      final stats = container.read(regretStatsProvider);
      expect(stats.totalCheckedIn, 3);
      expect(stats.worthItCount, 2);
      expect(stats.regrettedCount, 1);
      expect(stats.regrettedAmount, 500);
      expect(stats.worthItAmount, 3000);
      expect(stats.mindfulScore, 67); // 2/3 * 100 = 66.6 -> 67%
    });

    test('adds new check-in via controller', () async {
      final repository = FakeRegretRepository();
      final container = ProviderContainer(
        overrides: [
          regretRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(regretControllerProvider.notifier);
      expect(controller.isCheckedIn('Smartwatch'), isFalse);

      await controller.recordCheckin(
        productTitle: 'Smartwatch',
        amount: 3500,
        rating: RegretRating.worthIt,
        tag: RegretTag.essential,
      );

      expect(controller.isCheckedIn('Smartwatch'), isTrue);
      final stats = container.read(regretStatsProvider);
      expect(stats.totalCheckedIn, 1);
      expect(stats.mindfulScore, 100);
    });
  });

  group('Widgets', () {
    testWidgets('renders RegretBarometerCard correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            initialRegretCheckinsProvider.overrideWithValue([
              RegretCheckin(
                productTitle: 'Northpeak Atlas 30L',
                amount: 2199,
                rating: RegretRating.worthIt,
                checkedInAt: DateTime.now(),
              ),
            ]),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: RegretBarometerCard()),
            ),
          ),
        ),
      );

      expect(find.text('Regret Barometer'), findsOneWidget);
      expect(find.text('100% Mindful'), findsOneWidget);
      expect(find.text('Regretted purchases'), findsOneWidget);
    });

    testWidgets('opens RegretCheckinSheet and saves reflection', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showRegretCheckinSheet(
                    context,
                    productTitle: 'Desk Lamp',
                    amount: 800,
                  ),
                  child: const Text('Open Sheet'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Regret Check-in'), findsOneWidget);
      expect(find.text('Desk Lamp'), findsOneWidget);
      expect(find.text('WAS THIS PURCHASE WORTH IT?'), findsOneWidget);

      await tester.tap(find.text('Save Reflection'));
      await tester.pumpAndSettle();

      expect(find.text('Regret Check-in'), findsNothing);
    });
  });
}
