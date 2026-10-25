import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/links/deep_links.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/product_model.dart';
import '../../../l10n/l10n.dart';

/// Opens the system share sheet with a short, honest summary of [product]
/// (price, its position against the 30-day average, the user's fit) and a
/// link that opens it in Clarion.
Future<void> shareProduct(
  BuildContext context,
  Product product, {
  required int fit,
}) {
  final l10n = context.l10n;
  final dip = (product.discountVsAverage * 100).round();
  final text = [
    l10n.shareProductText(
      '${product.brand} ${product.title}',
      Fmt.inr(product.price),
      fit,
    ),
    if (dip >= 1) l10n.shareBelowAverage(dip),
    ProductLink(product.id).uri.toString(),
  ].join('\n');
  final box = context.findRenderObject() as RenderBox?;
  return SharePlus.instance.share(
    ShareParams(
      text: text,
      subject: product.title,
      // iPad anchors the share popover to the button.
      sharePositionOrigin: box == null
          ? null
          : box.localToGlobal(Offset.zero) & box.size,
    ),
  );
}
