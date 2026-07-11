import 'package:flutter/material.dart';

import '../onboarding_page_model.dart';

/// Placeholder hero — reserved for future feature highlights.
class OnboardingBlankHero extends StatelessWidget {
  const OnboardingBlankHero({super.key, required this.active});

  /// Whether this hero is on the visible onboarding page.
  final bool active;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class OnboardingHeroRegistry {
  static Widget build(OnboardingHeroId id, {required bool active}) {
    return OnboardingBlankHero(
      key: ValueKey(id),
      active: active,
    );
  }
}
