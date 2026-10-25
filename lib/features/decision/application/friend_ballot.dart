import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/db_providers.dart';
import '../../../core/links/deep_links.dart';
import '../../../data/models/clarity_models.dart';

/// Tally of votes on one shared comparison.
@immutable
class BallotTally {
  const BallotTally({required this.ballotId, required this.votes});

  final String ballotId;
  final List<FriendVote> votes;

  int countFor(String productId) =>
      votes.where((vote) => vote.choiceId == productId).length;
}

abstract final class FriendBallots {
  /// Stable id for a pair, so votes on the same comparison land together.
  static String idFor(String leftId, String rightId) {
    final pair = [leftId, rightId]..sort();
    return pair.join('~');
  }

  static CompareLink linkFor(String leftId, String rightId) =>
      CompareLink(leftId, rightId, ballotId: idFor(leftId, rightId));

  static VoteLink replyFor({
    required String leftId,
    required String rightId,
    required String choiceId,
  }) => VoteLink(
    ballotId: idFor(leftId, rightId),
    choiceId: choiceId,
    leftId: leftId,
    rightId: rightId,
  );
}

class FriendBallotController extends Notifier<List<FriendVote>> {
  @override
  List<FriendVote> build() => ref.watch(initialFriendVotesProvider);

  void cast({
    required String ballotId,
    required String choiceId,
    required String leftId,
    required String rightId,
    String voter = 'friend',
  }) {
    final vote = FriendVote(
      ballotId: ballotId,
      choiceId: choiceId,
      voter: voter,
      leftId: leftId,
      rightId: rightId,
      at: DateTime.now(),
    );
    state = [
      for (final existing in state)
        if (existing.ballotId != ballotId || existing.voter != voter) existing,
      vote,
    ];
    ref.read(clarityRepositoryProvider)?.upsertVote(vote).catchError((
      Object error,
      StackTrace stack,
    ) {
      developer.log(
        'Could not save friend vote',
        error: error,
        stackTrace: stack,
      );
    });
  }

  BallotTally tally(String ballotId) => BallotTally(
    ballotId: ballotId,
    votes: [
      for (final vote in state)
        if (vote.ballotId == ballotId) vote,
    ],
  );
}

final friendBallotProvider =
    NotifierProvider<FriendBallotController, List<FriendVote>>(
      FriendBallotController.new,
    );
