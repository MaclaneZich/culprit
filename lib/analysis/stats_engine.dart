/// The stats engine. Pure Dart, fully deterministic, no I/O.
///
/// Method, in one paragraph: for every candidate (a food, or a trigger-class
/// tag) and every lag window, count the meals that contained the candidate
/// (weighted exposures) and how many of those were followed by at least one
/// symptom episode inside the window. Compare that rate against the base rate
/// of *all* meals in the same window — this is what makes the analysis
/// denominator-aware; a food eaten daily will trail symptoms often by chance
/// alone. Small samples are shrunk toward the base rate with a pseudo-count
/// so one bad night after a rare food cannot top the ranking. The output is
/// an association ("worth testing"), never a causal claim.
library;

import 'models.dart';

class StatsEngine {
  const StatsEngine({this.config = const AnalysisConfig()});

  final AnalysisConfig config;

  AnalysisResult analyze({
    required List<ExposureEvent> meals,
    required List<SymptomEvent> symptoms,
    Map<String, String> foodDisplayNames = const {},
    Map<String, String> tagDisplayNames = const {},
    List<DayFactorObservation> dayFactors = const [],
  }) {
    final sortedSymptoms = [...symptoms]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Precompute, per meal, which windows contained a symptom.
    final followedByWindow = <int, List<bool>>{};
    for (var i = 0; i < meals.length; i++) {
      followedByWindow[i] = [
        for (final window in config.windows)
          _hasSymptomIn(meals[i].timestamp, window, sortedSymptoms),
      ];
    }

    // Base rates over ALL meals: the denominator.
    final baseRates = <String, double>{};
    for (var w = 0; w < config.windows.length; w++) {
      double totalWeight = 0, followedWeight = 0;
      for (var i = 0; i < meals.length; i++) {
        totalWeight += meals[i].weight;
        if (followedByWindow[i]![w]) followedWeight += meals[i].weight;
      }
      baseRates[config.windows[w].label] =
          totalWeight == 0 ? 0 : followedWeight / totalWeight;
    }

    // Group meal indices by candidate key.
    final byFood = <String, List<int>>{};
    final byTag = <String, List<int>>{};
    for (var i = 0; i < meals.length; i++) {
      for (final key in meals[i].foodKeys) {
        byFood.putIfAbsent(key, () => []).add(i);
      }
      for (final key in meals[i].tagKeys) {
        byTag.putIfAbsent(key, () => []).add(i);
      }
    }

    final candidates = <CandidateScore>[
      ..._scoreCandidates(
          byFood, meals, followedByWindow, baseRates, CandidateKind.food,
          foodDisplayNames),
      ..._scoreCandidates(
          byTag, meals, followedByWindow, baseRates, CandidateKind.tag,
          tagDisplayNames),
    ]..sort((a, b) => b.score.compareTo(a.score));

    final completeness = _completeness(meals, symptoms, dayFactors);

    return AnalysisResult(
      candidates: candidates,
      dayFactors: _scoreDayFactors(dayFactors, symptoms),
      completeness: completeness,
      baseRates: baseRates,
      config: config,
    );
  }

  bool _hasSymptomIn(
      DateTime mealTime, LagWindow window, List<SymptomEvent> sorted) {
    for (final symptom in sorted) {
      final lag = symptom.timestamp.difference(mealTime);
      if (lag < window.start) continue;
      if (lag >= window.end) break; // sorted ascending: nothing later fits
      return true;
    }
    return false;
  }

  List<CandidateScore> _scoreCandidates(
    Map<String, List<int>> byKey,
    List<ExposureEvent> meals,
    Map<int, List<bool>> followedByWindow,
    Map<String, double> baseRates,
    CandidateKind kind,
    Map<String, String> displayNames,
  ) {
    final scores = <CandidateScore>[];
    byKey.forEach((key, mealIndexes) {
      double totalWeight = 0;
      for (final i in mealIndexes) {
        totalWeight += meals[i].weightFor(key, kind);
      }
      if (totalWeight < config.minExposures) return;

      final windows = <WindowStats>[];
      for (var w = 0; w < config.windows.length; w++) {
        final window = config.windows[w];
        final baseRate = baseRates[window.label]!;
        double followedWeight = 0;
        for (final i in mealIndexes) {
          if (followedByWindow[i]![w]) {
            followedWeight += meals[i].weightFor(key, kind);
          }
        }
        windows.add(WindowStats(
          window: window,
          exposures: totalWeight,
          followed: followedWeight,
          baseRate: baseRate,
          shrunkRate: _shrink(followedWeight, totalWeight, baseRate),
        ));
      }

      final best = windows
          .map((s) => s.lift)
          .reduce((a, b) => a > b ? a : b);
      scores.add(CandidateScore(
        key: key,
        displayName: displayNames[key] ?? key,
        kind: kind,
        totalExposures: totalWeight,
        windows: windows,
        score: best,
      ));
    });
    return scores;
  }

