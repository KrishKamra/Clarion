import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/fit_score_gauge.dart';
import '../../../core/widgets/frosted_chrome.dart';
import '../../../core/widgets/pressable.dart';
import '../../../core/widgets/product_artwork.dart';
import '../../../data/models/product_model.dart';
import '../presentation/product_decision_screen.dart';

/// Sticky side-by-side candidate header for the Compare Matrix.
///
/// Expanded, it shows both products on their matte stages; as the matrix
/// scrolls the artwork recedes and the header pins as a compact frosted
/// A-vs-B bar with names, prices and fit gauges — so every row below is
/// always read against who it belongs to.
class StickyCompareHeader extends StatelessWidget {
  const StickyCompareHeader({
    super.key,
    required this.left,
    required this.right,
    this.leader,
  });

  final Product left;
  final Product right;

  /// The product leading on the user's priorities, if any.
  final Product? leader;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _Delegate(left: left, right: right, leader: leader),
    );
  }
}

class _Delegate extends SliverPersistentHeaderDelegate {
  _Delegate({required this.left, required this.right, this.leader});

  final Product left;
  final Product right;
  final Product? leader;

  static const double _compact = 76;
  static const double _stage = 128;

  @override
  double get minExtent => _compact;

  @override
  double get maxExtent => _compact + _stage;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    final t = (shrinkOffset / _stage).clamp(0.0, 1.0);
    final pinned = t > 0.98 || overlaps;

    final content = Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        children: [
          SizedBox(
            height: _stage * (1 - t),
            child: Opacity(
              opacity: (1 - t * 1.6).clamp(0.0, 1.0),
              child: Row(
                children: [
                  Expanded(child: _Stage(product: left)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: _Stage(product: right)),
                ],
              ),
            ),
          ),
          SizedBox(
            height: _compact,
            child: Row(
              children: [
                Expanded(
                  child: _Candidate(product: left, leads: leader == left),
                ),
                Container(
                  width: 0.5,
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  color: AppColors.edge,
                ),
                Expanded(
                  child: _Candidate(product: right, leads: leader == right),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (!pinned) return content;
    return Stack(
      fit: StackFit.expand,
      children: [
        FrostedChrome(
          sigma: 20,
          fill: AppColors.canvas.withValues(alpha: 0.78),
          rim: false,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.hairline)),
            ),
          ),
        ),
        content,
      ],
    );
  }

  @override
  bool shouldRebuild(_Delegate old) =>
      old.left != left || old.right != right || old.leader != leader;
}

class _Stage extends StatelessWidget {
  const _Stage({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: ProductArtwork(
        product: product,
        radius: AppRadii.md,
        glyphScale: 0.42,
      ),
    );
  }
}

class _Candidate extends StatelessWidget {
  const _Candidate({required this.product, required this.leads});

  final Product product;
  final bool leads;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () => ProductDecisionScreen.open(context, product.id),
      semanticLabel: 'Open ${product.title}',
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  leads ? 'LEADS' : product.brand.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.overline.copyWith(
                    color: leads ? AppColors.emeraldGlow : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  product.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label,
                ),
                const SizedBox(height: 2),
                Text(Fmt.inr(product.price), style: AppTypography.metricSmall),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          FitScoreGauge(score: product.fitScore, size: 40, animate: false),
        ],
      ),
    );
  }
}
