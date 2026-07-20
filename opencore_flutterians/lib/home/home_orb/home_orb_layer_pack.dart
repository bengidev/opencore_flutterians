import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:opencore_flutterians/home/home_orb/home_orb_metrics.dart';

class HomeOrbLayerDescriptor {
  const HomeOrbLayerDescriptor({
    required this.image,
    required this.restOpacity,
    required this.opacityRange,
    required this.opacityDuration,
    required this.restScale,
    required this.scaleRange,
    required this.scaleDuration,
    required this.rotationRange,
    required this.rotationDuration,
    required this.phaseOffset,
    required this.crispEdges,
    this.driftRadius = 0,
    this.driftVerticalScale = 0.72,
    this.driftDuration = 1,
  });

  final ui.Image image;
  final double restOpacity;
  final double opacityRange;
  final double opacityDuration;
  final double restScale;
  final double scaleRange;
  final double scaleDuration;
  final double rotationRange;
  final double rotationDuration;
  final double phaseOffset;
  final bool crispEdges;
  final double driftRadius;
  final double driftVerticalScale;
  final double driftDuration;

  List<ui.Offset> driftPoints() {
    const stepCount = 36;
    return List.generate(stepCount + 1, (step) {
      final progress = step / stepCount;
      final angle = progress * math.pi * 2 + phaseOffset;
      return ui.Offset(
        HomeOrbMetrics.center.dx + math.cos(angle) * driftRadius,
        HomeOrbMetrics.center.dy + math.sin(angle) * driftRadius * driftVerticalScale,
      );
    });
  }
}

class HomeOrbOrbitDotDescriptor {
  const HomeOrbOrbitDotDescriptor({
    required this.image,
    required this.imageSize,
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

  final ui.Image image;
  final ui.Size imageSize;
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

  List<ui.Offset> orbitPoints() {
    const stepCount = 72;
    return List.generate(stepCount + 1, (step) {
      return position(progress: step / stepCount);
    });
  }

  ui.Offset position({required double progress}) {
    final angle = angleOffset + progress * math.pi * 2;
    final radius = orbitRadius + math.sin(progress * math.pi * 2 + angleOffset) * radialPulse;
    return ui.Offset(
      HomeOrbMetrics.center.dx + math.cos(angle) * radius,
      HomeOrbMetrics.center.dy + math.sin(angle) * radius * verticalScale,
    );
  }
}

class HomeOrbSparkDescriptor {
  const HomeOrbSparkDescriptor({
    required this.image,
    required this.imageSize,
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

  final ui.Image image;
  final ui.Size imageSize;
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

  List<ui.Offset> orbitPoints() {
    const stepCount = 48;
    return List.generate(stepCount + 1, (step) {
      return position(progress: step / stepCount);
    });
  }

  ui.Offset position({required double progress}) {
    final angle = angleOffset + progress * math.pi * 2;
    final radius =
        orbitRadius + math.sin(progress * math.pi * 2 + angleOffset * 0.6) * radialPulse;
    return ui.Offset(
      HomeOrbMetrics.center.dx + math.cos(angle) * radius,
      HomeOrbMetrics.center.dy + math.sin(angle) * radius * verticalScale,
    );
  }
}

class HomeOrbLayerPack {
  const HomeOrbLayerPack({
    required this.layers,
    required this.outerOrbitDots,
    required this.sparks,
  });

  final List<HomeOrbLayerDescriptor> layers;
  final List<HomeOrbOrbitDotDescriptor> outerOrbitDots;
  final List<HomeOrbSparkDescriptor> sparks;

  void dispose() {
    for (final layer in layers) {
      layer.image.dispose();
    }
    if (outerOrbitDots.isNotEmpty) {
      outerOrbitDots.first.image.dispose();
    }
    for (final spark in sparks) {
      spark.image.dispose();
    }
  }
}
