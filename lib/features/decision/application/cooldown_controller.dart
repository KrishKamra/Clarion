import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/db_providers.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../data/catalog.dart';
import 'impulse_risk.dart';

/// 24h Cooling Off – products the user parked to decide on once the urge passes.
///
/// Maps product id → moment the hold expires. State starts from what was saved
/// in SQLite and every change is written back, so holds survive a restart.
class CooldownController extends Notifier<Map<String, DateTime>> {
  static const Duration period = Duration(hours: 24);

  late Map<String, DateTime> _started;

  @override
  Map<String, DateTime> build() {
    _started = {...ref.watch(initialCooldownStartsProvider)};
    return ref.watch(initialCooldownsProvider);
  }

  bool isHeld(String productId) => state.containsKey(productId);

  /// How long this hold lasts. Falls back to 24 hours when the start was
  /// not recorded (seeded holds).
  Duration spanOf(String productId) {
    final start = _started[productId];
    final end = state[productId];
    if (start == null || end == null) return period;
    final span = end.difference(start);
    return span.inMinutes < 1 ? period : span;
  }

  void hold(String productId, {Duration? forDuration}) {
    final now = DateTime.now();
    final duration =
        forDuration ?? ref.read(impulseAssessmentProvider(productId)).hold;
    final expiresAt = now.add(duration);
    _started[productId] = now;
    state = {...state, productId: expiresAt};
    _persist(
      ref.read(cooldownRepositoryProvider)?.upsert(productId, now, expiresAt),
    );
    // The moment a reminder becomes useful is the moment to ask for it.
    final product = ref.read(catalogProvider).byId(productId);
    NotificationService.requestPermission().then(
      (_) => NotificationService.scheduleCoolingOff(product, expiresAt),
    );
  }

  void release(String productId) {
    state = {...state}..remove(productId);
    _started.remove(productId);
    _persist(ref.read(cooldownRepositoryProvider)?.remove(productId));
    NotificationService.cancelCoolingOff(productId);
  }

  /// The UI updates instantly from memory; the database write happens after.
  /// A failed write is logged but never crashes the app.
  void _persist(Future<void>? write) {
    write?.catchError(
      (Object error, StackTrace stack) => developer.log(
        'Could not save cooldown change',
        error: error,
        stackTrace: stack,
      ),
    );
  }
}

final cooldownProvider =
    NotifierProvider<CooldownController, Map<String, DateTime>>(
      CooldownController.new,
    );

/// Minute-resolution clock so countdowns refresh without per-widget timers.
final clockProvider = StreamProvider<DateTime>((ref) {
  return Stream<DateTime>.periodic(
    const Duration(seconds: 30),
    (_) => DateTime.now(),
  );
});
