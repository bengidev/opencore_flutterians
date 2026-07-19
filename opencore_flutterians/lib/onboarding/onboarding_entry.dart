import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/onboarding_bloc.dart';
import 'bloc/onboarding_bootstrap_cubit.dart';
import 'bloc/onboarding_event.dart';
import 'bloc/onboarding_state.dart';
import 'heroes/onboarding_hero.dart';
import 'onboarding_completion_store.dart';
import 'onboarding_page_catalog.dart';
import 'onboarding_page_model.dart';
import 'onboarding_motion.dart';
import 'onboarding_theme.dart';
import 'widgets/onboarding_feature_header.dart';
import 'widgets/onboarding_nav_bar.dart';
import 'widgets/onboarding_page_shell.dart';

class OnboardingEntry extends StatelessWidget {
  const OnboardingEntry({
    super.key,
    required this.store,
  });

  final OnboardingCompletionStore store;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingBloc(
        pages: OnboardingPageCatalog.build(),
        store: store,
      ),
      child: const _OnboardingEntryView(),
    );
  }
}

class _OnboardingEntryView extends StatefulWidget {
  const _OnboardingEntryView();

  @override
  State<_OnboardingEntryView> createState() => _OnboardingEntryViewState();
}

class _OnboardingEntryViewState extends State<_OnboardingEntryView> {
  PageController? _pageController;
  double _dragDistance = 0;

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  PageController _controllerFor(OnboardingState state) {
    final existing = _pageController;
    if (existing != null) return existing;
    final created = PageController(initialPage: state.index);
    _pageController = created;
    return created;
  }

  void _syncPage(OnboardingState state, BuildContext context) {
    final controller = _pageController;
    if (controller == null || !controller.hasClients) return;
    final target = state.index;
    if (controller.page?.round() != target) {
      if (OnboardingMotion.reduceMotionOf(context)) {
        controller.jumpToPage(target);
      } else {
        controller.animateToPage(
          target,
          duration: OnboardingMotion.pageDuration,
          curve: OnboardingMotion.pageCurve,
        );
      }
    }
  }

  void _handleDragEnd(DragEndDetails details, OnboardingBloc bloc) {
    final velocity = details.primaryVelocity ?? 0;
    const distanceThreshold = 56.0;
    final flick = velocity.abs() / 1000 > 0.11;

    if (_dragDistance > distanceThreshold || (velocity > 200 && flick)) {
      bloc.add(const OnboardingBackPressed());
    } else if (_dragDistance < -distanceThreshold || (velocity < -200 && flick)) {
      bloc.add(const OnboardingNextPressed());
    }
    _dragDistance = 0;
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    final theme = brightness == Brightness.dark
        ? OnboardingTheme.dark()
        : OnboardingTheme.light();

    return Theme(
      data: theme,
      child: BlocListener<OnboardingBloc, OnboardingState>(
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            current.status == OnboardingStatus.completed,
        listener: (context, state) {
          context.read<OnboardingBootstrapCubit>().completeSession();
        },
        child: BlocConsumer<OnboardingBloc, OnboardingState>(
          listenWhen: (previous, current) => previous.index != current.index,
          listener: (context, state) => _syncPage(state, context),
          builder: (context, state) {
            final featureCount = state.pages
                .where((p) => p.kind == OnboardingPageKind.feature)
                .length;
            final bloc = context.read<OnboardingBloc>();
            final pageController = _controllerFor(state);

            final currentPage = state.pages[state.index];
            final onFeaturePage = currentPage.kind == OnboardingPageKind.feature;

            return Scaffold(
              body: SafeArea(
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    _dragDistance += details.primaryDelta ?? 0;
                  },
                  onHorizontalDragEnd: (details) {
                    _handleDragEnd(details, bloc);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (onFeaturePage)
                        OnboardingFeatureHeader(
                          pageIndex: state.index,
                          featureCount: featureCount,
                          stepLabel: currentPage.featureStepLabel,
                        )
                      else
                        const SizedBox(height: 64),
                      Expanded(
                        child: PageView.builder(
                          controller: pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.pages.length,
                          itemBuilder: (context, index) {
                            final page = state.pages[index];
                            return OnboardingPageShell(
                              page: page,
                              topInset: onFeaturePage ? 48 : 0,
                              hero: OnboardingHeroRegistry.build(
                                page.heroId,
                                active: state.index == index,
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                        child: OnboardingNavBar(
                          kind: currentPage.kind,
                          isFirst: state.index == 0,
                          isCta: currentPage.kind == OnboardingPageKind.cta,
                          enterError: state.enterError,
                          isEntering: state.isEntering,
                          onBack: () => bloc.add(const OnboardingBackPressed()),
                          onNext: () => bloc.add(const OnboardingNextPressed()),
                          onSkip: () => bloc.add(const OnboardingSkipPressed()),
                          onEnter: () async {
                            bloc.add(const OnboardingEnterPressed());
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
