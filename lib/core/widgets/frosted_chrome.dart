import 'package:flutter/material.dart';

import '../theme/app_decorations.dart';

/// Frosted glass for fixed chrome — the only widget in the app that owns a
/// `BackdropFilter`.
///
/// Use it for surfaces that never scroll (the nav island, pinned headers,
/// sheets, the decision drawer, floating overlay buttons). Anything repeated
/// inside a list should be a `TactileCard` instead.
class FrostedChrome extends StatelessWidget {
  const FrostedChrome({
    super.key,
    required this.child,
    this.borderRadius = BorderRadius.zero,
    this.sigma = 24,
    this.fill,
    this.rim = true,
    this.floating = false,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final double sigma;

  /// Defaults to [AppDecorations.frostFill].
  final Color? fill;

  /// Paint the directional rim light along the edge.
  final bool rim;

  /// Add a soft contact shadow, for chrome that hovers above content.
  final bool floating;

  @override
  Widget build(BuildContext context) {
    Widget glass = ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: AppDecorations.frost(sigma),
        child: CustomPaint(
          foregroundPainter: rim
              ? RimLightPainter(borderRadius: borderRadius)
              : null,
          child: ColoredBox(
            color: fill ?? AppDecorations.frostFill,
            child: child,
          ),
        ),
      ),
    );

    if (floating) {
      glass = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: AppDecorations.floatShadow,
        ),
        child: glass,
      );
    }
    return glass;
  }
}
