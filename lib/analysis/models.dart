/// Inputs and outputs of the stats engine. Pure Dart — no Flutter imports —
/// so the whole engine runs under plain `dart test`.
///
/// Everything here is an *association*, not a causal estimate. The engine
/// compares `rate(symptom | ate candidate)` against the same-window base rate
/// across all meals, which is only meaningful when the user logs every meal.
library;

/// A meal the user logged, reduced to what analysis needs: when it happened
/// and which candidate keys (foods and trigger-class tags) it exposes.
class ExposureEvent {
  const ExposureEvent({
    required this.timestamp,
    required this.foodKeys,
    required this.tagKeys,
    this.weight = 1.0,
    this.keyWeights = const {},
  });

  final DateTime timestamp;

  /// Canonical ingredient names, lowercased.
  final Set<String> foodKeys;

  /// Trigger-class tag names ([TriggerTag.name]).
  final Set<String> tagKeys;

  /// Weight of this meal in base-rate denominators. Normally 1.0.
  final double weight;

  /// Per-candidate overrides: a vision-guessed, unconfirmed ingredient
  /// counts at reduced weight without discounting the rest of the meal.
  final Map<String, double> keyWeights;

  double weightFor(String key) => weight * (keyWeights[key] ?? 1.0);
}

class SymptomEvent {
  const SymptomEvent({required this.timestamp, required this.severity});

  final DateTime timestamp;
  final int severity;
}

/// A half-open lag window after a meal: [start, end).
class LagWindow {
  const LagWindow(this.label, this.start, this.end);

  final String label;
  final Duration start;
  final Duration end;

  bool contains(Duration lag) => lag >= start && lag < end;

  static const defaults = [
    LagWindow('0–1 h', Duration.zero, Duration(hours: 1)),
    LagWindow('1–4 h', Duration(hours: 1), Duration(hours: 4)),
    LagWindow('4–12 h', Duration(hours: 4), Duration(hours: 12)),
  ];
}

enum CandidateKind { food, tag }

/// Per-window evidence for one candidate.
class WindowStats {
  const WindowStats({
    required this.window,
    required this.exposures,
    required this.followed,
    required this.baseRate,
    required this.shrunkRate,
  });

  final LagWindow window;

  /// Weighted count of meals containing the candidate.
  final double exposures;

  /// Weighted count of those meals followed by ≥1 symptom inside the window.
  final double followed;

  /// P(≥1 symptom in this window | any logged meal).
  final double baseRate;

  /// Empirical-Bayes rate: shrunk toward [baseRate] by the pseudo-count
  /// penalty, so a 1-out-of-1 coincidence can't outrank steady evidence.
  final double shrunkRate;

  double get observedRate => exposures == 0 ? 0 : followed / exposures;

  /// Association score for this window: shrunk rate as a multiple of the
  /// base rate. 1.0 = indistinguishable from any random meal.
  double get lift => baseRate <= 0 ? 0 : shrunkRate / baseRate;
}

enum EvidenceStrength { limited, moderate, strong }

class CandidateScore {
  const CandidateScore({
    required this.key,
    required this.displayName,
    required this.kind,
    required this.totalExposures,
    required this.windows,
    required this.score,
  });

  final String key;
  final String displayName;
  final CandidateKind kind;
  final double totalExposures;
  final List<WindowStats> windows;

  /// Max shrunk lift across windows. Ranking key.
  final double score;

  WindowStats get bestWindow =>
      windows.reduce((a, b) => a.lift >= b.lift ? a : b);

  EvidenceStrength get strength => totalExposures >= 10
      ? EvidenceStrength.strong
      : totalExposures >= 5
          ? EvidenceStrength.moderate
          : EvidenceStrength.limited;
}

/// A non-food, day-level factor (short sleep, high stress, alcohol...).
class DayFactorScore {
  const DayFactorScore({
    required this.key,
    required this.displayName,
    required this.factorDays,
    required this.symptomaticFactorDays,
    required this.baseRate,
    required this.shrunkRate,
  });

  final String key;
  final String displayName;

  /// Logged days on which the factor was present.
  final int factorDays;

  /// Of those, days with ≥1 symptom episode.
  final int symptomaticFactorDays;

  /// P(symptomatic | any logged day).
  final double baseRate;
  final double shrunkRate;

  double get observedRate =>
      factorDays == 0 ? 0 : symptomaticFactorDays / factorDays;

  double get lift => baseRate <= 0 ? 0 : shrunkRate / baseRate;

  EvidenceStrength get strength => factorDays >= 10
      ? EvidenceStrength.strong
      : factorDays >= 5
          ? EvidenceStrength.moderate
          : EvidenceStrength.limited;
}

/// The denominator is everything: how complete the log actually is, shown to
/// the user so they know how much to trust the ranking.
class CompletenessReport {
  const CompletenessReport({
    required this.firstLog,
    required this.lastLog,
    required this.loggedDays,
    required this.daysWithTwoPlusMeals,
    required this.daysWithContext,
    required this.totalMeals,
    required this.totalSymptoms,
  });

  final DateTime? firstLog;
  final DateTime? lastLog;
  final int loggedDays;
  final int daysWithTwoPlusMeals;
  final int daysWithContext;
  final int totalMeals;
  final int totalSymptoms;

  int get spanDays => firstLog == null || lastLog == null
      ? 0
      : lastLog!.difference(firstLog!).inDays + 1;

  double get mealCoverage =>
      spanDays == 0 ? 0 : daysWithTwoPlusMeals / spanDays;
  double get contextCoverage => spanDays == 0 ? 0 : daysWithContext / spanDays;
}

class AnalysisConfig {
  const AnalysisConfig({
    this.windows = LagWindow.defaults,
    this.shrinkagePseudoCount = 3.0,
    this.minExposures = 3.0,
    this.minSymptoms = 3,
    this.guessedIngredientWeight = 0.5,
  });

  final List<LagWindow> windows;

  /// Pseudo-observations pulled toward the base rate — the small-sample
  /// penalty. Higher = more conservative on rarely-eaten foods.
  final double shrinkagePseudoCount;

  /// Candidates seen fewer (weighted) times than this are not ranked.
  final double minExposures;

  /// Below this many total episodes the ranking is withheld entirely.
  final int minSymptoms;

  /// Exposure weight for vision-guessed, unconfirmed ingredients.
  final double guessedIngredientWeight;
}

class AnalysisResult {
  const AnalysisResult({
    required this.candidates,
    required this.dayFactors,
    required this.completeness,
    required this.baseRates,
    required this.config,
  });

  /// Ranked food + tag candidates, highest score first.
  final List<CandidateScore> candidates;

  /// Ranked day-level factors, highest lift first.
  final List<DayFactorScore> dayFactors;

  final CompletenessReport completeness;

  /// Per-window base rates across all meals, keyed by window label.
  final Map<String, double> baseRates;

  final AnalysisConfig config;

  bool get hasEnoughData =>
      completeness.totalSymptoms >= config.minSymptoms &&
      completeness.totalMeals > 0;
}
