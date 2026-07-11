import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/onboarding/heroes/onboarding_hero.dart';
import 'package:opencore_flutterians/onboarding/onboarding_page_model.dart';
import 'package:opencore_flutterians/onboarding/onboarding_theme.dart';

void main() {
  testWidgets('registry builds a blank hero for each hero id', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: OnboardingTheme.dark(),
        home: Scaffold(
          body: Column(
            children: OnboardingHeroId.values
                .map(
                  (id) => SizedBox(
                    height: 80,
                    child: OnboardingHeroRegistry.build(id, active: true),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(OnboardingBlankHero), findsNWidgets(5));
    expect(tester.takeException(), isNull);
  });
}
