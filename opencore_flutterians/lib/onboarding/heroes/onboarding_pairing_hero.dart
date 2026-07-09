import 'package:flutter/material.dart';

import '../onboarding_theme.dart';
import '../onboarding_tokens.dart';
import 'onboarding_hero_strategy.dart';

class OnboardingPairingHeroStrategy extends OnboardingHeroStrategy {
  const OnboardingPairingHeroStrategy();

  @override
  Widget build({required bool active}) => OnboardingPairingHero(active: active);
}

class OnboardingPairingHero extends StatefulWidget {
  const OnboardingPairingHero({super.key, required this.active});

  final bool active;

  @override
  State<OnboardingPairingHero> createState() => _OnboardingPairingHeroState();
}

class _OnboardingPairingHeroState extends State<OnboardingPairingHero>
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
  void didUpdateWidget(covariant OnboardingPairingHero oldWidget) {
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
    return FadeTransition(
      opacity: _opacity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _device(c),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.lock_outline, color: c.accent, size: 20),
          ),
          _device(c),
        ],
      ),
    );
  }

  Widget _device(OnboardingColorTokens c) {
    return Container(
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(color: c.borderVisible),
        borderRadius: BorderRadius.circular(OnboardingTokens.radiusControl),
      ),
    );
  }
}
