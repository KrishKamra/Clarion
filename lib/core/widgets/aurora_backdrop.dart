import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'obsidian_canvas.dart';

/// The arrival canvas (sign-in): one still light falling from above, plum
/// at its heart and champagne at its edge, like light through a coated
/// lens. Gradients only, never blurs, and nothing drifts: Clarion keeps
/// colour on edges and actions, not as fog behind content.
///
/// Put frosted glass on top: the light is what the glass refracts.
class AuroraBackdrop extends StatelessWidget {
  const AuroraBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ObsidianCanvas(
      glowIntensity: 0,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(child: CustomPaint(painter: _LightPainter())),
          child,
        ],
      ),
    );
  }
}

class _LightPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strength = AppColors.isDark ? 1.0 : 0.6;
    final centre = Offset(size.width * 0.5, -size.height * 0.08);
    final radius = size.longestSide * 0.75;
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.action.withValues(alpha: 0.20 * strength),
            AppColors.champagne.withValues(alpha: 0.07 * strength),
            AppColors.champagne.withValues(alpha: 0),
          ],
          stops: const [0, 0.45, 1],
        ).createShader(Rect.fromCircle(center: centre, radius: radius)),
    );
  }

  @override
  bool shouldRepaint(_LightPainter old) => false;
}
