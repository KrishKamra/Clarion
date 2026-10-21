import 'package:flutter/material.dart';

import '../../data/models/product_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Product shot on a matte studio stage: a soft key light from above tinted
/// by the product's tone, a contact shadow on the floor, and the glyph lit
/// in titanium. Stands in for photography until a CDN exists, and doubles
/// as the [Hero] anchor between list and detail.
class ProductArtwork extends StatelessWidget {
  const ProductArtwork({
    super.key,
    required this.product,
    this.size,
    this.radius = AppRadii.md,
    this.heroTag,
    this.glyphScale = 0.42,
  });

  final Product product;

  /// Square dimension; when null, fills the parent.
  final double? size;
  final double radius;
  final Object? heroTag;
  final double glyphScale;

  @override
  Widget build(BuildContext context) {
    final art = SizedBox(
      width: size,
      height: size,
      child: LayoutBuilder(
        builder: (context, c) {
          final extent = c.biggest.shortestSide;
          final borderRadius = BorderRadius.circular(radius);
          final staged = extent >= 96;
          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF16181F), AppColors.surface],
              ),
              border: Border.all(color: AppColors.hairline),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Key light.
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: borderRadius,
                      gradient: RadialGradient(
                        center: const Alignment(0, -0.85),
                        radius: 0.95,
                        colors: [
                          product.tone.withValues(alpha: 0.16),
                          product.tone.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
                if (staged)
                  Align(
                    alignment: const Alignment(0, 0.62),
                    child: Container(
                      width: extent * glyphScale * 1.1,
                      height: extent * 0.05,
                      decoration: BoxDecoration(
                        borderRadius: AppRadii.pillAll,
                        gradient: RadialGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.55),
                            Colors.black.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                Align(
                  alignment: Alignment(0, staged ? -0.08 : 0),
                  child: Icon(
                    product.icon,
                    size: extent * glyphScale,
                    color: AppColors.textPrimary.withValues(alpha: 0.92),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    if (heroTag == null) return art;
    return Hero(tag: heroTag!, child: art);
  }
}
