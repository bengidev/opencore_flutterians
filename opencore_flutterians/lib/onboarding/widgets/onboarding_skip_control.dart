import 'package:flutter/material.dart';

class OnboardingSkipControl extends StatelessWidget {
  const OnboardingSkipControl({super.key, required this.onSkip});

  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: onSkip,
        child: Text('SKIP', style: Theme.of(context).textTheme.labelSmall),
      ),
    );
  }
}
