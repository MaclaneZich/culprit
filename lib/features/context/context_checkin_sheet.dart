import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../data/db/database.dart';
import '../../domain/enums.dart';
import '../../providers.dart';

/// Daily context check-in. Logged on calm days too — that's the denominator
/// principle applied to the gut-brain axis. One value per factor per day;
/// re-logging replaces.
Future<void> showContextCheckInSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _ContextCheckInSheet(),
  );
}

class _ContextCheckInSheet extends ConsumerStatefulWidget {
  const _ContextCheckInSheet();

  @override
  ConsumerState<_ContextCheckInSheet> createState() =>
      _ContextCheckInSheetState();
}

class _ContextCheckInSheetState extends ConsumerState<_ContextCheckInSheet> {
  double _sleepHours = 7;
  double _stress = 2;
  double _alcoholUnits = 0;
  double _caffeineMg = 0;
  double _exercise = 0;
  double _hydration = 2;
  bool _skippedMeal = false;
  bool _illness = false;
  MenstrualPhase? _phase;
  bool _loaded = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadToday();
  }

  Future<void> _loadToday() async {
    final entries =
        await ref.read(databaseProvider).contextEntriesOn(DateTime.now());
    if (!mounted) return;
    setState(() {
      for (final entry in entries) {
        switch (entry.type) {
          case ContextType.sleepHours:
            _sleepHours = entry.value;
          case ContextType.stress:
            _stress = entry.value;
          case ContextType.alcoholUnits:
            _alcoholUnits = entry.value;
          case ContextType.caffeineMg:
            _caffeineMg = entry.value;
          case ContextType.exerciseIntensity:
            _exercise = entry.value;
          case ContextType.hydration:
            _hydration = entry.value;
          case ContextType.skippedMeal:
            _skippedMeal = entry.value > 0;
          case ContextType.illness:
            _illness = entry.value > 0;
          case ContextType.menstrualPhase:
            final i =
                entry.value.toInt().clamp(0, MenstrualPhase.values.length - 1);
            _phase = MenstrualPhase.values[i];
        }
      }
      _loaded = true;
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final db = ref.read(databaseProvider);
    final now = DateTime.now();

    Future<void> put(ContextType type, double value) =>
        db.upsertContextEntry(ContextEntriesCompanion.insert(
          timestamp: now,
          type: type,
          value: value,
        ));

    await put(ContextType.sleepHours, _sleepHours);
    await put(ContextType.stress, _stress);
    await put(ContextType.alcoholUnits, _alcoholUnits);
    await put(ContextType.caffeineMg, _caffeineMg);
    await put(ContextType.exerciseIntensity, _exercise);
    await put(ContextType.hydration, _hydration);
    await put(ContextType.skippedMeal, _skippedMeal ? 1 : 0);
    await put(ContextType.illness, _illness ? 1 : 0);
    if (_phase != null) {
      await put(ContextType.menstrualPhase, _phase!.index.toDouble());
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final tones = context.tones;
    final trackCycle =
        ref.watch(settingsProvider).value?.trackMenstrualCycle ?? false;

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
            Text('Daily check-in',
                style: TypeRamp.headline.copyWith(color: tones.ink)),
            const SizedBox(height: Space.x1),
            Text(
              'Calm days count as much as bad ones.',
              style: TypeRamp.caption.copyWith(color: tones.inkSecondary),
            ),
            const SizedBox(height: Space.x5),
            if (!_loaded)
              const Center(child: CircularProgressIndicator())
            else ...[
              _SliderRow(
                label: 'Sleep',
                display: '${_trim(_sleepHours)} h',
                value: _sleepHours,
                min: 0,
                max: 12,
                divisions: 24,
                onChanged: (v) => setState(() => _sleepHours = v),
              ),
              _SliderRow(
                label: 'Stress',
                display: '${_stress.round()}/5',
                value: _stress,
                min: 1,
                max: 5,
                divisions: 4,
                onChanged: (v) => setState(() => _stress = v),
              ),
              _SliderRow(
                label: 'Alcohol',
                display: '${_trim(_alcoholUnits)} drinks',
                value: _alcoholUnits,
                min: 0,
                max: 10,
                divisions: 20,
                onChanged: (v) => setState(() => _alcoholUnits = v),
              ),
              _SliderRow(
                label: 'Caffeine',
                display: '${_caffeineMg.round()} mg',
                value: _caffeineMg,
                min: 0,
                max: 600,
                divisions: 12,
                onChanged: (v) => setState(() => _caffeineMg = v),
              ),
              _SliderRow(
                label: 'Exercise',
                display: switch (_exercise.round()) {
                  0 => 'none',
                  1 => 'light',
                  2 => 'moderate',
                  _ => 'hard',
                },
                value: _exercise,
                min: 0,
                max: 3,
                divisions: 3,
                onChanged: (v) => setState(() => _exercise = v),
              ),
              _SliderRow(
                label: 'Hydration',
                display: switch (_hydration.round()) {
                  1 => 'low',
                  2 => 'okay',
                  _ => 'good',
                },
                value: _hydration,
                min: 1,
                max: 3,
                divisions: 2,
                onChanged: (v) => setState(() => _hydration = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Skipped a meal', style: TypeRamp.body),
                value: _skippedMeal,
                onChanged: (v) => setState(() => _skippedMeal = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Feeling ill', style: TypeRamp.body),
                value: _illness,
                onChanged: (v) => setState(() => _illness = v),
              ),
              if (trackCycle) ...[
                const SizedBox(height: Space.x3),
                Text('Cycle phase',
                    style: TypeRamp.label.copyWith(color: tones.inkSecondary)),
                const SizedBox(height: Space.x2),
                Wrap(
                  spacing: Space.x2,
                  children: [
                    for (final phase in MenstrualPhase.values)
                      ChoiceChip(
                        label: Text(phase.label),
                        selected: _phase == phase,
                        onSelected: (on) =>
                            setState(() => _phase = on ? phase : null),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: Space.x6),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Saving…' : 'Save check-in'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _trim(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.display,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final String label;
  final String display;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final tones = context.tones;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: TypeRamp.label.copyWith(color: tones.inkSecondary)),
            const Spacer(),
            Text(display, style: TypeRamp.label.copyWith(color: tones.ink)),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
