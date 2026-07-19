import 'package:flutter/material.dart';

import '../onboarding_motion.dart';
import '../onboarding_tokens.dart';
import 'onboarding_progress_indicator.dart';

class OnboardingFeatureHeader extends StatelessWidget {
  const OnboardingFeatureHeader({
    super.key,
    required this.pageIndex,
    required this.featureCount,
    required this.stepLabel,
  });

  final int pageIndex;
  final int featureCount;
  final String? stepLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reduceMotion = OnboardingMotion.reduceMotionOf(context);
    final duration = reduceMotion ? Duration.zero : OnboardingTokens.durationUi;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          OnboardingProgressIndicator(
            index: pageIndex,
            featureCount: featureCount,
          ),
          const Spacer(),
          AnimatedSwitcher(
            duration: duration,
            switchInCurve: OnboardingTokens.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) =>
                OnboardingMotion.fadeSlide(child, animation: animation, offsetY: 0.02),
            child: Text(
              stepLabel ?? '',
              key: ValueKey(stepLabel),
              style: theme.textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}
