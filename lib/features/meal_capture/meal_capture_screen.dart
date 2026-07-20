import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../data/db/database.dart';
import '../../domain/enums.dart';
import '../../providers.dart';

/// Quick Meal Capture: one tap to camera on open, then a confirm step that
/// captures the real components — including invisible ones the photo can't
/// show. Designed to finish in under ten seconds on a repeat meal.
class MealCaptureScreen extends ConsumerStatefulWidget {
  const MealCaptureScreen({super.key, this.openCamera = true});

  final bool openCamera;

  @override
  ConsumerState<MealCaptureScreen> createState() => _MealCaptureScreenState();
}

class _SelectedIngredient {
  _SelectedIngredient({
    required this.name,
    required this.tags,
    required this.confidence,
  });

  final String name;
  Set<TriggerTag> tags;
  IngredientConfidence confidence;
}

class _MealCaptureScreenState extends ConsumerState<MealCaptureScreen> {
  final _picker = ImagePicker();
  final _ingredientController = TextEditingController();
  final _noteController = TextEditingController();

  String? _photoPath;
  DateTime _timestamp = DateTime.now();
  final List<_SelectedIngredient> _selected = [];
  PortionSize _portion = PortionSize.medium;
  MealSource _source = MealSource.home;
  bool _guessing = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.openCamera) {
      // Straight to the camera; cancelling falls through to manual entry.
      WidgetsBinding.instance.addPostFrameCallback((_) => _capturePhoto());
    }
  }

  @override
  void dispose() {
    _ingredientController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    try {
      final shot = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 2048,
        imageQuality: 85,
      );
      if (shot == null) return;
      final saved = await ref.read(photoStoreProvider).persist(File(shot.path));
      if (!mounted) return;
      setState(() => _photoPath = saved);
    } on Exception {
      // No camera (simulator/desktop) — manual entry still works.
    }
  }

  Future<void> _guessFromPhoto() async {
    final photoPath = _photoPath;
    final llm = ref.read(llmServiceProvider).value;
    if (photoPath == null || llm == null) return;
    setState(() => _guessing = true);
    try {
      final guesses = await llm.guessIngredients(File(photoPath));
      final library = ref.read(ingredientsProvider).value ?? const [];
      if (!mounted) return;
      setState(() {
        for (final guess in guesses) {
          if (_selected.any((s) =>
              s.name.toLowerCase() == guess.name.toLowerCase())) {
            continue;
          }
          final known = library.where((i) =>
              i.canonicalName.toLowerCase() == guess.name.toLowerCase());
          _selected.add(_SelectedIngredient(
            name: known.isNotEmpty ? known.first.canonicalName : guess.name,
            tags: known.isNotEmpty ? known.first.triggerTags : {},
            confidence: IngredientConfidence.guessed,
          ));
        }
      });
    } on Exception catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vision guess failed: $error')),
      );
    } finally {
      if (mounted) setState(() => _guessing = false);
    }
  }

  void _addIngredient(String rawName) {
    final name = rawName.trim();
    if (name.isEmpty) return;
    if (_selected.any((s) => s.name.toLowerCase() == name.toLowerCase())) {
      _ingredientController.clear();
      return;
    }
    final library = ref.read(ingredientsProvider).value ?? const [];
    final known =
        library.where((i) => i.canonicalName.toLowerCase() == name.toLowerCase());
    setState(() {
      _selected.add(_SelectedIngredient(
        name: known.isNotEmpty ? known.first.canonicalName : name,
        tags: known.isNotEmpty ? known.first.triggerTags : {},
        confidence: IngredientConfidence.confirmed,
      ));
    });
    _ingredientController.clear();
  }

  Future<void> _editTags(_SelectedIngredient ingredient) async {
    final updated = await showModalBottomSheet<Set<TriggerTag>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _TagPickerSheet(
        name: ingredient.name,
        initial: ingredient.tags,
      ),
    );
    if (updated != null) {
      setState(() {
        ingredient.tags = updated;
        ingredient.confidence = IngredientConfidence.confirmed;
      });
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_timestamp),
    );
    if (time == null) return;
    setState(() {
      _timestamp = DateTime(_timestamp.year, _timestamp.month, _timestamp.day,
          time.hour, time.minute);
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final db = ref.read(databaseProvider);
    await db.insertMeal(
      meal: MealsCompanion.insert(
        timestamp: _timestamp,
        photoPath: Value(_photoPath),
        note: Value(
            _noteController.text.trim().isEmpty ? null : _noteController.text.trim()),
        portionSize: _portion,
        source: _source,
      ),
      ingredientEntries: [
        for (final s in _selected)
          (name: s.name, tags: s.tags, confidence: s.confidence),
      ],
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final tones = context.tones;
    final library = ref.watch(ingredientsProvider).value ?? const [];
    final llmReady = ref.watch(llmServiceProvider).value != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log meal'),
        actions: [
          TextButton(
            onPressed: _pickTime,
            child: Text(DateFormat('HH:mm').format(_timestamp)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.x4),
        children: [
          _PhotoRow(
            photoPath: _photoPath,
            onCapture: _capturePhoto,
            onGuess: llmReady && _photoPath != null ? _guessFromPhoto : null,
            guessing: _guessing,
          ),
          const SizedBox(height: Space.x5),
          Text('What was in it?', style: TypeRamp.title.copyWith(color: tones.ink)),
          const SizedBox(height: Space.x1),
          Text(
            'Include what the photo can\'t show — butter, garlic, sauces, '
            'sweeteners.',
            style: TypeRamp.caption.copyWith(color: tones.inkSecondary),
          ),
          const SizedBox(height: Space.x3),
          RawAutocomplete<String>(
            textEditingController: _ingredientController,
            focusNode: FocusNode(),
            optionsBuilder: (value) {
              final query = value.text.trim().toLowerCase();
              if (query.isEmpty) return const Iterable<String>.empty();
              return library
                  .map((i) => i.canonicalName)
                  .where((name) => name.toLowerCase().contains(query))
                  .take(6);
            },
            onSelected: _addIngredient,
            fieldViewBuilder: (context, controller, focusNode, _) => TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: const InputDecoration(
                hintText: 'Add ingredient…',
                prefixIcon: Icon(Icons.add, size: 20),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: _addIngredient,
            ),
            optionsViewBuilder: (context, onSelected, options) => Align(
              alignment: Alignment.topLeft,
              child: Material(
                color: tones.card,
                borderRadius: Corner.mdAll,
                elevation: 4,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 240, maxWidth: 320),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    children: [
                      for (final option in options)
                        ListTile(
                          dense: true,
                          title: Text(option, style: TypeRamp.bodySmall),
                          onTap: () => onSelected(option),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: Space.x3),
          Wrap(
            spacing: Space.x2,
            runSpacing: Space.x2,
            children: [
              for (final ingredient in _selected)
                InputChip(
                  label: Text(
                    ingredient.confidence == IngredientConfidence.guessed
                        ? '${ingredient.name}?'
                        : ingredient.name,
                  ),
                  avatar: ingredient.tags.isNotEmpty
                      ? Icon(Icons.label_outline, size: 16, color: tones.accent)
                      : null,
                  onPressed: () => _editTags(ingredient),
                  onDeleted: () => setState(() => _selected.remove(ingredient)),
                ),
            ],
          ),
          const SizedBox(height: Space.x6),
          _Segmented<PortionSize>(
            label: 'Portion',
            values: PortionSize.values,
            selected: _portion,
            labelOf: (v) => v.label,
            onChanged: (v) => setState(() => _portion = v),
          ),
          const SizedBox(height: Space.x4),
          _Segmented<MealSource>(
            label: 'Source',
            values: MealSource.values,
            selected: _source,
            labelOf: (v) => v.label,
            onChanged: (v) => setState(() => _source = v),
          ),
          const SizedBox(height: Space.x5),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(hintText: 'Note (optional)'),
            maxLines: 2,
            minLines: 1,
          ),
          const SizedBox(height: Space.x8),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Saving…' : 'Save meal'),
          ),
          const SizedBox(height: Space.x6),
        ],
      ),
    );
  }
}

class _PhotoRow extends StatelessWidget {
  const _PhotoRow({
    required this.photoPath,
    required this.onCapture,
    required this.onGuess,
    required this.guessing,
  });

  final String? photoPath;
  final VoidCallback onCapture;
  final VoidCallback? onGuess;
  final bool guessing;

  @override
  Widget build(BuildContext context) {
    final tones = context.tones;
    return Row(
      children: [
        GestureDetector(
          onTap: onCapture,
          child: ClipRRect(
            borderRadius: Corner.lgAll,
            child: photoPath != null
                ? Image.file(
                    File(photoPath!),
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: tones.cardSunken,
                      borderRadius: Corner.lgAll,
                      border: Border.all(color: tones.line),
                    ),
                    child: Icon(Icons.camera_alt_outlined,
                        color: tones.inkSecondary),
                  ),
          ),
        ),
        const SizedBox(width: Space.x4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                photoPath == null
                    ? 'Photo is optional — the confirm step is what matters.'
                    : 'Photo attached.',
                style: TypeRamp.caption.copyWith(color: tones.inkSecondary),
              ),
              if (onGuess != null) ...[
                const SizedBox(height: Space.x2),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    padding: const EdgeInsets.symmetric(horizontal: Space.x4),
                  ),
                  onPressed: guessing ? null : onGuess,
                  child: Text(guessing ? 'Guessing…' : 'Guess ingredients'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Segmented<T> extends StatelessWidget {
  const _Segmented({
    required this.label,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
  });

  final String label;
  final List<T> values;
  final T selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final tones = context.tones;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TypeRamp.label.copyWith(color: tones.inkSecondary)),
        const SizedBox(height: Space.x2),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<T>(
            segments: [
              for (final value in values)
                ButtonSegment(value: value, label: Text(labelOf(value))),
            ],
            selected: {selected},
            onSelectionChanged: (set) => onChanged(set.first),
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: tones.accentWash,
              selectedForegroundColor: tones.accent,
              side: BorderSide(color: tones.line),
            ),
          ),
        ),
      ],
    );
  }
}

