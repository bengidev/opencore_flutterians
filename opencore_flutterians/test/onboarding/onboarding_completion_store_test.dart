import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/onboarding/onboarding_shared_preferences_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('OnboardingSharedPreferencesStore', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('hasCompleted is false by default', () async {
      final store = OnboardingSharedPreferencesStore();
      expect(await store.hasCompleted(), isFalse);
    });

    test('markCompleted makes hasCompleted true', () async {
      final store = OnboardingSharedPreferencesStore();
      await store.markCompleted();
      expect(await store.hasCompleted(), isTrue);
    });

    test('uses namespaced key onboarding.completed', () async {
      final store = OnboardingSharedPreferencesStore();
      await store.markCompleted();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('onboarding.completed'), isTrue);
    });
  });
}
