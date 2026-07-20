import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../analysis/challenge_evaluator.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../data/db/database.dart';
import '../../domain/enums.dart';
import '../../providers.dart';

/// Day-by-day view of a running challenge: log adherence and worst severity
/// per day, then read the result out as reproduced / did not reproduce /
/// inconclusive — with the rule spelled out.
class ChallengeDetailScreen extends ConsumerWidget {
  const ChallengeDetailScreen({super.key, required this.challengeId});

  final int challengeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tones = context.tones;
    final challenges = ref.watch(challengesProvider).value ?? const [];
    final challenge =
        challenges.where((c) => c.id == challengeId).firstOrNull;
    final days = ref.watch(challengeDaysProvider(challengeId)).value ?? const [];

    if (challenge == null) {
      return const Scaffold(body: SizedBox.expand());
    }

    final readout = const ChallengeEvaluator().evaluate([
      for (final day in days)
        ChallengeDayLog(
          kind: day.kind,
          adhered: day.adhered,
          maxSeverity: day.maxSeverity,
        ),
    ]);
    final loggedCount =
        days.where((d) => d.adhered != null && d.maxSeverity != null).length;
    final finished = challenge.status == ChallengeStatus.completed;

    return Scaffold(
      appBar: AppBar(
        title: Text(challenge.title),
        actions: [
          if (!finished)
            IconButton(
              tooltip: 'Abandon',
              onPressed: () => _abandon(context, ref, challenge),
              icon: const Icon(Icons.close),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.x4),
        children: [
          if (finished && challenge.outcome != null)
            _ResultCard(challenge: challenge, readout: readout)
          else ...[
            Text(
              '$loggedCount of ${days.length} days logged'
              '${challenge.blinded ? ' · blinded run' : ''}',
              style: TypeRamp.bodySmall.copyWith(color: tones.inkSecondary),
            ),
            const SizedBox(height: Space.x3),
          ],
          for (final day in days)
            _DayTile(
              day: day,
              locked: finished,
              onLog: () => _logDay(context, ref, day),
            ),
          const SizedBox(height: Space.x5),
          if (!finished)
            FilledButton(
              onPressed: loggedCount == 0
                  ? null
                  : () => _finish(context, ref, challenge, readout),
              child: const Text('Finish & read result'),
            ),
          const SizedBox(height: Space.x6),
        ],
      ),
    );
  }

  Future<void> _logDay(
      BuildContext context, WidgetRef ref, ChallengeDay day) async {
    final result = await showModalBottomSheet<(bool, int)>(
      context: context,
      builder: (_) => _DayLogSheet(day: day),
    );
    if (result == null) return;
    await ref.read(databaseProvider).updateChallengeDay(
          day.id,
          ChallengeDaysCompanion(
            adhered: Value(result.$1),
            maxSeverity: Value(result.$2),
          ),
        );
  }

  Future<void> _finish(BuildContext context, WidgetRef ref,
      Challenge challenge, ChallengeReadout readout) async {
    await ref.read(databaseProvider).updateChallenge(
          challenge.id,
          ChallengesCompanion(
            status: const Value(ChallengeStatus.completed),
            outcome: Value(readout.outcome),
            resultNote: Value(readout.explanation),
          ),
        );
  }

