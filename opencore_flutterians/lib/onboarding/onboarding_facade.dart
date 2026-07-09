import 'package:flutter/widgets.dart';

import 'onboarding_completion_store.dart';
import 'onboarding_entry.dart';
import 'onboarding_shared_preferences_store.dart';

class OnboardingFacade {
  OnboardingFacade({OnboardingCompletionStore? store})
      : _store = store ?? OnboardingSharedPreferencesStore();

  final OnboardingCompletionStore _store;

  Future<Widget> buildRoot({required Widget home}) async {
    final completed = await _store.hasCompleted();
    if (completed) return home;
    return _OnboardingGate(store: _store, home: home);
  }
}

class _OnboardingGate extends StatefulWidget {
  const _OnboardingGate({required this.store, required this.home});

  final OnboardingCompletionStore store;
  final Widget home;

  @override
  State<_OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<_OnboardingGate> {
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    if (_done) return widget.home;
    return OnboardingEntry(
      store: widget.store,
      onCompleted: () => setState(() => _done = true),
    );
  }
}
