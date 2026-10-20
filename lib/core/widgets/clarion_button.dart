import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'pressable.dart';

enum ButtonTone {
  /// Solid iris. One per view: the action the screen exists for.
  primary,

  /// Vellum with a rim light. Secondary and "slow down" actions.
  secondary,

  /// Solid emerald. Confirms a value-positive action (a swap that saves).
  positive,
}

/// Tactile action button with loading and disabled states.
class ClarionButton extends StatelessWidget {
  const ClarionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.tone = ButtonTone.primary,
    this.isLoading = false,
    this.height = 52,
    this.subtitle,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ButtonTone tone;
  final bool isLoading;
  final double height;

  /// Optional second line set in mono, e.g. a countdown.
  final String? subtitle;

  bool get _enabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    const radius = AppRadii.mdAll;
    final (fill, ink) = switch (tone) {
      ButtonTone.primary => (AppColors.iris, AppColors.onAccent),
      ButtonTone.positive => (AppColors.emerald, AppColors.canvas),
      ButtonTone.secondary => (AppColors.vellumActive, AppColors.textPrimary),
    };

    final content = AnimatedSwitcher(
      duration: AppMotion.medium,
      switchInCurve: AppMotion.standard,
      child: isLoading
          ? SizedBox.square(
              key: const ValueKey('loading'),
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 1.8, color: ink),
            )
          : _Label(
              key: ValueKey('$label$subtitle'),
              label: label,
              subtitle: subtitle,
              icon: icon,
              color: ink,
            ),
    );

    return Semantics(
      button: true,
      enabled: _enabled,
      label: label,
      excludeSemantics: true,
      child: Pressable(
        onTap: _enabled ? onPressed : null,
        child: AnimatedOpacity(
          opacity: onPressed == null ? 0.4 : 1,
          duration: AppMotion.fast,
          child: CustomPaint(
            foregroundPainter: const RimLightPainter(borderRadius: radius),
            child: AnimatedContainer(
              duration: AppMotion.medium,
              curve: AppMotion.standard,
              height: height,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              alignment: Alignment.center,
              decoration: BoxDecoration(color: fill, borderRadius: radius),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({
    super.key,
    required this.label,
    required this.color,
    this.subtitle,
    this.icon,
  });

  final String label;
  final String? subtitle;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final title = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTypography.label.copyWith(
        color: color,
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
      ),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: color),
          const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(
          child: subtitle == null
              ? title
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.metricSmall.copyWith(
                        fontSize: 10.5,
                        color: color.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
