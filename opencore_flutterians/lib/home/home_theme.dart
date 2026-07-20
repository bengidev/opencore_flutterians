import 'package:flutter/material.dart';

@immutable
class HomeColors extends ThemeExtension<HomeColors> {
  const HomeColors({
    required this.surfaceBase,
    required this.surfaceRaised,
    required this.surfaceMuted,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
    required this.tabActiveFill,
    required this.orbTint,
    required this.orbAccent,
  });

  final Color surfaceBase;
  final Color surfaceRaised;
  final Color surfaceMuted;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color border;
  final Color tabActiveFill;
  final Color orbTint;
  final Color orbAccent;

  static const light = HomeColors(
    surfaceBase: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFF7F7F7),
    surfaceMuted: Color(0xFFEEEEEE),
    textPrimary: Color(0xFF141414),
    textSecondary: Color(0xFF6B6B6B),
    textTertiary: Color(0xFF9A9A9A),
    border: Color(0xFFE6E6E6),
    tabActiveFill: Color(0xFFE8E8E8),
    orbTint: Color(0xFF141414),
    orbAccent: Color(0xFF2B2B2B),
  );

  static HomeColors of(BuildContext context) =>
      Theme.of(context).extension<HomeColors>() ?? light;

  @override
  HomeColors copyWith({
    Color? surfaceBase,
    Color? surfaceRaised,
    Color? surfaceMuted,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? border,
    Color? tabActiveFill,
    Color? orbTint,
    Color? orbAccent,
  }) {
    return HomeColors(
      surfaceBase: surfaceBase ?? this.surfaceBase,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      border: border ?? this.border,
      tabActiveFill: tabActiveFill ?? this.tabActiveFill,
      orbTint: orbTint ?? this.orbTint,
      orbAccent: orbAccent ?? this.orbAccent,
    );
  }

  @override
  HomeColors lerp(ThemeExtension<HomeColors>? other, double t) {
    if (other is! HomeColors) return this;
    return HomeColors(
      surfaceBase: Color.lerp(surfaceBase, other.surfaceBase, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      border: Color.lerp(border, other.border, t)!,
      tabActiveFill: Color.lerp(tabActiveFill, other.tabActiveFill, t)!,
      orbTint: Color.lerp(orbTint, other.orbTint, t)!,
      orbAccent: Color.lerp(orbAccent, other.orbAccent, t)!,
    );
  }
}

class HomeTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: HomeColors.light.surfaceBase,
      extensions: const [HomeColors.light],
    );
  }
}
