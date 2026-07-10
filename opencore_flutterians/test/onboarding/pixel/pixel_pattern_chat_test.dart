import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/onboarding/heroes/pixel/pixel_pattern.dart';

void expectUniformRowWidths(PixelPattern pattern) {
  expect(pattern.rows, isNotEmpty);
  final width = pattern.width;
  for (final row in pattern.rows) {
    expect(row.length, width);
  }
}

void main() {
  test('chat bubble patterns exist and are non-empty', () {
    expect(OnboardingPixelPatterns.chatRequest.cellCount, greaterThan(4));
    expect(OnboardingPixelPatterns.chatResponse.cellCount, greaterThan(4));
    expect(OnboardingPixelPatterns.chatQueued.cellCount, greaterThan(4));
    expect(OnboardingPixelPatterns.chatResponse.width,
        greaterThan(OnboardingPixelPatterns.chatRequest.width - 1));
  });

  test('chat bubble patterns have uniform row widths', () {
    expectUniformRowWidths(OnboardingPixelPatterns.chatRequest);
    expectUniformRowWidths(OnboardingPixelPatterns.chatResponse);
    expectUniformRowWidths(OnboardingPixelPatterns.deviceScreen);
    expectUniformRowWidths(OnboardingPixelPatterns.lockOpen);
  });

  test('fromAscii strips per-line indent for multiline art', () {
    final pattern = PixelPattern.fromAscii('''
      ..######
      .#----##
      .#----##
      ..######
    ''');
    expectUniformRowWidths(pattern);
    expect(pattern.width, 8);
    expect(pattern.height, 4);
  });
}
