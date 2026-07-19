import 'package:flutter/material.dart';

import '../../onboarding_theme.dart';
import '../../onboarding_tokens.dart';

class OnboardingHeroFrame extends StatelessWidget {
  const OnboardingHeroFrame({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final colors = OnboardingThemeColors.of(context).colors;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: SizedBox(
        height: 280,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(OnboardingTokens.radiusControl + 2),
            border: Border.all(color: colors.borderVisible),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class OnboardingMiniPanel extends StatelessWidget {
  const OnboardingMiniPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(10),
    this.accentBorder = false,
  });

  final Widget child;
  final EdgeInsets padding;
  final bool accentBorder;

  @override
  Widget build(BuildContext context) {
    final colors = OnboardingThemeColors.of(context).colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: BorderRadius.circular(OnboardingTokens.radiusControl),
        border: Border.all(
          color: accentBorder ? colors.accent.withValues(alpha: 0.45) : colors.border,
        ),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
