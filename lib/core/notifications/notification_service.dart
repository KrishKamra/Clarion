import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../data/models/product_model.dart';
import '../links/deep_links.dart';
import '../utils/formatters.dart';

/// On-device reminders that bring Clarion's slow decisions back to the user:
/// a cooling-off hold ending, and a watched product reaching its target.
///
/// Calm by design: one notification per event, informational copy, no
/// countdowns. Android only for now; everywhere else (web, widget tests,
/// before [init]) every call is a quiet no-op.
abstract final class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  static const _iris = Color(0xFF4F46E5);

  static const _coolingOff = NotificationDetails(
    android: AndroidNotificationDetails(
      'cooling_off',
      'Cooling-off reminders',
      channelDescription: 'When a 24h cooling-off hold ends.',
      color: _iris,
    ),
  );

  static const _priceWatch = NotificationDetails(
    android: AndroidNotificationDetails(
      'price_watch',
      'Price watch',
      channelDescription: 'When a watched product reaches your target price.',
      color: _iris,
    ),
  );

  /// Call once before `runApp`. Also picks up a notification that launched
  /// the app from closed.
  static Future<void> init() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    await _guard(() async {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('ic_stat_clarion'),
        ),
        onDidReceiveNotificationResponse: (r) => _open(r.payload),
      );
      final launch = await _plugin.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp ?? false) {
        _open(launch!.notificationResponse?.payload);
      }
      _ready = true;
    });
  }

  /// Asks for permission (Android 13+) at the moment a reminder becomes
  /// useful, never at launch. The system only shows the prompt once.
  static Future<void> requestPermission() async {
    if (!_ready) return;
    await _guard(
      () async => _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission(),
    );
  }

  static Future<void> scheduleCoolingOff(Product product, DateTime endsAt) =>
      _whenReady(() async {
        if (!endsAt.isAfter(DateTime.now())) return;
        // An absolute instant, so UTC is exact whatever the device's zone.
        await _plugin.zonedSchedule(
          id: idFor('hold', product.id),
          scheduledDate: tz.TZDateTime.from(endsAt, tz.UTC),
          notificationDetails: _coolingOff,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          title: 'Your cooling-off is over',
          body:
              'Still want the ${product.title}? Decide now, with a clear head.',
          payload: product.id,
        );
      });

  static Future<void> cancelCoolingOff(String productId) =>
      _whenReady(() => _plugin.cancel(id: idFor('hold', productId)));

  /// Re-arms one account's reminders when its session opens: reschedules its
  /// holds, and announces watched products that have newly reached their
  /// target since the last check (each target is announced once).
  static Future<void> syncSession({
    required String userId,
    required Map<String, DateTime> holds,
    required Map<String, double?> watchlist,
    required Map<String, Product> products,
  }) => _whenReady(() async {
    await _plugin.cancelAllPendingNotifications();
    for (final MapEntry(key: id, value: endsAt) in holds.entries) {
      final product = products[id];
      if (product != null) await scheduleCoolingOff(product, endsAt);
    }

    final prefs = await SharedPreferences.getInstance();
    final key = 'watch_alerted_$userId';
    final announced = prefs.getStringList(key)?.toSet() ?? {};
    final hitNow = <String>{};
    for (final MapEntry(key: id, value: target) in watchlist.entries) {
      final product = products[id];
      if (product == null || target == null || product.price > target) {
        continue;
      }
      final tag = '$id@$target';
      hitNow.add(tag);
      if (announced.contains(tag)) continue;
      await _plugin.show(
        id: idFor('watch', id),
        title: '${product.title} reached your target',
        body:
            'Now ${Fmt.inr(product.price)}, at or below your '
            '${Fmt.inr(target)} target. Worth a look when you’re ready.',
        notificationDetails: _priceWatch,
        payload: id,
      );
    }
    // Only targets still met stay announced; one that lapses can fire again.
    await prefs.setStringList(key, hitNow.toList());
  });

  /// Clears every reminder, e.g. on sign-out, so the next account on this
  /// device never sees someone else's.
  static Future<void> cancelAll() => _whenReady(_plugin.cancelAll);

  /// Stable across launches (unlike `Object.hash`), so a reminder scheduled
  /// in one session can be cancelled in the next. FNV-1a, kept to 31 bits.
  @visibleForTesting
  static int idFor(String kind, String productId) {
    var hash = 0x811c9dc5;
    for (final unit in '$kind:$productId'.codeUnits) {
      hash = ((hash ^ unit) * 0x01000193) & 0xffffffff;
    }
    return hash & 0x7fffffff;
  }

  /// A tapped reminder opens its product, the same way a shared link does.
  static void _open(String? productId) {
    if (productId != null) DeepLinks.pending.value = ProductLink(productId);
  }

  static Future<void> _whenReady(Future<void> Function() action) async {
    if (_ready) await _guard(action);
  }

  /// Reminders are a convenience: a failure is logged, never thrown.
  static Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } catch (error, stack) {
      developer.log('Notification error', error: error, stackTrace: stack);
    }
  }
}
