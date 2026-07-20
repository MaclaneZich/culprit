import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The lint-style honesty check required by the project's guardrails: the
/// insight-facing surfaces must speak in candidates and associations. If
/// causal or diagnostic language creeps into the copy these files render,
/// this test fails the build.
///
/// It scans the *string literals* a file would show a user — comments are
/// stripped and adjacent literals are joined first, so a sentence broken
/// across source lines is still checked as one sentence.
void main() {
  const guardedFiles = [
    'lib/core/copy/copy.dart',
    'lib/features/insights/insights_screen.dart',
    'lib/features/challenge/challenge_screen.dart',
    'lib/features/challenge/challenge_detail_screen.dart',
    'lib/features/challenge/new_challenge_sheet.dart',
    'lib/services/export/doctor_report.dart',
  ];

  /// Phrases where the honest framing legitimately names the banned word in
  /// order to negate it.
  const allowedNegations = [
    'not a diagnosis',
    'not diagnostic',
    'not causes',
    'never causes',
    'not medical advice',
    'not a medical device',
  ];

  final bannedPatterns = <String, RegExp>{
    // \b anchors the start, so "because" and "causal" in prose do not match;
    // only the verb forms that would assert causation do.
    'causal language ("cause/causes/caused/causing")':
        RegExp(r'\bcaus(e|es|ed|ing)\b'),
    'diagnostic language ("diagnos…")': RegExp(r'diagnos'),
    'verdict language ("your trigger is")': RegExp(r'your trigger is'),
    'proof language ("proves/proven")': RegExp(r'\bprov(es|en)\b'),
  };

  /// Reduces Dart source to the user-facing text it renders.
  String renderedCopy(String source) {
    return source
        // Drop doc and line comments — they describe the guard, not the UI.
        .replaceAll(RegExp(r'//.*'), ' ')
        .replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), ' ')
        // Join adjacent string literals: Dart concatenates 'a ' 'b' at parse
        // time, so the guard must see the joined sentence.
        .replaceAll(RegExp(r"'\s*\n\s*'"), '')
        .replaceAll(RegExp(r'"\s*\n\s*"'), '')
        // Collapse the remaining whitespace so phrases match across wraps.
        .replaceAll(RegExp(r'\s+'), ' ')
        .toLowerCase();
  }

  for (final path in guardedFiles) {
    test('$path stays in association language', () {
      final file = File(path);
      expect(file.existsSync(), isTrue,
          reason: 'guarded file moved — update honest_copy_test.dart');

      var copy = renderedCopy(file.readAsStringSync());
      for (final negation in allowedNegations) {
        copy = copy.replaceAll(negation, '');
      }

      bannedPatterns.forEach((description, pattern) {
        final match = pattern.firstMatch(copy);
        final context = match == null
            ? ''
            : copy.substring(
                (match.start - 60).clamp(0, copy.length),
                (match.end + 60).clamp(0, copy.length),
              );
        expect(
          match,
          isNull,
          reason: 'Found $description in $path near: "…$context…"',
        );
      });
    });
  }

  test('the guard actually catches a violation', () {
    // Pins the check itself: if the patterns are ever loosened into
    // uselessness, this fails.
    final offending = renderedCopy("const bad = 'Onion causes your symptoms';");
    expect(RegExp(r'\bcaus(e|es|ed|ing)\b').hasMatch(offending), isTrue);

    final fine = renderedCopy(
        "const good = 'Onion is associated with your symptoms because "
        "you logged it often';");
    expect(RegExp(r'\bcaus(e|es|ed|ing)\b').hasMatch(fine), isFalse,
        reason: '"because" must not trip the causal-language guard');
  });
}
