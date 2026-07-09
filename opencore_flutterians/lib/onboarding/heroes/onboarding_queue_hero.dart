import 'package:flutter/material.dart';

import '../onboarding_theme.dart';
import '../onboarding_tokens.dart';
import 'onboarding_hero_strategy.dart';

class OnboardingQueueHeroStrategy extends OnboardingHeroStrategy {
  const OnboardingQueueHeroStrategy();

  @override
  Widget build({required bool active}) => OnboardingQueueHero(active: active);
}

class OnboardingQueueHero extends StatefulWidget {
  const OnboardingQueueHero({super.key, required this.active});

  final bool active;

  @override
  State<OnboardingQueueHero> createState() => _OnboardingQueueHeroState();
}

class _OnboardingQueueHeroState extends State<OnboardingQueueHero>
    with SingleTickerProviderStateMixin {
  static const _stagger = Duration(milliseconds: 60);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: OnboardingTokens.durationPage + _stagger * 2,
  );

  late final List<Animation<double>> _rowOpacities = List.generate(3, (i) {
    final start = i * 0.2;
    final end = (start + 0.6).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: OnboardingTokens.easeUi),
    );
  });

  @override
  void initState() {
    super.initState();
    if (widget.active) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant OnboardingQueueHero oldWidget) {
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
      children: List.generate(3, (i) {
        return Padding(
          padding: EdgeInsets.only(bottom: i < 2 ? 4 : 0),
          child: FadeTransition(
            opacity: _rowOpacities[i],
            child: _queueRow(c, widthFactor: 1.0 - i * 0.08),
          ),
        );
      }),
    );
  }

  Widget _queueRow(OnboardingColorTokens c, {required double widthFactor}) {
    return Align(
      alignment: Alignment.center,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: Container(
          height: 18,
          decoration: BoxDecoration(
            color: c.surfaceRaised,
            border: Border.all(color: c.borderVisible),
            borderRadius: BorderRadius.circular(OnboardingTokens.radiusControl),
          ),
        ),
      ),
    );
  }
}
