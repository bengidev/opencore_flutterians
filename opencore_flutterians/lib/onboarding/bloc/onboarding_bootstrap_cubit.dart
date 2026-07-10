import 'package:flutter_bloc/flutter_bloc.dart';

import '../onboarding_completion_store.dart';
import 'onboarding_bootstrap_state.dart';

/// Simple bootstrap gating — Cubit (no event classes).
class OnboardingBootstrapCubit extends Cubit<OnboardingBootstrapState> {
  OnboardingBootstrapCubit({required this._store})
      : super(const OnboardingBootstrapChecking());

  final OnboardingCompletionStore _store;

  Future<void> start() async {
    emit(const OnboardingBootstrapChecking());
    try {
      final completed = await _store.hasCompleted();
      emit(
        completed
            ? const OnboardingBootstrapShowHome()
            : const OnboardingBootstrapShowOnboarding(),
      );
    } catch (_) {
      emit(const OnboardingBootstrapFailure());
    }
  }

  void completeSession() {
    emit(const OnboardingBootstrapShowHome());
  }
}
