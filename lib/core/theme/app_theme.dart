import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Material bridge for the Clarion tokens.
///
/// Built for whichever [AppColors.brightness] is active. Custom components
/// read tokens directly; this theme exists so stock widgets (snackbars, dialogs,
/// sliders, text selection) speak the same language.
abstract final class AppTheme {
  /// Transparent system bars with icons that contrast the canvas.
  static SystemUiOverlayStyle get overlayStyle =>
      (AppColors.isDark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark)
          .copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarContrastEnforced: false,
          );

  static ThemeData get current {
    final scheme = ColorScheme(
      brightness: AppColors.brightness,
      primary: AppColors.iris,
      onPrimary: AppColors.onAccent,
      secondary: AppColors.emerald,
      onSecondary: AppColors.canvas,
      tertiary: AppColors.amber,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      surfaceContainerHighest: AppColors.surfaceHigh,
      error: AppColors.rose,
      onError: AppColors.onAccent,
      outline: AppColors.rim,
      outlineVariant: AppColors.hairline,
    );
    final textTheme = AppTypography.textTheme(
      scheme.onSurface,
      scheme.onSurfaceVariant,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: AppColors.brightness,
      colorScheme: scheme,
      fontFamily: AppTypography.sans,
      scaffoldBackgroundColor: AppColors.canvas,
      textTheme: textTheme,
      // Custom controls give tactile scale feedback instead of ink.
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: AppTypography.titleSmall,
        systemOverlayStyle: overlayStyle,
      ),
      iconTheme: IconThemeData(color: AppColors.textPrimary, size: 20),
      dividerTheme: DividerThemeData(
        color: AppColors.hairline,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceHigh,
        contentTextStyle: AppTypography.label,
        actionTextColor: AppColors.irisGlow,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.mdAll,
          side: BorderSide(color: AppColors.rim),
        ),
        elevation: 0,
        insetPadding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.xs,
          AppSpacing.gutter,
          AppSpacing.sm,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.irisGlow,
        selectionColor: AppColors.iris.withValues(alpha: 0.35),
        selectionHandleColor: AppColors.irisGlow,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        isDense: true,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.irisGlow,
        inactiveTrackColor: AppColors.hairline,
        thumbColor: AppColors.textPrimary,
        overlayColor: AppColors.iris.withValues(alpha: 0.16),
        trackHeight: 2,
        showValueIndicator: ShowValueIndicator.never,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: AppRadii.smAll,
          border: Border.all(color: AppColors.rim),
        ),
        textStyle: AppTypography.caption.copyWith(color: AppColors.textPrimary),
      ),
    );
  }
}
