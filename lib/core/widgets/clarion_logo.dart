import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_glass.dart';
import '../theme/app_typography.dart';

/// Clarion mark: an open "C" arc (a lens) around a focal point – clarity of
/// intent – drawn on a brand-gradient tile.
class ClarionLogo extends StatelessWidget {
  const ClarionLogo({super.key, this.size = 34, this.showWordmark = true});

  final double size;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: AppGlass.glow(
          AppColors.primary,
          blurRadius: size * 0.7,
          opacity: 0.6,
          offset: Offset(0, size * 0.12),
        ),
      ),
      child: CustomPaint(painter: _MarkPainter()),
    );

    if (!showWordmark) return mark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        SizedBox(width: size * 0.3),
        Text(
          'Clarion',
          style: AppTypography.titleSmall.copyWith(
            fontSize: size * 0.56,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
          ),
        ),
      ],
    );
  }
}

class _MarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width * 0.27;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.1
      ..strokeCap = StrokeCap.round
      ..color = Colors.white;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      math.pi * 0.28,
      math.pi * 1.44,
      false,
      stroke,
    );
    canvas.drawCircle(
      c.translate(r * 0.55, 0),
      size.width * 0.075,
      Paint()..color = const Color(0xFFA5F3FC),
    );
  }

  @override
  bool shouldRepaint(_MarkPainter oldDelegate) => false;
}
