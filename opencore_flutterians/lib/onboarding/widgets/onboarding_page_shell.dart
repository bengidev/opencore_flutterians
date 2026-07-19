import 'package:flutter/material.dart';

import '../onboarding_page_model.dart';

class OnboardingPageShell extends StatelessWidget {
  const OnboardingPageShell({
    super.key,
    required this.page,
    required this.hero,
    this.topInset = 48,
  });

  final OnboardingPageModel page;
  final Widget hero;

  /// Space below the persistent feature header, or top breathing room on CTA.
  final double topInset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: topInset),
          Expanded(child: Center(child: hero)),
          const SizedBox(height: 32),
          Text(page.headline, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 12),
          Text(page.body, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
