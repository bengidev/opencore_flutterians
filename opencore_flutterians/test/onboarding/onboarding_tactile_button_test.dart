import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/onboarding/onboarding_theme.dart';
import 'package:opencore_flutterians/onboarding/widgets/onboarding_tactile_button.dart';

void main() {
  testWidgets('filled button scales down while pressed', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: OnboardingTheme.dark(),
        home: Scaffold(
          body: Center(
            child: OnboardingFilledButton(
              onPressed: () {},
              child: const Text('CONTINUE'),
            ),
          ),
        ),
      ),
    );

    final scaleFinder = find.byType(AnimatedScale);
    expect(scaleFinder, findsOneWidget);
    expect(tester.widget<AnimatedScale>(scaleFinder).scale, 1);

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('CONTINUE')),
    );
    await tester.pump();
    expect(tester.widget<AnimatedScale>(scaleFinder).scale, 0.97);

    await gesture.up();
    await tester.pump();
    expect(tester.widget<AnimatedScale>(scaleFinder).scale, 1);
  });
}
