import 'package:flutter/material.dart';

import 'heroes/onboarding_hero_strategy.dart';
import 'onboarding_completion_store.dart';
import 'onboarding_flow_controller.dart';
import 'onboarding_page_catalog.dart';
import 'onboarding_page_model.dart';
import 'onboarding_theme.dart';
import 'onboarding_tokens.dart';
import 'widgets/onboarding_nav_bar.dart';
import 'widgets/onboarding_page_shell.dart';

class OnboardingEntry extends StatefulWidget {
  const OnboardingEntry({
    super.key,
    required this.store,
    required this.onCompleted,
  });

  final OnboardingCompletionStore store;
  final VoidCallback onCompleted;

  @override
  State<OnboardingEntry> createState() => _OnboardingEntryState();
}

class _OnboardingEntryState extends State<OnboardingEntry> {
  late final OnboardingFlowController _flow = OnboardingFlowController(
    pages: OnboardingPageCatalog.build(),
    store: widget.store,
    onCompleted: widget.onCompleted,
  );
  late final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _flow.addListener(_syncPage);
  }

  void _syncPage() {
    if (!_pageController.hasClients) return;
    final target = _flow.index;
    if (_pageController.page?.round() != target) {
      _pageController.animateToPage(
        target,
        duration: OnboardingTokens.durationPage,
        curve: OnboardingTokens.easeUi,
      );
    }
    setState(() {});
  }

  @override
  void dispose() {
    _flow.removeListener(_syncPage);
    _flow.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    final theme = brightness == Brightness.dark
        ? OnboardingTheme.dark()
        : OnboardingTheme.light();
    final featureCount = _flow.pages
        .where((p) => p.kind == OnboardingPageKind.feature)
        .length;

    return Theme(
      data: theme,
      child: Scaffold(
        body: GestureDetector(
          onHorizontalDragEnd: (details) {
            final v = details.primaryVelocity ?? 0;
            if (v > 200) {
              _flow.next();
            } else if (v < -200) {
              _flow.back();
            }
          },
          child: PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _flow.pages.length,
            itemBuilder: (context, index) {
              final page = _flow.pages[index];
              return OnboardingPageShell(
                page: page,
                pageIndex: index,
                featureCount: featureCount,
                hero: OnboardingHeroRegistry.build(
                  page.heroId,
                  active: _flow.index == index,
                ),
                navBar: OnboardingNavBar(
                  kind: page.kind,
                  isFirst: index == 0,
                  isCta: page.kind == OnboardingPageKind.cta,
                  enterError: _flow.enterError,
                  isEntering: _flow.isEntering,
                  onBack: _flow.back,
                  onNext: _flow.next,
                  onSkip: _flow.skip,
                  onEnter: _flow.enter,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
