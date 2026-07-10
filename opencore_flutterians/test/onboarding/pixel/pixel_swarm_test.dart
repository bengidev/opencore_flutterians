import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/onboarding/heroes/pixel/ascii_glyph.dart';
import 'package:opencore_flutterians/onboarding/heroes/pixel/pixel_pattern.dart';
import 'package:opencore_flutterians/onboarding/heroes/pixel/pixel_swarm.dart';
import 'package:opencore_flutterians/onboarding/onboarding_theme.dart';
import 'package:opencore_flutterians/onboarding/onboarding_tokens.dart';

void main() {
  group('PixelSwarmMath', () {
    test('holds assemble at zero during early scatter', () {
      expect(PixelSwarmMath.assembleProgress(0.0), 0);
      expect(PixelSwarmMath.assembleProgress(0.2), 0);
      expect(PixelSwarmMath.assembleProgress(1.0), 1);
    });

    test('edgeFade is lower near margins than center', () {
      expect(PixelSwarmMath.edgeFade(0.0, 0.5), lessThan(0.4));
      expect(PixelSwarmMath.edgeFade(0.5, 0.5), greaterThan(0.85));
      expect(PixelSwarmMath.edgeFade(1.0, 0.0), lessThan(0.4));
    });
  });

  testWidgets('PixelHeroAssembly tap restarts enter animation', (tester) async {
    final enter = AnimationController(
      vsync: const TestVSync(),
      duration: const Duration(milliseconds: 400),
    );
    addTearDown(enter.dispose);
    enter.value = 1;

    await tester.pumpWidget(
      MaterialApp(
        theme: OnboardingTheme.dark(),
        home: Scaffold(
          body: PixelHeroAssembly(
            enter: enter,
            colors: OnboardingTokens.dark,
            seed: 7,
            motifs: [OnboardingPixelPatterns.link],
            onReplay: () => enter.forward(from: 0),
            child: const SizedBox(width: 40, height: 40, child: Text('GUI')),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(enter.value, 1);

    await tester.tap(find.byType(PixelHeroAssembly));
    await tester.pump();
    expect(enter.value, lessThan(1));
    expect(enter.isAnimating, isTrue);
    enter.stop();
  });

  testWidgets('swarm cloud uses mixed glyph pool characters', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: OnboardingTheme.dark(),
        home: Scaffold(
          body: PixelSwarmCloud(
            patterns: [OnboardingPixelPatterns.link],
            colors: OnboardingTokens.dark,
            enterT: 0.15,
            seed: 3,
            width: 280,
            height: 140,
            particleCount: 40,
          ),
        ),
      ),
    );
    await tester.pump();
    final texts = tester.widgetList<Text>(find.byType(Text)).map((t) => t.data);
    expect(texts.any(kSwarmGlyphPool.contains), isTrue);
  });
}
