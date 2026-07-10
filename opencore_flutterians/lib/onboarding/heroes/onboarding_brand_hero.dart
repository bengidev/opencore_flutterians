import 'package:flutter/material.dart';

import '../onboarding_theme.dart';
import '../onboarding_tokens.dart';
import 'onboarding_hero_stage.dart';
import 'onboarding_hero_strategy.dart';
import 'pixel/onboarding_hero_motion.dart';
import 'pixel/pixel_grid.dart';
import 'pixel/pixel_pattern.dart';
import 'pixel/pixel_swarm.dart';

class OnboardingBrandHeroStrategy extends OnboardingHeroStrategy {
  const OnboardingBrandHeroStrategy();

  @override
  Widget build({required bool active}) => OnboardingBrandHero(active: active);
}

/// Swarm → [OC] mark + wordmark + rule assemble into brand GUI.
class OnboardingBrandHero extends HeroActiveWidget {
  const OnboardingBrandHero({super.key, required this.active});

  final bool active;

  @override
  State<OnboardingBrandHero> createState() => _OnboardingBrandHeroState();
}

class _OnboardingBrandHeroState extends State<OnboardingBrandHero>
    with TickerProviderStateMixin, OnboardingHeroMotion {
  static const _seed = 55;
  static final _motifs = [
    OnboardingPixelPatterns.badgeOc,
    OnboardingPixelPatterns.link,
  ];

  @override
  bool get heroActive => widget.active;

  late final Animation<double> _wordEnter = CurvedAnimation(
    parent: enter,
    curve: const Interval(0.32, 0.72, curve: OnboardingTokens.easeOut),
  );
  late final Animation<Offset> _wordSlide = Tween<Offset>(
    begin: const Offset(0, 0.12),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(
      parent: enter,
      curve: const Interval(0.32, 0.72, curve: OnboardingTokens.easeOut),
    ),
  );
  late final Animation<double> _wordScale = Tween<double>(
    begin: 0.96,
    end: 1,
  ).animate(
    CurvedAnimation(
      parent: enter,
      curve: const Interval(0.32, 0.72, curve: OnboardingTokens.easeOut),
    ),
  );

  late final Animation<double> _ruleEnter = CurvedAnimation(
    parent: enter,
    curve: const Interval(0.55, 0.95, curve: OnboardingTokens.easeOut),
  );

  late final Animation<double> _hold = lifePulse();

  @override
  void initState() {
    super.initState();
    life.duration = const Duration(milliseconds: 1800);
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
        cloudWidth: 250,
        cloudHeight: 130,
        particleCount: 120,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _hold,
                builder: (context, child) {
                  final breath = live ? _hold.value : 1.0;
                  return Opacity(
                    opacity: breath,
                    child: child,
                  );
                },
                child: PixelGrid(
                  pattern: OnboardingPixelPatterns.badgeOc,
                  colors: c,
                  cellSize: 5,
                  gap: 1,
                  enter: enter,
                  swarmSeed: _seed,
                ),
              ),
              const SizedBox(height: 12),
              FadeTransition(
                opacity: _wordEnter,
                child: SlideTransition(
                  position: _wordSlide,
                  child: ScaleTransition(
                    scale: _wordScale,
                    child: Text(
                      'OpenCore',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              AnimatedBuilder(
                animation: Listenable.merge([_ruleEnter, _hold]),
                builder: (context, _) {
                  final breath = live ? _hold.value : 1.0;
                  return Opacity(
                    opacity: _ruleEnter.value * breath,
                    child: PixelGrid(
                      pattern: OnboardingPixelPatterns.link,
                      colors: c,
                      cellSize: 4,
                      gap: 1,
                      enter: enter,
                      swarmSeed: _seed + 1,
                      scaleX: 0.1 + 0.9 * _ruleEnter.value,
                      transformOrigin: Alignment.center,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
