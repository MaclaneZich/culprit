import 'dart:io';

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
import '../context/context_checkin_sheet.dart';
import '../meal_capture/meal_capture_screen.dart';
import '../symptom/symptom_log_sheet.dart';

/// Home: a single vertical timeline interleaving meals, context, and
/// symptoms, with the two primary logging actions one tap away.
class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meals = ref.watch(mealsProvider).value ?? const [];
    final symptoms = ref.watch(symptomsProvider).value ?? const [];
    final contextEntries =
        ref.watch(contextEntriesProvider).value ?? const [];

    final days = _groupByDay(meals, symptoms, contextEntries);

    return Scaffold(
      appBar: AppBar(title: const Text(Copy.appName)),
      body: Column(
        children: [
          Expanded(
            child: days.isEmpty
                ? const _EmptyTimeline()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                        Space.x4, Space.x2, Space.x4, Space.x6),
                    itemCount: days.length,
                    itemBuilder: (context, i) => _DaySection(day: days[i]),
                  ),
          ),
          const _QuickLogBar(),
        ],
      ),
    );
  }

  List<_TimelineDay> _groupByDay(
    List<MealWithIngredients> meals,
    List<Symptom> symptoms,
    List<ContextEntry> contextEntries,
  ) {
    final byDay = <DateTime, _TimelineDay>{};
    _TimelineDay dayFor(DateTime t) {
      final day = DateTime(t.year, t.month, t.day);
      return byDay.putIfAbsent(day, () => _TimelineDay(day));
    }

    for (final meal in meals) {
      dayFor(meal.meal.timestamp).events.add(_MealEvent(meal));
    }
    for (final symptom in symptoms) {
      dayFor(symptom.timestamp).events.add(_SymptomEvent(symptom));
    }
    for (final entry in contextEntries) {
      dayFor(entry.timestamp).context.add(entry);
    }

    final days = byDay.values.toList()
      ..sort((a, b) => b.day.compareTo(a.day));
    for (final day in days) {
      day.events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }
    return days;
  }
}

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------

class _TimelineDay {
  _TimelineDay(this.day);

  final DateTime day;
  final List<_TimelineEvent> events = [];
  final List<ContextEntry> context = [];
}

sealed class _TimelineEvent {
  DateTime get timestamp;
}

class _MealEvent implements _TimelineEvent {
  _MealEvent(this.meal);
  final MealWithIngredients meal;
  @override
  DateTime get timestamp => meal.meal.timestamp;
}

class _SymptomEvent implements _TimelineEvent {
  _SymptomEvent(this.symptom);
  final Symptom symptom;
  @override
  DateTime get timestamp => symptom.timestamp;
}

// ---------------------------------------------------------------------------
// Day section
// ---------------------------------------------------------------------------

class _DaySection extends StatelessWidget {
  const _DaySection({required this.day});

  final _TimelineDay day;

  @override
  Widget build(BuildContext context) {
    final tones = context.tones;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: Space.x5, bottom: Space.x2),
          child: Text(
            _dayLabel(day.day),
            style: TypeRamp.label.copyWith(color: tones.inkSecondary),
          ),
        ),
        if (day.context.isNotEmpty) _ContextStrip(entries: day.context),
        for (final event in day.events)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.x2),
            child: switch (event) {
              _MealEvent(:final meal) => _MealCard(meal: meal),
              _SymptomEvent(:final symptom) => _SymptomCard(symptom: symptom),
            },
          ),
      ],
    );
  }

  String _dayLabel(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (day == today) return 'Today';
    if (day == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return DateFormat('EEEE, MMM d').format(day).toUpperCase();
  }
}

class _ContextStrip extends StatelessWidget {
  const _ContextStrip({required this.entries});

  final List<ContextEntry> entries;

  @override
  Widget build(BuildContext context) {
    final tones = context.tones;
    final parts = <String>[];
    for (final entry in entries..sort((a, b) => a.type.index.compareTo(b.type.index))) {
      final text = _describe(entry);
      if (text != null) parts.add(text);
    }
    if (parts.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.x2),
      child: Text(
        parts.join('  ·  '),
        style: TypeRamp.caption.copyWith(color: tones.slate),
      ),
    );
  }

  String? _describe(ContextEntry entry) {
    switch (entry.type) {
      case ContextType.sleepHours:
        return '${_trim(entry.value)} h sleep';
      case ContextType.stress:
        return 'stress ${entry.value.toInt()}/5';
      case ContextType.alcoholUnits:
        return entry.value > 0 ? '${_trim(entry.value)} drinks' : null;
      case ContextType.caffeineMg:
        return entry.value > 0 ? '${entry.value.toInt()} mg caffeine' : null;
      case ContextType.exerciseIntensity:
        return entry.value > 0 ? 'exercise ${entry.value.toInt()}/3' : null;
      case ContextType.skippedMeal:
        return entry.value > 0 ? 'skipped a meal' : null;
      case ContextType.menstrualPhase:
        final i = entry.value.toInt().clamp(0, MenstrualPhase.values.length - 1);
        return MenstrualPhase.values[i].label.toLowerCase();
      case ContextType.illness:
        return entry.value > 0 ? 'feeling ill' : null;
      case ContextType.hydration:
        return entry.value <= 1 ? 'low hydration' : null;
    }
  }

  String _trim(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
}

// ---------------------------------------------------------------------------
// Cards
// ---------------------------------------------------------------------------

class _MealCard extends ConsumerWidget {
  const _MealCard({required this.meal});

  final MealWithIngredients meal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tones = context.tones;
    final names = meal.ingredients
        .map((detail) => detail.confidence == IngredientConfidence.guessed
            ? '${detail.ingredient.canonicalName}?'
            : detail.ingredient.canonicalName)
        .toList();
    final tags = meal.allTags.map((tag) => tag.label).toList()..sort();

