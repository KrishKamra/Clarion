import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// What the Android home-screen widget shows. Money is formatted here, so
/// the widget reads rupees exactly as the app does; times stay raw, so the
/// widget can render them in the device's own clock format.
@immutable
class HomeWidgetSnapshot {
  const HomeWidgetSnapshot({
    required this.budgetFigure,
    required this.budgetCaption,
    required this.ratio,
    required this.over,
    this.holdTitle,
    this.holdProductId,
    this.holdStarts,
    this.holdEnds,
    this.holdCount = 0,
    this.watching = 0,
    this.atTarget = 0,
    required this.saved,
    this.avoided = 0,
  });

  /// "₹12,400" — the headroom, or the overspend when [over].
  final String budgetFigure;

  /// "left of ₹40,000" / "over ₹40,000".
  final String budgetCaption;

  /// Committed spend over the ceiling (1.0 = at the ceiling).
  final double ratio;
  final bool over;

  /// The cooling-off hold that ends soonest, if any.
  final String? holdTitle;
  final String? holdProductId;
  final DateTime? holdStarts;
  final DateTime? holdEnds;
  final int holdCount;

  /// Products on the watchlist, and how many are at or below their target.
  final int watching;
  final int atTarget;

  /// "₹3,200" kept by cooling off.
  final String saved;
  final int avoided;

  Map<String, Object?> toMap() => {
    'budget': budgetFigure,
    'budgetCaption': budgetCaption,
    'ratio': ratio,
    'over': over,
    'hold': holdTitle ?? '',
    'holdId': holdProductId ?? '',
    'startsAt': holdStarts?.millisecondsSinceEpoch ?? 0,
    'endsAt': holdEnds?.millisecondsSinceEpoch ?? 0,
    'holdCount': holdCount,
    'watching': watching,
    'atTarget': atTarget,
    'saved': saved,
    'avoided': avoided,
  };
}

/// Writes a [HomeWidgetSnapshot] to the Android home-screen widget.
/// Everywhere else, including tests, this is a no-op.
abstract final class HomeWidgetBridge {
  static const _channel = MethodChannel('com.example.clarion/home_widget');

  static Future<void> publish(HomeWidgetSnapshot snapshot) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _channel.invokeMethod<void>('update', snapshot.toMap());
    } catch (error, stack) {
      developer.log(
        'Home widget update skipped',
        error: error,
        stackTrace: stack,
      );
    }
  }
}
