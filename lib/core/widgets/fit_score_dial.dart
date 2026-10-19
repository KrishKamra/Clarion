import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Radial 0–100 fit indicator.
///
/// The arc sweeps in on first build, coloured by the semantic fit scale
/// (emerald / amber / coral) with a soft glow at its leading edge.
class FitScoreDial extends StatelessWidget {
  const FitScoreDial({
    super.key,
    required this.score,
    this.size = 64,
    this.strokeWidth,
    this.label = 'Match',
    this.showLabel = true,
    this.animate = true,
  });

  final int score;
  final double size;
  final double? strokeWidth;
  final String label;
  final bool showLabel;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forFitScore(score);
    final stroke = strokeWidth ?? (size * 0.085).clamp(3.0, 10.0);
    final target = score.clamp(0, 100) / 100;

    return Semantics(
      label: '$score percent $label',
      child: RepaintBoundary(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: animate ? 0 : target, end: target),
          duration: AppMotion.dial,
          curve: AppMotion.emphasized,
          builder: (context, value, _) => SizedBox.square(
            dimension: size,
            child: CustomPaint(
              painter: _DialPainter(
                progress: value,
                color: color,
                strokeWidth: stroke,
              ),
              child: Center(child: _centerLabel(value, color)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _centerLabel(double value, Color color) {
    final shown = (value * 100).round();
    final numberSize = size * (showLabel ? 0.3 : 0.34);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text.rich(
          TextSpan(
            text: '$shown',
            children: [
              TextSpan(
                text: '%',
                style: TextStyle(
                  fontSize: numberSize * 0.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          style: AppTypography.numeric.copyWith(
            fontSize: numberSize,
            letterSpacing: -0.5,
            height: 1,
          ),
        ),
        if (showLabel && size >= 56)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              label.toUpperCase(),
              style: AppTypography.overline.copyWith(
                fontSize: (size * 0.11).clamp(7.0, 11.0),
                color: color,
                letterSpacing: 0.8,
              ),
            ),
          ),
      ],
    );
  }
}

class _DialPainter extends CustomPainter {
  _DialPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final double strokeWidth;

  static const double _start = -math.pi / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = Colors.white.withValues(alpha: 0.07),
    );

    if (progress <= 0) return;
    final sweep = 2 * math.pi * progress;

    // Glow
    canvas.drawArc(
      rect,
      _start,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 1.6
        ..strokeCap = StrokeCap.round
        ..color = color.withValues(alpha: 0.35)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, strokeWidth),
    );

    // Arc: gradient brightens toward the leading edge.
    final shader = SweepGradient(
      startAngle: 0,
      endAngle: sweep,
      colors: [color.withValues(alpha: 0.55), color],
      transform: const GradientRotation(_start),
    ).createShader(rect);

    canvas.drawArc(
      rect,
      _start,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..shader = shader,
    );
  }

  @override
  bool shouldRepaint(_DialPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.strokeWidth != strokeWidth;
}
