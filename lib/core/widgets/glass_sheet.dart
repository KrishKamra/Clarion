import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_glass.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Presents [child] in a true-glass modal bottom sheet.
Future<T?> showGlassSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  String? title,
  bool isDismissible = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: isDismissible,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (context) => GlassSheet(title: title, child: builder(context)),
  );
}

/// Frosted sheet chrome: grab handle, optional title, safe-area padding.
class GlassSheet extends StatelessWidget {
  const GlassSheet({super.key, required this.child, this.title});

  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.vertical(top: Radius.circular(AppRadii.xl));
    final bottom =
        MediaQuery.paddingOf(context).bottom +
        MediaQuery.viewInsetsOf(context).bottom;

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: AppGlass.blur(28),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            color: AppColors.surface.withValues(alpha: 0.82),
            border: const Border(top: BorderSide(color: AppColors.glassBorder)),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              AppSpacing.md,
              AppSpacing.gutter,
              AppSpacing.xl + bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: AppRadii.pillAll,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (title != null) ...[
                  Text(title!, style: AppTypography.title),
                  const SizedBox(height: AppSpacing.lg),
                ],
                Flexible(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Round frosted icon button used in headers.
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.showDot = false,
    this.size = 42,
    this.blur = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final bool showDot;
  final double size;

  /// Enable a true backdrop blur when floating over imagery.
  final bool blur;

  @override
  Widget build(BuildContext context) {
    Widget body = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: blur
            ? AppColors.backgroundDeep.withValues(alpha: 0.35)
            : Colors.white.withValues(alpha: 0.06),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(icon, size: 20, color: AppColors.textPrimary),
          if (showDot)
            Positioned(
              top: size * 0.24,
              right: size * 0.26,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
    if (blur) {
      body = ClipOval(
        child: BackdropFilter(filter: AppGlass.blur(12), child: body),
      );
    }
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints.tight(Size.square(size)),
      style: IconButton.styleFrom(shape: const CircleBorder()),
      icon: body,
    );
  }
}
