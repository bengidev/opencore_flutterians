import 'package:flutter/material.dart';

import '../onboarding_theme.dart';
import '../onboarding_tokens.dart';
import 'onboarding_hero_stage.dart';
import 'onboarding_hero_strategy.dart';
import 'pixel/onboarding_hero_motion.dart';
import 'pixel/pixel_grid.dart';
import 'pixel/pixel_pattern.dart';
import 'pixel/pixel_swarm.dart';

class OnboardingPairingHeroStrategy extends OnboardingHeroStrategy {
  const OnboardingPairingHeroStrategy();

  @override
  Widget build({required bool active}) => OnboardingPairingHero(active: active);
}

/// Swarm cloud → pixel devices + lock link assemble into pairing GUI.
class OnboardingPairingHero extends HeroActiveWidget {
  const OnboardingPairingHero({super.key, required this.active});

  final bool active;

  @override
  State<OnboardingPairingHero> createState() => _OnboardingPairingHeroState();
}

class _OnboardingPairingHeroState extends State<OnboardingPairingHero>
    with TickerProviderStateMixin, OnboardingHeroMotion {
  static const _seed = 11;
  static final _motifs = [
    OnboardingPixelPatterns.device,
    OnboardingPixelPatterns.deviceScreen,
    OnboardingPixelPatterns.link,
    OnboardingPixelPatterns.lockOpen,
    OnboardingPixelPatterns.badgeE2e,
  ];

  @override
  bool get heroActive => widget.active;

  late final Animation<double> _devicesEnter = CurvedAnimation(
    parent: enter,
    curve: const Interval(0.12, 0.58, curve: OnboardingTokens.easeOut),
  );
  late final Animation<double> _linkEnter = CurvedAnimation(
    parent: enter,
    curve: const Interval(0.38, 0.72, curve: OnboardingTokens.easeOut),
  );
  late final Animation<double> _lockMorph = CurvedAnimation(
    parent: enter,
    curve: const Interval(0.55, 0.95, curve: OnboardingTokens.easeOut),
  );
  late final Animation<double> _linkBreath = lifePulse();
  late final Animation<double> _lockBreath = lifePulse();

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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _PixelDevice(
                  colors: c,
                  swarmEnter: enter,
                  reveal: _devicesEnter,
                  mirror: false,
                  seed: _seed,
                ),
                SizedBox(
                  width: 52,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: Listenable.merge([_linkEnter, _linkBreath]),
                        builder: (context, _) {
                          final breath = live ? _linkBreath.value : 1.0;
                          return Opacity(
                            opacity: _linkEnter.value * breath,
                            child: PixelGrid(
                              pattern: OnboardingPixelPatterns.link,
                              colors: c,
                              cellSize: 4,
                              gap: 1,
                              enter: enter,
                              swarmSeed: _seed + 2,
                              scaleX: 0.12 + 0.88 * _linkEnter.value,
                              transformOrigin: Alignment.center,
                            ),
                          );
                        },
                      ),
                      AnimatedBuilder(
                        animation: Listenable.merge([_lockMorph, _lockBreath]),
                        builder: (context, _) {
                          final breath = live ? _lockBreath.value : 1.0;
                          return Opacity(
                            opacity: _lockMorph.value * breath,
                            child: PixelGrid(
                              pattern: OnboardingPixelPatterns.lockOpen,
                              colors: c,
                              cellSize: 3,
                              gap: 0.5,
                              enter: enter,
                              morph: _lockMorph,
                              morphTarget: OnboardingPixelPatterns.lockClosed,
                              swarmSeed: _seed + 3,
                              staggerCells: false,
                              swarmSpread: 16,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                _PixelDevice(
                  colors: c,
                  swarmEnter: enter,
                  reveal: _devicesEnter,
                  mirror: true,
                  seed: _seed + 1,
                ),
              ],
            ),
            const SizedBox(height: 14),
            PixelGrid(
              pattern: OnboardingPixelPatterns.badgeE2e,
              colors: c,
              cellSize: 4,
              gap: 1,
              enter: enter,
              swarmSeed: _seed + 4,
            ),
          ],
        ),
      ),
    );
  }
}

class _PixelDevice extends StatelessWidget {
  const _PixelDevice({
    required this.colors,
    required this.swarmEnter,
    required this.reveal,
    required this.mirror,
    required this.seed,
  });

  final OnboardingColorTokens colors;
  final Animation<double> swarmEnter;
  final Animation<double> reveal;
  final bool mirror;
  final int seed;

  @override
  Widget build(BuildContext context) {
    final body = PixelPanel(
      colors: colors,
      padding: const EdgeInsets.all(8),
      reveal: reveal,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PixelGrid(
            pattern: OnboardingPixelPatterns.device,
            colors: colors,
            cellSize: 3,
            gap: 1,
            enter: swarmEnter,
            swarmSeed: seed,
          ),
          const SizedBox(height: 6),
          PixelGrid(
            pattern: OnboardingPixelPatterns.deviceScreen,
            colors: colors,
            cellSize: 3,
            gap: 1,
            enter: swarmEnter,
            swarmSeed: seed + 10,
            totalStaggerCells:
                OnboardingPixelPatterns.device.cellCount +
                OnboardingPixelPatterns.deviceScreen.cellCount,
          ),
        ],
      ),
    );
    if (mirror) {
      return Transform.flip(flipX: true, child: body);
    }
    return body;
  }
}
