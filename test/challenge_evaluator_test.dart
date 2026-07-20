import 'package:culprit/analysis/challenge_evaluator.dart';
import 'package:culprit/domain/enums.dart';
import 'package:flutter_test/flutter_test.dart';

ChallengeDayLog day(ChallengeDayKind kind,
        {bool? adhered = true, int? severity}) =>
    ChallengeDayLog(kind: kind, adhered: adhered, maxSeverity: severity);

void main() {
  const evaluator = ChallengeEvaluator();

  group('challenge readout', () {
    test('clear on/off contrast reads as reproduced', () {
      final readout = evaluator.evaluate([
        day(ChallengeDayKind.washout, severity: 0),
        day(ChallengeDayKind.washout, severity: 0),
        day(ChallengeDayKind.on, severity: 3),
        day(ChallengeDayKind.on, severity: 4),
        day(ChallengeDayKind.off, severity: 0),
        day(ChallengeDayKind.off, severity: 1),
      ]);
      expect(readout.outcome, ChallengeOutcome.reproduced);
      expect(readout.onSymptomaticRate, 1.0);
      expect(readout.offSymptomaticRate, 0.0);
    });

    test('no contrast reads as did-not-reproduce', () {
      final readout = evaluator.evaluate([
        day(ChallengeDayKind.washout, severity: 2),
        day(ChallengeDayKind.on, severity: 2),
        day(ChallengeDayKind.on, severity: 0),
        day(ChallengeDayKind.off, severity: 2),
        day(ChallengeDayKind.off, severity: 0),
      ]);
      expect(readout.outcome, ChallengeOutcome.notReproduced);
    });

    test('a middling contrast reads as inconclusive', () {
      // on: 2/3 symptomatic (0.67); off: 1/3 (0.33). Difference 0.33 sits
      // between the clear margin (0.15) and the reproduced margin (0.5).
      final readout = evaluator.evaluate([
        day(ChallengeDayKind.on, severity: 3),
        day(ChallengeDayKind.on, severity: 2),
        day(ChallengeDayKind.on, severity: 0),
        day(ChallengeDayKind.off, severity: 2),
        day(ChallengeDayKind.off, severity: 0),
        day(ChallengeDayKind.off, severity: 1),
      ]);
      expect(readout.outcome, ChallengeOutcome.inconclusive);
    });

    test('too few logged days on either side is inconclusive regardless '
        'of rates', () {
      final readout = evaluator.evaluate([
        day(ChallengeDayKind.on, severity: 5),
        day(ChallengeDayKind.off, severity: 0),
        day(ChallengeDayKind.off, severity: 0),
      ]);
      expect(readout.outcome, ChallengeOutcome.inconclusive);
      expect(readout.onDaysLogged, 1);
    });

    test('non-adherent and unlogged days carry no evidence', () {
      final readout = evaluator.evaluate([
        // Ate the candidate on an off day: excluded.
        day(ChallengeDayKind.off, adhered: false, severity: 4),
        // Skipped it on an on day: excluded.
        day(ChallengeDayKind.on, adhered: false, severity: 0),
        // Never logged: excluded.
        day(ChallengeDayKind.on, adhered: null, severity: null),
        day(ChallengeDayKind.on, severity: 3),
        day(ChallengeDayKind.on, severity: 3),
        day(ChallengeDayKind.off, severity: 0),
        day(ChallengeDayKind.off, severity: 0),
      ]);
      expect(readout.onDaysLogged, 2);
      expect(readout.offDaysLogged, 2);
      expect(readout.outcome, ChallengeOutcome.reproduced);
    });

    test('washout days count toward the off arm', () {
      final readout = evaluator.evaluate([
        day(ChallengeDayKind.washout, severity: 0),
        day(ChallengeDayKind.washout, severity: 0),
        day(ChallengeDayKind.on, severity: 4),
        day(ChallengeDayKind.on, severity: 3),
      ]);
      expect(readout.offDaysLogged, 2);
      expect(readout.outcome, ChallengeOutcome.reproduced);
    });
  });

  group('schedule generation', () {
    test('washout precedes alternating on/off cycles, dates contiguous', () {
      final schedule = buildSchedule(
        startDate: DateTime(2026, 7, 21),
        washoutDays: 3,
        onDaysPerCycle: 2,
        offDaysPerCycle: 2,
        cycles: 2,
      );
      expect(schedule.length, 3 + 4 * 2);
      expect(
        schedule.map((d) => d.kind).toList(),
        [
          ChallengeDayKind.washout,
          ChallengeDayKind.washout,
          ChallengeDayKind.washout,
          ChallengeDayKind.on,
          ChallengeDayKind.on,
          ChallengeDayKind.off,
          ChallengeDayKind.off,
          ChallengeDayKind.on,
          ChallengeDayKind.on,
          ChallengeDayKind.off,
          ChallengeDayKind.off,
        ],
      );
      for (var i = 0; i < schedule.length; i++) {
        expect(schedule[i].dayIndex, i);
        expect(schedule[i].date, DateTime(2026, 7, 21 + i));
      }
    });
  });
}
