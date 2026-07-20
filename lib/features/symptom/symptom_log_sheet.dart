import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../data/db/database.dart';
import '../../domain/enums.dart';
import '../../providers.dart';

/// One-handed structured symptom entry, built to be usable mid-attack:
/// quick-tap chips, a big severity slider, minimal typing. "Minutes since
/// last meal" is derived from the log but editable, because timing
/// implicates mechanism.
Future<void> showSymptomLogSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _SymptomLogSheet(),
  );
}

class _SymptomLogSheet extends ConsumerStatefulWidget {
  const _SymptomLogSheet();

  @override
  ConsumerState<_SymptomLogSheet> createState() => _SymptomLogSheetState();
}

class _SymptomLogSheetState extends ConsumerState<_SymptomLogSheet> {
  final Set<SymptomType> _types = {};
  double _severity = 3;
  int? _minutesSinceMeal;
  bool _minutesEdited = false;
  final Set<String> _factors = {};
  final _noteController = TextEditingController();
  final _factorController = TextEditingController();
  bool _saving = false;

  static const _quickFactors = ['party', 'travel', 'deadline', 'poor sleep'];

  @override
  void initState() {
    super.initState();
    _deriveMinutesSinceMeal();
  }

  Future<void> _deriveMinutesSinceMeal() async {
    final lastMeal =
        await ref.read(databaseProvider).lastMealBefore(DateTime.now());
    if (lastMeal == null || !mounted || _minutesEdited) return;
    setState(() {
      _minutesSinceMeal =
          DateTime.now().difference(lastMeal.timestamp).inMinutes;
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    _factorController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_types.isEmpty || _saving) return;
    setState(() => _saving = true);
    await ref.read(databaseProvider).insertSymptom(
          SymptomsCompanion.insert(
            timestamp: DateTime.now(),
            types: _types,
            severity: _severity.round(),
            minutesSinceLastMeal: Value(_minutesSinceMeal),
            note: Value(_noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim()),
            coincidentFactors: Value(_factors.toList()),
          ),
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final tones = context.tones;
    final severe = _severity >= 4;

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
            Text('Log symptom', style: TypeRamp.headline.copyWith(color: tones.ink)),
            const SizedBox(height: Space.x4),
            Wrap(
              spacing: Space.x2,
              runSpacing: Space.x2,
              children: [
                for (final type in SymptomType.values)
                  FilterChip(
                    label: Text(type.label),
                    labelStyle: TypeRamp.body.copyWith(
                      color: _types.contains(type) ? tones.accent : tones.ink,
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: Space.x3, vertical: Space.x3),
                    selected: _types.contains(type),
                    onSelected: (on) => setState(() {
                      on ? _types.add(type) : _types.remove(type);
                    }),
                  ),
              ],
            ),
            const SizedBox(height: Space.x6),
            Row(
              children: [
                Text('Severity',
                    style: TypeRamp.label.copyWith(color: tones.inkSecondary)),
                const Spacer(),
                Text(
                  '${_severity.round()}/5',
                  style: TypeRamp.statNumber.copyWith(
                    color: severe ? tones.alert : tones.ink,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
            Slider(
              value: _severity,
              min: 1,
              max: 5,
              divisions: 4,
              activeColor: severe ? tones.alert : tones.accent,
              thumbColor: severe ? tones.alert : tones.accent,
              onChanged: (v) => setState(() => _severity = v),
            ),
            const SizedBox(height: Space.x4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _minutesSinceMeal == null
                        ? 'Time since last meal: unknown'
                        : 'Time since last meal: ${_formatMinutes(_minutesSinceMeal!)}',
                    style: TypeRamp.bodySmall.copyWith(color: tones.inkSecondary),
                  ),
                ),
                TextButton(
                  onPressed: _editMinutes,
                  child: const Text('Edit'),
                ),
              ],
            ),
            const SizedBox(height: Space.x2),
            Wrap(
              spacing: Space.x2,
              runSpacing: Space.x2,
              children: [
                for (final factor in {..._quickFactors, ..._factors})
                  FilterChip(
                    label: Text(factor),
                    selected: _factors.contains(factor),
                    onSelected: (on) => setState(() {
                      on ? _factors.add(factor) : _factors.remove(factor);
                    }),
                  ),
                ActionChip(
                  label: const Icon(Icons.add, size: 16),
                  onPressed: _addFactor,
                ),
              ],
            ),
            const SizedBox(height: Space.x4),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(hintText: 'Note (optional)'),
              minLines: 1,
              maxLines: 2,
            ),
            const SizedBox(height: Space.x6),
            FilledButton(
              onPressed: _types.isEmpty || _saving ? null : _save,
              style: severe
                  ? FilledButton.styleFrom(backgroundColor: tones.alert)
                  : null,
              child: Text(_saving ? 'Saving…' : 'Save episode'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMinutes(int minutes) {
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '$h h' : '$h h $m min';
  }

  Future<void> _editMinutes() async {
    final controller =
        TextEditingController(text: _minutesSinceMeal?.toString() ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Minutes since last meal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Set'),
          ),
        ],
      ),
    );
    if (result == null) return;
    setState(() {
      _minutesEdited = true;
      _minutesSinceMeal = int.tryParse(result.trim());
    });
  }

  Future<void> _addFactor() async {
    _factorController.clear();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coincident factor'),
        content: TextField(
          controller: _factorController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. wedding, exam'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _factorController.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    final factor = result?.trim().toLowerCase();
    if (factor != null && factor.isNotEmpty) {
      setState(() => _factors.add(factor));
    }
  }
}
