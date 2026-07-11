import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/onboarding/bloc/onboarding_bootstrap_cubit.dart';
import 'package:opencore_flutterians/onboarding/bloc/onboarding_bootstrap_state.dart';
import 'package:opencore_flutterians/onboarding/onboarding_completion_store.dart';

class _FakeStore implements OnboardingCompletionStore {
  _FakeStore({this.completed = false, this.throwOnRead = false});

  bool completed;
  bool throwOnRead;

  @override
  Future<bool> hasCompleted() async {
    if (throwOnRead) throw StateError('read failed');
    return completed;
  }

  @override
  Future<void> markCompleted() async => completed = true;
}

void main() {
  group('OnboardingBootstrapCubit', () {
    blocTest<OnboardingBootstrapCubit, OnboardingBootstrapState>(
      'incomplete shows onboarding',
      build: () => OnboardingBootstrapCubit(store: _FakeStore(completed: false)),
      act: (cubit) => cubit.start(),
      expect: () => const [
        OnboardingBootstrapChecking(),
        OnboardingBootstrapShowOnboarding(),
      ],
    );

    blocTest<OnboardingBootstrapCubit, OnboardingBootstrapState>(
      'complete shows home',
      build: () => OnboardingBootstrapCubit(store: _FakeStore(completed: true)),
      act: (cubit) => cubit.start(),
      expect: () => const [
        OnboardingBootstrapChecking(),
        OnboardingBootstrapShowHome(),
      ],
    );

    blocTest<OnboardingBootstrapCubit, OnboardingBootstrapState>(
      'session completed shows home',
      build: () => OnboardingBootstrapCubit(store: _FakeStore()),
      seed: () => const OnboardingBootstrapShowOnboarding(),
      act: (cubit) => cubit.completeSession(),
      expect: () => const [OnboardingBootstrapShowHome()],
    );

    blocTest<OnboardingBootstrapCubit, OnboardingBootstrapState>(
      'read failure emits failure',
      build: () => OnboardingBootstrapCubit(
        store: _FakeStore(throwOnRead: true),
      ),
      act: (cubit) => cubit.start(),
      expect: () => const [
        OnboardingBootstrapChecking(),
        OnboardingBootstrapFailure(),
      ],
    );
  });
}
