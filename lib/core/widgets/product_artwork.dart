import 'package:flutter/material.dart';

import '../../data/models/product_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Product shot on a matte studio stage: a soft key light from above tinted
/// by the product's tone, a contact shadow on the floor, and the glyph lit
/// in titanium. Shows the product's photo from `assets/products/` when one
/// has been added (see [Product.imageAssets]) and the glyph otherwise, and
/// doubles as the [Hero] anchor between list and detail.
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

  Widget glyph(double extent) => Icon(
    product.icon,
    size: extent * glyphScale,
    color: AppColors.textPrimary.withValues(alpha: 0.92),
  );

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
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: AppColors.isDark
                    ? [const Color(0xFF16181F), AppColors.surface]
                    : const [Color(0xFFF8F9FB), Color(0xFFECEEF2)],
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
                            Colors.black.withValues(
                              alpha: AppColors.isDark ? 0.55 : 0.16,
                            ),
                            Colors.black.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                Align(
                  alignment: Alignment(0, staged ? -0.08 : 0),
                  child: glyph(extent),
                ),
                // A real photo, when one has been added, covers the stage.
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: borderRadius,
                    child: _ProductPhoto(
                      candidates: product.imageAssets,
                      fallback: const SizedBox.shrink(),
                    ),
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

/// Tries each candidate asset in turn and shows the first that exists; shows
/// [fallback] (nothing) when none does, so a missing photo is never an error.
class _ProductPhoto extends StatefulWidget {
  const _ProductPhoto({required this.candidates, required this.fallback});

  final List<String> candidates;
  final Widget fallback;

  @override
  State<_ProductPhoto> createState() => _ProductPhotoState();
}

class _ProductPhotoState extends State<_ProductPhoto> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    if (_index >= widget.candidates.length) return widget.fallback;
    final path = widget.candidates[_index];
    return Image.asset(
      path,
      key: ValueKey(path),
      fit: BoxFit.cover,
      gaplessPlayback: true,
      frameBuilder: (context, child, frame, sync) => AnimatedOpacity(
        opacity: frame == null && !sync ? 0 : 1,
        duration: const Duration(milliseconds: 220),
        child: child,
      ),
      errorBuilder: (context, error, stack) {
        // Not found: try the next extension after this frame.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _index < widget.candidates.length) {
            setState(() => _index++);
          }
        });
        return widget.fallback;
      },
    );
  }
}
