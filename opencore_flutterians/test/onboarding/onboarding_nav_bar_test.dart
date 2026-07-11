import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/onboarding/onboarding_page_model.dart';
import 'package:opencore_flutterians/onboarding/onboarding_theme.dart';
import 'package:opencore_flutterians/onboarding/widgets/onboarding_nav_bar.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: OnboardingTheme.dark(),
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('page 0 shows Continue and Skip only', (tester) async {
    await tester.pumpWidget(
      _wrap(
        OnboardingNavBar(
          kind: OnboardingPageKind.feature,
          isFirst: true,
          isCta: false,
          enterError: null,
          isEntering: false,
          onBack: () {},
          onNext: () {},
          onSkip: () {},
          onEnter: () async {},
        ),
      ),
    );
    expect(find.text('CONTINUE'), findsOneWidget);
    expect(find.text('SKIP'), findsOneWidget);
    expect(find.text('BACK'), findsNothing);
    expect(find.text('NEXT'), findsNothing);
    expect(find.text('ENTER'), findsNothing);
  });

  testWidgets('middle feature page shows Back Next Skip', (tester) async {
    await tester.pumpWidget(
      _wrap(
        OnboardingNavBar(
          kind: OnboardingPageKind.feature,
          isFirst: false,
          isCta: false,
          enterError: null,
          isEntering: false,
          onBack: () {},
          onNext: () {},
          onSkip: () {},
          onEnter: () async {},
        ),
      ),
    );
    expect(find.text('BACK'), findsOneWidget);
    expect(find.text('NEXT'), findsOneWidget);
    expect(find.text('SKIP'), findsOneWidget);
  });

  testWidgets('cta shows Enter only and error text', (tester) async {
    await tester.pumpWidget(
      _wrap(
        OnboardingNavBar(
          kind: OnboardingPageKind.cta,
          isFirst: false,
          isCta: true,
          enterError: '[ERROR: COULD NOT SAVE]',
          isEntering: false,
          onBack: () {},
          onNext: () {},
          onSkip: () {},
          onEnter: () async {},
        ),
      ),
    );
    expect(find.text('ENTER'), findsOneWidget);
    expect(find.text('[ERROR: COULD NOT SAVE]'), findsOneWidget);
    expect(find.text('SKIP'), findsNothing);
    expect(find.text('BACK'), findsNothing);
  });
}
