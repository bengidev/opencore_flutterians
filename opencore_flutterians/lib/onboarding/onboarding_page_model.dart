enum OnboardingPageKind { feature, cta }

enum OnboardingHeroId { pairing, workspace, queue, depth, brand }

class OnboardingPageModel {
  const OnboardingPageModel({
    required this.kind,
    required this.heroId,
    required this.headline,
    required this.body,
    required this.featureStepLabel,
  });

  final OnboardingPageKind kind;
  final OnboardingHeroId heroId;
  final String headline;
  final String body;

  /// Null on CTA. Feature pages use values like `01 / 04`.
  final String? featureStepLabel;
}
