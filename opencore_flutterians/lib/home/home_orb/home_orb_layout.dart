import 'dart:math' as math;
import 'dart:ui';

import 'package:opencore_flutterians/home/home_orb/home_orb_math.dart';
import 'package:opencore_flutterians/home/home_orb/home_orb_metrics.dart';

class HomeOrbDot {
  const HomeOrbDot({
    required this.point,
    required this.size,
    required this.opacity,
  });

  final Offset point;
  final double size;
  final double opacity;
}

class HomeOrbBlock {
  const HomeOrbBlock({
    required this.point,
    required this.glyph,
    required this.size,
    required this.opacity,
  });

  final Offset point;
  final String glyph;
  final double size;
  final double opacity;
}

class HomeOrbOrbitDotSeed {
  const HomeOrbOrbitDotSeed({
    required this.orbitRadius,
    required this.verticalScale,
    required this.angleOffset,
    required this.radialPulse,
    required this.orbitDuration,
    required this.opacityDuration,
    required this.scaleDuration,
    required this.phaseOffset,
    required this.restOpacity,
    required this.restScale,
    required this.scaleRange,
  });

  final double orbitRadius;
  final double verticalScale;
  final double angleOffset;
  final double radialPulse;
  final double orbitDuration;
  final double opacityDuration;
  final double scaleDuration;
  final double phaseOffset;
  final double restOpacity;
  final double restScale;
  final double scaleRange;
}

class HomeOrbSparkSeed {
  const HomeOrbSparkSeed({
    required this.glyph,
    required this.pointSize,
    required this.orbitRadius,
    required this.verticalScale,
    required this.angleOffset,
    required this.radialPulse,
    required this.orbitDuration,
    required this.opacityDuration,
    required this.scaleDuration,
    required this.phaseOffset,
    required this.restOpacity,
    required this.restScale,
    required this.scaleRange,
  });

  final String glyph;
  final double pointSize;
  final double orbitRadius;
  final double verticalScale;
  final double angleOffset;
  final double radialPulse;
  final double orbitDuration;
  final double opacityDuration;
  final double scaleDuration;
  final double phaseOffset;
  final double restOpacity;
  final double restScale;
  final double scaleRange;
}

class HomeOrbLayout {
  static List<HomeOrbDot> makeOuterDots({
    required int seedOffset,
    required int count,
    required double radiusBias,
  }) {
    final dots = <HomeOrbDot>[];

    for (var index = 0; index < count; index++) {
      final seed = (seedOffset + index).toDouble();
      final orbit = 0.28 + math.pow(HomeOrbMath.noise(seed, 3), 0.82) * radiusBias;
      final angle = HomeOrbMath.noise(seed, 11) * math.pi * 2;
      final jitterX = (HomeOrbMath.noise(seed, 29) - 0.5) * 14;
      final jitterY = (HomeOrbMath.noise(seed, 37) - 0.5) * 11;
      final point = Offset(
        HomeOrbMetrics.center.dx +
            math.cos(angle) * HomeOrbMetrics.outerField.width * orbit * 0.5 +
            jitterX,
        HomeOrbMetrics.center.dy +
            math.sin(angle) * HomeOrbMetrics.outerField.height * orbit * 0.5 +
            jitterY,
      );
      final size = 1.2 + HomeOrbMath.noise(seed, 47) * 2.4;
      final opacity = 0.16 + HomeOrbMath.noise(seed, 59) * 0.28;
      dots.add(
        HomeOrbDot(
          point: point,
          size: size,
          opacity: opacity,
        ),
      );
    }

    return dots;
  }

  static List<HomeOrbDot> makeOrbDust({
    required int seedOffset,
    required int count,
  }) {
    final dots = <HomeOrbDot>[];

    for (var index = 0; index < count; index++) {
      final seed = (seedOffset + index).toDouble();
      final angle = HomeOrbMath.noise(seed, 5) * math.pi * 2;
      final radial = 0.18 + math.pow(HomeOrbMath.noise(seed, 13), 0.58) * 0.50;
      final xOffset = math.cos(angle) * HomeOrbMetrics.outerField.width * radial * 0.38;
      final yOffset = math.sin(angle) * HomeOrbMetrics.outerField.height * radial * 0.34;
      final point = Offset(
        HomeOrbMetrics.center.dx + xOffset,
        HomeOrbMetrics.center.dy + yOffset,
      );
      final size = 1.1 + HomeOrbMath.noise(seed, 23) * 2.0;
      final opacity = 0.10 + HomeOrbMath.noise(seed, 31) * 0.18;

      dots.add(
        HomeOrbDot(
          point: point,
          size: size,
          opacity: opacity,
        ),
      );
    }

    return dots;
  }

