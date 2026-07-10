import 'package:flutter/material.dart';

import '../onboarding_theme.dart';
import '../onboarding_tokens.dart';
import 'onboarding_hero_stage.dart';
import 'onboarding_hero_strategy.dart';
import 'pixel/onboarding_hero_motion.dart';
import 'pixel/pixel_grid.dart';
import 'pixel/pixel_pattern.dart';
import 'pixel/pixel_swarm.dart';

class OnboardingWorkspaceHeroStrategy extends OnboardingHeroStrategy {
  const OnboardingWorkspaceHeroStrategy();

  @override
  Widget build({required bool active}) =>
      OnboardingWorkspaceHero(active: active);
}

/// Swarm → prompt + surface assemble into workspace GUI.
class OnboardingWorkspaceHero extends HeroActiveWidget {
  const OnboardingWorkspaceHero({super.key, required this.active});

  final bool active;

  @override
  State<OnboardingWorkspaceHero> createState() =>
      _OnboardingWorkspaceHeroState();
}

class _OnboardingWorkspaceHeroState extends State<OnboardingWorkspaceHero>
    with TickerProviderStateMixin, OnboardingHeroMotion {
  static const _seed = 22;
  static final _motifs = [
    OnboardingPixelPatterns.chevron,
    OnboardingPixelPatterns.outputLine,
    OnboardingPixelPatterns.caret,
    OnboardingPixelPatterns.badgeAi,
  ];

  @override
  bool get heroActive => widget.active;

  late final Animation<double> _promptEnter = CurvedAnimation(
    parent: enter,
    curve: const Interval(0.14, 0.52, curve: OnboardingTokens.easeOut),
  );

  late final Animation<double> _surfaceEnter = CurvedAnimation(
    parent: enter,
    curve: const Interval(0.28, 0.68, curve: OnboardingTokens.easeOut),
  );
  late final Animation<double> _surfaceScale = Tween<double>(
    begin: 0.92,
    end: 1,
  ).animate(
    CurvedAnimation(
      parent: enter,
      curve: const Interval(0.28, 0.68, curve: OnboardingTokens.easeOut),
    ),
  );

  late final Animation<double> _caretBlink = TweenSequence<double>([
    TweenSequenceItem(tween: ConstantTween(1), weight: 48),
    TweenSequenceItem(tween: ConstantTween(0), weight: 52),
  ]).animate(life);

  late final Animation<double> _lineBreath = lifePulse();

  static final _lines = [
    OnboardingPixelPatterns.outputLine,
    OnboardingPixelPatterns.outputLineShort,
    OnboardingPixelPatterns.outputLineShorter,
  ];

  @override
  void initState() {
    super.initState();
    life.duration = const Duration(milliseconds: 900);
  }

  @override
  Widget build(BuildContext context) {
    final c = OnboardingThemeColors.of(context).colors;
    final live = enter.isCompleted;

    return OnboardingHeroStage(
      designHeight: 156,
      child: PixelHeroAssembly(
        enter: enter,
        colors: c,
        seed: _seed,
        motifs: _motifs,
        cloudWidth: 270,
        cloudHeight: 140,
        particleCount: 140,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PixelPanel(
              colors: c,
              width: 260,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              reveal: _promptEnter,
              child: Row(
                children: [
                    PixelGrid(
                      pattern: OnboardingPixelPatterns.chevron,
                      colors: c,
                      cellSize: 3,
                      gap: 0.5,
                      enter: enter,
                      swarmSeed: _seed,
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                      child: PixelGrid(
                        pattern: OnboardingPixelPatterns.outputLine,
                        colors: c,
                        cellSize: 3,
                        gap: 1,
                        enter: enter,
                      swarmSeed: _seed + 1,
                      totalStaggerCells: 12,
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedBuilder(
                    animation: _caretBlink,
                    builder: (context, _) {
                      return Opacity(
                        opacity: live ? _caretBlink.value : 1,
                        child: PixelGrid(
                          pattern: OnboardingPixelPatterns.caret,
                          colors: c,
                          cellSize: 3,
                          gap: 0,
                          enter: enter,
                          swarmSeed: _seed + 2,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ScaleTransition(
              scale: _surfaceScale,
              alignment: Alignment.topCenter,
              child: PixelPanel(
                colors: c,
                width: 260,
                reveal: _surfaceEnter,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < 3; i++) ...[
                      if (i > 0) const SizedBox(height: 8),
                      AnimatedBuilder(
                        animation: _lineBreath,
                        builder: (context, child) {
                          final breath =
                              i == 0 && live ? _lineBreath.value : 1.0;
                          return Opacity(opacity: breath, child: child);
                        },
                        child: PixelGrid(
                          pattern: _lines[i],
                          colors: c,
                          cellSize: 4,
                          gap: 1,
                          enter: enter,
                          swarmSeed: _seed + 3 + i,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: PixelGrid(
                        pattern: OnboardingPixelPatterns.badgeAi,
                        colors: c,
                        cellSize: 4,
                        gap: 1,
                        enter: enter,
                        swarmSeed: _seed + 7,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
