import 'package:flutter/material.dart';

import '../onboarding_motion.dart';
import '../onboarding_page_model.dart';
import '../onboarding_theme.dart';
import '../onboarding_tokens.dart';
import 'onboarding_skip_control.dart';
import 'onboarding_tactile_button.dart';

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
    final reduceMotion = OnboardingMotion.reduceMotionOf(context);
    final duration = reduceMotion ? Duration.zero : OnboardingTokens.durationUi;

    if (isCta || kind == OnboardingPageKind.cta) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedSwitcher(
            duration: duration,
            switchInCurve: OnboardingTokens.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) =>
                OnboardingMotion.fadeSlide(child, animation: animation),
            child: enterError == null
                ? const SizedBox.shrink(key: ValueKey('enter-error-empty'))
                : Padding(
                    key: ValueKey(enterError),
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      enterError!,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                    ),
                  ),
          ),
          OnboardingFilledButton(
            onPressed: isEntering ? null : () => onEnter(),
            enabled: !isEntering,
            child: _EnterLabel(isEntering: isEntering),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OnboardingSkipControl(onSkip: onSkip),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: duration,
          switchInCurve: OnboardingTokens.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) => OnboardingMotion.fadeSlide(
            child,
            animation: animation,
            offsetY: 0.05,
          ),
          child: isFirst
              ? OnboardingFilledButton(
                  key: const ValueKey('nav-continue'),
                  onPressed: onNext,
                  child: Text('CONTINUE', style: Theme.of(context).textTheme.labelSmall),
                )
              : Row(
                  key: const ValueKey('nav-back-next'),
                  children: [
                    Expanded(
                      child: OnboardingOutlinedButton(
                        onPressed: onBack,
                        child: Text('BACK', style: Theme.of(context).textTheme.labelSmall),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OnboardingFilledButton(
                        onPressed: onNext,
                        child: Text('NEXT', style: Theme.of(context).textTheme.labelSmall),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _EnterLabel extends StatelessWidget {
  const _EnterLabel({required this.isEntering});

  final bool isEntering;

  @override
  Widget build(BuildContext context) {
    final c = OnboardingThemeColors.of(context).colors;
    return AnimatedSwitcher(
      duration: OnboardingTokens.durationUi,
      switchInCurve: OnboardingTokens.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: isEntering
          ? SizedBox(
              key: const ValueKey('enter-loading'),
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: c.black,
              ),
            )
          : Text(
              'ENTER',
              key: const ValueKey('enter-label'),
              style: Theme.of(context).textTheme.labelSmall,
            ),
    );
  }
}
