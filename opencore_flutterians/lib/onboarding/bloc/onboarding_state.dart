import 'package:equatable/equatable.dart';

import '../onboarding_page_model.dart';

enum OnboardingStatus { inProgress, completed }

final class OnboardingState extends Equatable {
  const OnboardingState({
    required this.pages,
    this.index = 0,
    this.enterError,
    this.isEntering = false,
    this.status = OnboardingStatus.inProgress,
  });

  final List<OnboardingPageModel> pages;
  final int index;
  final String? enterError;
  final bool isEntering;
  final OnboardingStatus status;

  bool get isFirst => index == 0;
  bool get isCta => pages[index].kind == OnboardingPageKind.cta;
  OnboardingPageModel get currentPage => pages[index];
  int get ctaIndex => pages.indexWhere((p) => p.kind == OnboardingPageKind.cta);

  OnboardingState copyWith({
    List<OnboardingPageModel>? pages,
    int? index,
    String? enterError,
    bool clearEnterError = false,
    bool? isEntering,
    OnboardingStatus? status,
  }) {
    return OnboardingState(
      pages: pages ?? this.pages,
      index: index ?? this.index,
      enterError: clearEnterError ? null : (enterError ?? this.enterError),
      isEntering: isEntering ?? this.isEntering,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [pages, index, enterError, isEntering, status];
}
