import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'onboarding_tokens.dart';

class OnboardingTheme {
  static ThemeData dark() => _build(OnboardingTokens.dark, Brightness.dark);
  static ThemeData light() => _build(OnboardingTokens.light, Brightness.light);

  static ThemeData _build(OnboardingColorTokens c, Brightness brightness) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(OnboardingTokens.radiusControl),
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: c.black,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: c.textDisplay,
        onPrimary: c.black,
        secondary: c.textSecondary,
        onSecondary: c.black,
        error: c.accent,
        onError: c.textDisplay,
        surface: c.surface,
        onSurface: c.textPrimary,
      ),
    );

    TextStyle grotesk({
      double size = 16,
      FontWeight weight = FontWeight.w400,
      Color? color,
      double? height,
      double? letterSpacing,
    }) =>
        GoogleFonts.spaceGrotesk(
          fontSize: size,
          fontWeight: weight,
          color: color ?? c.textPrimary,
          height: height,
          letterSpacing: letterSpacing,
        );

    TextStyle mono({
      double size = 11,
      FontWeight weight = FontWeight.w400,
      Color? color,
      double letterSpacing = 0.08 * 11,
    }) =>
        GoogleFonts.spaceMono(
          fontSize: size,
          fontWeight: weight,
          color: color ?? c.textSecondary,
          letterSpacing: letterSpacing,
        );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: c.black,
        foregroundColor: c.textDisplay,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: grotesk(
          size: 24,
          weight: FontWeight.w400,
          color: c.textDisplay,
          height: 1.2,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.doto(
          fontSize: 48,
          fontWeight: FontWeight.w400,
          color: c.textDisplay,
          height: 1.05,
          letterSpacing: -0.02 * 48,
        ),
        headlineMedium: grotesk(size: 24, weight: FontWeight.w400, color: c.textDisplay, height: 1.2),
        bodyLarge: grotesk(size: 16, height: 1.5),
        bodyMedium: grotesk(size: 14, color: c.textSecondary, height: 1.5),
        labelSmall: mono(),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.textDisplay,
          foregroundColor: c.black,
          shape: shape,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(120, 48),
          animationDuration: OnboardingTokens.durationFast,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return c.textPrimary.withValues(alpha: 0.12);
            }
            return null;
          }),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.textPrimary,
          side: BorderSide(color: c.borderVisible),
          shape: shape,
          elevation: 0,
          minimumSize: const Size(120, 48),
          animationDuration: OnboardingTokens.durationFast,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return c.textPrimary.withValues(alpha: 0.08);
            }
            return null;
          }),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.textSecondary,
          shape: shape,
          animationDuration: OnboardingTokens.durationFast,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return c.textPrimary.withValues(alpha: 0.08);
            }
            return null;
          }),
        ),
      ),
      extensions: <ThemeExtension<dynamic>>[
        OnboardingThemeColors(colors: c),
      ],
    );
  }
}

class OnboardingThemeColors extends ThemeExtension<OnboardingThemeColors> {
  const OnboardingThemeColors({required this.colors});

  final OnboardingColorTokens colors;

  static OnboardingThemeColors of(BuildContext context) =>
      Theme.of(context).extension<OnboardingThemeColors>()!;

  @override
  OnboardingThemeColors copyWith({OnboardingColorTokens? colors}) =>
      OnboardingThemeColors(colors: colors ?? this.colors);

  @override
  OnboardingThemeColors lerp(ThemeExtension<OnboardingThemeColors>? other, double t) {
    if (other is! OnboardingThemeColors) return this;
    return t < 0.5 ? this : other;
  }
}
