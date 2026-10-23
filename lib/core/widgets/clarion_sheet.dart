import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'frosted_chrome.dart';

/// Presents [builder] in a frosted modal sheet.
Future<T?> showClarionSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  String? eyebrow,
  String? title,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.isDark
        ? const Color(0x9907080B)
        : const Color(0x4D0F172A),
    builder: (context) =>
        ClarionSheet(eyebrow: eyebrow, title: title, child: builder(context)),
  );
}

/// Sheet chrome: grab handle, optional eyebrow and title, safe-area padding.
class ClarionSheet extends StatelessWidget {
  const ClarionSheet({
    super.key,
    required this.child,
    this.eyebrow,
    this.title,
  });

  final Widget child;
  final String? eyebrow;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final bottom =
        MediaQuery.paddingOf(context).bottom +
        MediaQuery.viewInsetsOf(context).bottom;

    return FrostedChrome(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadii.xl),
      ),
      sigma: 28,
      fill: AppColors.surfaceHigh.withValues(alpha: 0.9),
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
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.rimBright,
                  borderRadius: AppRadii.pillAll,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (eyebrow != null) ...[
              Text(eyebrow!.toUpperCase(), style: AppTypography.overline),
              const SizedBox(height: AppSpacing.xs),
            ],
            if (title != null) ...[
              Text(title!, style: AppTypography.headline),
              const SizedBox(height: AppSpacing.lg),
            ],
            Flexible(child: SingleChildScrollView(child: child)),
          ],
        ),
      ),
    );
  }
}
