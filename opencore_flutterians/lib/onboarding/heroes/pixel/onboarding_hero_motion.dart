import 'package:flutter/material.dart';

import '../../onboarding_tokens.dart';

/// Widgets using [OnboardingHeroMotion] must expose [active].
abstract class HeroActiveWidget extends StatefulWidget {
  const HeroActiveWidget({super.key});

  bool get active;
}

/// Shared enter + ambient life cycle for onboarding heroes.
mixin OnboardingHeroMotion<T extends HeroActiveWidget>
    on State<T>, TickerProviderStateMixin<T> {
  late final AnimationController enter = AnimationController(
    vsync: this,
    duration: OnboardingTokens.durationHeroEnter,
  );
  late final AnimationController life = AnimationController(
    vsync: this,
    duration: OnboardingTokens.durationHeroLife,
  );

  bool get heroActive;

  @override
  void initState() {
    super.initState();
    enter.addStatusListener(_onEnterStatus);
    if (heroActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) playHero();
      });
    }
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasActive = oldWidget.active;
    if (heroActive && !wasActive) {
      playHero(fromStart: true);
    } else if (!heroActive && wasActive) {
      stopLife();
    }
  }

  void _onEnterStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && heroActive) {
      startLife();
    }
  }

  void replayHero() => playHero(fromStart: true);

  void playHero({bool fromStart = false}) {
    if (!mounted) return;
    stopLife();
    if (MediaQuery.disableAnimationsOf(context)) {
      enter.value = 1;
      return;
    }
    if (fromStart) {
      enter.forward(from: 0);
    } else {
      enter.forward();
    }
  }

  void startLife() {
    if (!mounted || !heroActive) return;
    if (MediaQuery.disableAnimationsOf(context)) return;
    life.repeat();
  }

  void stopLife() {
    life.stop();
    life.value = 0;
  }

  @override
  void dispose() {
    enter.removeStatusListener(_onEnterStatus);
    enter.dispose();
    life.dispose();
    super.dispose();
  }

  Animation<double> lifePulse() {
    return TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.45, end: 1).chain(
          CurveTween(curve: OnboardingTokens.easeInOut),
        ),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0.45).chain(
          CurveTween(curve: OnboardingTokens.easeInOut),
        ),
        weight: 50,
      ),
    ]).animate(life);
  }

  Animation<double> lifeProgress() {
    return TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.25, end: 0.85).chain(
          CurveTween(curve: OnboardingTokens.easeInOut),
        ),
        weight: 55,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.85, end: 0.35).chain(
          CurveTween(curve: OnboardingTokens.easeInOut),
        ),
        weight: 45,
      ),
    ]).animate(life);
  }
}
