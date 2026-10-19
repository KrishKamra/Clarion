import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Clarion typographic scale.
///
/// Uses the platform system face (SF Pro on iOS, Roboto on Android) so text
/// renders instantly with no font download, tightened with negative tracking
/// on large sizes for a Linear / Inter-like precision. Numeric styles use
/// tabular figures so prices and scores never jitter while animating.
abstract final class AppTypography {
  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  static const TextStyle display = TextStyle(
    fontSize: 34,
    height: 1.12,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.1,
    color: AppColors.textPrimary,
  );

  static const TextStyle headline = TextStyle(
    fontSize: 26,
    height: 1.18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.7,
    color: AppColors.textPrimary,
  );

  static const TextStyle title = TextStyle(
    fontSize: 20,
    height: 1.25,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 16,
    height: 1.3,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    height: 1.45,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.1,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    height: 1.4,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle label = TextStyle(
    fontSize: 13,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.05,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11.5,
    height: 1.3,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: AppColors.textSecondary,
  );

  /// All-caps micro heading, e.g. section eyebrows.
  static const TextStyle overline = TextStyle(
    fontSize: 11,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    color: AppColors.textTertiary,
  );

  static const TextStyle numericLarge = TextStyle(
    fontSize: 30,
    height: 1.1,
    fontWeight: FontWeight.w700,
    letterSpacing: -1,
    color: AppColors.textPrimary,
    fontFeatures: _tabular,
  );

  static const TextStyle numeric = TextStyle(
    fontSize: 17,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
    fontFeatures: _tabular,
  );

  static const TextStyle numericSmall = TextStyle(
    fontSize: 13,
    height: 1.2,
    fontWeight: FontWeight.w600,
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