  /// Empirical-Bayes shrinkage: acts as if the candidate came with
  /// [AnalysisConfig.shrinkagePseudoCount] extra meals that behaved exactly
  /// like the average meal.
  double _shrink(double followed, double exposures, double baseRate) {
    final m = config.shrinkagePseudoCount;
    if (exposures + m == 0) return 0;
    return (followed + m * baseRate) / (exposures + m);
  }

  List<DayFactorScore> _scoreDayFactors(
    List<DayFactorObservation> observations,
    List<SymptomEvent> symptoms,
  ) {
    if (observations.isEmpty) return const [];

    final symptomaticDays = <DateTime>{
      for (final s in symptoms)
        DateTime(s.timestamp.year, s.timestamp.month, s.timestamp.day),
    };

    final allDays = <DateTime>{for (final o in observations) o.day};
    if (allDays.isEmpty) return const [];
    final symptomaticLoggedDays =
        allDays.where(symptomaticDays.contains).length;
    final baseRate = symptomaticLoggedDays / allDays.length;

    final daysByFactor = <String, Set<DateTime>>{};
    final namesByFactor = <String, String>{};
    for (final o in observations) {
      for (final factor in o.presentFactors) {
        daysByFactor.putIfAbsent(factor.key, () => {}).add(o.day);
        namesByFactor[factor.key] = factor.displayName;
      }
    }

    final scores = <DayFactorScore>[];
    daysByFactor.forEach((key, days) {
      if (days.length < config.minExposures) return;
      final symptomatic = days.where(symptomaticDays.contains).length;
      scores.add(DayFactorScore(
        key: key,
        displayName: namesByFactor[key] ?? key,
        factorDays: days.length,
        symptomaticFactorDays: symptomatic,
        baseRate: baseRate,
        shrunkRate:
            _shrink(symptomatic.toDouble(), days.length.toDouble(), baseRate),
      ));
    });
    return scores..sort((a, b) => b.lift.compareTo(a.lift));
  }

  CompletenessReport _completeness(
    List<ExposureEvent> meals,
    List<SymptomEvent> symptoms,
    List<DayFactorObservation> dayFactors,
  ) {
    DateTime? first, last;
    void extend(DateTime t) {
      if (first == null || t.isBefore(first!)) first = t;
      if (last == null || t.isAfter(last!)) last = t;
    }

    final mealsPerDay = <DateTime, int>{};
    for (final meal in meals) {
      extend(meal.timestamp);
      final day = DateTime(
          meal.timestamp.year, meal.timestamp.month, meal.timestamp.day);
      mealsPerDay[day] = (mealsPerDay[day] ?? 0) + 1;
    }
    for (final s in symptoms) {
      extend(s.timestamp);
    }
    final contextDays = <DateTime>{
      for (final o in dayFactors)
        if (o.hasCheckIn) o.day,
    };

    return CompletenessReport(
      firstLog: first,
      lastLog: last,
      loggedDays: mealsPerDay.length,
      daysWithTwoPlusMeals:
          mealsPerDay.values.where((count) => count >= 2).length,
      daysWithContext: contextDays.length,
      totalMeals: meals.length,
      totalSymptoms: symptoms.length,
    );
  }
}

/// One logged day's non-food factors, already thresholded into binary
/// presence (e.g. sleep 5.5h → "short-sleep" present).
class DayFactorObservation {
  const DayFactorObservation({
    required this.day,
    required this.presentFactors,
    this.hasCheckIn = true,
  });

  final DateTime day;
  final List<({String key, String displayName})> presentFactors;

  /// Whether the user actually did a context check-in this day (drives the
  /// completeness report; a day can be logged with zero factors present).
  final bool hasCheckIn;
}
