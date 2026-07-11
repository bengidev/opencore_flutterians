import 'package:shared_preferences/shared_preferences.dart';

import 'onboarding_completion_store.dart';

class OnboardingSharedPreferencesStore implements OnboardingCompletionStore {
  static const completedKey = 'onboarding.completed';

  @override
  Future<bool> hasCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(completedKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(completedKey, true);
  }
}
