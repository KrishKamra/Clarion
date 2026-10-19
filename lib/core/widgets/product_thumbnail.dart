import 'package:flutter/material.dart';

import '../models/product.dart';
import '../theme/app_spacing.dart';

/// Stylised product artwork: the product's signature gradient, a soft
/// spotlight and its glyph. Stands in for photography until a CDN exists,
/// and doubles as the [Hero] anchor between list and detail views.
class ProductThumbnail extends StatelessWidget {
  const ProductThumbnail({
    super.key,
    required this.product,
    this.size,
    this.borderRadius = AppRadii.md,
    this.heroTag,
    this.iconScale = 0.42,
  });

  final Product product;

  /// Square dimension; when null, fills the parent.
  final double? size;
  final double borderRadius;
  final Object? heroTag;
  final double iconScale;

  @override
  Widget build(BuildContext context) {
    final art = LayoutBuilder(
      builder: (context, constraints) {
        final extent = size ?? constraints.biggest.shortestSide;
        final c1 = product.palette.first;
        final c2 = product.palette.last;
        return Container(
          width: size ?? constraints.maxWidth,
          height: size ?? constraints.maxHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(c1, Colors.black, 0.35)!,
                Color.lerp(c2, Colors.black, 0.6)!,
              ],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
                    gradient: RadialGradient(
                      center: const Alignment(-0.3, -0.5),
                      radius: 0.9,
                      colors: [
                        c1.withValues(alpha: 0.55),
                        c1.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              Icon(
                product.icon,
                size: extent.isFinite ? extent * iconScale : 48,
                color: Colors.white.withValues(alpha: 0.92),
                shadows: [
                  Shadow(
                    color: c1.withValues(alpha: 0.9),
                    blurRadius: extent.isFinite ? extent * 0.2 : 20,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (heroTag == null) return art;
    return Hero(tag: heroTag!, child: art);
  }
}
