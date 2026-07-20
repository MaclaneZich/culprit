import 'package:culprit/analysis/analysis_service.dart';
import 'package:culprit/analysis/models.dart';
import 'package:culprit/core/copy/copy.dart';
import 'package:culprit/core/theme/app_theme.dart';
import 'package:culprit/data/db/database.dart';
import 'package:culprit/domain/enums.dart';
import 'package:culprit/features/insights/insights_screen.dart';
import 'package:culprit/providers.dart';
import 'package:culprit/services/export/doctor_report.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// End-to-end check of the pipeline the app exists for: real meals and
/// symptoms written through the real database, reduced by the real analysis
/// service, ranked by the real engine, rendered by the real Insights screen,
/// and carried into the doctor report.
///
/// The scenario is the one that breaks naive food diaries. Rice is eaten
/// every single day and therefore precedes every attack. Onion is eaten a
/// third as often but is followed by symptoms most times. A denominator-blind
/// app blames rice; Culprit must rank onion first.
void main() {
  /// Writes 30 days: rice every morning, onion every third day at 13:00,
  /// with an episode at 14:30 on eight of those onion days.
  Future<void> seedSyntheticLog(AppDatabase db) async {
    final day0 = DateTime(2026, 5, 1);
    DateTime at(int day, int hour, [int minute = 0]) =>
        day0.add(Duration(days: day, hours: hour, minutes: minute));

    for (var d = 0; d < 30; d++) {
      await db.insertMeal(
        meal: MealsCompanion.insert(
          timestamp: at(d, 8),
          portionSize: PortionSize.medium,
          source: MealSource.home,
        ),
        ingredientEntries: [
          (
            name: 'White rice',
            tags: <TriggerTag>{},
            confidence: IngredientConfidence.confirmed
          ),
        ],
      );
      if (d % 3 == 0) {
        await db.insertMeal(
          meal: MealsCompanion.insert(
            timestamp: at(d, 13),
            portionSize: PortionSize.medium,
            source: MealSource.home,
          ),
          ingredientEntries: [
            (
              name: 'Onion',
              tags: {TriggerTag.fructan},
              confidence: IngredientConfidence.confirmed
            ),
          ],
        );
      }
    }

    for (var i = 0; i < 8; i++) {
      await db.insertSymptom(SymptomsCompanion.insert(
        timestamp: at(i * 3, 14, 30),
        types: {SymptomType.bloating, SymptomType.pain},
        severity: 3,
        minutesSinceLastMeal: const Value(90),
      ));
    }
  }

  /// Runs the real analysis over whatever is in the database.
  Future<AnalysisResult> analyze(AppDatabase db) async =>
      const AnalysisService().analyze(
        meals: await db.allMealsWithIngredients(),
        symptoms: await db.allSymptoms(),
        contextEntries: await db.allContextEntries(),
      );

  test('the ranking survives a food eaten three times as often', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await seedSyntheticLog(db);

    final analysis = await analyze(db);
    expect(analysis.hasEnoughData, isTrue);

    final onion = analysis.candidates
        .firstWhere((c) => c.displayName == 'Onion');
    final rice = analysis.candidates
        .firstWhere((c) => c.displayName == 'White rice');

    expect(
      analysis.candidates.first.displayName,
      'Onion',
      reason: 'rice is eaten 3x as often and precedes every episode; '
          'ranking it first is the exact failure this app exists to avoid',
    );
    expect(onion.score, greaterThan(rice.score * 2));
    expect(onion.bestWindow.window.label, '1–4 h');
  });

  testWidgets('Insights renders the ranking with honest framing, no API key',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await seedSyntheticLog(db);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: buildTheme(Brightness.light),
          home: const InsightsScreen(),
        ),
      ),
    );
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // The ranking rendered rather than the not-enough-data state.
    expect(find.text(Copy.emptyInsights), findsNothing);
    expect(find.text(Copy.insightsHeader), findsOneWidget);
    expect(find.text('Onion'), findsOneWidget);

    // Framing is on screen, not merely defined in the copy constants.
    expect(find.text(Copy.worthTesting), findsWidgets);
    expect(find.textContaining('not a diagnosis'), findsOneWidget);
    expect(find.textContaining('Keep eating gluten'), findsOneWidget);

    // Completeness sits above the ranking: 30 rice + 10 onion meals, and
    // the 8 episodes.
    expect(find.text('40'), findsOneWidget);
    expect(find.text('meals'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('episodes'), findsOneWidget);

    // Dispose the tree, then let the database stream subscriptions' timers
    // drain (fake time, so this costs nothing) before the binding checks
    // for pending timers.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 5));
  });

  test('the doctor report produces a real PDF from the log', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await seedSyntheticLog(db);

    final bytes = await const DoctorReportBuilder().build(
      analysis: await analyze(db),
      symptoms: await db.allSymptoms(),
      challenges: await db.allChallenges(),
    );

    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    expect(bytes.length, greaterThan(2000),
        reason: 'a report with content, not an empty page');
  });

  test('report text is sanitized to glyphs Helvetica can actually draw', () {
    // The built-in PDF font drops General Punctuation silently, so a lag
    // window label would reach the clinician as "14 h" rather than "1-4 h".
    expect(asciiForPdf('1–4 h'), '1-4 h');
    expect(asciiForPdf('summary — associations'), 'summary - associations');
    expect(asciiForPdf('3.3× vs base'), '3.3x vs base');
    expect(asciiForPdf('doesn’t'), "doesn't");
    expect(asciiForPdf('a · b'), 'a - b');

    // Accented Latin is WinAnsi-encodable and must survive untouched, so
    // ingredient names like these still read correctly.
    expect(asciiForPdf('jalapeño'), 'jalapeño');
    expect(asciiForPdf('crème fraîche'), 'crème fraîche');
  });
}
