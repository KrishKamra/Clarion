/// Starting data for a brand-new account.
///
/// Every account starts clean: an empty cart, no cooling-off holds, nothing
/// spent and no mindful stats. The only default is the monthly ceiling, which
/// the user can change from the Profile tab. The same values are the in-memory
/// defaults when no database is available (widget tests, web).
abstract final class DemoSeed {
  /// (product id, quantity, priority name) in cart order. Priority names
  /// match `IntentPriority.name`: essential | important | niceToHave.
  static const List<(String, int, String)> cartLines = [];

  static const double monthlyLimit = 5000.0;
  static const int impulseBuysAvoided = 0;
  static const double savedViaCooldown = 0.0;

  /// (category, amount) settled this month.
  static const List<(String, double)> spend = [];

  /// Settled totals for previous months, oldest first. Zeros keep the
  /// six-month chart laid out until there is real history.
  static const List<double> monthlyHistory = [0, 0, 0, 0, 0];
}