  static List<HomeOrbDot> makePulseDots({
    required int seedOffset,
    required int count,
  }) {
    final dots = <HomeOrbDot>[];

    for (var index = 0; index < count; index++) {
      final seed = (seedOffset + index).toDouble();
      final angle =
          index / count * math.pi * 2 + (HomeOrbMath.noise(seed, 5) - 0.5) * 0.22;
      final radius = 0.38 + HomeOrbMath.noise(seed, 13) * 0.16;
      final point = Offset(
        HomeOrbMetrics.center.dx + math.cos(angle) * HomeOrbMetrics.coreField.width * radius,
        HomeOrbMetrics.center.dy +
            math.sin(angle) * HomeOrbMetrics.coreField.height * radius * 0.70,
      );
      final size = 1.0 + HomeOrbMath.noise(seed, 19) * 2.1;
      final opacity = 0.08 + HomeOrbMath.noise(seed, 31) * 0.22;

      dots.add(HomeOrbDot(point: point, size: size, opacity: opacity));
    }

    return dots;
  }

  static List<HomeOrbSparkSeed> makeSparkSeeds({
    required int seedOffset,
    required int count,
  }) {
    final seeds = <HomeOrbSparkSeed>[];

    for (var index = 0; index < count; index++) {
      final seed = (seedOffset + index).toDouble();
      final energy = HomeOrbMath.noise(seed, 7);
      final glyphIndex = math.min(
        HomeOrbMetrics.glyphRamp.length - 1,
        math.max(0, (energy * HomeOrbMetrics.glyphRamp.length).round() - 1),
      );
      final angleOffset = HomeOrbMath.noise(seed, 13) * math.pi * 2;
      final orbitRadius = 34 + HomeOrbMath.noise(seed, 17) * 76;
      final pointSize = 5.2 + HomeOrbMath.noise(seed, 23) * 4.8;
      final opacity = 0.08 + HomeOrbMath.noise(seed, 29) * 0.18;

      seeds.add(
        HomeOrbSparkSeed(
          glyph: HomeOrbMetrics.glyphRamp[glyphIndex],
          pointSize: pointSize,
          orbitRadius: orbitRadius,
          verticalScale: 0.58 + HomeOrbMath.noise(seed, 31) * 0.26,
          angleOffset: angleOffset,
          radialPulse: 2 + HomeOrbMath.noise(seed, 37) * 5,
          orbitDuration: 8.5 + HomeOrbMath.noise(seed, 41) * 10.0,
          opacityDuration: 5.5 + HomeOrbMath.noise(seed, 43) * 5.0,
          scaleDuration: 6.0 + HomeOrbMath.noise(seed, 47) * 5.0,
          phaseOffset: HomeOrbMath.noise(seed, 53) * 9.0,
          restOpacity: opacity,
          restScale: 0.74 + HomeOrbMath.noise(seed, 59) * 0.34,
          scaleRange: 0.06 + HomeOrbMath.noise(seed, 61) * 0.10,
        ),
      );
    }

    return seeds;
  }

  static List<HomeOrbOrbitDotSeed> makeOuterOrbitDotSeeds({
    required int seedOffset,
    required int count,
  }) {
    final seeds = <HomeOrbOrbitDotSeed>[];

    for (var index = 0; index < count; index++) {
      final seed = (seedOffset + index).toDouble();
      final angleOffset =
          index / count * math.pi * 2 + (HomeOrbMath.noise(seed, 13) - 0.5) * 0.18;
      final ring = HomeOrbMath.noise(seed, 17);
      final orbitRadius = 94 + ring * 72;
      final opacity = 0.07 + HomeOrbMath.noise(seed, 29) * 0.15;

      seeds.add(
        HomeOrbOrbitDotSeed(
          orbitRadius: orbitRadius,
          verticalScale: 0.56 + HomeOrbMath.noise(seed, 31) * 0.22,
          angleOffset: angleOffset,
          radialPulse: 1.4 + HomeOrbMath.noise(seed, 37) * 4.6,
          orbitDuration: 17.0 + HomeOrbMath.noise(seed, 41) * 14.0,
          opacityDuration: 7.5 + HomeOrbMath.noise(seed, 43) * 7.0,
          scaleDuration: 8.0 + HomeOrbMath.noise(seed, 47) * 6.5,
          phaseOffset: HomeOrbMath.noise(seed, 53) * 13.0,
          restOpacity: opacity,
          restScale: 0.34 + HomeOrbMath.noise(seed, 59) * 0.56,
          scaleRange: 0.035 + HomeOrbMath.noise(seed, 61) * 0.07,
        ),
      );
    }

    return seeds;
  }

