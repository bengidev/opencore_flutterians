import 'package:flutter/material.dart';

class OnboardingColorTokens {
  const OnboardingColorTokens({
    required this.black,
    required this.surface,
    required this.surfaceRaised,
    required this.border,
    required this.borderVisible,
    required this.textDisabled,
    required this.textSecondary,
    required this.textPrimary,
    required this.textDisplay,
    required this.accent,
  });

  final Color black;
  final Color surface;
  final Color surfaceRaised;
  final Color border;
  final Color borderVisible;
  final Color textDisabled;
  final Color textSecondary;
  final Color textPrimary;
  final Color textDisplay;
  final Color accent;
}

class OnboardingTokens {
  static const radiusControl = 6.0;
  static const accent = Color(0xFFD71921);

  static const durationFast = Duration(milliseconds: 160);
  static const durationUi = Duration(milliseconds: 200);
  static const durationPage = Duration(milliseconds: 300);
  static const easeOut = Cubic(0.23, 1, 0.32, 1);
  static const easeUi = Cubic(0.25, 0.1, 0.25, 1);

  static const dark = OnboardingColorTokens(
    black: Color(0xFF000000),
    surface: Color(0xFF111111),
    surfaceRaised: Color(0xFF1A1A1A),
    border: Color(0xFF222222),
    borderVisible: Color(0xFF333333),
    textDisabled: Color(0xFF666666),
    textSecondary: Color(0xFF999999),
    textPrimary: Color(0xFFE8E8E8),
    textDisplay: Color(0xFFFFFFFF),
    accent: accent,
  );

  static const light = OnboardingColorTokens(
    black: Color(0xFFF5F5F5),
    surface: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFF0F0F0),
    border: Color(0xFFE8E8E8),
    borderVisible: Color(0xFFCCCCCC),
    textDisabled: Color(0xFF999999),
    textSecondary: Color(0xFF666666),
    textPrimary: Color(0xFF1A1A1A),
    textDisplay: Color(0xFF000000),
    accent: accent,
  );
}
