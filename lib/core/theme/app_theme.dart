import 'package:flutter/material.dart';

import 'tokens.dart';

/// Semantic colors resolved per brightness. Widgets read these through
/// `context.tones` instead of touching raw token values.
@immutable
class CulpritTones extends ThemeExtension<CulpritTones> {
  const CulpritTones({
    required this.surface,
    required this.card,
    required this.cardSunken,
    required this.ink,
    required this.inkSecondary,
    required this.inkFaint,
    required this.line,
    required this.accent,
    required this.accentWash,
    required this.alert,
    required this.slate,
    required this.moss,
  });

  final Color surface;
  final Color card;
  final Color cardSunken;
  final Color ink;
  final Color inkSecondary;
  final Color inkFaint;
  final Color line;
  final Color accent;
  final Color accentWash;

  /// Reserved for high-severity (4-5) symptom episodes. Do not use elsewhere.
  final Color alert;
  final Color slate;
  final Color moss;

  static const light = CulpritTones(
    surface: InkTones.surface,
    card: InkTones.card,
    cardSunken: InkTones.cardSunken,
    ink: InkTones.ink,
    inkSecondary: InkTones.inkSecondary,
    inkFaint: InkTones.inkFaint,
    line: InkTones.line,
    accent: AccentTones.clay,
    accentWash: AccentTones.clayWash,
    alert: AccentTones.alert,
    slate: AccentTones.slate,
    moss: AccentTones.moss,
  );

  static const dark = CulpritTones(
    surface: InkTones.surfaceDark,
    card: InkTones.cardDark,
    cardSunken: InkTones.cardSunkenDark,
    ink: InkTones.inkDark,
    inkSecondary: InkTones.inkSecondaryDark,
    inkFaint: InkTones.inkFaintDark,
    line: InkTones.lineDark,
    accent: AccentTones.clayDark,
    accentWash: AccentTones.clayWashDark,
    alert: AccentTones.alertDark,
    slate: AccentTones.slateDark,
    moss: AccentTones.mossDark,
  );

  @override
  CulpritTones copyWith({Color? surface}) => this;

  @override
  CulpritTones lerp(ThemeExtension<CulpritTones>? other, double t) {
    if (other is! CulpritTones) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return CulpritTones(
      surface: mix(surface, other.surface),
      card: mix(card, other.card),
      cardSunken: mix(cardSunken, other.cardSunken),
      ink: mix(ink, other.ink),
      inkSecondary: mix(inkSecondary, other.inkSecondary),
      inkFaint: mix(inkFaint, other.inkFaint),
      line: mix(line, other.line),
      accent: mix(accent, other.accent),
      accentWash: mix(accentWash, other.accentWash),
      alert: mix(alert, other.alert),
      slate: mix(slate, other.slate),
      moss: mix(moss, other.moss),
    );
  }
}

extension CulpritThemeContext on BuildContext {
  CulpritTones get tones => Theme.of(this).extension<CulpritTones>()!;
}

ThemeData buildTheme(Brightness brightness) {
  final tones =
      brightness == Brightness.light ? CulpritTones.light : CulpritTones.dark;

  final textTheme = TextTheme(
    displayLarge: TypeRamp.display.copyWith(color: tones.ink),
    displaySmall: TypeRamp.statNumber.copyWith(color: tones.ink),
    headlineMedium: TypeRamp.headline.copyWith(color: tones.ink),
    titleMedium: TypeRamp.title.copyWith(color: tones.ink),
    bodyLarge: TypeRamp.body.copyWith(color: tones.ink),
    bodyMedium: TypeRamp.bodySmall.copyWith(color: tones.ink),
    labelLarge: TypeRamp.label.copyWith(color: tones.ink),
    bodySmall: TypeRamp.caption.copyWith(color: tones.inkSecondary),
  );

  final colorScheme = ColorScheme(
    brightness: brightness,
    primary: tones.accent,
    onPrimary: brightness == Brightness.light ? Colors.white : InkTones.ink,
    secondary: tones.slate,
    onSecondary: Colors.white,
    error: tones.alert,
    onError: Colors.white,
    surface: tones.surface,
    onSurface: tones.ink,
    surfaceContainerHighest: tones.cardSunken,
    outline: tones.line,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: tones.surface,
    canvasColor: tones.surface,
    cardColor: tones.card,
    dividerColor: tones.line,
    splashFactory: NoSplash.splashFactory,
    highlightColor: tones.accent.withValues(alpha: 0.06),
    textTheme: textTheme,
    extensions: [tones],
    appBarTheme: AppBarTheme(
      backgroundColor: tones.surface,
      foregroundColor: tones.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TypeRamp.headline.copyWith(color: tones.ink),
    ),
    cardTheme: CardThemeData(
      color: tones.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: Corner.lgAll,
        side: BorderSide(color: tones.line),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: tones.accent,
        foregroundColor:
            brightness == Brightness.light ? Colors.white : InkTones.ink,
        minimumSize: const Size.fromHeight(52),
        textStyle: TypeRamp.title,
        shape: RoundedRectangleBorder(borderRadius: Corner.mdAll),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: tones.ink,
        minimumSize: const Size.fromHeight(52),
        textStyle: TypeRamp.title,
        side: BorderSide(color: tones.line, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: Corner.mdAll),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: tones.accent,
        textStyle: TypeRamp.label,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: tones.card,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Space.x4,
        vertical: Space.x3,
      ),
      border: OutlineInputBorder(
        borderRadius: Corner.mdAll,
        borderSide: BorderSide(color: tones.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: Corner.mdAll,
        borderSide: BorderSide(color: tones.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: Corner.mdAll,
        borderSide: BorderSide(color: tones.accent, width: 1.5),
      ),
      hintStyle: TypeRamp.body.copyWith(color: tones.inkFaint),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: tones.cardSunken,
      selectedColor: tones.accentWash,
      labelStyle: TypeRamp.label.copyWith(color: tones.ink),
      side: BorderSide(color: tones.line),
      shape: RoundedRectangleBorder(borderRadius: Corner.smAll),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(
        horizontal: Space.x3,
        vertical: Space.x2,
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: tones.accent,
      inactiveTrackColor: tones.cardSunken,
      thumbColor: tones.accent,
      overlayColor: tones.accent.withValues(alpha: 0.12),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(Colors.white),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? tones.accent
            : tones.cardSunken,
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? tones.accent
            : tones.line,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: tones.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Corner.xl)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: tones.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: tones.accentWash,
      height: 68,
      labelTextStyle: WidgetStatePropertyAll(
        TypeRamp.caption.copyWith(color: tones.inkSecondary),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? tones.accent
              : tones.inkSecondary,
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: tones.ink,
      contentTextStyle: TypeRamp.bodySmall.copyWith(color: tones.surface),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: Corner.mdAll),
    ),
  );
}
