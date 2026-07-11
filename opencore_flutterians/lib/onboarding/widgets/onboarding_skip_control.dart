import 'package:flutter/material.dart';

import 'onboarding_tactile_button.dart';

class OnboardingSkipControl extends StatelessWidget {
  const OnboardingSkipControl({super.key, required this.onSkip});

  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: OnboardingTextButton(
        onPressed: onSkip,
        child: Text('SKIP', style: Theme.of(context).textTheme.labelSmall),
      ),
    );
  }
}
