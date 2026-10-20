import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Clarion type system.
///
/// Two bundled faces with distinct jobs:
///  * **Schibsted Grotesk** — an editorial grotesque with sharp terminals for
///    everything a person reads.
///  * **Geist Mono** — fixed-width figures for everything a person compares:
///    prices, scores, deltas and micro labels. Every glyph has the same
///    advance, so animated counters never shift the layout.
abstract final class AppTypography {
  static const String sans = 'SchibstedGrotesk';
  static const String mono = 'GeistMono';

  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  // ── Reading (sans) ────────────────────────────────────────────────────────
  /// Intent prompts and screen titles (24–28px band).
  static const TextStyle display = TextStyle(
    fontFamily: sans,
    fontSize: 28,
    height: 1.14,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.6,
    color: AppColors.textPrimary,
  );

  static const TextStyle headline = TextStyle(
    fontFamily: sans,
    fontSize: 24,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.6,
    color: AppColors.textPrimary,
  );

  static const TextStyle title = TextStyle(
    fontFamily: sans,
    fontSize: 18,
    height: 1.3,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: sans,
    fontSize: 15.5,
    height: 1.35,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.15,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: sans,
    fontSize: 15,
    height: 1.5,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: sans,
    fontSize: 13.5,
    height: 1.45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    color: AppColors.textSecondary,
  );

  static const TextStyle label = TextStyle(
    fontFamily: sans,
    fontSize: 13.5,
    height: 1.3,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: sans,
    fontSize: 12,
    height: 1.4,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    color: AppColors.textSecondary,
  );

  // ── Comparing (mono) ──────────────────────────────────────────────────────
  /// Uppercase instrument-panel micro label, e.g. section eyebrows.
  static const TextStyle overline = TextStyle(
    fontFamily: mono,
    fontSize: 10.5,
    height: 1.3,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.3,
    color: AppColors.textTertiary,
  );

  static const TextStyle metricXL = TextStyle(
    fontFamily: mono,
    fontSize: 34,
    height: 1.05,
    fontWeight: FontWeight.w500,
    letterSpacing: -1.6,
    color: AppColors.textPrimary,
    fontFeatures: _tabular,
  );

  static const TextStyle metricLarge = TextStyle(
    fontFamily: mono,
    fontSize: 24,
    height: 1.1,
    fontWeight: FontWeight.w500,
    letterSpacing: -1,
    color: AppColors.textPrimary,
    fontFeatures: _tabular,
  );

  static const TextStyle metric = TextStyle(
    fontFamily: mono,
    fontSize: 15,
    height: 1.2,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.4,
    color: AppColors.textPrimary,
    fontFeatures: _tabular,
  );

  static const TextStyle metricSmall = TextStyle(
    fontFamily: mono,
    fontSize: 12,
    height: 1.25,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
    fontFeatures: _tabular,
  );

  /// Material [TextTheme] bridge so stock widgets inherit the scale.
  static TextTheme textTheme(Color primary, Color secondary) => TextTheme(
    displaySmall: display.copyWith(color: primary),
    headlineMedium: headline.copyWith(color: primary),
    titleLarge: title.copyWith(color: primary),
    titleMedium: titleSmall.copyWith(color: primary),
    bodyLarge: body.copyWith(color: primary),
    bodyMedium: body.copyWith(fontSize: 14, color: primary),
    bodySmall: bodySmall.copyWith(color: secondary),
    labelLarge: label.copyWith(color: primary),
    labelMedium: caption.copyWith(color: secondary),
    labelSmall: overline.copyWith(color: secondary),
  );
}
