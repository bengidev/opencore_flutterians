import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/onboarding/heroes/onboarding_hero.dart';
import 'package:opencore_flutterians/onboarding/onboarding_page_model.dart';
import 'package:opencore_flutterians/onboarding/onboarding_theme.dart';

void main() {
  testWidgets('registry builds the matching hero for each hero id', (tester) async {
    for (final id in OnboardingHeroId.values) {
      await tester.pumpWidget(
        MaterialApp(
          theme: OnboardingTheme.dark(),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                height: 320,
                width: 320,
                child: OnboardingHeroRegistry.build(id, active: true),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull, reason: 'hero $id should render without exceptions');
    }
  });

  testWidgets('inactive heroes pause without throwing', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: OnboardingTheme.dark(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              height: 320,
              width: 320,
              child: OnboardingHeroRegistry.build(OnboardingHeroId.pairing, active: false),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
  });
}
