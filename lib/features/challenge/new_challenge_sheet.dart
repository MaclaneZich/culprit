import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../analysis/challenge_evaluator.dart';
import '../../analysis/models.dart';
import '../../core/copy/copy.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../data/db/database.dart';
import '../../domain/enums.dart';
import '../../providers.dart';

/// Sets up a reintroduction challenge: pick the candidate, tune the
/// schedule, optionally read the self-blinding guidance, start.
Future<void> showNewChallengeSheet(BuildContext context,
    {CandidateScore? candidate}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _NewChallengeSheet(candidate: candidate),
  );
}

class _NewChallengeSheet extends ConsumerStatefulWidget {
  const _NewChallengeSheet({this.candidate});

  final CandidateScore? candidate;

  @override
  ConsumerState<_NewChallengeSheet> createState() => _NewChallengeSheetState();
}

class _NewChallengeSheetState extends ConsumerState<_NewChallengeSheet> {
  late final TextEditingController _titleController = TextEditingController(
    text: widget.candidate?.displayName ?? '',
  );
  int _washoutDays = 3;
  int _onDays = 2;
  int _offDays = 2;
  int _cycles = 2;
  bool _blinded = false;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  int get _totalDays => _washoutDays + (_onDays + _offDays) * _cycles;

  Future<void> _start() async {
    final title = _titleController.text.trim();
    if (title.isEmpty || _saving) return;
    setState(() => _saving = true);

    final startDate = DateTime.now().add(const Duration(days: 1));
    final schedule = buildSchedule(
      startDate: startDate,
      washoutDays: _washoutDays,
      onDaysPerCycle: _onDays,
      offDaysPerCycle: _offDays,
      cycles: _cycles,
    );

    final candidate = widget.candidate;
    final tag = candidate != null && candidate.kind == CandidateKind.tag
        ? TriggerTag.values.asNameMap()[candidate.key]
        : null;

    await ref.read(databaseProvider).insertChallenge(
          challenge: ChallengesCompanion.insert(
            title: title,
            tag: Value(tag),
            createdAt: DateTime.now(),
            startDate: startDate,
            status: ChallengeStatus.running,
            blinded: Value(_blinded),
          ),
          days: [
            for (final day in schedule)
              ChallengeDaysCompanion.insert(
                challengeId: 0, // overwritten inside the transaction
                dayIndex: day.dayIndex,
                date: day.date,
                kind: day.kind,
              ),
          ],
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final tones = context.tones;
    return Padding(
      padding: EdgeInsets.only(
        left: Space.x4,
        right: Space.x4,
        top: Space.x5,
        bottom: MediaQuery.of(context).viewInsets.bottom + Space.x4,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New challenge',
                style: TypeRamp.headline.copyWith(color: tones.ink)),
            const SizedBox(height: Space.x1),
            Text(Copy.challengeIntro,
                style: TypeRamp.caption.copyWith(color: tones.inkSecondary)),
            const SizedBox(height: Space.x4),
            TextField(
              controller: _titleController,
              decoration:
                  const InputDecoration(hintText: 'Candidate to test (e.g. Onion)'),
            ),
            const SizedBox(height: Space.x5),
            _Stepper(
              label: 'Washout days',
              hint: 'avoid the candidate, settle the baseline',
              value: _washoutDays,
              min: 2,
              max: 7,
              onChanged: (v) => setState(() => _washoutDays = v),
            ),
            _Stepper(
              label: 'On days per cycle',
              hint: 'eat it deliberately, normal portion',
              value: _onDays,
              min: 1,
              max: 3,
              onChanged: (v) => setState(() => _onDays = v),
            ),
            _Stepper(
              label: 'Off days per cycle',
              hint: 'avoid it again',
              value: _offDays,
              min: 1,
              max: 3,
              onChanged: (v) => setState(() => _offDays = v),
            ),
            _Stepper(
              label: 'Cycles',
              hint: 'more cycles, stronger answer',
              value: _cycles,
              min: 1,
              max: 3,
              onChanged: (v) => setState(() => _cycles = v),
            ),
            const SizedBox(height: Space.x3),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Self-blinding', style: TypeRamp.body),
              subtitle: Text(
                'Ask someone to prepare on/off portions you can\'t tell '
                'apart (e.g. capsules, or mixed into a strong-tasting dish) '
                'and only reveal the schedule at the end. Harder, but it '
                'removes expectation effects.',
                style: TypeRamp.caption.copyWith(color: tones.inkSecondary),
              ),
              value: _blinded,
              onChanged: (v) => setState(() => _blinded = v),
            ),
            const SizedBox(height: Space.x4),
            Text(
              '$_totalDays days total, starting tomorrow.',
              style: TypeRamp.bodySmall.copyWith(color: tones.ink),
            ),
            const SizedBox(height: Space.x4),
            FilledButton(
              onPressed: _saving ? null : _start,
              child: Text(_saving ? 'Starting…' : 'Start challenge'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.hint,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final tones = context.tones;
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.x3),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TypeRamp.body.copyWith(color: tones.ink)),
                Text(hint,
                    style: TypeRamp.caption.copyWith(color: tones.inkFaint)),
              ],
            ),
          ),
          IconButton(
            onPressed: value > min ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          SizedBox(
            width: 28,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: TypeRamp.title.copyWith(color: tones.ink),
            ),
          ),
          IconButton(
            onPressed: value < max ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }
}
