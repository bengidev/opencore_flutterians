import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../onboarding_tokens.dart';
import 'ascii_glyph.dart';
import 'pixel_cell_role.dart';
import 'pixel_pattern.dart';

/// Deterministic scatter + assemble math for pixel swarms.
abstract final class PixelSwarmMath {
  /// Hold scattered cloud before cells fly to grid slots.
  static const assembleStart = 0.28;
  static const assembleEnd = 0.94;
  static const guiRevealStart = 0.20;

  static double assembleProgress(double enterT) {
    if (enterT <= assembleStart) return 0;
    if (enterT >= assembleEnd) return 1;
    return OnboardingTokens.easeOut.transform(
      (enterT - assembleStart) / (assembleEnd - assembleStart),
    );
  }

  static double cloudOpacity(double enterT) {
    if (enterT <= 0.02) return 0;
    if (enterT < 0.10) return enterT / 0.10;
    final assemble = assembleProgress(enterT);
    return (1 - assemble * 0.95).clamp(0.0, 1.0);
  }

  static double guiOpacity(double enterT) {
    if (enterT < guiRevealStart) return 0;
    return OnboardingTokens.easeOut.transform(
      ((enterT - guiRevealStart) / (1 - guiRevealStart)).clamp(0.0, 1.0),
    );
  }

  static bool isSwarmPhase(double enterT) => assembleProgress(enterT) < 0.08;

  static double edgeFade(double nx, double ny) {
    final dx = (nx - 0.5).abs() * 2;
    final dy = (ny - 0.5).abs() * 2;
    final radial = math.max(dx, dy);
    return (1 - Curves.easeIn.transform(radial.clamp(0.0, 1.0)) * 0.75)
        .clamp(0.15, 1.0);
  }

  static int hash(int a, int b, int c) {
    var h = a * 374761393 + b * 668265263 + c * 1274126177;
    h = (h ^ (h >> 13)) * 1274126177;
    return h ^ (h >> 16);
  }

  static Offset scatter({
    required int seed,
    required int cellIndex,
    double spread = 48,
  }) {
    final h = hash(seed, cellIndex, 0x9e3779b9);
    final angle = (h & 0xffff) / 0xffff * math.pi * 2;
    final dist = spread * (0.65 + ((h >> 16) & 0xff) / 255 * 0.75);
    return Offset(math.cos(angle) * dist, math.sin(angle) * dist);
  }

  /// Column-biased anchor for swarm glyphs — vertical ASCII rain columns.
  static Offset columnAnchor({
    required int index,
    required int total,
    required double width,
    required double height,
    int columns = 16,
  }) {
    final col = index % columns;
    final row = index ~/ columns;
    final rows = (total / columns).ceil().clamp(1, 999);
    final colSpacing = width / (columns + 1);
    final rowSpacing = height / (rows + 1);
    final x = -width / 2 + colSpacing * (col + 1);
    final y = -height / 2 + rowSpacing * (row + 1);
    return Offset(x, y);
  }

  static double cellAssemble({
    required double assembleProgress,
    required int staggerIndex,
    required int staggerTotal,
    double staggerSpread = 0.42,
  }) {
    if (staggerTotal <= 0) {
      return Curves.easeOutCubic.transform(assembleProgress);
    }
    final delay = (staggerIndex / staggerTotal) * staggerSpread;
    final local = ((assembleProgress - delay) / (1 - staggerSpread))
        .clamp(0.0, 1.0);
    return Curves.easeOutCubic.transform(local);
  }

  static Offset drift({
    required int seed,
    required int cellIndex,
    required double phase,
    double amplitude = 5,
  }) {
    final h = hash(seed, cellIndex, 0x85ebca6b);
    final a = (h & 0xff) / 255 * math.pi * 2;
    return Offset(
      math.cos(a + phase * math.pi * 2) * amplitude,
      math.sin(a * 1.3 + phase * math.pi * 2) * amplitude * 0.75,
    );
  }

  static double cellScale(double cellT) =>
      0.35 + 0.65 * Curves.easeOut.transform(cellT);

  static double cellOpacity(double enterT, double cellT) {
    if (enterT <= 0.01) return 0;
    final appear = ((enterT - 0.02) / 0.14).clamp(0.0, 1.0);
    if (cellT < 0.04) return appear;
    return appear * (0.55 + 0.45 * Curves.easeOut.transform(cellT));
  }
}

