import 'package:flutter/material.dart';

import '../onboarding_theme.dart';
import '../onboarding_tokens.dart';
import 'onboarding_hero_strategy.dart';

class OnboardingDepthHeroStrategy extends OnboardingHeroStrategy {
  const OnboardingDepthHeroStrategy();

  @override
  Widget build({required bool active}) => OnboardingDepthHero(active: active);
}

class OnboardingDepthHero extends StatefulWidget {
  const OnboardingDepthHero({super.key, required this.active});

  final bool active;

  @override
  State<OnboardingDepthHero> createState() => _OnboardingDepthHeroState();
}

class _OnboardingDepthHeroState extends State<OnboardingDepthHero>
    with SingleTickerProviderStateMixin {
  static const _labels = ['FAST', 'BALANCED', 'DEEP'];
  static const _activeIndex = 1;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: OnboardingTokens.durationPage,
  );
  late final Animation<double> _selectionOpacity = CurvedAnimation(
    parent: _controller,
    curve: OnboardingTokens.easeUi,
  );

  @override
  void initState() {
    super.initState();
    if (widget.active) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant OnboardingDepthHero oldWidget) {
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
    final labelStyle = Theme.of(context).textTheme.labelSmall;

    return AnimatedBuilder(
      animation: _selectionOpacity,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_labels.length, (i) {
            final isActive = i == _activeIndex;
            final segmentOpacity = isActive ? _selectionOpacity.value : 1.0;

            return Padding(
              padding: EdgeInsets.only(left: i > 0 ? 8 : 0),
              child: Opacity(
                opacity: segmentOpacity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive ? c.accent : c.surfaceRaised,
                        border: Border.all(
                          color: isActive ? c.accent : c.borderVisible,
                        ),
                        borderRadius:
                            BorderRadius.circular(OnboardingTokens.radiusControl),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _labels[i],
                      style: labelStyle?.copyWith(
                        color: isActive ? c.accent : c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
