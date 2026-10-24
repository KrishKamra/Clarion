import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../theme/app_spacing.dart';
import 'pressable.dart';

/// Which material a [TactileCard] is made of. See [AppDecorations].
enum CardMaterial {
  /// Tier 1 — the default for content in lists.
  matte,

  /// Tier 2 — the one card on a screen that should lift (a highlighted
  /// decision node, a floating summary).
  floating,

  /// Translucent — inputs, empty states, quiet panels.
  vellum,
}

/// The base surface for content: a blur-free card with a specular rim,
/// safe to repeat any number of times inside a fast-scrolling list.
///
/// Pass [tint] to give one card a contextual wash of colour (a budget alert,
/// a winning verdict); leave it null everywhere else.
class TactileCard extends StatelessWidget {
  const TactileCard({
    super.key,
    required this.child,
    this.material = CardMaterial.matte,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.radius = AppRadii.lg,
    this.tint,
    this.onTap,
    this.semanticLabel,
  });

  final Widget child;
  final CardMaterial material;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? tint;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    final decoration = switch (material) {
      CardMaterial.matte => AppDecorations.matte(
        borderRadius: borderRadius,
        tint: tint,
      ),
      CardMaterial.floating => AppDecorations.floating(
        borderRadius: borderRadius,
        tint: tint,
      ),
      CardMaterial.vellum => AppDecorations.vellum(
        borderRadius: borderRadius,
        tint: tint,
      ),
    };

    final accent = tint ?? AppColors.irisGlow;
    Widget card = Builder(
      // Under a hovering pointer the rim catches the accent, so the card
      // reads as lit from within rather than merely highlighted.
      builder: (context) => CustomPaint(
        foregroundPainter: RimLightPainter(
          borderRadius: borderRadius,
          gradient: Pressable.stateOf(context).hovered
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accent.withValues(alpha: 0.75),
                    accent.withValues(alpha: 0.12),
                  ],
                )
              : material == CardMaterial.vellum
              ? AppDecorations.rimLightSoft
              : AppDecorations.rimLight,
        ),
        child: DecoratedBox(
          decoration: decoration,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );

    if (onTap != null) {
      card = Pressable(
        onTap: onTap,
        semanticLabel: semanticLabel,
        child: PressGlow(
          color: tint ?? AppColors.iris,
          borderRadius: borderRadius,
          child: card,
        ),
      );
    }
    return card;
  }
}
