import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Clarion wordmark: a hairline lens with an iris focal point, set beside
/// the name in the grotesque. Quiet enough to sit in a header all day.
class ClarionWordmark extends StatelessWidget {
  const ClarionWordmark({super.key, this.size = 18});

  /// Height of the mark; the type scales from it.
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Clarion',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomPaint(size: Size.square(size), painter: const _LensPainter()),
          SizedBox(width: size * 0.45),
          Text(
            'Clarion',
            style: AppTypography.title.copyWith(
              fontSize: size * 0.98,
              letterSpacing: -0.5,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _LensPainter extends CustomPainter {
  const _LensPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    canvas
      ..drawCircle(
        c,
        r - 0.8,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = AppColors.textPrimary,
      )
      ..drawCircle(
        c.translate(r * 0.28, -r * 0.28),
        r * 0.26,
        Paint()..color = AppColors.irisGlow,
      );
  }

  @override
  bool shouldRepaint(_LensPainter oldDelegate) => false;
}
