import 'package:clarion/core/db/price_watch_repository.dart';
import 'package:clarion/data/catalog.dart';
import 'package:clarion/data/mock_catalog.dart';
import 'package:clarion/features/decision/application/watch_status.dart';
import 'package:clarion/features/decision/application/watchlist_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Price Memory Watcher', () {
    test('verdict compares today\'s price with the target', () {
      expect(watchVerdict(price: 1899), WatchVerdict.noTarget);
      expect(watchVerdict(price: 1899, target: 1900), WatchVerdict.targetHit);
      expect(watchVerdict(price: 1899, target: 1899), WatchVerdict.targetHit);
      expect(watchVerdict(price: 1899, target: 1830), WatchVerdict.close);
      expect(watchVerdict(price: 1899, target: 1700), WatchVerdict.waiting);
    });

    test('target options are sensible for every product', () {
      final catalog = Catalog(MockCatalog.products, MockCatalog.comparePairs);
      for (final p in catalog.products) {
        final options = targetOptions(p);
        expect(options, isNotEmpty, reason: p.id);
        expect(options.toSet(), hasLength(options.length), reason: p.id);
        for (final t in options) {
          expect(t, lessThanOrEqualTo(p.price.ceilToDouble()), reason: p.id);
        }
        final sorted = [...options]..sort((a, b) => b.compareTo(a));
        expect(options, sorted, reason: p.id);
      }
    });

    test('day keys are zero-padded and sort chronologically', () {
      expect(PriceWatchRepository.dayKey(DateTime(2026, 10, 5)), '2026-10-05');
      expect(
        PriceWatchRepository.dayKey(DateTime(2026, 9, 30))
            .compareTo(PriceWatchRepository.dayKey(DateTime(2026, 10, 1))),
        lessThan(0),
      );
    });

    test('watchlist starts empty and tracks watch, target and unwatch', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(watchlistProvider.notifier);

      expect(container.read(watchlistProvider), isEmpty);

      controller.watch('hp_pro');
      expect(container.read(watchlistProvider), {'hp_pro': null});
      expect(controller.isWatching('hp_pro'), isTrue);

      controller.setTarget('hp_pro', 1800);
      expect(container.read(watchlistProvider), {'hp_pro': 1800});

      controller.unwatch('hp_pro');
      expect(container.read(watchlistProvider), isEmpty);
      expect(controller.isWatching('hp_pro'), isFalse);
    });

    test(
      'price history falls back to the catalogue without a database',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final history = await container.read(
          priceHistoryProvider('hp_pro').future,
        );
        expect(history, hasLength(30));
        expect(
          history.last.price,
          container.read(catalogProvider).byId('hp_pro').price,
        );
      },
    );
  });
}
