import 'package:culprit/core/copy/copy.dart';
import 'package:culprit/core/theme/app_theme.dart';
import 'package:culprit/data/db/database.dart';
import 'package:culprit/features/onboarding/onboarding_screen.dart';
import 'package:culprit/providers.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Onboarding is the one screen with a hard contract: the user cannot reach
/// the app without acknowledging what Culprit is and is not. This test pins
/// that gate.
///
/// It mounts the onboarding screen rather than the whole app: booting the
/// full shell pulls in four tabs' worth of streams, secure storage, and an
/// indeterminate progress indicator that `pumpAndSettle` can never settle.
void main() {
  Future<AppDatabase> pumpOnboarding(WidgetTester tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: buildTheme(Brightness.light),
          home: const OnboardingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return db;
  }

  /// Disposes the tree so provider subscriptions and their timers are
  /// cancelled before the test ends.
  Future<void> teardownTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  }

  testWidgets('walks three pages and gates entry on the disclaimer',
      (tester) async {
    final db = await pumpOnboarding(tester);

    expect(find.text('Find your culprit'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // The denominator principle is stated before the first meal is logged.
    expect(find.text('Log everything, not just bad days'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // The honest limits, then a required acknowledgment.
    expect(find.text('Candidates, not answers'), findsOneWidget);
    final startButton = find.widgetWithText(FilledButton, 'Start logging');
    expect(
      tester.widget<FilledButton>(startButton).onPressed,
      isNull,
      reason: 'entry must be gated on the disclaimer acknowledgment',
    );
    expect(
      (await db.getSettings()).disclaimerAccepted,
      isFalse,
      reason: 'nothing is accepted until the user ticks the box',
    );

    await tester.tap(find.text(Copy.disclaimerAck));
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(startButton).onPressed, isNotNull);

    await tester.tap(startButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final settings = await db.getSettings();
    expect(settings.disclaimerAccepted, isTrue);
    expect(settings.onboardingComplete, isTrue);

    await teardownTree(tester);
  });

  testWidgets('scrolls rather than overflowing on the smallest iPhone',
      (tester) async {
    // iPhone SE (1st gen): 320x568 logical points. physicalSize is in
    // physical pixels, hence the devicePixelRatio multiplier.
    const dpr = 2.0;
    tester.view.physicalSize = const Size(320 * dpr, 568 * dpr);
    tester.view.devicePixelRatio = dpr;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpOnboarding(tester);

    expect(find.text('Find your culprit'), findsOneWidget);
    expect(
      tester.takeException(),
      isNull,
      reason: 'onboarding must scroll, not overflow, on a small screen',
    );

    await teardownTree(tester);
  });
}
