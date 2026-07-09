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
  late final Animation<double> _deviceOpacity = CurvedAnimation(
    parent: _controller,
    curve: OnboardingTokens.easeUi,
  );
  late final Animation<double> _lockOpacity = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.4, 1.0, curve: OnboardingTokens.easeUi),
  );
  late final Animation<double> _lockScale = Tween<double>(
    begin: 0.95,
    end: 1.0,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: OnboardingTokens.easeUi),
    ),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FadeTransition(opacity: _deviceOpacity, child: _device(c)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FadeTransition(
            opacity: _lockOpacity,
            child: ScaleTransition(
              scale: _lockScale,
              child: Icon(Icons.lock_outline, color: c.accent, size: 20),
            ),
          ),
        ),
        FadeTransition(opacity: _deviceOpacity, child: _device(c)),
      ],
    );
  }

  Widget _device(OnboardingColorTokens c) {
    return Container(
      width: 56,
      height: 88,
      decoration: BoxDecoration(
        border: Border.all(color: c.borderVisible),
        borderRadius: BorderRadius.circular(OnboardingTokens.radiusControl),
      ),
    );
  }
}
