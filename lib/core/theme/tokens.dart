import 'package:flutter/widgets.dart';

/// Design tokens for Culprit.
///
/// Every color, distance, radius, and text size in the app comes from here.
/// The palette aims for calm clinical confidence: warm off-white surfaces,
/// near-black ink, a single clay accent, and one reserved alert red that only
/// ever marks high-severity episodes.
abstract final class InkTones {
  // Light mode.
  static const Color surface = Color(0xFFFAF7F2);
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardSunken = Color(0xFFF3EFE7);
  static const Color ink = Color(0xFF1D1B17);
  static const Color inkSecondary = Color(0xFF6C675D);
  static const Color inkFaint = Color(0xFFA6A095);
  static const Color line = Color(0xFFE8E2D7);

  // Dark mode.
  static const Color surfaceDark = Color(0xFF161513);
  static const Color cardDark = Color(0xFF201F1B);
  static const Color cardSunkenDark = Color(0xFF2A2823);
  static const Color inkDark = Color(0xFFEDE9E1);
  static const Color inkSecondaryDark = Color(0xFFA39E93);
  static const Color inkFaintDark = Color(0xFF716C62);
  static const Color lineDark = Color(0xFF35332D);
}

abstract final class AccentTones {
  /// The one confident accent: a muted clay. Warm and gut-adjacent without
  /// being literal.
  static const Color clay = Color(0xFFA85638);
  static const Color clayDark = Color(0xFFD08A66);

  /// Soft washes of the accent for chips and selected states.
  static const Color clayWash = Color(0xFFF3E4DC);
  static const Color clayWashDark = Color(0xFF3B2A22);

  /// Reserved: high-severity (4-5) symptom episodes only. Nothing else may
  /// use this color.
  static const Color alert = Color(0xFFAF3B31);
  static const Color alertDark = Color(0xFFE0665A);

  /// Quiet supporting hues for non-food context entries and charts.
  static const Color slate = Color(0xFF5C7078);
  static const Color slateDark = Color(0xFF93A6AD);
  static const Color moss = Color(0xFF6A7A52);
  static const Color mossDark = Color(0xFFA3B385);
}

abstract final class Space {
  static const double x1 = 4;
  static const double x2 = 8;
  static const double x3 = 12;
  static const double x4 = 16;
  static const double x5 = 20;
  static const double x6 = 24;
  static const double x8 = 32;
  static const double x10 = 40;
  static const double x12 = 48;
}

abstract final class Corner {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;

  static BorderRadius get smAll => BorderRadius.circular(sm);
  static BorderRadius get mdAll => BorderRadius.circular(md);
  static BorderRadius get lgAll => BorderRadius.circular(lg);
  static BorderRadius get xlAll => BorderRadius.circular(xl);
}

/// Type ramp. UI text uses the platform humanist sans (SF Pro on iOS); large
/// numbers and insight headlines use a serif (New York / Georgia) so the
/// statistics feel considered rather than gamified.
abstract final class TypeRamp {
  static const String serif = 'Georgia';

  static const TextStyle display = TextStyle(
    fontFamily: serif,
    fontSize: 40,
    height: 1.1,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
  );
  static const TextStyle statNumber = TextStyle(
    fontFamily: serif,
    fontSize: 30,
    height: 1.1,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
  );
  static const TextStyle headline = TextStyle(
    fontFamily: serif,
    fontSize: 24,
    height: 1.25,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle title = TextStyle(
    fontSize: 18,
    height: 1.3,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle body = TextStyle(
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    height: 1.45,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle label = TextStyle(
    fontSize: 13,
    height: 1.35,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    height: 1.35,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
  );
}
