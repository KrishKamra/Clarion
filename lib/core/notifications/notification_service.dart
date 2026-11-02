import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../data/models/order_model.dart';
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

  /// The app's accent meanings, carried into the shade: plum when it is
  /// time to act, sea for a good price, ochre for a window closing. The
  /// light-theme values, which read on both light and dark shades.
  static const _plum = Color(0xFF6A3C82);
  static const _sea = Color(0xFF1B6F86);
  static const _ochre = Color(0xFF8C6A12);

  /// One channel per kind of reminder, so each can be silenced on its own.
  static const _coolingOffChannel = (
    id: 'cooling_off',
    name: 'Cooling-off reminders',
    description: 'When a 24h cooling-off hold ends.',
    group: 'clarion.cooling_off',
    label: 'Cooling-off',
    color: _plum,
    category: AndroidNotificationCategory.reminder,
  );
  static const _vaultChannel = (
    id: 'warranty_vault',
    name: 'Receipts and warranty',
    description: 'When a return window is about to close, or a warranty is about to expire.',
    group: 'clarion.vault',
    label: 'Receipts & warranty',
    color: _ochre,
    category: AndroidNotificationCategory.reminder,
  );
  static const _priceWatchChannel = (
    id: 'price_watch',
    name: 'Price watch',
    description: 'When a watched product reaches your target price.',
    group: 'clarion.price_watch',
    label: 'Price watch',
    color: _sea,
    category: AndroidNotificationCategory.recommendation,
  );

  /// Expanded copy, the kind as a sub-label, one action that opens the
  /// subject, and content hidden on a secure lock screen — what someone is
  /// thinking of buying is nobody else's business.
  static NotificationDetails _details(
    ({
      String id,
      String name,
      String description,
      String group,
      String label,
      Color color,
      AndroidNotificationCategory category,
    })
    channel, {
    required String body,
    String? action,
    String? summary,
    DateTime? when,
    StyleInformation? style,
    bool groupSummary = false,
  }) => NotificationDetails(
    android: AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      icon: 'ic_stat_clarion',
      color: channel.color,
      category: channel.category,
      groupKey: channel.group,
      setAsGroupSummary: groupSummary,
      subText: channel.label,
      styleInformation:
          style ?? BigTextStyleInformation(body, summaryText: summary),
      visibility: NotificationVisibility.private,
      when: when?.millisecondsSinceEpoch,
      showWhen: when != null,
      ticker: body,
      actions: [
        if (action != null)
          AndroidNotificationAction(
            'open',
            action,
            titleColor: channel.color,
            showsUserInterface: true,
          ),
      ],
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
        final body =
            'Still want the ${product.title}? Decide now, with a clear head.';
        // An absolute instant, so UTC is exact whatever the device's zone.
        await _plugin.zonedSchedule(
          id: idFor('hold', product.id),
          scheduledDate: tz.TZDateTime.from(endsAt, tz.UTC),
          notificationDetails: _details(
            _coolingOffChannel,
            body:
                '$body It’s ${Fmt.inr(product.price)} today. Buy it, keep '
                'watching, or let it go — all three are good outcomes.',
            summary: product.title,
            action: 'Decide now',
            when: endsAt,
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          title: 'Your cooling-off is over',
          body: body,
          payload: product.id,
        );
      });

  static Future<void> cancelCoolingOff(String productId) =>
      _whenReady(() => _plugin.cancel(id: idFor('hold', productId)));

  /// Reminds the buyer three days before the return window closes, and
  /// thirty days before a finite warranty expires.
  static Future<void> scheduleVault(
    Order order,
    Map<String, Product> products,
  ) => _whenReady(() async {
    final now = DateTime.now();
    final returnAt = (order.collectedAt ?? order.placedAt)
        .add(Order.returnWindow)
        .subtract(const Duration(days: 3));
    if (returnAt.isAfter(now)) {
      final title = order.lines.isEmpty
          ? 'your order'
          : order.lines.first.title;
      final closes = returnAt.add(const Duration(days: 3));
      await _plugin.zonedSchedule(
        id: idFor('return', order.id),
        scheduledDate: tz.TZDateTime.from(returnAt, tz.UTC),
        notificationDetails: _details(
          _vaultChannel,
          body:
              'Still happy with the $title? The return window closes on '
              '${Fmt.shortDate(closes)}. If it isn’t earning its place, '
              'there’s still time.',
          summary: 'Order ${order.id}',
          action: 'View order',
          when: returnAt,
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: 'Return window closes in 3 days',
        body: 'Still happy with the $title?',
        payload: 'order:${order.id}',
      );
    }
    for (final line in order.lines) {
      if (line.returned != null) continue;
      final product = products[line.productId];
      final yearsValue = product?.spec('warranty')?.value;
      if (yearsValue == null || yearsValue >= 90) continue;
      final years = yearsValue.round();
      if (years <= 0) continue;
      final expires = DateTime(
        order.placedAt.year + years,
        order.placedAt.month,
        order.placedAt.day,
      );
      final remind = expires.subtract(const Duration(days: 30));
      if (!remind.isAfter(now)) continue;
      final body =
          'The warranty on ${line.title} expires on ${Fmt.shortDate(expires)}.';
      await _plugin.zonedSchedule(
        id: idFor('warranty', '${order.id}:${line.productId}'),
        scheduledDate: tz.TZDateTime.from(remind, tz.UTC),
        notificationDetails: _details(
          _vaultChannel,
          body:
              '$body If anything has been playing up, now is the time to '
              'get it looked at — your receipt is in the vault.',
          summary: line.title,
          action: 'Open product',
          when: remind,
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: 'Warranty ending soon',
        body: body,
        payload: line.productId,
      );
    }
  });

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
    final fresh = <String>[];
    for (final MapEntry(key: id, value: target) in watchlist.entries) {
      final product = products[id];
      if (product == null || target == null || product.price > target) {
        continue;
      }
      final tag = '$id@$target';
      hitNow.add(tag);
      if (announced.contains(tag)) continue;
      final saving = product.historyMax - product.price;
      final body =
          'Now ${Fmt.inr(product.price)}, at or below your '
          '${Fmt.inr(target)} target. Worth a look when you’re ready.';
      await _plugin.show(
        id: idFor('watch', id),
        title: '${product.title} reached your target',
        body: body,
        notificationDetails: _details(
          _priceWatchChannel,
          body: saving > 0
              ? '$body That’s ${Fmt.inr(saving)} under its 30-day high.'
              : body,
          summary: 'Target ${Fmt.inr(target)}',
          action: 'See the price',
        ),
        payload: id,
      );
      fresh.add('${product.title} · ${Fmt.inr(product.price)}');
    }
    // Several at once fold under one summary in the shade.
    if (fresh.length > 1) {
      await _plugin.show(
        id: idFor('watch', 'summary'),
        title: '${fresh.length} watched products reached your target',
        body: fresh.join(', '),
        notificationDetails: _details(
          _priceWatchChannel,
          body: fresh.join(', '),
          style: InboxStyleInformation(
            fresh,
            contentTitle: '${fresh.length} at your target',
            summaryText: 'Price watch',
          ),
          groupSummary: true,
        ),
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

  /// A tapped reminder opens its product, or the order for a vault reminder.
  static void _open(String? payload) {
    if (payload == null || payload.isEmpty) return;
    if (payload.startsWith('order:')) {
      DeepLinks.pending.value = OrderLink(payload.substring('order:'.length));
      return;
    }
    DeepLinks.pending.value = ProductLink(payload);
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
