import 'onboarding_page_model.dart';

class OnboardingPageCatalog {
  const OnboardingPageCatalog._();

  static List<OnboardingPageModel> build() => const [
        OnboardingPageModel(
          kind: OnboardingPageKind.feature,
          heroId: OnboardingHeroId.pairing,
          headline: 'End-to-end encrypted pairing and chats',
          body:
              'Pair trusted devices, keep local workspace context private, and open AI chats without leaking the conversation boundary.',
          featureStepLabel: '01 / 04',
        ),
        OnboardingPageModel(
          kind: OnboardingPageKind.feature,
          heroId: OnboardingHeroId.workspace,
          headline: 'Ask, write, and explore with AI models',
          body:
              'OpenCore turns prompts into a focused working surface for drafting, refactoring, research, and interface decisions.',
          featureStepLabel: '02 / 04',
        ),
        OnboardingPageModel(
          kind: OnboardingPageKind.feature,
          heroId: OnboardingHeroId.queue,
          headline: 'Queue follow-ups while a turn is running',
          body:
              'Keep momentum by lining up the next question, test request, or implementation step before the current model turn finishes.',
          featureStepLabel: '03 / 04',
        ),
        OnboardingPageModel(
          kind: OnboardingPageKind.feature,
          heroId: OnboardingHeroId.depth,
          headline: 'Tune how much thinking the AI uses',
          body:
              'Choose faster answers, balanced planning, or deeper reasoning before the model commits compute to the task.',
          featureStepLabel: '04 / 04',
        ),
        OnboardingPageModel(
          kind: OnboardingPageKind.cta,
          heroId: OnboardingHeroId.brand,
          headline: 'OpenCore',
          body:
              'Your AI-native command center. Deploy specialized agents to handle code, review, test, and ship — all within your existing workflow without context switching.',
          featureStepLabel: null,
        ),
      ];
}
