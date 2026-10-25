import '../../../data/models/product_model.dart';

/// In-store barcodes for the mock catalogue. A scan resolves to a product
/// so the fit score and price history can be shown on the shop floor.
abstract final class BarcodeCatalog {
  static const codes = {
    '8901234500018': 'bp_atlas',
    '8901234500025': 'bp_metro',
    '8901234500032': 'hp_pro',
    '8901234500049': 'hp_core',
    '8901234500056': 'sling_field',
    '8901234500063': 'lamp_halo',
    '8901234500070': 'org_kova',
    '8901234500087': 'kb_loom',
    '8901234500094': 'mouse_glide',
    '8901234500100': 'mouse_ergo',
    '8901234500117': 'bottle_thermo',
    '8901234500124': 'notebook_dot',
    '8901234500131': 'pb_volt',
    '8901234500148': 'stand_lift',
    '8901234500155': 'earb_pulse',
    '8901234500162': 'cam_clear',
    '8901234500179': 'cushion_lumbar',
  };

  static Product? lookup(String raw, List<Product> products) {
    final code = raw.replaceAll(RegExp(r'\s+'), '');
    final id = codes[code];
    if (id == null) return null;
    for (final product in products) {
      if (product.id == id) return product;
    }
    return null;
  }

  static String? codeFor(String productId) {
    for (final entry in codes.entries) {
      if (entry.value == productId) return entry.key;
    }
    return null;
  }
}
