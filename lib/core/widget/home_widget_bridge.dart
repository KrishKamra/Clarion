import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Writes the budget left and the soonest cooling-off timer to the Android
/// home-screen widget. Everywhere else, including tests, this is a no-op.
abstract final class HomeWidgetBridge {
  static const _channel = MethodChannel('com.example.clarion/home_widget');

  static Future<void> publish({
    required String budget,
    required String holdTitle,
    DateTime? holdEnds,
  }) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _channel.invokeMethod<void>('update', {
        'budget': budget,
        'hold': holdTitle,
        'endsAt': holdEnds?.millisecondsSinceEpoch ?? 0,
      });
    } catch (error, stack) {
      developer.log(
        'Home widget update skipped',
        error: error,
        stackTrace: stack,
      );
    }
  }
}
