import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/sub_page.dart';
import '../../../core/widgets/tactile_card.dart';
import '../../../data/catalog.dart';
import '../application/orders_controller.dart';
import '../application/warranty_vault.dart';
import 'order_detail_screen.dart';

/// Receipts, return windows and warranty dates in one place.
class WarrantyVaultScreen extends ConsumerWidget {
  const WarrantyVaultScreen({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context).push(fadeRiseRoute(const WarrantyVaultScreen()));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = WarrantyVault.entries(
      orders: ref.watch(ordersProvider),
      catalog: ref.watch(catalogProvider).products,
    );
    final now = DateTime.now();
    return SubPage(
      eyebrow: 'Kept purchases',
      title: 'Receipts & warranty',
      slivers: [
        SliverPadding(
          padding: AppSpacing.screenPadding.copyWith(top: AppSpacing.lg),
          sliver: SliverList.list(
            children: [
              if (entries.isEmpty)
                Text(
                  'Orders you keep will list their return window and warranty here.',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                )
              else
                for (final entry in entries) ...[
                  TactileCard(
                    onTap: () =>
                        OrderDetailScreen.open(context, entry.order.id),
                    semanticLabel: entry.line.title,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.line.title, style: AppTypography.title),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _returnLine(entry, now),
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _warrantyLine(entry),
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
            ],
          ),
        ),
      ],
    );
  }

  static String _returnLine(VaultEntry entry, DateTime now) {
    final closes = entry.returnCloses;
    if (closes == null) {
      return 'Return window opens after pickup, then stays open 7 days.';
    }
    final days = closes.difference(now).inDays;
    if (days < 0) return 'Return window closed ${Fmt.shortDate(closes)}.';
    if (days <= 3) {
      return 'Return window closes in $days days. Still happy?';
    }
    return 'Return window closes ${Fmt.shortDate(closes)}.';
  }

  static String _warrantyLine(VaultEntry entry) {
    final expires = entry.warrantyExpires;
    if (expires == null) return 'Warranty: lifetime, or not stated.';
    return 'Warranty expires ${Fmt.shortDate(expires)}.';
  }
}
