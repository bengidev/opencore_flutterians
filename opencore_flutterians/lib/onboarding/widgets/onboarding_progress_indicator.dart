import 'package:flutter/material.dart';

import '../onboarding_theme.dart';
import '../onboarding_tokens.dart';

class OnboardingProgressIndicator extends StatelessWidget {
  const OnboardingProgressIndicator({
    super.key,
    required this.index,
    required this.featureCount,
  });

  final int index;
  final int featureCount;

  @override
  Widget build(BuildContext context) {
    final c = OnboardingThemeColors.of(context).colors;
    return Row(
      children: List.generate(featureCount, (i) {
        final active = i == index.clamp(0, featureCount - 1) && index < featureCount;
        return AnimatedContainer(
          duration: OnboardingTokens.durationUi,
          curve: OnboardingTokens.easeUi,
          margin: const EdgeInsets.only(right: 8),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? c.accent : c.borderVisible,
            borderRadius: BorderRadius.circular(OnboardingTokens.radiusControl),
          ),
        );
      }),
    );
  }
}
