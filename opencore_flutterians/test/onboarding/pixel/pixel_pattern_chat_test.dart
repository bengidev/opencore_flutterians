import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/onboarding/heroes/pixel/pixel_pattern.dart';

void main() {
  test('chat bubble patterns exist and are non-empty', () {
    expect(OnboardingPixelPatterns.chatRequest.cellCount, greaterThan(4));
    expect(OnboardingPixelPatterns.chatResponse.cellCount, greaterThan(4));
    expect(OnboardingPixelPatterns.chatQueued.cellCount, greaterThan(4));
    expect(OnboardingPixelPatterns.chatResponse.width,
        greaterThan(OnboardingPixelPatterns.chatRequest.width - 1));
  });
}