  static List<HomeOrbBlock> makeCoreBlocks({
    required int seedOffset,
    required int count,
    required double prominence,
  }) {
    final blocks = <HomeOrbBlock>[];

    final maxAttempts = count * 12;
    var attempts = 0;

    while (blocks.length < count && attempts < maxAttempts) {
      final seed = (seedOffset + attempts).toDouble();
      final x = HomeOrbMath.noise(seed, 3) * 2 - 1;
      final y = HomeOrbMath.noise(seed, 9) * 2 - 1;
      final density = coreDensity(x: x, y: y, seed: seed) * prominence;

      if (HomeOrbMath.noise(seed, 15) < density) {
        final snappedX = snap(
          HomeOrbMetrics.center.dx + x * HomeOrbMetrics.coreField.width * 0.5,
        );
        final snappedY = snap(
          HomeOrbMetrics.center.dy + y * HomeOrbMetrics.coreField.height * 0.5,
        );
        final energy = math.min(1, math.max(0, density + HomeOrbMath.noise(seed, 25) * 0.12));
        final size = 4.1 + energy * 5.8 + HomeOrbMath.noise(seed, 21) * 1.1;
        final glyphIndex = math.min(
          HomeOrbMetrics.glyphRamp.length - 1,
          math.max(0, (energy * HomeOrbMetrics.glyphRamp.length).round() - 1),
        );
        final opacity =
            math.min(1.0, 0.18 + energy * 0.82 + HomeOrbMath.noise(seed, 33) * 0.08);

        blocks.add(
          HomeOrbBlock(
            point: Offset(snappedX, snappedY),
            glyph: HomeOrbMetrics.glyphRamp[glyphIndex],
            size: size,
            opacity: opacity,
          ),
        );
      }

      attempts += 1;
    }

    return blocks;
  }

  static double coreDensity({
    required double x,
    required double y,
    required double seed,
  }) {
    final radius = math.sqrt(x * x + y * y);
    final angle = math.atan2(y, x);
    final shell = math.max(0, 1 - math.pow(radius / 1.05, 2)) * 0.36;
    final ring = math.exp(-math.pow((radius - 0.56) / 0.24, 2)) * 0.34;
    final centerMass =
        HomeOrbMath.gaussian2D(x: x + 0.03, y: y + 0.02, sigmaX: 0.34, sigmaY: 0.30) * 0.38;
    final upperLeftMass =
        HomeOrbMath.gaussian2D(x: x + 0.24, y: y + 0.15, sigmaX: 0.28, sigmaY: 0.18) * 0.28;
    final lowerRightMass =
        HomeOrbMath.gaussian2D(x: x - 0.22, y: y - 0.20, sigmaX: 0.22, sigmaY: 0.20) * 0.24;
    final spiral = (0.5 + 0.5 * math.sin(angle * 3.2 + radius * 8.4)) * 0.16;
    final centerCut =
        HomeOrbMath.gaussian2D(x: x - 0.02, y: y - 0.02, sigmaX: 0.18, sigmaY: 0.16) * 0.20;
    final bite =
        HomeOrbMath.gaussian2D(x: x + 0.34, y: y - 0.23, sigmaX: 0.18, sigmaY: 0.14) * 0.18;
    final noise = (HomeOrbMath.noise(seed, 41) - 0.5) * 0.20;

    return math.min(
      1,
      math.max(
        0,
        shell + ring + centerMass + upperLeftMass + lowerRightMass + spiral - centerCut - bite + noise,
      ),
    );
  }

  static double snap(double value) {
    return (value / HomeOrbMetrics.snapGrid).roundToDouble() * HomeOrbMetrics.snapGrid;
  }
}
