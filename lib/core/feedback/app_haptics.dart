import 'package:flutter/services.dart';

/// Clarion's haptic vocabulary: five words, each with one meaning, so a
/// gesture feels the same wherever it happens. Feature code never calls
/// [HapticFeedback] directly.
///
/// Haptics confirm what the hand just did; they never reward or nudge.
/// There is no buzz for browsing, scrolling or opening things, and the
/// system's own haptics setting is respected.
abstract final class AppHaptics {
  /// Stepping through choices: a pill, a tab, a notch on a chart or slider.
  static void select() => HapticFeedback.selectionClick();

  /// Pressing a button or a tappable surface.
  static void tap() => HapticFeedback.lightImpact();

  /// A deliberate decision that changes state: adding to the cart, a
  /// cooling-off hold set, a goal saved, a long press.
  static void commit() => HapticFeedback.mediumImpact();

  /// A decision landed well: an order placed. Light, then firmer — a
  /// settling, not a celebration.
  static Future<void> success() async {
    await HapticFeedback.lightImpact();
    await Future<void>.delayed(const Duration(milliseconds: 90));
    await HapticFeedback.mediumImpact();
  }

  /// Something needs a second look: a failed sign-in, a purchase that
  /// would break the ceiling. Two even knocks, never a long buzz.
  static Future<void> warn() async {
    await HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 110));
    await HapticFeedback.mediumImpact();
  }
}
