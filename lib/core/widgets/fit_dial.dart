import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Personal Fit Score gauge: a 300° instrument arc, open at the base, with
/// the score set in mono at its centre.
///
/// The arc and the figure animate together on first build; because the
/// numerals are fixed-width the count-up never nudges the layout. Larger
/// dials get a faint backlight in their fit colour and a tick ring.
class FitDial extends StatelessWidget {
  const FitDial({
    super.key,
    required this.score,
    this.size = 56,
    this.animate = true,
    this.caption = 'FIT',
  });

  final int score;
  final double size;
  final bool animate;

  /// Micro label set in the arc's opening; hidden on small dials.
  final String caption;

  @override
  Widget build(BuildContext context) {
    final target = score.clamp(0, 100).toDouble();
    final color = AppColors.forFit(score);
    final showCaption = size >= 56;

    return Semantics(
      label: 'Personal fit $score percent',
      excludeSemantics: true,
      child: RepaintBoundary(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: animate ? 0 : target, end: target),
          duration: AppMotion.reveal,
          curve: AppMotion.standard,
          builder: (context, value, _) => CustomPaint(
            size: Size.square(size),
            painter: _DialPainter(
              progress: value / 100,
              color: color,
              detailed: size >= 72,
            ),
            child: SizedBox.square(
              dimension: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    '${value.round()}',
                    style: AppTypography.metric.copyWith(
                      fontSize: size * 0.3,
                      letterSpacing: -size * 0.015,
                      height: 1,
                    ),
                  ),
                  if (showCaption)
                    Positioned(
                      bottom: size * 0.04,
                      child: Text(
                        caption,
                        style: AppTypography.overline.copyWith(
                          fontSize: (size * 0.12).clamp(7.5, 10.0),
                          color: color,
                          letterSpacing: 1,
                          height: 1,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  _DialPainter({
    required this.progress,
    required this.color,
    required this.detailed,
  });

  final double progress;
  final Color color;
  final bool detailed;

  static const double _start = math.pi / 2 + math.pi / 6; // 120°
  static const double _span = math.pi * 5 / 3; // 300°

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = (size.width * 0.055).clamp(2.0, 4.5);
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - stroke) / 2 - (detailed ? 4 : 0);
    final arcRect = Rect.fromCircle(center: center, radius: radius);

    if (size.width >= 56) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [color.withValues(alpha: 0.14), color.withValues(alpha: 0)],
          ).createShader(arcRect),
      );
    }

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke;

    canvas.drawArc(
      arcRect,
      _start,
      _span,
      false,
      line..color = AppColors.hairline,
    );

    if (detailed) {
      final tick = Paint()
        ..color = Colors.white.withValues(alpha: 0.10)
        ..strokeWidth = 1;
      for (var i = 0; i <= 10; i++) {
        final a = _start + _span * i / 10;
        final dir = Offset(math.cos(a), math.sin(a));
        canvas.drawLine(
          center + dir * (radius + stroke / 2 + 2),
          center + dir * (radius + stroke / 2 + 5),
          tick,
        );
      }
    }

    if (progress <= 0) return;
    canvas.drawArc(
      arcRect,
      _start,
      _span * progress.clamp(0.0, 1.0),
      false,
      line..color = color,
    );
  }

  @override
  bool shouldRepaint(_DialPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.detailed != detailed;
}
