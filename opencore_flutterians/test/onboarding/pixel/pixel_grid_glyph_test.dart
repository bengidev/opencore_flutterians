import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/onboarding/heroes/pixel/pixel_grid.dart';
import 'package:opencore_flutterians/onboarding/heroes/pixel/pixel_pattern.dart';
import 'package:opencore_flutterians/onboarding/onboarding_theme.dart';
import 'package:opencore_flutterians/onboarding/onboarding_tokens.dart';

void main() {
  testWidgets('PixelGrid renders shade-block glyphs for filled cells', (tester) async {
    final colors = OnboardingTokens.dark;
    await tester.pumpWidget(
      MaterialApp(
        theme: OnboardingTheme.dark(),
        home: Scaffold(
          body: Center(
            child: PixelGrid(
              pattern: PixelPattern.fromAscii('#!-'),
              colors: colors,
              cellSize: 6,
              gap: 1,
              swarm: false,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('█'), findsWidgets);
    expect(find.text('▓'), findsWidgets);
    expect(find.text('░'), findsWidgets);
    expect(find.text('#'), findsNothing);
  });
}
