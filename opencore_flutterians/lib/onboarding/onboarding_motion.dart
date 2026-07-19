import 'package:flutter/material.dart';

import 'onboarding_tokens.dart';

/// Shared motion helpers for onboarding surfaces.
abstract final class OnboardingMotion {
  static bool reduceMotionOf(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);

  static Duration get pageDuration =>
      OnboardingTokens.durationPage;

  static Curve get pageCurve => OnboardingTokens.easeDrawer;

  /// Crossfade + slight lift for copy that swaps on the same surface.
  static Widget fadeSlide(
    Widget child, {
    required Animation<double> animation,
    double offsetY = 0.04,
  }) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: OnboardingTokens.easeOut,
      reverseCurve: Curves.easeIn,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, offsetY),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
