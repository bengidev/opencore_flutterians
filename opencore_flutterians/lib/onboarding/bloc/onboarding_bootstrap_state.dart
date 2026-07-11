import 'package:equatable/equatable.dart';

sealed class OnboardingBootstrapState extends Equatable {
  const OnboardingBootstrapState();

  @override
  List<Object?> get props => [];
}

final class OnboardingBootstrapChecking extends OnboardingBootstrapState {
  const OnboardingBootstrapChecking();
}

final class OnboardingBootstrapShowOnboarding extends OnboardingBootstrapState {
  const OnboardingBootstrapShowOnboarding();
}

final class OnboardingBootstrapShowHome extends OnboardingBootstrapState {
  const OnboardingBootstrapShowHome();
}

final class OnboardingBootstrapFailure extends OnboardingBootstrapState {
  const OnboardingBootstrapFailure();
}
