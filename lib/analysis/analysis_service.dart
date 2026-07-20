import '../data/db/database.dart';
import '../domain/enums.dart';
import 'models.dart';
import 'stats_engine.dart';

/// Bridges the database and the pure stats engine: reduces logged rows to
/// exposure/symptom events and thresholds continuous context into binary
/// day-level factors.
class AnalysisService {
  const AnalysisService({this.config = const AnalysisConfig()});

  final AnalysisConfig config;

  AnalysisResult analyze({
    required List<MealWithIngredients> meals,
    required List<Symptom> symptoms,
    required List<ContextEntry> contextEntries,
  }) {
    final foodNames = <String, String>{};
    final exposures = <ExposureEvent>[];
    for (final entry in meals) {
      final foodKeys = <String>{};
      final tagKeys = <String>{};
      final keyWeights = <String, double>{};
      final confirmedTags = <String>{};
      for (final detail in entry.ingredients) {
        final key = detail.ingredient.canonicalName.toLowerCase();
        foodKeys.add(key);
        foodNames[key] = detail.ingredient.canonicalName;
        if (detail.confidence == IngredientConfidence.guessed) {
          keyWeights[key] = config.guessedIngredientWeight;
        }
        for (final tag in detail.ingredient.triggerTags) {
          tagKeys.add(tag.name);
          if (detail.confidence == IngredientConfidence.confirmed) {
            confirmedTags.add(tag.name);
          }
        }
      }
      // A tag counts at full weight if any confirmed ingredient carries it;
      // a tag carried only by guesses gets the guessed discount.
      for (final tag in tagKeys) {
        if (!confirmedTags.contains(tag)) {
          keyWeights[tag] = config.guessedIngredientWeight;
        }
      }
      exposures.add(ExposureEvent(
        timestamp: entry.meal.timestamp,
        foodKeys: foodKeys,
        tagKeys: tagKeys,
        keyWeights: keyWeights,
      ));
    }

    final tagNames = {
      for (final tag in TriggerTag.values) tag.name: tag.label,
    };

    return StatsEngine(config: config).analyze(
      meals: exposures,
      symptoms: [
        for (final s in symptoms)
          SymptomEvent(timestamp: s.timestamp, severity: s.severity),
      ],
      foodDisplayNames: foodNames,
      tagDisplayNames: tagNames,
      dayFactors: buildDayFactors(contextEntries),
    );
  }

  /// Thresholds each logged day's context into present/absent factors.
  /// The cutoffs are deliberately simple and documented in the UI.
  static List<DayFactorObservation> buildDayFactors(
      List<ContextEntry> entries) {
    final byDay = <DateTime, List<ContextEntry>>{};
    for (final entry in entries) {
      final day = DateTime(
          entry.timestamp.year, entry.timestamp.month, entry.timestamp.day);
      byDay.putIfAbsent(day, () => []).add(entry);
    }

    final observations = <DayFactorObservation>[];
    byDay.forEach((day, dayEntries) {
      final present = <({String key, String displayName})>[];
      for (final entry in dayEntries) {
        switch (entry.type) {
          case ContextType.sleepHours:
            if (entry.value < 6) {
              present.add((key: 'short-sleep', displayName: 'Short sleep'));
            }
          case ContextType.stress:
            if (entry.value >= 4) {
              present.add((key: 'high-stress', displayName: 'High stress'));
            }
          case ContextType.alcoholUnits:
            if (entry.value > 0) {
              present.add((key: 'alcohol-day', displayName: 'Alcohol'));
            }
          case ContextType.caffeineMg:
            if (entry.value >= 200) {
              present.add((key: 'high-caffeine', displayName: 'High caffeine'));
            }
          case ContextType.exerciseIntensity:
            if (entry.value >= 3) {
              present.add((key: 'hard-exercise', displayName: 'Hard exercise'));
            }
          case ContextType.skippedMeal:
            if (entry.value > 0) {
              present.add((key: 'skipped-meal', displayName: 'Skipped a meal'));
            }
          case ContextType.menstrualPhase:
            final phase = MenstrualPhase
                .values[entry.value.toInt().clamp(0, MenstrualPhase.values.length - 1)];
            present.add((
              key: 'phase-${phase.name}',
              displayName: '${phase.label} phase',
            ));
          case ContextType.illness:
            if (entry.value > 0) {
              present.add((key: 'illness', displayName: 'Illness'));
            }
          case ContextType.hydration:
            if (entry.value <= 1) {
              present.add((key: 'low-hydration', displayName: 'Low hydration'));
            }
        }
      }
      observations.add(
        DayFactorObservation(day: day, presentFactors: present),
      );
    });
    return observations;
  }
}
