import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'frosted_chrome.dart';

/// Pinned screen header: transparent at rest, frosted once content scrolls
/// beneath it. At scroll offset 0 the backdrop blur isn't composited at all.
class ChromeSliverHeader extends StatelessWidget {
  const ChromeSliverHeader({super.key, required this.child, this.height = 60});

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _HeaderDelegate(
        child: child,
        height: height,
        topInset: MediaQuery.paddingOf(context).top,
      ),
    );
  }
}

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  _HeaderDelegate({
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
        if (scrolled)
          const FrostedChrome(
            sigma: 20,
            fill: Color(0xC708090C), // canvas @ 78 %
            rim: false,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.hairline)),
              ),
            ),
          ),
        Padding(
          padding: EdgeInsets.only(
            top: topInset,
            left: AppSpacing.gutter,
            right: AppSpacing.gutter,
          ),
          child: child,
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(_HeaderDelegate old) =>
      old.child != child || old.height != height || old.topInset != topInset;
}

/// Standard tab header content: mono eyebrow over a title, optional trailing.
class ScreenTitle extends StatelessWidget {
  const ScreenTitle({
    super.key,
    required this.eyebrow,
    required this.title,
    this.trailing,
  });

  final String eyebrow;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(eyebrow.toUpperCase(), style: AppTypography.overline),
              const SizedBox(height: 3),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.title.copyWith(fontSize: 19),
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}
