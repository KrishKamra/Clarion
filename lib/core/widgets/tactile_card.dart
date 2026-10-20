import 'package:flutter/material.dart';

import '../theme/app_decorations.dart';
import '../theme/app_spacing.dart';
import 'pressable.dart';

/// Which material a [TactileCard] is made of. See [AppDecorations].
enum CardMaterial { raised, vellum }

/// The base surface for content: a blur-free card with a directional rim
/// light, safe to repeat any number of times inside a scroll view.
///
/// Pass [tint] to give one card a contextual wash of colour (a budget alert,
/// a winning verdict); leave it null everywhere else.
class TactileCard extends StatelessWidget {
  const TactileCard({
    super.key,
    required this.child,
    this.material = CardMaterial.raised,
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
      CardMaterial.raised => AppDecorations.raised(
        borderRadius: borderRadius,
        tint: tint,
      ),
      CardMaterial.vellum => AppDecorations.vellum(
        borderRadius: borderRadius,
        tint: tint,
      ),
    };

    Widget card = CustomPaint(
      foregroundPainter: RimLightPainter(
        borderRadius: borderRadius,
        gradient: material == CardMaterial.raised
            ? AppDecorations.rimLight
            : AppDecorations.rimLightSoft,
      ),
      child: DecoratedBox(
        decoration: decoration,
        child: Padding(padding: padding, child: child),
      ),
    );

    if (onTap != null) {
      card = Pressable(onTap: onTap, semanticLabel: semanticLabel, child: card);
    }
    return card;
  }
}
