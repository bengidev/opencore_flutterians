import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/onboarding/heroes/onboarding_pairing_hero.dart';
import 'package:opencore_flutterians/onboarding/onboarding_theme.dart';

void main() {
  testWidgets('pairing hero accepts tap without overflow', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: OnboardingTheme.dark(),
        home: const Scaffold(
          body: SizedBox(
            height: 180,
            child: OnboardingPairingHero(active: true),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byType(OnboardingPairingHero));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.takeException(), isNull);
  });
}
