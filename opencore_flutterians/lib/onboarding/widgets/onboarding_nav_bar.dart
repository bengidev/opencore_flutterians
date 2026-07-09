import 'package:flutter/material.dart';

import '../onboarding_page_model.dart';
import 'onboarding_skip_control.dart';

class OnboardingNavBar extends StatelessWidget {
  const OnboardingNavBar({
    super.key,
    required this.kind,
    required this.isFirst,
    required this.isCta,
    required this.enterError,
    required this.isEntering,
    required this.onBack,
    required this.onNext,
    required this.onSkip,
    required this.onEnter,
  });

  final OnboardingPageKind kind;
  final bool isFirst;
  final bool isCta;
  final String? enterError;
  final bool isEntering;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final Future<void> Function() onEnter;

  @override
  Widget build(BuildContext context) {
    if (isCta || kind == OnboardingPageKind.cta) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (enterError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                enterError!,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
            ),
          FilledButton(
            onPressed: isEntering ? null : () => onEnter(),
            child: Text(
              'ENTER',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OnboardingSkipControl(onSkip: onSkip),
        const SizedBox(height: 8),
        if (isFirst)
          FilledButton(
            onPressed: onNext,
            child: Text(
              'CONTINUE',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
          )
        else
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onBack,
                  child: Text('BACK', style: Theme.of(context).textTheme.labelSmall),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: onNext,
                  child: Text(
                    'NEXT',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
