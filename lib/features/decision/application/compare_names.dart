import '../../../data/models/product_model.dart';

/// The shortest names that tell two compared products apart, for buttons
/// and verdicts where the full title won't fit.
///
/// Different brands: the brands. Same brand: the model, up to and
/// including the first word where the titles differ ("Q30 Pro" against
/// "Q30 Core"), never fewer than two words.
(String, String) distinctNames(Product a, Product b) {
  if (a.brand.toLowerCase() != b.brand.toLowerCase()) return (a.brand, b.brand);
  final aw = a.title.split(' ');
  final bw = b.title.split(' ');
  var i = 0;
  while (i < aw.length && i < bw.length && aw[i] == bw[i]) {
    i++;
  }
  String cut(List<String> words) =>
      words.take((i + 1).clamp(2, words.length)).join(' ');
  return (cut(aw), cut(bw));
}
