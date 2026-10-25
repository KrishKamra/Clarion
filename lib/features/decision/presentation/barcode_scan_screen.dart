import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/clarion_button.dart';
import '../../../core/widgets/fit_score_gauge.dart';
import '../../../core/widgets/sub_page.dart';
import '../../../core/widgets/tactile_card.dart';
import '../../../data/catalog.dart';
import '../../../data/models/product_model.dart';
import '../../home/application/intent_controller.dart';
import '../application/barcode_catalog.dart';
import '../widgets/price_band_card.dart';
import 'product_decision_screen.dart';

/// In-store scan: a barcode becomes the fit score, the price history and
/// the nearest pickup, without leaving the aisle.
class BarcodeScanScreen extends ConsumerStatefulWidget {
  const BarcodeScanScreen({super.key, this.initialCode});

  final String? initialCode;

  static Future<void> open(BuildContext context, {String? code}) =>
      Navigator.of(context)
          .push(fadeRiseRoute(BarcodeScanScreen(initialCode: code)));

  @override
  ConsumerState<BarcodeScanScreen> createState() => _BarcodeScanScreenState();
}

class _BarcodeScanScreenState extends ConsumerState<BarcodeScanScreen> {
  late final TextEditingController _code = TextEditingController(
    text: widget.initialCode ?? '',
  );
  bool _camera = false;
  String? _miss;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _resolve(String raw) {
    final product = BarcodeCatalog.lookup(
      raw,
      ref.read(catalogProvider).products,
    );
    setState(() {
      _code.text = raw;
      _miss = product == null ? raw : null;
      _camera = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = BarcodeCatalog.lookup(
      _code.text,
      ref.watch(catalogProvider).products,
    );
    return SubPage(
      eyebrow: 'In store',
      title: 'Scan a barcode',
      slivers: [
        SliverPadding(
          padding: AppSpacing.screenPadding.copyWith(top: AppSpacing.lg),
          sliver: SliverList.list(
            children: [
              TextField(
                controller: _code,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Barcode',
                  hintText: 'Type or scan',
                ),
                onSubmitted: _resolve,
              ),
              const SizedBox(height: AppSpacing.md),
              ClarionButton(
                label: 'Look up',
                tone: ButtonTone.secondary,
                onPressed: () => _resolve(_code.text),
              ),
              const SizedBox(height: AppSpacing.sm),
              ClarionButton(
                label: _camera ? 'Close camera' : 'Use camera',
                onPressed: () => setState(() => _camera = !_camera),
              ),
              if (_camera) ...[
                const SizedBox(height: AppSpacing.md),
                ClipRRect(
                  borderRadius: AppRadii.lgAll,
                  child: SizedBox(
                    height: 220,
                    child: MobileScanner(
                      onDetect: (capture) {
                        final code = capture.barcodes
                            .map((barcode) => barcode.rawValue)
                            .whereType<String>()
                            .firstOrNull;
                        if (code != null) _resolve(code);
                      },
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              if (_miss != null)
                Text(
                  'No product for $_miss.',
                  style: AppTypography.body.copyWith(color: AppColors.amber),
                )
              else if (product != null)
                _ScanResult(product: product),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScanResult extends ConsumerWidget {
  const _ScanResult({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fit = ref.watch(fitProvider(product.id)).score;
    final pickup = product.pickup;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TactileCard(
          material: CardMaterial.floating,
          onTap: () => ProductDecisionScreen.open(context, product.id),
          semanticLabel: product.title,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  FitScoreGauge(score: fit, size: 64),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.title, style: AppTypography.title),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${Fmt.inr(product.price)} · $fit% fit',
                          style: AppTypography.body,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (pickup != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Pickup in ${pickup.distanceLabel}, ${pickup.area}.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        PriceBandCard(product: product),
      ],
    );
  }
}
