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

class OnboardingQueueHeroStrategy extends OnboardingHeroStrategy {
  const OnboardingQueueHeroStrategy();

  @override
  Widget build({required bool active}) => OnboardingQueueHero(active: active);
}

/// Swarm → queue rows stagger-assemble with live running state.
class OnboardingQueueHero extends HeroActiveWidget {
  const OnboardingQueueHero({super.key, required this.active});

  final bool active;

  @override
  State<OnboardingQueueHero> createState() => _OnboardingQueueHeroState();
}

class _OnboardingQueueHeroState extends State<OnboardingQueueHero>
    with TickerProviderStateMixin, OnboardingHeroMotion {
  static const _seed = 33;
  static final _motifs = [OnboardingPixelPatterns.queueArrow];

  @override
  bool get heroActive => widget.active;

  late final List<Animation<double>> _rowEnters = List.generate(3, (i) {
    final start = 0.16 + i * 0.12;
    return CurvedAnimation(
      parent: enter,
      curve: Interval(
        start,
        (start + 0.48).clamp(0.0, 1.0),
        curve: OnboardingTokens.easeOut,
      ),
    );
  });

  late final Animation<double> _pulse = lifePulse();
  late final Animation<double> _progress = lifeProgress();

  static const _labels = ['RUNNING…', 'QUEUED', 'QUEUED'];

  @override
  void initState() {
    super.initState();
    life.duration = const Duration(milliseconds: 1100);
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: PixelGrid(
                pattern: OnboardingPixelPatterns.queueArrow,
                colors: c,
                cellSize: 4,
                gap: 1,
                enter: enter,
                swarmSeed: _seed,
                pulse: _pulse,
                pulseRoles: const {PixelCellRole.accent},
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  final accent = i == 0;
                  return Padding(
                    padding: EdgeInsets.only(bottom: i < 2 ? 8 : 0),
                    child: _QueuePixelRow(
                      colors: c,
                      label: _labels[i],
                      accent: accent,
                      swarmEnter: enter,
                      rowEnter: _rowEnters[i],
                      pulse: _pulse,
                      progress: _progress,
                      live: live,
                      widthFactor: 1.0 - i * 0.06,
                      seed: _seed + i,
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QueuePixelRow extends StatelessWidget {
  const _QueuePixelRow({
    required this.colors,
    required this.label,
    required this.accent,
    required this.swarmEnter,
    required this.rowEnter,
    required this.pulse,
    required this.progress,
    required this.live,
    required this.widthFactor,
    required this.seed,
  });

  final OnboardingColorTokens colors;
  final String label;
  final bool accent;
  final Animation<double> swarmEnter;
  final Animation<double> rowEnter;
  final Animation<double> pulse;
  final Animation<double> progress;
  final bool live;
  final double widthFactor;
  final int seed;

  @override
  Widget build(BuildContext context) {
    return Align(
      child: FractionallySizedBox(
        widthFactor: widthFactor.clamp(0.72, 1.0),
        child: PixelPanel(
          colors: colors,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          reveal: rowEnter,
          child: SizedBox(
            height: 20,
            child: Row(
              children: [
                PixelStatusDot(
                  colors: colors,
                  animation: pulse,
                  accent: accent,
                  live: live,
                  enter: swarmEnter,
                  swarmSeed: seed,
                ),
                const SizedBox(width: 8),
                PixelAsciiLabel(
                  text: label,
                  colors: colors,
                  accent: accent,
                  reveal: rowEnter,
                ),
                const Spacer(),
                PixelProgressBar(
                  colors: colors,
                  animation: progress,
                  live: accent && live,
                  enter: swarmEnter,
                  swarmSeed: seed + 5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
