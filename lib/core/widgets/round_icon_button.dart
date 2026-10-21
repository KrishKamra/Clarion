import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import 'frosted_chrome.dart';
import 'pressable.dart';

/// Circular icon control. [frosted] gives it a backdrop blur for use as a
/// fixed overlay above imagery; otherwise it is plain vellum.
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.size = 40,
    this.frosted = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String semanticLabel;
  final double size;
  final bool frosted;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size / 2);
    final face = Icon(icon, size: size * 0.46, color: AppColors.textPrimary);

    final Widget body = frosted
        ? FrostedChrome(
            borderRadius: radius,
            sigma: 14,
            fill: const Color(0x7307080B),
            child: SizedBox.square(
              dimension: size,
              child: Center(child: face),
            ),
          )
        : CustomPaint(
            foregroundPainter: RimLightPainter(
              borderRadius: radius,
              gradient: AppDecorations.rimLightSoft,
            ),
            child: Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: AppDecorations.vellum(borderRadius: radius),
              child: face,
            ),
          );

    return Tooltip(
      message: semanticLabel,
      excludeFromSemantics: true,
      child: Pressable(
        onTap: onPressed,
        scale: 0.92,
        semanticLabel: semanticLabel,
        child: body,
      ),
    );
  }
}
