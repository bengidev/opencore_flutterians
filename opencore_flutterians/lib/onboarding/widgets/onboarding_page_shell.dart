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

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 420;
        final inset = compact ? (topInset * 0.5).clamp(0.0, topInset) : topInset;
        final gapAfterHero = compact ? 16.0 : 32.0;
        final gapAfterHeadline = compact ? 8.0 : 12.0;

        final copy = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              page.headline,
              softWrap: true,
              style: theme.textTheme.headlineMedium,
            ),
            SizedBox(height: gapAfterHeadline),
            Text(
              page.body,
              softWrap: true,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        );

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: inset),
              Expanded(
                flex: compact ? 3 : 5,
                child: Center(child: hero),
              ),
              SizedBox(height: gapAfterHero),
              Flexible(
                flex: compact ? 4 : 3,
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: copy,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
