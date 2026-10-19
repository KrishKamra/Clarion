import 'package:flutter/material.dart';

import '../theme/app_glass.dart';
import 'pressable.dart';

/// Frosted surface with a directional gradient border.
///
/// * `blur > 0` renders true glass via [BackdropFilter]. Use for persistent
///   overlays (bars, sheets, dialogs, sticky headers).
/// * [GlassContainer.card] (blur 0) renders identical styling without the
///   backdrop pass – use for anything repeated inside a scroll view.
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    this.child,
    this.blur = AppGlass.defaultBlur,
    this.opacity = AppGlass.defaultOpacity,
    this.borderRadius = AppGlass.defaultRadius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.tint,
    this.backgroundColor,
    this.borderIntensity = 1,
    this.gradientFill = true,
    this.boxShadow,
    this.onTap,
    this.alignment,
  });

  /// Performant faux-glass variant for list items (no backdrop blur).
  const GlassContainer.card({
    super.key,
    this.child,
    this.opacity = AppGlass.defaultOpacity,
    this.borderRadius = AppGlass.defaultRadius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.tint,
    this.backgroundColor,
    this.borderIntensity = 1,
    this.gradientFill = true,
    this.boxShadow,
    this.onTap,
    this.alignment,
  }) : blur = 0;

  final Widget? child;

  /// Backdrop blur sigma; `0` disables the (expensive) backdrop filter.
  final double blur;

  /// White (or [tint]) fill opacity.
  final double opacity;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;

  /// Optional colour cast for the fill, e.g. an emerald-tinted success card.
  final Color? tint;

  /// Solid colour painted beneath the glass fill – handy on true-glass bars
  /// to guarantee legibility over busy content.
  final Color? backgroundColor;

  /// Multiplier for the border sheen; 0 hides it.
  final double borderIntensity;

  /// When false, the fill is flat rather than a soft diagonal gradient.
  final bool gradientFill;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final fillColor = (tint ?? Colors.white).withValues(alpha: opacity);

    Widget surface = DecoratedBox(
      decoration: BoxDecoration(color: backgroundColor, borderRadius: radius),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          color: gradientFill ? null : fillColor,
          gradient: gradientFill
              ? AppGlass.fillGradient(opacity: opacity, tint: tint)
              : null,
        ),
        child: CustomPaint(
          foregroundPainter: borderIntensity > 0
              ? GlassBorderPainter(
                  radius: borderRadius,
                  gradient: AppGlass.borderGradient(intensity: borderIntensity),
                )
              : null,
          child: Container(
            padding: padding,
            alignment: alignment,
            child: child,
          ),
        ),
      ),
    );

    if (blur > 0) {
      surface = ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(filter: AppGlass.blur(blur), child: surface),
      );
    }

    if (boxShadow != null) {
      surface = DecoratedBox(
        decoration: BoxDecoration(borderRadius: radius, boxShadow: boxShadow),
        child: surface,
      );
    }

    surface = SizedBox(width: width, height: height, child: surface);

    if (onTap != null) surface = Pressable(onTap: onTap, child: surface);
    if (margin != null) surface = Padding(padding: margin!, child: surface);
    return surface;
  }
}
