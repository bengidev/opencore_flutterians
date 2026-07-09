import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/onboarding/heroes/onboarding_hero_strategy.dart';
import 'package:opencore_flutterians/onboarding/onboarding_page_model.dart';
import 'package:opencore_flutterians/onboarding/onboarding_theme.dart';

void main() {
  testWidgets('registry builds a distinct hero for each hero id', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: OnboardingTheme.dark(),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return Column(
                children: OnboardingHeroId.values
                    .map(
                      (id) => SizedBox(
                        height: 80,
                        child: OnboardingHeroRegistry.build(id, active: true),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(OnboardingPairingHero), findsOneWidget);
    expect(find.byType(OnboardingWorkspaceHero), findsOneWidget);
    expect(find.byType(OnboardingQueueHero), findsOneWidget);
    expect(find.byType(OnboardingDepthHero), findsOneWidget);
    expect(find.byType(OnboardingBrandHero), findsOneWidget);
  });
}
