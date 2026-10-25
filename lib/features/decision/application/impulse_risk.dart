import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/db_providers.dart';
import '../../../data/catalog.dart';
import '../../../data/models/clarity_models.dart';
import '../../cart/application/budget_controller.dart';

/// How long to cool off, given how the purchase is being made.
@immutable
class ImpulseAssessment {
  const ImpulseAssessment({
    required this.score,
    required this.hold,
    required this.reasons,
  });

  /// 0–100. Higher means the purchase looks more impulsive.
  final int score;
  final Duration hold;
  final List<String> reasons;

  bool get isBaseline => hold == ImpulseRiskEngine.baseline;

  String get holdLabel {
    final hours = hold.inHours;
    return hours == 24 ? '24h Cooling Off' : '${hours}h Cooling Off';
  }

  String get summary {
    if (reasons.isEmpty) return 'Calm pace. A 24-hour hold.';
    return reasons.join(' · ');
  }
}

/// Lengthens the cooling-off hold for rapid adds, late-night browsing and
/// large purchases, and shortens it when the pace is calm and the amount
/// is small. With no signals, the hold stays 24 hours.
abstract final class ImpulseRiskEngine {
  static const Duration baseline = Duration(hours: 24);
  static const Duration shortened = Duration(hours: 8);
  static const Duration extended = Duration(hours: 48);
  static const Duration longest = Duration(hours: 72);

  static bool isLateNight(DateTime at) => at.hour >= 23 || at.hour < 5;

  static ImpulseAssessment assess({
    required List<ImpulseEvent> events,
    required double price,
    required double monthlyLimit,
    required DateTime now,
  }) {
    final recentAdds = events.where(
      (event) =>
          event.isAdd &&
          now.difference(event.at) <= const Duration(minutes: 10),
    );
    final lateBrowsing = events.where(
      (event) =>
          event.isBrowse &&
          isLateNight(event.at) &&
          now.difference(event.at) <= const Duration(hours: 12),
    );
    final large = monthlyLimit > 0 && price >= monthlyLimit * 0.5;
    final small = monthlyLimit > 0 && price <= monthlyLimit * 0.08;
    final reasons = <String>[];
    var score = 20;

    if (recentAdds.length >= 2) {
      score += 35;
      reasons.add('Several adds in a few minutes');
    }
    if (lateBrowsing.length >= 2) {
      score += 25;
      reasons.add('Late-night browsing');
    }
    if (large) {
      score += 30;
      reasons.add('Large against the monthly budget');
    }

    score = score.clamp(0, 100);
    // A small purchase with no hurry signals keeps a short hold. The base
    // score is 20, so this is decided from the signals, not from that floor.
    if (reasons.isEmpty && small) {
      return const ImpulseAssessment(
        score: 10,
        hold: shortened,
        reasons: ['Small, unhurried purchase'],
      );
    }
    if (score >= 70) {
      return ImpulseAssessment(score: score, hold: longest, reasons: reasons);
    }
    if (score >= 45) {
      return ImpulseAssessment(score: score, hold: extended, reasons: reasons);
    }
    return ImpulseAssessment(score: score, hold: baseline, reasons: reasons);
  }
}

class ImpulseController extends Notifier<List<ImpulseEvent>> {
  @override
  List<ImpulseEvent> build() => ref.watch(initialImpulseEventsProvider);

  void noteAdd(String productId, double amount) => _add(
    ImpulseEvent(
      kind: 'add',
      productId: productId,
      amount: amount,
      at: DateTime.now(),
    ),
  );

  void noteBrowse(String productId) => _add(
    ImpulseEvent(
      kind: 'browse',
      productId: productId,
      amount: 0,
      at: DateTime.now(),
    ),
  );

  void _add(ImpulseEvent event) {
    final next = [...state, event];
    state = next.length > 80 ? next.sublist(next.length - 80) : next;
    ref.read(clarityRepositoryProvider)?.insertImpulse(event).catchError((
      Object error,
      StackTrace stack,
    ) {
      developer.log(
        'Could not save impulse signal',
        error: error,
        stackTrace: stack,
      );
    });
  }
}

final impulseProvider = NotifierProvider<ImpulseController, List<ImpulseEvent>>(
  ImpulseController.new,
);

/// The hold length for one product, from the signals recorded so far.
final impulseAssessmentProvider = Provider.family<ImpulseAssessment, String>((
  ref,
  productId,
) {
  final product = ref.watch(catalogProvider).byId(productId);
  final events = ref.watch(impulseProvider);
  final limit = ref.watch(budgetProvider).monthlyLimit;
  return ImpulseRiskEngine.assess(
    events: events,
    price: product.price,
    monthlyLimit: limit,
    now: DateTime.now(),
  );
});
