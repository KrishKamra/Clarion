import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 24h Cooling Off – products the user parked to decide on once the urge passes.
///
/// Maps product id → moment the hold expires.
class CooldownController extends Notifier<Map<String, DateTime>> {
  static const Duration period = Duration(hours: 24);

  @override
  Map<String, DateTime> build() => {
    // Seeded so the profile screen demonstrates an in-progress hold.
    'kb_loom': DateTime.now().add(const Duration(hours: 17, minutes: 42)),
  };

  bool isHeld(String productId) => state.containsKey(productId);

  void hold(String productId) {
    state = {...state, productId: DateTime.now().add(period)};
  }

  void release(String productId) {
    state = {...state}..remove(productId);
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
