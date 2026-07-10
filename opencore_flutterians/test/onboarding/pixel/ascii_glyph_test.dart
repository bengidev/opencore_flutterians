import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/onboarding/heroes/pixel/ascii_glyph.dart';
import 'package:opencore_flutterians/onboarding/heroes/pixel/pixel_cell_role.dart';
import 'package:opencore_flutterians/onboarding/heroes/pixel/pixel_pattern.dart';

void main() {
  group('asciiCharForRole', () {
    test('maps roles to shade blocks by default', () {
      expect(asciiCharForRole(PixelCellRole.empty), '');
      expect(asciiCharForRole(PixelCellRole.muted), '░');
      expect(asciiCharForRole(PixelCellRole.primary), '▓');
      expect(asciiCharForRole(PixelCellRole.accent), '█');
    });

    test('maps roles to ASCII accents when asciiAccent is true', () {
      expect(asciiCharForRole(PixelCellRole.muted, asciiAccent: true), '-');
      expect(asciiCharForRole(PixelCellRole.primary, asciiAccent: true), '#');
      expect(asciiCharForRole(PixelCellRole.accent, asciiAccent: true), '!');
    });
  });

  group('swarmGlyphsFromPatterns', () {
    test('includes shade blocks and ASCII accents', () {
      final glyphs = swarmGlyphsFromPatterns([
        PixelPattern.fromAscii('#!-'),
      ]);
      expect(glyphs, containsAll(['░', '▒', '▓', '█', '-', '.', ':', '#', '+', '=', '!', '*', '>']));
    });
  });
}
