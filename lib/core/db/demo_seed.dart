/// Starting data for a brand-new install.
///
/// The same values are the in-memory defaults when no database is available
/// (widget tests, web), so both paths show the same demo scenario:
/// ceiling ₹5,000 · settled ₹2,000 · cart ₹1,200 → "₹3,200 / ₹5,000".
abstract final class DemoSeed {
  /// (product id, quantity, priority name) in cart order. Priority names
  /// match `IntentPriority.name`: essential | important | niceToHave.
  static const List<(String, int, String)> cartLines = [
    ('lamp_halo', 1, 'essential'),
    ('org_kova', 1, 'niceToHave'),
  ];

  static const double monthlyLimit = 5000.0;
  static const int impulseBuysAvoided = 11;
  static const double savedViaCooldown = 6240.0;

  /// (category, amount) settled this month.
  static const List<(String, double)> spend = [
    ('Electronics', 1200.0),
    ('Books', 450.0),
    ('Essentials', 350.0),
  ];

  /// Settled totals for previous months, oldest first.
  static const List<double> monthlyHistory = [
    4620.0,
    5340.0,
    4180.0,
    3950.0,
    4410.0,
  ];
}
