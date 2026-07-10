import 'package:flutter/material.dart';

import '../onboarding_theme.dart';
import '../onboarding_tokens.dart';
import 'onboarding_hero_stage.dart';
import 'onboarding_hero_strategy.dart';
import 'pixel/onboarding_hero_motion.dart';
import 'pixel/pixel_cell_role.dart';
import 'pixel/pixel_grid.dart';
import 'pixel/pixel_pattern.dart';
import 'pixel/pixel_swarm.dart';

class OnboardingDepthHeroStrategy extends OnboardingHeroStrategy {
  const OnboardingDepthHeroStrategy();

  @override
  Widget build({required bool active}) => OnboardingDepthHero(active: active);
}

/// Swarm → depth bars assemble; BALANCED grows from left origin.
class OnboardingDepthHero extends HeroActiveWidget {
  const OnboardingDepthHero({super.key, required this.active});

  final bool active;

  @override
  State<OnboardingDepthHero> createState() => _OnboardingDepthHeroState();
}

class _OnboardingDepthHeroState extends State<OnboardingDepthHero>
    with TickerProviderStateMixin, OnboardingHeroMotion {
  static const _seed = 44;
  static const _labels = ['FAST', 'BALANCED', 'DEEP'];
  static const _activeIndex = 1;

  static final _bars = [
    OnboardingPixelPatterns.barFastMuted,
    OnboardingPixelPatterns.barBalanced,
    OnboardingPixelPatterns.barDeepMuted,
  ];

  static final _motifs = [
    OnboardingPixelPatterns.barFastMuted,
    OnboardingPixelPatterns.barBalanced,
    OnboardingPixelPatterns.barDeepMuted,
  ];

  @override
  bool get heroActive => widget.active;

  late final List<Animation<double>> _segmentEnters = List.generate(3, (i) {
    final start = 0.14 + i * 0.1;
    return CurvedAnimation(
      parent: enter,
      curve: Interval(
        start,
        (start + 0.5).clamp(0.0, 1.0),
        curve: OnboardingTokens.easeOut,
      ),
    );
  });

  late final Animation<double> _barGrow = CurvedAnimation(
    parent: enter,
    curve: const Interval(0.52, 0.96, curve: OnboardingTokens.easeOut),
  );

  late final Animation<double> _selectionBreath = lifePulse();

  @override
  Widget build(BuildContext context) {
    final c = OnboardingThemeColors.of(context).colors;
    final live = enter.isCompleted;

    return OnboardingHeroStage(
      designHeight: 148,
      child: PixelHeroAssembly(
        enter: enter,
        colors: c,
        seed: _seed,
        motifs: _motifs,
        cloudWidth: 270,
        cloudHeight: 140,
        particleCount: 140,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_labels.length, (i) {
            final isActive = i == _activeIndex;
            return Padding(
              padding: EdgeInsets.only(left: i > 0 ? 14 : 0),
              child: _DepthSegment(
                colors: c,
                label: _labels[i],
                pattern: _bars[i],
                swarmEnter: enter,
                reveal: _segmentEnters[i],
                barGrow: isActive ? _barGrow : null,
                breath: isActive ? _selectionBreath : null,
                active: isActive,
                live: live,
                seed: _seed + i,
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _DepthSegment extends StatelessWidget {
  const _DepthSegment({
    required this.colors,
    required this.label,
    required this.pattern,
    required this.swarmEnter,
    required this.reveal,
    required this.active,
    required this.live,
    required this.seed,
    this.barGrow,
    this.breath,
  });

  final OnboardingColorTokens colors;
  final String label;
  final PixelPattern pattern;
  final Animation<double> swarmEnter;
  final Animation<double> reveal;
  final Animation<double>? barGrow;
  final Animation<double>? breath;
  final bool active;
  final bool live;
  final int seed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PixelPanel(
          colors: colors,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          reveal: reveal,
          child: AnimatedBuilder(
            animation: Listenable.merge([barGrow, breath]),
            builder: (context, _) {
              final grow = active && barGrow != null ? barGrow!.value : 1.0;
              final pulse =
                  active && live && breath != null ? breath!.value : 1.0;
              return Opacity(
                opacity: pulse,
                child: PixelGrid(
                  pattern: pattern,
                  colors: colors,
                  cellSize: 4,
                  gap: 1,
                  enter: swarmEnter,
                  swarmSeed: seed,
                  swarmSpread: 28,
                  scaleX: grow,
                  transformOrigin: Alignment.centerLeft,
                  pulse: active ? breath : null,
                  pulseRoles: {
                    PixelCellRole.accent,
                    PixelCellRole.primary,
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        PixelAsciiLabel(
          text: label,
          colors: colors,
          accent: active,
          fontSize: 10,
          reveal: reveal,
        ),
      ],
    );
  }
}
