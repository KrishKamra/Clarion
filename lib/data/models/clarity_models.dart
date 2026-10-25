import 'package:flutter/foundation.dart';

/// A named amount the user is saving toward, such as a laptop.
@immutable
class SavingsGoal {
  const SavingsGoal({
    required this.id,
    required this.name,
    required this.target,
    this.saved = 0,
    required this.createdAt,
  });

  final String id;
  final String name;
  final double target;
  final double saved;
  final DateTime createdAt;

  double get remaining => (target - saved).clamp(0, target);

  SavingsGoal copyWith({double? saved}) => SavingsGoal(
    id: id,
    name: name,
    target: target,
    saved: saved ?? this.saved,
    createdAt: createdAt,
  );
}

/// A monthly ceiling for one catalogue category, inside the overall envelope.
@immutable
class CategoryBudget {
  const CategoryBudget({required this.category, required this.monthlyLimit});

  final String category;
  final double monthlyLimit;
}

/// A signal the impulse-risk score reads: a cart add or a product view.
@immutable
class ImpulseEvent {
  const ImpulseEvent({
    required this.kind,
    this.productId,
    required this.amount,
    required this.at,
  });

  /// `add` or `browse`.
  final String kind;
  final String? productId;
  final double amount;
  final DateTime at;

  bool get isAdd => kind == 'add';
  bool get isBrowse => kind == 'browse';
}

/// One friend's vote on a shared comparison.
@immutable
class FriendVote {
  const FriendVote({
    required this.ballotId,
    required this.choiceId,
    required this.voter,
    required this.leftId,
    required this.rightId,
    required this.at,
  });

  final String ballotId;
  final String choiceId;
  final String voter;
  final String leftId;
  final String rightId;
  final DateTime at;
}
