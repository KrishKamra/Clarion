import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Deep-navy canvas lit by large, soft radial glows (Stripe-style ambient
/// illumination). Radial gradients are rasterised once and isolated behind a
/// [RepaintBoundary], so the effect is free while content scrolls above it.
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({
    super.key,
    required this.child,
    this.primaryGlow = AppColors.primary,
    this.secondaryGlow = AppColors.secondary,
    this.accentGlow = AppColors.accent,
  });

  final Widget child;
  final Color primaryGlow;
  final Color secondaryGlow;
  final Color accentGlow;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: DecoratedBox(
              decoration: const BoxDecoration(color: AppColors.backgroundDeep),
              child: Stack(
                children: [
                  _Glow(
                    alignment: const Alignment(-1.3, -1.1),
                    color: primaryGlow,
                    opacity: 0.30,
                    sizeFactor: 1.25,
                  ),
                  _Glow(
                    alignment: const Alignment(1.4, -0.35),
                    color: secondaryGlow,
                    opacity: 0.20,
                    sizeFactor: 1.0,
                  ),
                  _Glow(
                    alignment: const Alignment(-0.8, 1.25),
                    color: accentGlow,
                    opacity: 0.12,
                    sizeFactor: 1.1,
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({
    required this.alignment,
    required this.color,
    required this.opacity,
    required this.sizeFactor,
  });

  final Alignment alignment;
  final Color color;
  final double opacity;
  final double sizeFactor;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context).width * sizeFactor;
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: opacity),
                color.withValues(alpha: opacity * 0.35),
                color.withValues(alpha: 0),
              ],
              stops: const [0, 0.45, 1],
            ),
          ),
        ),
      ),
    );
  }
}
