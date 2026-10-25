import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../theme/app_spacing.dart';
import 'chrome_header.dart';
import 'obsidian_canvas.dart';
import 'round_icon_button.dart';

/// The route every screen pushed above the tabs uses: a short fade and rise.
Route<T> fadeRiseRoute<T>(Widget page) => PageRouteBuilder<T>(
  transitionDuration: AppMotion.slow,
  reverseTransitionDuration: AppMotion.medium,
  pageBuilder: (_, _, _) => page,
  transitionsBuilder: (_, animation, _, child) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: AppMotion.standard,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.03),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  },
);

/// A screen pushed above the tabs (Browse, Orders): the canvas, a pinned
/// frosted header with a back button, and scrolling content.
class SubPage extends StatelessWidget {
  const SubPage({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.slivers,
    this.trailing,
  });

  final String eyebrow;
  final String title;
  final Widget? trailing;
  final List<Widget> slivers;

  @override
  Widget build(BuildContext context) {
    return ObsidianCanvas(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            ChromeSliverHeader(
              child: Row(
                children: [
                  RoundIconButton(
                    icon: Icons.arrow_back_rounded,
                    semanticLabel: context.l10n.back,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ScreenTitle(
                      eyebrow: eyebrow,
                      title: title,
                      trailing: trailing,
                    ),
                  ),
                ],
              ),
            ),
            ...slivers,
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.paddingOf(context).bottom + AppSpacing.xxl,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
