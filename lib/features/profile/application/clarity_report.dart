import 'package:flutter/foundation.dart';

import '../../../core/utils/formatters.dart';
import '../../../data/models/regret_checkin_model.dart';
import '../../cart/application/budget_controller.dart';
import 'regret_controller.dart';

/// One month of decisions, written so it can be shared.
@immutable
class ClarityReport {
  const ClarityReport({
    required this.monthLabel,
    required this.impulseBuysAvoided,
    required this.moneyKept,
    required this.regretRate,
    required this.bestDecisions,
    required this.shareText,
  });

  final String monthLabel;
  final int impulseBuysAvoided;
  final double moneyKept;
  final int regretRate;
  final List<String> bestDecisions;
  final String shareText;
}

abstract final class ClarityReportBuilder {
  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static ClarityReport build({
    required BudgetState budget,
    required RegretStats stats,
    required List<RegretCheckin> checkins,
    required DateTime now,
  }) {
    final month = _months[now.month - 1];
    final best = [
      for (final checkin in checkins)
        if (checkin.isWorthIt) checkin.productTitle,
    ];
    final shown = best.take(3).toList();
    final bestLine = shown.isEmpty
        ? 'Best decisions will show up after a check-in you were glad about.'
        : 'Best decisions: ${shown.join(', ')}.';
    final share = [
      'Clarion clarity · $month',
      '${budget.impulseBuysAvoided} impulse buys avoided.',
      '${Fmt.inr(budget.savedViaCooldown)} kept by cooling off.',
      'Personal regret rate ${stats.regretRate}%.',
      bestLine,
    ].join('\n');
    return ClarityReport(
      monthLabel: month,
      impulseBuysAvoided: budget.impulseBuysAvoided,
      moneyKept: budget.savedViaCooldown,
      regretRate: stats.regretRate,
      bestDecisions: shown,
      shareText: share,
    );
  }
}
