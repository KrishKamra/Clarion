import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_glass.dart';
import '../theme/app_spacing.dart';

/// Pinned top bar that is transparent at rest and turns into true frosted
/// glass once content scrolls beneath it.
///
/// The backdrop filter is only composited while content is underneath, so
/// a screen at scroll offset 0 pays nothing for it.
class GlassSliverHeader extends StatelessWidget {
  const GlassSliverHeader({super.key, required this.child, this.height = 64});

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _GlassHeaderDelegate(
        child: child,
        height: height,
        topInset: MediaQuery.paddingOf(context).top,
      ),
    );
  }
}

class _GlassHeaderDelegate extends SliverPersistentHeaderDelegate {
  _GlassHeaderDelegate({
    required this.child,
    required this.height,
    required this.topInset,
  });

  final Widget child;
  final double height;
  final double topInset;

  @override
  double get minExtent => height + topInset;

  @override
  double get maxExtent => height + topInset;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final scrolled = shrinkOffset > 0 || overlapsContent;
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedOpacity(
          opacity: scrolled ? 1 : 0,
          duration: AppMotion.medium,
          child: ClipRect(
            child: BackdropFilter(
              filter: AppGlass.blur(20),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.backgroundDeep.withValues(alpha: 0.6),
                  border: const Border(
                    bottom: BorderSide(color: AppColors.hairline),
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: topInset,
            left: AppSpacing.gutter,
            right: AppSpacing.gutter - AppSpacing.xs,
          ),
          child: child,
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(_GlassHeaderDelegate old) =>
      old.child != child || old.height != height || old.topInset != topInset;
}
