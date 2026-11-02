import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Clarion type system — typography as interface architecture.
///
/// Three bundled faces with distinct jobs:
///  * **Newsreader** — an editorial serif with optical sizes, for what the
///    eye lands on first: screen and section titles, the goal prompt and
///    hero figures (24px and up). It gives Clarion the voice of a decision
///    journal rather than a storefront. Hindi falls back to Tiro Devanagari
///    Hindi, so Hindi headings stay set in a serif.
///  * **Schibsted Grotesk** — a sharp grotesque for everything a person
///    reads and taps: body, labels, buttons.
///  * **IBM Plex Mono** — fixed-width figures for everything a person
///    compares below hero size: prices in lists, scores, deltas and micro
///    labels. Every glyph shares one advance, so counters never shift.
///
/// All three carry ₹ natively. The Clarion wordmark is a logotype and stays
/// in the grotesque ([logotype]).
abstract final class AppTypography {
  static const String serif = 'Newsreader';
  static const String sans = 'SchibstedGrotesk';
  static const String mono = 'IBMPlexMono';

  static const List<String> _serifFallback = ['TiroDevanagariHindi'];
  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  // ── Voice (serif) ─────────────────────────────────────────────────────────
  /// Display / intent: authoritative, calm, inviting (24–28px band).
  static TextStyle get display => TextStyle(
    fontFamily: serif,
    fontFamilyFallback: _serifFallback,
    fontSize: 28,
    height: 1.15,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.4,
    color: AppColors.textPrimary,
  );

  static TextStyle get headline => TextStyle(
    fontFamily: serif,
    fontFamilyFallback: _serifFallback,
    fontSize: 24,
    height: 1.2,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  /// Section headers: the architectural anchor points (17–19px band).
  static TextStyle get title => TextStyle(
    fontFamily: serif,
    fontFamilyFallback: _serifFallback,
    fontSize: 19,
    height: 1.3,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.1,
    color: AppColors.textPrimary,
  );

  /// The "Clarion" wordmark. A logotype, so it keeps the grotesque whatever
  /// the display face is.
  static TextStyle get logotype => TextStyle(
    fontFamily: sans,
    fontSize: 28,
    height: 1,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // ── Reading (sans) ────────────────────────────────────────────────────────
  static TextStyle get titleSmall => TextStyle(
    fontFamily: sans,
    fontSize: 15,
    height: 1.35,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.15,
    color: AppColors.textPrimary,
  );

  /// Body / trade-offs: crisp editorial clarity. Nothing a person must read
  /// is set below 12.5px; only uppercase mono micro labels go to 11px.
  static TextStyle get body => TextStyle(
    fontFamily: sans,
    fontSize: 15,
    height: 1.5,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodySmall => TextStyle(
    fontFamily: sans,
    fontSize: 13.5,
    height: 1.5,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.textSecondary,
  );

  static TextStyle get label => TextStyle(
    fontFamily: sans,
    fontSize: 14,
    height: 1.3,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  static TextStyle get caption => TextStyle(
    fontFamily: sans,
    fontSize: 12.5,
    height: 1.45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.textSecondary,
  );

  // ── Comparing (figures) ───────────────────────────────────────────────────
  /// Uppercase instrument-panel micro label for eyebrows and timestamps.
  static TextStyle get overline => TextStyle(
    fontFamily: mono,
    fontSize: 11,
    height: 1.3,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.1,
    color: AppColors.textTertiary,
  );

  /// Hero figures — the price on a product, the month on the barometer — in
  /// the serif, with tabular figures so they hold still while they count.
  static TextStyle get metricXL => TextStyle(
    fontFamily: serif,
    fontSize: 36,
    height: 1.05,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.6,
    color: AppColors.textPrimary,
    fontFeatures: _tabular,
  );

  static TextStyle get metricLarge => TextStyle(
    fontFamily: serif,
    fontSize: 26,
    height: 1.1,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
    fontFeatures: _tabular,
  );

  /// Score & metric digits (12–16px band).
  static TextStyle get metric => TextStyle(
    fontFamily: mono,
    fontSize: 15,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
    color: AppColors.textPrimary,
    fontFeatures: _tabular,
  );

  static TextStyle get metricSmall => TextStyle(
    fontFamily: mono,
    fontSize: 12.5,
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
    bodyMedium: body.copyWith(color: primary),
    bodySmall: bodySmall.copyWith(color: secondary),
    labelLarge: label.copyWith(color: primary),
    labelMedium: caption.copyWith(color: secondary),
    labelSmall: overline.copyWith(color: secondary),
  );
}
