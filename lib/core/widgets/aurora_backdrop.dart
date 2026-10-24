import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'obsidian_canvas.dart';

/// Slowly drifting pools of brand light on the canvas — the one place
/// Clarion lets colour move, for moments that should feel like an arrival
/// (sign-in). Gradients only, never blurs, on their own layer, and held
/// still when the system asks for reduced motion.
///
/// Put frosted glass on top: the drift is what gives the blur something to
/// refract.
class AuroraBackdrop extends StatefulWidget {
  const AuroraBackdrop({super.key, required this.child});

  final Widget child;

  @override
  State<AuroraBackdrop> createState() => _AuroraBackdropState();
}

class _AuroraBackdropState extends State<AuroraBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drift = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _drift.stop();
    } else if (!_drift.isAnimating) {
      _drift.repeat();
    }
  }

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ObsidianCanvas(
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(child: CustomPaint(painter: _AuroraPainter(_drift))),
          widget.child,
        ],
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  _AuroraPainter(this.t) : super(repaint: t);

  final Animation<double> t;

  @override
  void paint(Canvas canvas, Size size) {
    // Whole-number frequencies of one turn, so the loop is seamless.
    final a = t.value * 2 * math.pi;
    final r = size.longestSide;
    final strength = AppColors.isDark ? 1.0 : 0.55;

    void pool(double x, double y, double radius, Color color, double alpha) {
      final c = Offset(size.width * x, size.height * y);
      canvas.drawCircle(
        c,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              color.withValues(alpha: alpha * strength),
              color.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: c, radius: radius)),
      );
    }

    pool(
      0.18 + 0.14 * math.sin(a),
      0.1 + 0.06 * math.cos(a),
      r * 0.55,
      AppColors.iris,
      0.38,
    );
    pool(
      0.88 + 0.08 * math.cos(a),
      0.32 + 0.08 * math.sin(2 * a),
      r * 0.42,
      AppColors.emeraldGlow,
      0.2,
    );
    pool(
      0.4 + 0.16 * math.cos(2 * a),
      0.9 + 0.05 * math.sin(a),
      r * 0.5,
      AppColors.irisGlow,
      0.24,
    );
  }

  @override
  bool shouldRepaint(_AuroraPainter old) => old.t != t;
}
