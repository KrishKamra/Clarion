import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_glass.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'pressable.dart';

enum GradientButtonVariant {
  /// Indigo → violet fill with a soft glow. The single primary action.
  primary,

  /// Frosted, outlined. Secondary or "slow down" actions.
  glass,

  /// Success fill, used once an action has completed (e.g. "In cart").
  success,
}

/// Tactile action button with loading and disabled states.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = GradientButtonVariant.primary,
    this.isLoading = false,
    this.expand = true,
    this.height = 54,
    this.gradient,
    this.subtitle,
    this.horizontalPadding = AppSpacing.xl,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final GradientButtonVariant variant;
  final bool isLoading;
  final bool expand;
  final double height;

  /// Overrides the primary gradient.
  final Gradient? gradient;

  /// Optional second line, e.g. "24h cooldown".
  final String? subtitle;

  /// Inner horizontal padding; reduce for side-by-side button pairs.
  final double horizontalPadding;

  bool get _enabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadii.md);
    final isGlass = variant == GradientButtonVariant.glass;

    final Gradient fill = switch (variant) {
      GradientButtonVariant.primary => gradient ?? AppColors.brandGradient,
      GradientButtonVariant.success => const LinearGradient(
        colors: [Color(0xFF059669), AppColors.fitHigh],
      ),
      GradientButtonVariant.glass => AppGlass.fillGradient(opacity: 0.08),
    };
    final glowColor = switch (variant) {
      GradientButtonVariant.primary => AppColors.primary,
      GradientButtonVariant.success => AppColors.fitHigh,
      GradientButtonVariant.glass => null,
    };

    final content = AnimatedSwitcher(
      duration: AppMotion.medium,
      switchInCurve: AppMotion.standard,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween(begin: 0.9, end: 1.0).animate(animation),
          child: child,
        ),
      ),
      child: isLoading
          ? const SizedBox(
              key: ValueKey('loading'),
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: Colors.white,
              ),
            )
          : _Label(
              key: ValueKey('$label$icon$subtitle'),
              label: label,
              icon: icon,
              subtitle: subtitle,
              color: isGlass ? AppColors.textPrimary : Colors.white,
            ),
    );

    final button = AnimatedOpacity(
      opacity: onPressed == null ? 0.45 : 1,
      duration: AppMotion.fast,
      child: AnimatedContainer(
        duration: AppMotion.medium,
        curve: AppMotion.standard,
        height: height,
        width: expand ? double.infinity : null,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        decoration: BoxDecoration(
          gradient: fill,
          borderRadius: radius,
          border: isGlass ? Border.all(color: AppColors.glassBorder) : null,
          boxShadow: glowColor != null && _enabled
              ? AppGlass.glow(glowColor, opacity: 0.5)
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (!isGlass)
              // Top sheen for a subtle glassy bevel on solid fills.
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.center,
                      colors: [
                        Colors.white.withValues(alpha: 0.18),
                        Colors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            content,
          ],
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: _enabled,
      label: label,
      excludeSemantics: true,
      child: Pressable(onTap: _enabled ? onPressed : null, child: button),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.subtitle,
  });

  final String label;
  final IconData? icon;
  final String? subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = subtitle == null
        ? Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.label.copyWith(color: color, fontSize: 15),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.label.copyWith(color: color, fontSize: 14),
              ),
              Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption.copyWith(
                  color: color.withValues(alpha: 0.65),
                  fontSize: 10.5,
                ),
              ),
            ],
          );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 19, color: color),
          const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(child: text),
      ],
    );
  }
}
