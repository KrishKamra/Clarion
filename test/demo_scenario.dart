import 'package:clarion/core/db/budget_repository.dart';
import 'package:clarion/core/db/db_providers.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

/// The scenario these tests were written against: cart ₹1,200 · settled
/// ₹2,000 · ceiling ₹5,000, with the Loom keyboard cooling off. New accounts
/// now start empty, so tests that need this state supply it explicitly.
List<Override> demoScenario() => [
  initialCartProvider.overrideWithValue([
    (productId: 'lamp_halo', quantity: 1, priority: 'essential'),
    (productId: 'org_kova', quantity: 1, priority: 'niceToHave'),
  ]),
  initialBudgetProvider.overrideWithValue(
    const StoredBudget(
      monthlyLimit: 5000,
      impulseBuysAvoided: 11,
      savedViaCooldown: 6240,
      spend: [
        (label: 'Electronics', amount: 1200),
        (label: 'Books', amount: 450),
        (label: 'Essentials', amount: 350),
      ],
    ),
  ),
  initialCooldownsProvider.overrideWithValue({
    'kb_loom': DateTime.now().add(const Duration(hours: 17, minutes: 42)),
  }),
];
