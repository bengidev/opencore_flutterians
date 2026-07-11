import 'package:flutter/material.dart';

import '../onboarding_page_model.dart';
import 'onboarding_progress_indicator.dart';

class OnboardingPageShell extends StatelessWidget {
  const OnboardingPageShell({
    super.key,
    required this.page,
    required this.pageIndex,
    required this.featureCount,
    required this.hero,
    required this.navBar,
  });

  final OnboardingPageModel page;
  final int pageIndex;
  final int featureCount;
  final Widget hero;
  final Widget navBar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (page.kind == OnboardingPageKind.feature) ...[
              Row(
                children: [
                  OnboardingProgressIndicator(
                    index: pageIndex,
                    featureCount: featureCount,
                  ),
                  const Spacer(),
                  Text(
                    page.featureStepLabel ?? '',
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
              const SizedBox(height: 48),
            ] else
              const SizedBox(height: 64),
            Expanded(child: Center(child: hero)),
            const SizedBox(height: 32),
            Text(page.headline, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 12),
            Text(page.body, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 32),
            navBar,
          ],
        ),
      ),
    );
  }
}