/// Bottom sheet for confirming an ingredient's trigger-class tags.
class _TagPickerSheet extends StatefulWidget {
  const _TagPickerSheet({required this.name, required this.initial});

  final String name;
  final Set<TriggerTag> initial;

  @override
  State<_TagPickerSheet> createState() => _TagPickerSheetState();
}

class _TagPickerSheetState extends State<_TagPickerSheet> {
  late final Set<TriggerTag> _tags = {...widget.initial};

  @override
  Widget build(BuildContext context) {
    final tones = context.tones;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: Space.x4,
          right: Space.x4,
          top: Space.x5,
          bottom: MediaQuery.of(context).viewInsets.bottom + Space.x4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trigger classes for ${widget.name}',
                style: TypeRamp.title.copyWith(color: tones.ink)),
            const SizedBox(height: Space.x1),
            Text(
              'Tags let the analysis find class-level patterns (e.g. FODMAPs) '
              'a single food can\'t reveal.',
              style: TypeRamp.caption.copyWith(color: tones.inkSecondary),
            ),
            const SizedBox(height: Space.x4),
            Wrap(
              spacing: Space.x2,
              runSpacing: Space.x2,
              children: [
                for (final tag in TriggerTag.values)
                  FilterChip(
                    label: Text(tag.label),
                    tooltip: tag.hint,
                    selected: _tags.contains(tag),
                    onSelected: (on) => setState(() {
                      on ? _tags.add(tag) : _tags.remove(tag);
                    }),
                  ),
              ],
            ),
            const SizedBox(height: Space.x6),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(_tags),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
