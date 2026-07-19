import 'package:flutter/material.dart';

import '../onboarding_page_model.dart';
import 'brand_hero.dart';
import 'depth_hero.dart';
import 'pairing_hero.dart';
import 'queue_hero.dart';
import 'workspace_hero.dart';

class OnboardingHeroRegistry {
  const OnboardingHeroRegistry._();

  static const Size _featureSize = Size(320, 280);
  static const Size _brandSize = Size(300, 300);

  static Widget build(OnboardingHeroId id, {required bool active}) {
    final Widget hero = switch (id) {
      OnboardingHeroId.pairing => PairingHero(key: ValueKey(id), active: active),
      OnboardingHeroId.workspace => WorkspaceHero(key: ValueKey(id), active: active),
      OnboardingHeroId.queue => QueueHero(key: ValueKey(id), active: active),
      OnboardingHeroId.depth => DepthHero(key: ValueKey(id), active: active),
      OnboardingHeroId.brand => BrandHero(key: ValueKey(id), active: active),
    };

    final designSize = id == OnboardingHeroId.brand ? _brandSize : _featureSize;
    return LayoutBuilder(
      builder: (context, constraints) {
        return FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.center,
          child: SizedBox(
            width: designSize.width,
            height: designSize.height,
            child: hero,
          ),
        );
      },
    );
  }
}
