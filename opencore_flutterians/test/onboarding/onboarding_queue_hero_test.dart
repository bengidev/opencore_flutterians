import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/onboarding/heroes/onboarding_queue_hero.dart';
import 'package:opencore_flutterians/onboarding/onboarding_theme.dart';

void main() {
  testWidgets('queue hero shows chat labels and no arrow motif dependency',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: OnboardingTheme.dark(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: const Scaffold(
          body: SizedBox(
            height: 180,
            child: OnboardingQueueHero(active: true),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(OnboardingQueueHero), findsOneWidget);
    expect(find.text('YOU'), findsOneWidget);
    expect(find.text('RUNNING…'), findsOneWidget);
    expect(find.text('QUEUED'), findsOneWidget);
  });

  testWidgets('tap on queue hero does not throw', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: OnboardingTheme.dark(),
        home: const Scaffold(
          body: SizedBox(
            height: 180,
            child: OnboardingQueueHero(active: true),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byType(OnboardingQueueHero));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  });
}
