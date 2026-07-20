/// Reads out a reintroduction challenge. Pure Dart, deterministic, and
/// deliberately transparent: the rule is simple enough to explain on the
/// result screen, because an answer the user can't audit isn't an answer.
library;

import '../domain/enums.dart';

class ChallengeDayLog {
  const ChallengeDayLog({
    required this.kind,
    required this.adhered,
    required this.maxSeverity,
  });

  final ChallengeDayKind kind;

  /// Whether the user followed the day's instruction. Null = not logged.
  final bool? adhered;

  /// Worst symptom severity that day (0 = symptom-free). Null = not logged.
  final int? maxSeverity;
}

class ChallengeReadout {
  const ChallengeReadout({
    required this.outcome,
    required this.onDaysLogged,
    required this.offDaysLogged,
    required this.onSymptomaticRate,
    required this.offSymptomaticRate,
    required this.explanation,
  });

  final ChallengeOutcome outcome;
  final int onDaysLogged;
  final int offDaysLogged;
  final double onSymptomaticRate;
  final double offSymptomaticRate;
  final String explanation;
}

class ChallengeEvaluator {
  const ChallengeEvaluator({
    this.symptomaticThreshold = 2,
    this.minLoggedDaysPerArm = 2,
    this.reproducedMargin = 0.5,
    this.clearMargin = 0.15,
  });

  /// A day counts as symptomatic at this severity or above.
  final int symptomaticThreshold;

  /// Below this many adherent, logged days in either arm the result is
  /// inconclusive no matter what the rates say.
  final int minLoggedDaysPerArm;

  /// On-rate must exceed off-rate by at least this much to call it
  /// reproduced.
  final double reproducedMargin;

  /// On-rate within this much of off-rate reads as did-not-reproduce.
  final double clearMargin;

  ChallengeReadout evaluate(List<ChallengeDayLog> days) {
    // Only adherent, logged days carry evidence. A day where the user ate
    // the candidate on an "off" day (or skipped it on an "on" day) tells us
    // nothing about the schedule's contrast.
    final onDays = days
        .where((d) =>
            d.kind == ChallengeDayKind.on &&
            d.adhered == true &&
            d.maxSeverity != null)
        .toList();
    final offDays = days
        .where((d) =>
            d.kind != ChallengeDayKind.on &&
            d.adhered == true &&
            d.maxSeverity != null)
        .toList();

    double symptomaticRate(List<ChallengeDayLog> arm) => arm.isEmpty
        ? 0
        : arm.where((d) => d.maxSeverity! >= symptomaticThreshold).length /
            arm.length;

    final onRate = symptomaticRate(onDays);
    final offRate = symptomaticRate(offDays);

    if (onDays.length < minLoggedDaysPerArm ||
        offDays.length < minLoggedDaysPerArm) {
      return ChallengeReadout(
        outcome: ChallengeOutcome.inconclusive,
        onDaysLogged: onDays.length,
        offDaysLogged: offDays.length,
        onSymptomaticRate: onRate,
        offSymptomaticRate: offRate,
        explanation:
            'Not enough adherent, logged days on both sides of the schedule '
            'to compare (${onDays.length} on-days, ${offDays.length} '
            'off/washout days; $minLoggedDaysPerArm+ each needed).',
      );
    }

    final ChallengeOutcome outcome;
    final String explanation;
    if (onRate - offRate >= reproducedMargin) {
      outcome = ChallengeOutcome.reproduced;
      explanation =
          'Symptoms followed ${(onRate * 100).round()}% of on-days versus '
          '${(offRate * 100).round()}% of off/washout days — the candidate '
          'reproduced the pattern under a controlled schedule. Worth showing '
          'your gastroenterologist.';
    } else if (onRate - offRate <= clearMargin) {
      outcome = ChallengeOutcome.notReproduced;
      explanation =
          'On-days (${(onRate * 100).round()}% symptomatic) looked like '
          'off/washout days (${(offRate * 100).round()}%). This candidate '
          'did not reproduce symptoms under a controlled schedule.';
    } else {
      outcome = ChallengeOutcome.inconclusive;
      explanation =
          'On-days were somewhat worse (${(onRate * 100).round()}% vs '
          '${(offRate * 100).round()}%) but not clearly enough to call. '
          'A longer schedule or another round would help.';
    }

    return ChallengeReadout(
      outcome: outcome,
      onDaysLogged: onDays.length,
      offDaysLogged: offDays.length,
      onSymptomaticRate: onRate,
      offSymptomaticRate: offRate,
      explanation: explanation,
    );
  }
}

/// Generates the reintroduction schedule: a baseline washout, then
/// alternating on/off blocks.
List<({int dayIndex, DateTime date, ChallengeDayKind kind})> buildSchedule({
  required DateTime startDate,
  int washoutDays = 3,
  int onDaysPerCycle = 2,
  int offDaysPerCycle = 2,
  int cycles = 2,
}) {
  final schedule = <({int dayIndex, DateTime date, ChallengeDayKind kind})>[];
  var index = 0;
  DateTime dateAt(int i) =>
      DateTime(startDate.year, startDate.month, startDate.day + i);

  for (var i = 0; i < washoutDays; i++) {
    schedule.add((dayIndex: index, date: dateAt(index), kind: ChallengeDayKind.washout));
    index++;
  }
  for (var cycle = 0; cycle < cycles; cycle++) {
    for (var i = 0; i < onDaysPerCycle; i++) {
      schedule.add((dayIndex: index, date: dateAt(index), kind: ChallengeDayKind.on));
      index++;
    }
    for (var i = 0; i < offDaysPerCycle; i++) {
      schedule.add((dayIndex: index, date: dateAt(index), kind: ChallengeDayKind.off));
      index++;
    }
  }
  return schedule;
}
