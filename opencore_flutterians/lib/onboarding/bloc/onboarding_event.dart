import 'package:equatable/equatable.dart';

sealed class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

final class OnboardingNextPressed extends OnboardingEvent {
  const OnboardingNextPressed();
}

final class OnboardingBackPressed extends OnboardingEvent {
  const OnboardingBackPressed();
}

final class OnboardingSkipPressed extends OnboardingEvent {
  const OnboardingSkipPressed();
}

final class OnboardingEnterPressed extends OnboardingEvent {
  const OnboardingEnterPressed();
}
