import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/onboarding_bootstrap_cubit.dart';
import 'bloc/onboarding_bootstrap_state.dart';
import 'onboarding_completion_store.dart';
import 'onboarding_entry.dart';
import 'onboarding_shared_preferences_store.dart';

class OnboardingFacade {
  OnboardingFacade({OnboardingCompletionStore? store})
      : _store = store ?? OnboardingSharedPreferencesStore();

  final OnboardingCompletionStore _store;

  Widget buildRoot({required Widget home}) {
    return BlocProvider(
      create: (_) => OnboardingBootstrapCubit(store: _store)..start(),
      child: _OnboardingBootstrapView(store: _store, home: home),
    );
  }
}

class _OnboardingBootstrapView extends StatelessWidget {
  const _OnboardingBootstrapView({
    required this.store,
    required this.home,
  });

  final OnboardingCompletionStore store;
  final Widget home;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBootstrapCubit, OnboardingBootstrapState>(
      builder: (context, state) {
        return switch (state) {
          OnboardingBootstrapChecking() => const Scaffold(
              body: Center(child: Text('[LOADING...]')),
            ),
          OnboardingBootstrapFailure() => const Scaffold(
              body: Center(child: Text('[ERROR: COULD NOT LOAD]')),
            ),
          OnboardingBootstrapShowHome() => home,
          OnboardingBootstrapShowOnboarding() => OnboardingEntry(store: store),
        };
      },
    );
  }
}
