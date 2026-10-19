/// Formatting helpers for Indian-locale currency and durations.
///
/// Implemented locally (rather than pulling in `intl`) because the app only
/// needs whole-rupee amounts with Indian digit grouping: ₹1,23,456.
abstract final class Fmt {
  /// `2299` → `₹2,299`, `123456` → `₹1,23,456`, `-400` → `-₹400`.
  static String inr(num amount, {bool signed = false}) {
    final value = amount.round();
    final negative = value < 0;
    final grouped = _indianGrouping(value.abs());
    final sign = negative ? '-' : (signed && value > 0 ? '+' : '');
    return '$sign₹$grouped';
  }

  /// Compact form for tight spaces: `3200` → `₹3.2k`, `150000` → `₹1.5L`.
  static String inrCompact(num amount) {
    final v = amount.abs();
    final sign = amount < 0 ? '-' : '';
    if (v >= 100000) return '$sign₹${_trim(v / 100000)}L';
    if (v >= 1000) return '$sign₹${_trim(v / 1000)}k';
    return '$sign₹${v.round()}';
  }

  static String percent(num value, {int decimals = 0}) =>
      '${value.toStringAsFixed(decimals)}%';

  /// `Duration(hours: 23, minutes: 4)` → `23h 04m`.
  static String countdown(Duration d) {
    if (d.isNegative || d == Duration.zero) return 'Ready';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '${h}h ${m}m' : '${d.inMinutes}m';
  }

  static String _trim(num v) {
    final s = v.toStringAsFixed(1);
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }

  static String _indianGrouping(int n) {
    final digits = n.toString();
    if (digits.length <= 3) return digits;
    final last3 = digits.substring(digits.length - 3);
    var rest = digits.substring(0, digits.length - 3);
    final parts = <String>[];
    while (rest.length > 2) {
      parts.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) parts.insert(0, rest);
    return '${parts.join(',')},$last3';
  }
}
