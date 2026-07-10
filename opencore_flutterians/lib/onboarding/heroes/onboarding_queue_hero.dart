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

/// Swarm → chat request/response bubbles with queued follow-up.
class OnboardingQueueHero extends HeroActiveWidget {
  const OnboardingQueueHero({super.key, required this.active});

  final bool active;

  @override
  State<OnboardingQueueHero> createState() => _OnboardingQueueHeroState();
}

class _OnboardingQueueHeroState extends State<OnboardingQueueHero>
    with TickerProviderStateMixin, OnboardingHeroMotion {
  static const _seed = 33;
  static final _motifs = [
    OnboardingPixelPatterns.chatRequest,
    OnboardingPixelPatterns.chatResponse,
    OnboardingPixelPatterns.chatQueued,
  ];

  @override
  bool get heroActive => widget.active;

  late final Animation<double> _requestEnter = CurvedAnimation(
    parent: enter,
    curve: const Interval(0.14, 0.52, curve: OnboardingTokens.easeOut),
  );
  late final Animation<double> _responseEnter = CurvedAnimation(
    parent: enter,
    curve: const Interval(0.28, 0.72, curve: OnboardingTokens.easeOut),
  );
  late final Animation<double> _queuedEnter = CurvedAnimation(
    parent: enter,
    curve: const Interval(0.42, 0.88, curve: OnboardingTokens.easeOut),
  );

  late final Animation<double> _pulse = lifePulse();
  late final Animation<double> _progress = lifeProgress();

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
      designHeight: 168,
      child: PixelHeroAssembly(
        enter: enter,
        colors: c,
        seed: _seed,
        motifs: _motifs,
        onReplay: replayHero,
        cloudWidth: 320,
        cloudHeight: 160,
        particleCount: 160,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: _ChatBubble(
                colors: c,
                label: 'YOU',
                pattern: OnboardingPixelPatterns.chatRequest,
                swarmEnter: enter,
                reveal: _requestEnter,
                accent: false,
                live: live,
                seed: _seed,
                maxWidthFactor: 0.72,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: _ChatBubble(
                colors: c,
                label: 'RUNNING…',
                pattern: OnboardingPixelPatterns.chatResponse,
                swarmEnter: enter,
                reveal: _responseEnter,
                accent: true,
                live: live,
                seed: _seed + 1,
                progress: _progress,
                pulse: _pulse,
                maxWidthFactor: 0.82,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: _ChatBubble(
                colors: c,
                label: 'QUEUED',
                pattern: OnboardingPixelPatterns.chatQueued,
                swarmEnter: enter,
                reveal: _queuedEnter,
                accent: false,
                live: false,
                seed: _seed + 2,
                maxWidthFactor: 0.64,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.colors,
    required this.label,
    required this.pattern,
    required this.swarmEnter,
    required this.reveal,
    required this.accent,
    required this.live,
    required this.seed,
    required this.maxWidthFactor,
    this.progress,
    this.pulse,
  });

  final OnboardingColorTokens colors;
  final String label;
  final PixelPattern pattern;
  final Animation<double> swarmEnter;
  final Animation<double> reveal;
  final bool accent;
  final bool live;
  final int seed;
  final double maxWidthFactor;
  final Animation<double>? progress;
  final Animation<double>? pulse;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: maxWidthFactor,
      child: PixelPanel(
        colors: colors,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        reveal: reveal,
        child: Row(
          children: [
            PixelGrid(
              pattern: pattern,
              colors: colors,
              cellSize: 3.5,
              gap: 0.8,
              enter: swarmEnter,
              swarmSeed: seed,
              pulse: accent ? pulse : null,
              pulseRoles: const {PixelCellRole.accent},
            ),
            const SizedBox(width: 8),
            Expanded(
              child: PixelAsciiLabel(
                text: label,
                colors: colors,
                accent: accent,
                reveal: reveal,
              ),
            ),
            if (progress != null) ...[
              const SizedBox(width: 8),
              PixelProgressBar(
                colors: colors,
                animation: progress!,
                live: live,
                enter: swarmEnter,
                swarmSeed: seed + 9,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
