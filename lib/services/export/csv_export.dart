import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../data/db/database.dart';
import '../../domain/enums.dart';

/// Full raw-data export as CSV — every table the user logged, machine
/// readable, suitable for a clinician's spreadsheet or their own analysis.
class CsvExporter {
  const CsvExporter(this.db);

  final AppDatabase db;

  /// Writes meals/symptoms/context/challenge CSVs to a temp directory and
  /// returns the file paths for sharing.
  Future<List<String>> writeAll() async {
    final dir = Directory(
        p.join((await getTemporaryDirectory()).path, 'culprit_export'));
    await dir.create(recursive: true);

    final meals = await db.allMealsWithIngredients();
    final symptoms = await db.allSymptoms();
    final contextEntries = await db.allContextEntries();
    final challenges = await db.allChallenges();

    final files = <String>[];

    files.add(await _write(dir, 'meals.csv', [
      ['timestamp', 'ingredients', 'trigger_tags', 'portion', 'source', 'note'],
      for (final meal in meals)
        [
          meal.meal.timestamp.toIso8601String(),
          meal.ingredients
              .map((i) => i.ingredient.canonicalName)
              .join('; '),
          (meal.allTags.map((t) => t.name).toList()..sort()).join('; '),
          meal.meal.portionSize.name,
          meal.meal.source.name,
          meal.meal.note ?? '',
        ],
    ]));

    files.add(await _write(dir, 'symptoms.csv', [
      [
        'timestamp',
        'types',
        'severity_1_5',
        'minutes_since_last_meal',
        'coincident_factors',
        'note',
      ],
      for (final s in symptoms)
        [
          s.timestamp.toIso8601String(),
          (s.types.map((t) => t.name).toList()..sort()).join('; '),
          '${s.severity}',
          s.minutesSinceLastMeal?.toString() ?? '',
          s.coincidentFactors.join('; '),
          s.note ?? '',
        ],
    ]));

    files.add(await _write(dir, 'context.csv', [
      ['timestamp', 'type', 'value'],
      for (final entry in contextEntries)
        [
          entry.timestamp.toIso8601String(),
          entry.type.name,
          _formatValue(entry),
        ],
    ]));

    final challengeRows = <List<String>>[
      ['title', 'status', 'start_date', 'blinded', 'outcome', 'result'],
    ];
    for (final challenge in challenges) {
      challengeRows.add([
        challenge.title,
        challenge.status.name,
        challenge.startDate.toIso8601String(),
        '${challenge.blinded}',
        challenge.outcome?.name ?? '',
        challenge.resultNote ?? '',
      ]);
    }
    files.add(await _write(dir, 'challenges.csv', challengeRows));

    return files;
  }

  String _formatValue(ContextEntry entry) {
    if (entry.type == ContextType.menstrualPhase) {
      final i = entry.value.toInt().clamp(0, MenstrualPhase.values.length - 1);
      return MenstrualPhase.values[i].name;
    }
    return entry.value == entry.value.roundToDouble()
        ? entry.value.toInt().toString()
        : entry.value.toString();
  }

  Future<String> _write(
      Directory dir, String name, List<List<String>> rows) async {
    final file = File(p.join(dir.path, name));
    final buffer = StringBuffer();
    for (final row in rows) {
      buffer.writeln(row.map(_escape).join(','));
    }
    await file.writeAsString(buffer.toString());
    return file.path;
  }

  String _escape(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
}
