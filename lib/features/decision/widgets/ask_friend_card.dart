import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/clarion_button.dart';
import '../../../core/widgets/tactile_card.dart';
import '../../../data/models/product_model.dart';
import '../application/friend_ballot.dart';

/// Share a comparison. A friend votes by opening the link, with no feed.
class AskFriendCard extends ConsumerWidget {
  const AskFriendCard({super.key, required this.left, required this.right});

  final Product left;
  final Product right;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ballotId = FriendBallots.idFor(left.id, right.id);
    final tally = ref.watch(friendBallotProvider);
    final votes = [
      for (final vote in tally)
        if (vote.ballotId == ballotId) vote,
    ];
    final leftVotes = votes.where((vote) => vote.choiceId == left.id).length;
    final rightVotes = votes.where((vote) => vote.choiceId == right.id).length;
    return TactileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ASK A FRIEND', style: AppTypography.overline),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Send the comparison. They vote by opening the link.',
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          if (votes.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${left.title}: $leftVotes · ${right.title}: $rightVotes',
              style: AppTypography.bodySmall,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          ClarionButton(
            label: 'Share comparison',
            tone: ButtonTone.secondary,
            onPressed: () => _share(context),
          ),
          const SizedBox(height: AppSpacing.sm),
          ClarionButton(
            label: 'I pick ${left.brand}',
            tone: ButtonTone.secondary,
            onPressed: () => _vote(ref, left.id, 'me'),
          ),
          const SizedBox(height: AppSpacing.sm),
          ClarionButton(
            label: 'I pick ${right.brand}',
            tone: ButtonTone.secondary,
            onPressed: () => _vote(ref, right.id, 'me'),
          ),
        ],
      ),
    );
  }

  void _vote(WidgetRef ref, String choiceId, String voter) {
    ref
        .read(friendBallotProvider.notifier)
        .cast(
          ballotId: FriendBallots.idFor(left.id, right.id),
          choiceId: choiceId,
          leftId: left.id,
          rightId: right.id,
          voter: voter,
        );
  }

  void _share(BuildContext context) {
    final compare = FriendBallots.linkFor(left.id, right.id);
    final forLeft = FriendBallots.replyFor(
      leftId: left.id,
      rightId: right.id,
      choiceId: left.id,
    );
    final forRight = FriendBallots.replyFor(
      leftId: left.id,
      rightId: right.id,
      choiceId: right.id,
    );
    final text = [
      'Which would you pick?',
      '${left.brand} ${left.title} or ${right.brand} ${right.title}',
      compare.uri.toString(),
      'Or send a vote back:',
      '${left.title}: ${forLeft.uri}',
      '${right.title}: ${forRight.uri}',
    ].join('\n');
    final box = context.findRenderObject() as RenderBox?;
    SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: 'A Clarion comparison',
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }
}