  Future<void> _abandon(
      BuildContext context, WidgetRef ref, Challenge challenge) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abandon this challenge?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep going')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Abandon')),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(databaseProvider).updateChallenge(
            challenge.id,
            const ChallengesCompanion(
                status: Value(ChallengeStatus.abandoned)),
          );
      if (context.mounted) Navigator.of(context).pop();
    }
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.challenge, required this.readout});

  final Challenge challenge;
  final ChallengeReadout readout;

  @override
  Widget build(BuildContext context) {
    final tones = context.tones;
    final outcome = challenge.outcome!;
    final color = switch (outcome) {
      ChallengeOutcome.reproduced => tones.accent,
      ChallengeOutcome.notReproduced => tones.moss,
      ChallengeOutcome.inconclusive => tones.slate,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: Space.x5),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: Corner.lgAll,
          side: BorderSide(color: color, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Space.x5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(outcome.label,
                  style: TypeRamp.headline.copyWith(color: color)),
              const SizedBox(height: Space.x3),
              Text(
                challenge.resultNote ?? readout.explanation,
                style: TypeRamp.body.copyWith(color: tones.ink),
              ),
              const SizedBox(height: Space.x3),
              Text(
                'On-days: ${(readout.onSymptomaticRate * 100).round()}% '
                'symptomatic (${readout.onDaysLogged} logged) · '
                'off/washout: ${(readout.offSymptomaticRate * 100).round()}% '
                '(${readout.offDaysLogged} logged).',
                style: TypeRamp.caption.copyWith(color: tones.inkSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({required this.day, required this.locked, required this.onLog});

  final ChallengeDay day;
  final bool locked;
  final VoidCallback onLog;

  @override
  Widget build(BuildContext context) {
    final tones = context.tones;
    final logged = day.adhered != null && day.maxSeverity != null;
    final today = DateTime.now();
    final isToday = day.date.year == today.year &&
        day.date.month == today.month &&
        day.date.day == today.day;
    final kindColor = switch (day.kind) {
      ChallengeDayKind.on => tones.accent,
      ChallengeDayKind.off => tones.slate,
      ChallengeDayKind.washout => tones.inkFaint,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: Space.x2),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: Corner.lgAll,
          side: BorderSide(color: isToday ? tones.accent : tones.line),
        ),
        child: ListTile(
          onTap: locked ? null : onLog,
          leading: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: kindColor, shape: BoxShape.circle),
          ),
          title: Text(
            '${DateFormat('EEE, MMM d').format(day.date)} — ${day.kind.label}',
            style: TypeRamp.body.copyWith(color: tones.ink),
          ),
          subtitle: Text(
            logged
                ? '${day.adhered! ? 'Followed plan' : 'Off-plan'} · worst '
                    'severity ${day.maxSeverity}/5'
                : day.kind.instruction,
            style: TypeRamp.caption.copyWith(
                color: logged ? tones.inkSecondary : tones.inkFaint),
          ),
          trailing: locked
              ? null
              : Icon(
                  logged ? Icons.check_circle_outline : Icons.edit_outlined,
                  size: 20,
                  color: logged ? tones.moss : tones.inkFaint,
                ),
        ),
      ),
    );
  }
}

class _DayLogSheet extends StatefulWidget {
  const _DayLogSheet({required this.day});

  final ChallengeDay day;

  @override
  State<_DayLogSheet> createState() => _DayLogSheetState();
}

class _DayLogSheetState extends State<_DayLogSheet> {
  late bool _adhered = widget.day.adhered ?? true;
  late double _severity = (widget.day.maxSeverity ?? 0).toDouble();

  @override
  Widget build(BuildContext context) {
    final tones = context.tones;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(Space.x4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${DateFormat('EEEE, MMM d').format(widget.day.date)} — '
              '${widget.day.kind.label}',
              style: TypeRamp.title.copyWith(color: tones.ink),
            ),
            const SizedBox(height: Space.x1),
            Text(widget.day.kind.instruction,
                style: TypeRamp.caption.copyWith(color: tones.inkSecondary)),
            const SizedBox(height: Space.x4),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Followed the plan', style: TypeRamp.body),
              value: _adhered,
              onChanged: (v) => setState(() => _adhered = v),
            ),
            Row(
              children: [
                Text('Worst severity today',
                    style: TypeRamp.label.copyWith(color: tones.inkSecondary)),
                const Spacer(),
                Text(
                  _severity.round() == 0 ? 'none' : '${_severity.round()}/5',
                  style: TypeRamp.title.copyWith(
                    color: _severity >= 4 ? tones.alert : tones.ink,
                  ),
                ),
              ],
            ),
            Slider(
              value: _severity,
              min: 0,
              max: 5,
              divisions: 5,
              activeColor: _severity >= 4 ? tones.alert : tones.accent,
              onChanged: (v) => setState(() => _severity = v),
            ),
            const SizedBox(height: Space.x4),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop((_adhered, _severity.round())),
              child: const Text('Save day'),
            ),
          ],
        ),
      ),
    );
  }
}
