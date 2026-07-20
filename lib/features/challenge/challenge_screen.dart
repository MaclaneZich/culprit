import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../core/copy/copy.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../data/db/database.dart';
import '../../domain/enums.dart';
import '../../providers.dart';
import 'challenge_detail_screen.dart';
import 'new_challenge_sheet.dart';

/// Challenge Lab: the module that turns a candidate into an answer.
class ChallengeScreen extends ConsumerWidget {
  const ChallengeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tones = context.tones;
    final challenges = ref.watch(challengesProvider).value ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenges'),
        actions: [
          IconButton(
            onPressed: () => showNewChallengeSheet(context),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: challenges.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(Space.x8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/illustrations/challenge_complete.svg',
                      width: 160,
                    ),
                    const SizedBox(height: Space.x5),
                    Text(
                      Copy.challengeIntro,
                      textAlign: TextAlign.center,
                      style: TypeRamp.body.copyWith(color: tones.inkSecondary),
                    ),
                    const SizedBox(height: Space.x5),
                    FilledButton(
                      onPressed: () => showNewChallengeSheet(context),
                      child: const Text('Start a challenge'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(Space.x4),
              itemCount: challenges.length,
              itemBuilder: (context, i) =>
                  _ChallengeCard(challenge: challenges[i]),
            ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.challenge});

  final Challenge challenge;

  @override
  Widget build(BuildContext context) {
    final tones = context.tones;
    final outcome = challenge.outcome;

    return Padding(
      padding: const EdgeInsets.only(bottom: Space.x3),
      child: Card(
        child: InkWell(
          borderRadius: Corner.lgAll,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ChallengeDetailScreen(challengeId: challenge.id),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(Space.x4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(challenge.title,
                          style: TypeRamp.title.copyWith(color: tones.ink)),
                      const SizedBox(height: 2),
                      Text(
                        outcome != null
                            ? outcome.label
                            : '${challenge.status.label} · started '
                                '${DateFormat('MMM d').format(challenge.startDate)}'
                                '${challenge.blinded ? ' · blinded' : ''}',
                        style: TypeRamp.caption.copyWith(
                          color: switch (outcome) {
                            ChallengeOutcome.reproduced => tones.accent,
                            ChallengeOutcome.notReproduced => tones.moss,
                            ChallengeOutcome.inconclusive => tones.slate,
                            null => tones.inkSecondary,
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: tones.inkFaint),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
