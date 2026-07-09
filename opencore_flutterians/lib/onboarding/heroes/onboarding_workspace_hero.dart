import 'package:flutter/material.dart';

import '../onboarding_theme.dart';
import '../onboarding_tokens.dart';
import 'onboarding_hero_strategy.dart';

class OnboardingWorkspaceHeroStrategy extends OnboardingHeroStrategy {
  const OnboardingWorkspaceHeroStrategy();

  @override
  Widget build({required bool active}) => OnboardingWorkspaceHero(active: active);
}

class OnboardingWorkspaceHero extends StatefulWidget {
  const OnboardingWorkspaceHero({super.key, required this.active});

  final bool active;

  @override
  State<OnboardingWorkspaceHero> createState() => _OnboardingWorkspaceHeroState();
}

class _OnboardingWorkspaceHeroState extends State<OnboardingWorkspaceHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: OnboardingTokens.durationPage,
  );
  late final Animation<double> _promptOpacity = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.5, curve: OnboardingTokens.easeUi),
  );
  late final Animation<double> _surfaceOpacity = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.35, 1, curve: OnboardingTokens.easeUi),
  );

  @override
  void initState() {
    super.initState();
    if (widget.active) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant OnboardingWorkspaceHero oldWidget) {
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
    final c = OnboardingThemeColors.of(context).colors;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FadeTransition(
          opacity: _promptOpacity,
          child: Container(
            width: 160,
            height: 8,
            decoration: BoxDecoration(
              color: c.textSecondary,
              borderRadius: BorderRadius.circular(OnboardingTokens.radiusControl),
            ),
          ),
        ),
        const SizedBox(height: 6),
        FadeTransition(
          opacity: _surfaceOpacity,
          child: Container(
            width: 180,
            height: 44,
            decoration: BoxDecoration(
              color: c.surfaceRaised,
              border: Border.all(color: c.borderVisible),
              borderRadius: BorderRadius.circular(OnboardingTokens.radiusControl),
            ),
          ),
        ),
      ],
    );
  }
}
