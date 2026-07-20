import 'package:culprit/analysis/models.dart';
import 'package:culprit/analysis/stats_engine.dart';
import 'package:flutter_test/flutter_test.dart';

/// The stats engine is the honesty core of Culprit. These tests pin the
/// denominator math with hand-computed values on synthetic data.
void main() {
  final day0 = DateTime(2026, 1, 1);
  DateTime at(int day, int hour, [int minute = 0]) =>
      day0.add(Duration(days: day, hours: hour, minutes: minute));

  ExposureEvent meal(DateTime t, List<String> foods,
          {List<String> tags = const [], double weight = 1.0}) =>
      ExposureEvent(
        timestamp: t,
        foodKeys: foods.toSet(),
        tagKeys: tags.toSet(),
        weight: weight,
      );

  SymptomEvent symptom(DateTime t, [int severity = 3]) =>
      SymptomEvent(timestamp: t, severity: severity);

  group('base rates (the denominator)', () {
    test('are computed over ALL meals per window', () {
      // 4 meals; one symptom 2h after the first meal.
      final meals = [
        meal(at(0, 8), ['rice']),
        meal(at(0, 14), ['rice']),
        meal(at(1, 8), ['rice']),
        meal(at(1, 14), ['rice']),
      ];
      final symptoms = [symptom(at(0, 10))];

      final result = const StatsEngine().analyze(
        meals: meals,
        symptoms: symptoms,
      );

      // Only the 08:00 day-0 meal has the symptom in its 1–4 h window.
      expect(result.baseRates['1–4 h'], closeTo(0.25, 1e-9));
      // No meal has a symptom 0–1 h after it.
      expect(result.baseRates['0–1 h'], closeTo(0.0, 1e-9));
    });

    test('shrunk rate and lift follow the documented formula', () {
      // Hand-computed: onion in 2 of 4 meals, followed once in 1–4 h.
      // base(1–4) = 1/4. shrunk = (1 + 3·0.25) / (2 + 3) = 0.35. lift = 1.4.
      final meals = [
        meal(at(0, 8), ['onion']),
        meal(at(0, 14), ['rice']),
        meal(at(1, 8), ['onion']),
        meal(at(1, 14), ['rice']),
      ];
      final symptoms = [symptom(at(0, 10))];

      final result = StatsEngine(
        config: const AnalysisConfig(minExposures: 1, minSymptoms: 1),
      ).analyze(meals: meals, symptoms: symptoms);

      final onion =
          result.candidates.singleWhere((c) => c.key == 'onion');
      final window =
          onion.windows.singleWhere((w) => w.window.label == '1–4 h');
      expect(window.exposures, closeTo(2, 1e-9));
      expect(window.followed, closeTo(1, 1e-9));
      expect(window.shrunkRate, closeTo(0.35, 1e-9));
      expect(window.lift, closeTo(1.4, 1e-9));
    });
  });

  group('a real trigger beats a frequently-eaten innocent food', () {
    // 30 days. Rice every morning. Onion every 3rd day at 13:00; on 8 of
    // those 10 days a symptom follows at 14:30 (1.5 h after onion, 6.5 h
    // after rice). Rice is eaten 3× as often as onion — a naive
    // count-the-attack-meals app would blame rice.
    final meals = <ExposureEvent>[];
    final symptoms = <SymptomEvent>[];
    for (var d = 0; d < 30; d++) {
      meals.add(meal(at(d, 8), ['rice']));
      if (d % 3 == 0) meals.add(meal(at(d, 13), ['onion']));
    }
    for (var i = 0; i < 8; i++) {
      symptoms.add(symptom(at(i * 3, 14, 30)));
    }

    final result =
        const StatsEngine().analyze(meals: meals, symptoms: symptoms);

    test('onion ranks first, with the 1–4 h window as best evidence', () {
      expect(result.candidates.first.key, 'onion');
      expect(result.candidates.first.bestWindow.window.label, '1–4 h');
      // Hand-computed: base(1–4) = 8/40 = 0.2;
      // onion shrunk = (8 + 3·0.2)/(10 + 3) = 0.6615…; lift ≈ 3.31.
      expect(result.candidates.first.score, closeTo(8.6 / 13 / 0.2, 1e-9));
    });

    test('rice stays near base rate despite trailing every symptom', () {
      final rice = result.candidates.singleWhere((c) => c.key == 'rice');
      // Rice is followed in 4–12 h on all 8 symptom days, but so is the
      // average meal: lift stays modest.
      expect(rice.score, lessThan(1.5));
      expect(result.candidates.first.score, greaterThan(rice.score * 2));
    });
  });

  group('small-sample penalty', () {
    test('one perfect coincidence cannot outrank steady evidence', () {
      final meals = <ExposureEvent>[];
      final symptoms = <SymptomEvent>[];
      // Steady trigger: eaten 10 times, followed 8 times.
      for (var d = 0; d < 10; d++) {
        meals.add(meal(at(d, 12), ['gluten pasta']));
        if (d < 8) symptoms.add(symptom(at(d, 14)));
      }
      // Rare food: eaten once, followed once (observed rate 1.0).
      meals.add(meal(at(20, 12), ['durian']));
      symptoms.add(symptom(at(20, 14)));
      // Background meals so base rate isn't dominated by the trigger.
      for (var d = 0; d < 30; d++) {
        meals.add(meal(at(d, 18), ['rice']));
      }

      final result = StatsEngine(
        config: const AnalysisConfig(minExposures: 1),
      ).analyze(meals: meals, symptoms: symptoms);

      final pasta =
          result.candidates.singleWhere((c) => c.key == 'gluten pasta');
      final durian = result.candidates.singleWhere((c) => c.key == 'durian');
      expect(durian.windows.every((w) => w.observedRate <= 1.0), isTrue);
      expect(pasta.score, greaterThan(durian.score));
    });

    test('candidates under minExposures are not ranked at all', () {
      final meals = [
        meal(at(0, 8), ['once-food']),
        meal(at(1, 8), ['rice']),
        meal(at(2, 8), ['rice']),
        meal(at(3, 8), ['rice']),
      ];
      final result = const StatsEngine() // default minExposures = 3
          .analyze(meals: meals, symptoms: [symptom(at(0, 9, 30))]);
      expect(result.candidates.any((c) => c.key == 'once-food'), isFalse);
      expect(result.candidates.any((c) => c.key == 'rice'), isTrue);
    });
  });

  group('lag-window boundaries', () {
    test('symptom exactly at window start counts; at window end does not', () {
      final meals = [meal(at(0, 12), ['x'])];
      final engine = StatsEngine(
        config: const AnalysisConfig(minExposures: 1),
      );

      final atStart = engine.analyze(
        meals: meals,
        symptoms: [symptom(at(0, 13))], // exactly +1 h
      );
      final x = atStart.candidates.single;
      expect(
        x.windows.singleWhere((w) => w.window.label == '1–4 h').followed,
        closeTo(1, 1e-9),
      );
      expect(
        x.windows.singleWhere((w) => w.window.label == '0–1 h').followed,
        closeTo(0, 1e-9),
      );

      final atEnd = engine.analyze(
        meals: meals,
        symptoms: [symptom(at(1, 0))], // exactly +12 h
      );
      expect(
        atEnd.candidates.single.windows
            .singleWhere((w) => w.window.label == '4–12 h')
            .followed,
        closeTo(0, 1e-9),
      );
    });

    test('symptoms before the meal never count', () {
      final meals = [meal(at(0, 12), ['x'])];
      final result = StatsEngine(
        config: const AnalysisConfig(minExposures: 1),
      ).analyze(meals: meals, symptoms: [symptom(at(0, 10))]);
      final x = result.candidates.single;
      expect(x.windows.every((w) => w.followed == 0), isTrue);
    });
  });

  group('tag-level rollup', () {
    test('a class accumulates evidence its member foods cannot', () {
      final meals = [
        meal(at(0, 12), ['milk'], tags: ['lactose', 'dairy']),
        meal(at(2, 12), ['ice cream'], tags: ['lactose', 'dairy']),
        meal(at(4, 12), ['soft cheese'], tags: ['lactose', 'dairy']),
        meal(at(6, 12), ['yogurt'], tags: ['lactose', 'dairy']),
        for (var d = 0; d < 8; d++) meal(at(d, 18), ['rice']),
      ];
      final symptoms = [
        symptom(at(0, 14)),
        symptom(at(2, 14)),
        symptom(at(4, 14)),
      ];

      final result =
          const StatsEngine().analyze(meals: meals, symptoms: symptoms);

      // Each dairy food was eaten once → below minExposures, not ranked.
      expect(result.candidates.any((c) => c.key == 'milk'), isFalse);
      // The tag has 4 weighted exposures and surfaces the class signal.
      final lactose = result.candidates
          .singleWhere((c) => c.key == 'lactose' && c.kind == CandidateKind.tag);
      expect(lactose.totalExposures, closeTo(4, 1e-9));
      final best = lactose.bestWindow;
      expect(best.window.label, '1–4 h');
      expect(best.followed, closeTo(3, 1e-9));
      expect(result.candidates.first.kind, CandidateKind.tag);
    });
  });

  group('guessed-ingredient weighting', () {
    test('unconfirmed exposures count at reduced weight', () {
      final meals = [
        meal(at(0, 12), ['x'], weight: 0.5),
        meal(at(1, 12), ['x'], weight: 0.5),
        meal(at(2, 12), ['x'], weight: 1.0),
      ];
      final result = StatsEngine(
        config: const AnalysisConfig(minExposures: 1),
      ).analyze(meals: meals, symptoms: [symptom(at(2, 13))]);
      final x = result.candidates.single;
      expect(x.totalExposures, closeTo(2.0, 1e-9));
      final window =
          x.windows.singleWhere((w) => w.window.label == '1–4 h');
      expect(window.followed, closeTo(1.0, 1e-9));
    });

    test('a guessed ingredient is discounted without dragging down the rest '
        'of its meal', () {
      final meals = [
        ExposureEvent(
          timestamp: at(0, 12),
          foodKeys: const {'rice', 'onion'},
          tagKeys: const {},
          keyWeights: const {'onion': 0.5}, // onion guessed, rice confirmed
        ),
        meal(at(1, 12), ['rice', 'onion']),
      ];
      final result = StatsEngine(
        config: const AnalysisConfig(minExposures: 1),
      ).analyze(meals: meals, symptoms: [symptom(at(0, 13, 30))]);

      expect(
        result.candidates.singleWhere((c) => c.key == 'rice').totalExposures,
        closeTo(2.0, 1e-9),
      );
      final onion =
          result.candidates.singleWhere((c) => c.key == 'onion');
      expect(onion.totalExposures, closeTo(1.5, 1e-9));
      expect(
        onion.windows
            .singleWhere((w) => w.window.label == '1–4 h')
            .followed,
        closeTo(0.5, 1e-9),
      );
    });
  });

  group('day-level factors (gut-brain axis is first-class)', () {
    test('high-stress days show lift against the logged-day base rate', () {
      DateTime day(int d) => DateTime(2026, 1, 1 + d);
      final observations = <DayFactorObservation>[
        // 6 high-stress days, 5 of them symptomatic.
        for (var d = 0; d < 6; d++)
          DayFactorObservation(
            day: day(d),
            presentFactors: [(key: 'high-stress', displayName: 'High stress')],
          ),
        // 6 calm days, 1 symptomatic.
        for (var d = 6; d < 12; d++)
          DayFactorObservation(day: day(d), presentFactors: const []),
      ];
      final symptoms = [
        for (var d = 0; d < 5; d++) symptom(day(d).add(const Duration(hours: 15))),
        symptom(day(7).add(const Duration(hours: 15))),
      ];

      final result = const StatsEngine().analyze(
        meals: [meal(day(0).add(const Duration(hours: 8)), ['rice'])],
        symptoms: symptoms,
        dayFactors: observations,
      );

      final stress = result.dayFactors.single;
      // base = 6 symptomatic / 12 logged days = 0.5.
      expect(stress.baseRate, closeTo(0.5, 1e-9));
      expect(stress.observedRate, closeTo(5 / 6, 1e-9));
      // shrunk = (5 + 3·0.5)/(6 + 3) = 0.7222…; lift ≈ 1.44.
      expect(stress.shrunkRate, closeTo(6.5 / 9, 1e-9));
      expect(stress.lift, greaterThan(1.4));
    });

    test('factors on too few days are not ranked', () {
      final result = const StatsEngine().analyze(
        meals: const [],
        symptoms: [symptom(DateTime(2026, 1, 1, 12))],
        dayFactors: [
          DayFactorObservation(
            day: DateTime(2026, 1, 1),
            presentFactors: [(key: 'travel', displayName: 'Travel')],
          ),
        ],
      );
      expect(result.dayFactors, isEmpty);
    });
  });

  group('completeness report', () {
    test('counts span, coverage, and totals', () {
      final meals = [
        meal(at(0, 8), ['rice']),
        meal(at(0, 13), ['rice']),
        meal(at(2, 8), ['rice']),
      ];
      final result = const StatsEngine().analyze(
        meals: meals,
        symptoms: [symptom(at(1, 12))],
        dayFactors: [
          DayFactorObservation(day: at(0, 0), presentFactors: const []),
        ],
      );

      final report = result.completeness;
      expect(report.spanDays, 3);
      expect(report.loggedDays, 2);
      expect(report.daysWithTwoPlusMeals, 1);
      expect(report.daysWithContext, 1);
      expect(report.totalMeals, 3);
      expect(report.totalSymptoms, 1);
      expect(report.mealCoverage, closeTo(1 / 3, 1e-9));
    });
  });

  group('not-enough-data gating', () {
    test('ranking is withheld below the symptom minimum', () {
      final result = const StatsEngine().analyze(
        meals: [meal(at(0, 8), ['rice'])],
        symptoms: [symptom(at(0, 10))],
      );
      expect(result.hasEnoughData, isFalse);
    });

    test('no symptoms at all → zero base rates, no crash', () {
      final result = const StatsEngine().analyze(
        meals: [
          for (var d = 0; d < 5; d++) meal(at(d, 8), ['rice']),
        ],
        symptoms: const [],
      );
      expect(result.hasEnoughData, isFalse);
      expect(result.baseRates.values.every((r) => r == 0), isTrue);
      final rice = result.candidates.singleWhere((c) => c.key == 'rice');
      expect(rice.score, 0);
    });
  });
}
