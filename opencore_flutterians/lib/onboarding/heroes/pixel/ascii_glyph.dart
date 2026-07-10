import 'package:flutter/material.dart';

import '../../onboarding_tokens.dart';
import 'pixel_cell_role.dart';
import 'pixel_pattern.dart';

/// Monospace glyph for a pixel cell role.
///
/// Default display uses shade blocks. Pass [asciiAccent] for ASCII companions
/// used in mixed swarm / decorative cells.
String asciiCharForRole(PixelCellRole role, {bool asciiAccent = false}) {
  if (asciiAccent) {
    return switch (role) {
      PixelCellRole.empty => '',
      PixelCellRole.muted => '-',
      PixelCellRole.primary => '#',
      PixelCellRole.accent => '!',
    };
  }
  return switch (role) {
    PixelCellRole.empty => '',
    PixelCellRole.muted => '░',
    PixelCellRole.primary => '▓',
    PixelCellRole.accent => '█',
  };
}

/// Fixed mixed pool for swarm clouds (blocks + ASCII).
const kSwarmGlyphPool = <String>[
  '░', '▒', '▓', '█',
  '-', '.', ':',
  '#', '+', '=',
  '!', '*', '>',
];

/// Collect display glyphs from hero motifs, always unioned with the mixed pool.
List<String> swarmGlyphsFromPatterns(List<PixelPattern> patterns) {
  final glyphs = <String>{...kSwarmGlyphPool};
  for (final pattern in patterns) {
    for (final row in pattern.rows) {
      for (final role in row) {
        final block = asciiCharForRole(role);
        final ascii = asciiCharForRole(role, asciiAccent: true);
        if (block.isNotEmpty) glyphs.add(block);
        if (ascii.isNotEmpty) glyphs.add(ascii);
      }
    }
  }
  return glyphs.toList();
}

String shadeForIndex(int index) {
  const shades = ['░', '▒', '▓', '█'];
  return shades[index % shades.length];
}

/// Single monospace ASCII / pixel block glyph.
class AsciiGlyph extends StatelessWidget {
  const AsciiGlyph({
    super.key,
    required this.char,
    required this.colors,
    required this.role,
    this.fontSize = 9,
    this.opacity = 1,
    this.glow = false,
  });

  final String char;
  final OnboardingColorTokens colors;
  final PixelCellRole role;
  final double fontSize;
  final double opacity;
  final bool glow;

  Color get _color {
    return switch (role) {
      PixelCellRole.empty => Colors.transparent,
      PixelCellRole.muted => colors.borderVisible,
      PixelCellRole.primary => colors.textPrimary.withValues(alpha: 0.82),
      PixelCellRole.accent => colors.accent,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (char.isEmpty) {
      return SizedBox(width: fontSize * 0.72, height: fontSize);
    }

    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Text(
        char,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: fontSize,
          height: 1,
          color: _color,
          fontWeight: role == PixelCellRole.accent ? FontWeight.w700 : FontWeight.w500,
          shadows: glow && role == PixelCellRole.accent
              ? [
                  Shadow(
                    color: colors.accent.withValues(alpha: 0.45),
                    blurRadius: 6,
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}
