import 'package:flutter/material.dart';

/// Clarion colour tokens.
///
/// The palette is tuned for a deep, near-black navy canvas lit by soft
/// indigo / violet / cyan glows. Semantic "fit" colours communicate how well
/// a product matches the user's declared intent and are reused by every
/// score, gauge and trade-off indicator in the app.
abstract final class AppColors {
  // ── Canvas ────────────────────────────────────────────────────────────────
  static const Color backgroundDeep = Color(0xFF090D16);
  static const Color backgroundRaised = Color(0xFF0C111D);
  static const Color surface = Color(0xFF111827);
  static const Color surfaceHigh = Color(0xFF172033);

  // ── Brand cores ───────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF6366F1); // Indigo glow
  static const Color secondary = Color(0xFF8B5CF6); // Violet accent
  static const Color accent = Color(0xFF06B6D4); // Cyan – local / value

  // ── Semantic fit scale ────────────────────────────────────────────────────
  static const Color fitHigh = Color(0xFF10B981); // Emerald, 90–100
  static const Color fitMid = Color(0xFFF59E0B); // Amber, 70–89
  static const Color fitLow = Color(0xFFEF4444); // Coral red, trade-off

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textTertiary = Color(0xFF64748B);
  static const Color textOnAccent = Colors.white;

  // ── Glass ─────────────────────────────────────────────────────────────────
  static const Color glassTintLow = Color(0x0AFFFFFF); // 4 %
  static const Color glassTint = Color(0x12FFFFFF); // 7 %
  static const Color glassTintHigh = Color(0x14FFFFFF); // 8 %
  static const Color glassBorder = Color(0x1FFFFFFF); // 12 %
  static const Color glassBorderFaint = Color(0x14FFFFFF); // 8 %
  static const Color hairline = Color(0x0FFFFFFF); // 6 %

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static const LinearGradient valueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, primary],
  );

  /// Green → amber → red, used by budget gauges.
  static const List<Color> budgetSweep = [fitHigh, fitMid, fitLow];

  /// Resolves the semantic colour for a 0–100 fit score.
  static Color forFitScore(num score) {
    if (score >= 90) return fitHigh;
    if (score >= 70) return fitMid;
    return fitLow;
  }

  /// Resolves budget utilisation (0.0 = nothing used, 1.0 = at limit).
  static Color forBudgetRatio(double ratio) {
    if (ratio > 1.0) return fitLow;
    if (ratio >= 0.85) return fitMid;
    return fitHigh;
  }
}