/// Loose ASCII / pixel block cloud — visible swarm before the GUI forms.
class PixelSwarmCloud extends StatelessWidget {
  const PixelSwarmCloud({
    super.key,
    required this.patterns,
    required this.colors,
    required this.enterT,
    required this.seed,
    this.width = 320,
    this.height = 150,
    this.particleCount = 160,
    this.columns = 18,
  });

  final List<PixelPattern> patterns;
  final OnboardingColorTokens colors;
  final double enterT;
  final int seed;
  final double width;
  final double height;
  final int particleCount;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final phase = enterT * 3.2;
    final assemble = PixelSwarmMath.assembleProgress(enterT);

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          for (var i = 0; i < particleCount; i++)
            _cloudParticle(i, phase, assemble),
        ],
      ),
    );
  }

  Widget _cloudParticle(
    int i,
    double phase,
    double assemble,
  ) {
    final anchor = PixelSwarmMath.columnAnchor(
      index: i,
      total: particleCount,
      width: width * 0.92,
      height: height * 0.88,
      columns: columns,
    );
    final scatter = PixelSwarmMath.scatter(
      seed: seed,
      cellIndex: i,
      spread: 28 + (i % 9),
    );
    final drift = PixelSwarmMath.drift(
      seed: seed,
      cellIndex: i,
      phase: phase,
      amplitude: 7 * (1 - assemble * 0.55),
    );
    final role = _roleFor(i);
    final char = kSwarmGlyphPool[i % kSwarmGlyphPool.length];
    final fontSize = 7.0 + (i % 4);
    final rows = (particleCount / columns).ceil().clamp(1, 999);
    final col = i % columns;
    final row = i ~/ columns;
    final nx = columns > 1 ? col / (columns - 1) : 0.5;
    final ny = rows > 1 ? row / (rows - 1) : 0.5;
    final edge = PixelSwarmMath.edgeFade(nx, ny);

    return Transform.translate(
      offset: anchor + scatter * (1 - assemble * 0.85) + drift,
      child: Opacity(
        opacity: (0.5 + (1 - assemble) * 0.5).clamp(0.0, 1.0) * edge,
        child: AsciiGlyph(
          char: char,
          colors: colors,
          role: role,
          fontSize: fontSize,
          glow: role == PixelCellRole.accent && assemble < 0.4,
        ),
      ),
    );
  }

  PixelCellRole _roleFor(int i) {
    final roles = <PixelCellRole>[];
    for (final pattern in patterns) {
      for (final row in pattern.rows) {
        for (final role in row) {
          if (role != PixelCellRole.empty) roles.add(role);
        }
      }
    }
    if (roles.isEmpty) {
      return i.isEven ? PixelCellRole.muted : PixelCellRole.accent;
    }
    return roles[i % roles.length];
  }
}

/// Wraps a hero: ASCII swarm cloud → assembled pixel GUI.
class PixelHeroAssembly extends StatelessWidget {
  const PixelHeroAssembly({
    super.key,
    required this.enter,
    required this.colors,
    required this.seed,
    required this.motifs,
    required this.child,
    this.onReplay,
    this.cloudWidth = 320,
    this.cloudHeight = 150,
    this.particleCount = 160,
  });

  final Animation<double> enter;
  final OnboardingColorTokens colors;
  final int seed;
  final List<PixelPattern> motifs;
  final Widget child;
  final VoidCallback? onReplay;
  final double cloudWidth;
  final double cloudHeight;
  final int particleCount;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onReplay,
      child: AnimatedBuilder(
        animation: enter,
        builder: (context, assembled) {
          final t = enter.value;
          final reduced = MediaQuery.disableAnimationsOf(context);
          final cloud = reduced ? 0.0 : PixelSwarmMath.cloudOpacity(t);
          final gui = reduced ? 1.0 : PixelSwarmMath.guiOpacity(t);
          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (cloud > 0.03)
                IgnorePointer(
                  child: Opacity(
                    opacity: cloud,
                    child: PixelSwarmCloud(
                      patterns: motifs,
                      colors: colors,
                      enterT: t,
                      seed: seed,
                      width: cloudWidth,
                      height: cloudHeight,
                      particleCount: particleCount,
                    ),
                  ),
                ),
              if (gui > 0.01) Opacity(opacity: gui, child: assembled),
            ],
          );
        },
        child: child,
      ),
    );
  }
}
