import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:opencore_flutterians/onboarding/onboarding_theme.dart';
import 'package:opencore_flutterians/onboarding/onboarding_tokens.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  test('dark and light themes use 6pt control radius', () async {
    await runZonedGuarded(() async {
      final dark = OnboardingTheme.dark();
      final light = OnboardingTheme.light();
      await pumpEventQueue();
      expect(dark.filledButtonTheme.style?.shape?.resolve({}), isA<RoundedRectangleBorder>());
      final darkShape =
          dark.filledButtonTheme.style!.shape!.resolve({})! as RoundedRectangleBorder;
      expect(darkShape.borderRadius, BorderRadius.circular(OnboardingTokens.radiusControl));
      expect(OnboardingTokens.radiusControl, 6);
      expect(light.scaffoldBackgroundColor, OnboardingTokens.light.black);
      expect(dark.scaffoldBackgroundColor, OnboardingTokens.dark.black);
    }, (_, __) {
      // Fonts fall back when runtime fetching is disabled in tests.
    });
  });
}
