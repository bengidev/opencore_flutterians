import 'package:flutter/material.dart';

import '../onboarding_tokens.dart';
import 'onboarding_hero_strategy.dart';

class OnboardingBrandHeroStrategy extends OnboardingHeroStrategy {
  const OnboardingBrandHeroStrategy();

  @override
  Widget build({required bool active}) => OnboardingBrandHero(active: active);
}

class OnboardingBrandHero extends StatefulWidget {
  const OnboardingBrandHero({super.key, required this.active});

  final bool active;

  @override
  State<OnboardingBrandHero> createState() => _OnboardingBrandHeroState();
}

class _OnboardingBrandHeroState extends State<OnboardingBrandHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: OnboardingTokens.durationPage,
  );
  late final Animation<double> _opacity = CurvedAnimation(
    parent: _controller,
    curve: OnboardingTokens.easeUi,
  );

  @override
  void initState() {
    super.initState();
    if (widget.active) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant OnboardingBrandHero oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Text(
        'OpenCore',
        style: Theme.of(context).textTheme.displayLarge,
      ),
    );
  }
}
