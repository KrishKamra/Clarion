import 'package:clarion/core/links/deep_links.dart';
import 'package:clarion/core/notifications/notification_service.dart';
import 'package:clarion/data/mock_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('notification ids are stable, distinct per kind and fit 31 bits', () {
    final hold = NotificationService.idFor('hold', 'kb_loom');
    expect(NotificationService.idFor('hold', 'kb_loom'), hold);
    expect(NotificationService.idFor('watch', 'kb_loom'), isNot(hold));
    for (final p in MockCatalog.products) {
      final id = NotificationService.idFor('hold', p.id);
      expect(id, inInclusiveRange(0, 0x7fffffff));
    }
  });

  test('every call is a quiet no-op before init (tests, web)', () async {
    final product = MockCatalog.products.first;
    await NotificationService.requestPermission();
    await NotificationService.scheduleCoolingOff(
      product,
      DateTime.now().add(const Duration(hours: 24)),
    );
    await NotificationService.cancelCoolingOff(product.id);
    await NotificationService.syncSession(
      userId: 'u',
      holds: {product.id: DateTime.now().add(const Duration(hours: 1))},
      watchlist: {product.id: product.price},
      products: {product.id: product},
    );
    await NotificationService.cancelAll();
    expect(DeepLinks.pending.value, isNull);
  });
}
