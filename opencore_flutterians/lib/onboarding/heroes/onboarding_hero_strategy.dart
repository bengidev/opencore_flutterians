import 'package:flutter/material.dart';

import '../onboarding_page_model.dart';
import 'onboarding_brand_hero.dart';
import 'onboarding_depth_hero.dart';
import 'onboarding_pairing_hero.dart';
import 'onboarding_queue_hero.dart';
import 'onboarding_workspace_hero.dart';

export 'onboarding_brand_hero.dart';
export 'onboarding_depth_hero.dart';
export 'onboarding_pairing_hero.dart';
export 'onboarding_queue_hero.dart';
export 'onboarding_workspace_hero.dart';

abstract class OnboardingHeroStrategy {
  const OnboardingHeroStrategy();

  Widget build({required bool active});
}

class OnboardingHeroRegistry {
  static Widget build(OnboardingHeroId id, {required bool active}) {
    final strategy = switch (id) {
      OnboardingHeroId.pairing => const OnboardingPairingHeroStrategy(),
      OnboardingHeroId.workspace => const OnboardingWorkspaceHeroStrategy(),
      OnboardingHeroId.queue => const OnboardingQueueHeroStrategy(),
      OnboardingHeroId.depth => const OnboardingDepthHeroStrategy(),
      OnboardingHeroId.brand => const OnboardingBrandHeroStrategy(),
    };
    return strategy.build(active: active);
  }
}