    return Card(
      child: InkWell(
        borderRadius: Corner.lgAll,
        onLongPress: () => _confirmDelete(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(Space.x4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (meal.meal.photoPath != null) ...[
                ClipRRect(
                  borderRadius: Corner.mdAll,
                  child: Image.file(
                    File(meal.meal.photoPath!),
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 56,
                      height: 56,
                      color: tones.cardSunken,
                    ),
                  ),
                ),
                const SizedBox(width: Space.x3),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          DateFormat('HH:mm').format(meal.meal.timestamp),
                          style: TypeRamp.label
                              .copyWith(color: tones.inkSecondary),
                        ),
                        const SizedBox(width: Space.x2),
                        Text(
                          '${meal.meal.portionSize.label.toLowerCase()} · '
                          '${meal.meal.source.label.toLowerCase()}',
                          style: TypeRamp.caption
                              .copyWith(color: tones.inkFaint),
                        ),
                      ],
                    ),
                    const SizedBox(height: Space.x1),
                    Text(
                      names.isEmpty ? 'Meal' : names.join(', '),
                      style: TypeRamp.body.copyWith(color: tones.ink),
                    ),
                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: Space.x2),
                      Text(
                        tags.join(' · '),
                        style:
                            TypeRamp.caption.copyWith(color: tones.accent),
                      ),
                    ],
                    if (meal.meal.note case final note?) ...[
                      const SizedBox(height: Space.x1),
                      Text(
                        note,
                        style: TypeRamp.caption
                            .copyWith(color: tones.inkSecondary),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this meal?'),
        content: const Text('Removing meals weakens the log the analysis '
            'depends on. Delete only if it was logged in error.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(databaseProvider).deleteMeal(meal.meal.id);
    }
  }
}

class _SymptomCard extends ConsumerWidget {
  const _SymptomCard({required this.symptom});

  final Symptom symptom;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tones = context.tones;
    final severe = symptom.severity >= 4;
    final color = severe ? tones.alert : tones.accent;
    final types = symptom.types.map((t) => t.label).join(', ');

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: Corner.lgAll,
        side: BorderSide(color: severe ? color : tones.line),
      ),
      child: InkWell(
        borderRadius: Corner.lgAll,
        onLongPress: () => _confirmDelete(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(Space.x4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 5),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: Space.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          DateFormat('HH:mm').format(symptom.timestamp),
                          style: TypeRamp.label
                              .copyWith(color: tones.inkSecondary),
                        ),
                        const SizedBox(width: Space.x2),
                        Text(
                          'severity ${symptom.severity}/5',
                          style: TypeRamp.caption.copyWith(color: color),
                        ),
                      ],
                    ),
                    const SizedBox(height: Space.x1),
                    Text(types.isEmpty ? 'Episode' : types,
                        style: TypeRamp.body.copyWith(color: tones.ink)),
                    if (symptom.minutesSinceLastMeal case final minutes?) ...[
                      const SizedBox(height: Space.x1),
                      Text(
                        _sinceMeal(minutes),
                        style: TypeRamp.caption
                            .copyWith(color: tones.inkSecondary),
                      ),
                    ],
                    if (symptom.coincidentFactors.isNotEmpty) ...[
                      const SizedBox(height: Space.x1),
                      Text(
                        symptom.coincidentFactors.join(' · '),
                        style: TypeRamp.caption.copyWith(color: tones.slate),
                      ),
                    ],
                    if (symptom.note case final note?) ...[
                      const SizedBox(height: Space.x1),
                      Text(
                        note,
                        style: TypeRamp.caption
                            .copyWith(color: tones.inkSecondary),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _sinceMeal(int minutes) {
    if (minutes < 60) return '$minutes min after last meal';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0
        ? '$h h after last meal'
        : '$h h $m min after last meal';
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this episode?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(databaseProvider).deleteSymptom(symptom.id);
    }
  }
}

// ---------------------------------------------------------------------------
// Quick log bar + empty state
// ---------------------------------------------------------------------------

class _QuickLogBar extends StatelessWidget {
  const _QuickLogBar();

  @override
  Widget build(BuildContext context) {
    final tones = context.tones;
    return Container(
      padding: const EdgeInsets.fromLTRB(Space.x4, Space.x3, Space.x4, Space.x3),
      decoration: BoxDecoration(
        color: tones.surface,
        border: Border(top: BorderSide(color: tones.line)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const MealCaptureScreen(),
                  ),
                ),
                icon: const Icon(Icons.camera_alt_outlined, size: 20),
                label: const Text('Meal'),
              ),
            ),
            const SizedBox(width: Space.x3),
            Expanded(
              flex: 3,
              child: OutlinedButton(
                onPressed: () => showSymptomLogSheet(context),
                child: const Text('Symptom'),
              ),
            ),
            const SizedBox(width: Space.x3),
            SizedBox(
              width: 52,
              height: 52,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(52, 52),
                ),
                onPressed: () => showContextCheckInSheet(context),
                child: SvgPicture.asset(
                  'assets/icons/checkin.svg',
                  width: 22,
                  height: 22,
                  colorFilter:
                      ColorFilter.mode(tones.ink, BlendMode.srcIn),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyTimeline extends StatelessWidget {
  const _EmptyTimeline();

  @override
  Widget build(BuildContext context) {
    final tones = context.tones;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Space.x8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/illustrations/empty_timeline.svg',
              width: 180,
            ),
            const SizedBox(height: Space.x6),
            Text(
              Copy.emptyTimeline,
              textAlign: TextAlign.center,
              style: TypeRamp.body.copyWith(color: tones.inkSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
