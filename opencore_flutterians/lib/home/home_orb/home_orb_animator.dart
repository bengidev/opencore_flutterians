import 'package:flutter/animation.dart';
import 'package:opencore_flutterians/home/home_orb/home_orb_layer_pack.dart';
import 'package:opencore_flutterians/home/home_orb/home_orb_metrics.dart';

class HomeOrbLayerSample {
  const HomeOrbLayerSample({
    required this.position,
    required this.opacity,
    required this.scale,
    required this.rotation,
  });

  final Offset position;
  final double opacity;
  final double scale;
  final double rotation;
}

class HomeOrbOrbitDotSample {
  const HomeOrbOrbitDotSample({
    required this.position,
    required this.opacity,
    required this.scale,
  });

  final Offset position;
  final double opacity;
  final double scale;
}

class HomeOrbSparkSample {
  const HomeOrbSparkSample({
    required this.position,
    required this.opacity,
    required this.scale,
  });

  final Offset position;
  final double opacity;
  final double scale;
}

double homeOrbLoopedTime(double elapsed, double duration, double phaseOffset) {
  if (duration <= 0) {
    return 0;
  }
  final time = elapsed + phaseOffset;
  final mod = time % duration;
  return mod < 0 ? mod + duration : mod;
}

double homeOrbLoopedProgress(double elapsed, double duration, double phaseOffset) {
  return homeOrbLoopedTime(elapsed, duration, phaseOffset) / duration;
}

double homeOrbSampleKeyframes({
  required List<double> values,
  required List<double> keyTimes,
  required double progress,
}) {
  assert(values.length == keyTimes.length);
  final clamped = progress.clamp(0.0, 1.0);
  if (clamped <= keyTimes.first) {
    return values.first;
  }
  if (clamped >= keyTimes.last) {
    return values.last;
  }

  for (var index = 0; index < keyTimes.length - 1; index++) {
    final start = keyTimes[index];
    final end = keyTimes[index + 1];
    if (clamped >= start && clamped <= end) {
      final segment = end - start;
      if (segment <= 0) {
        return values[index + 1];
      }
      final local = (clamped - start) / segment;
      final eased = Curves.easeInOut.transform(local);
      return values[index] + (values[index + 1] - values[index]) * eased;
    }
  }

  return values.last;
}

Offset homeOrbSamplePacedPath(List<Offset> points, double progress) {
  if (points.isEmpty) {
    return Offset.zero;
  }
  if (points.length == 1) {
    return points.first;
  }

  final segmentLengths = <double>[];
  var totalLength = 0.0;
  for (var index = 0; index < points.length - 1; index++) {
    final length = (points[index + 1] - points[index]).distance;
    segmentLengths.add(length);
    totalLength += length;
  }

  if (totalLength <= 0) {
    return points.first;
  }

  final target = progress.clamp(0.0, 1.0) * totalLength;
  var traveled = 0.0;
  for (var index = 0; index < segmentLengths.length; index++) {
    final length = segmentLengths[index];
    if (traveled + length >= target) {
      final local = length <= 0 ? 0.0 : (target - traveled) / length;
      return Offset.lerp(points[index], points[index + 1], local)!;
    }
    traveled += length;
  }

  return points.last;
}

double homeOrbSamplePingPong({
  required double elapsed,
  required double duration,
  required double phaseOffset,
  required double minValue,
  required double maxValue,
}) {
  if (duration <= 0) {
    return minValue;
  }

  final cycleDuration = duration * 2;
  final time = homeOrbLoopedTime(elapsed, cycleDuration, phaseOffset);
  final half = duration;
  if (time <= half) {
    final eased = Curves.easeInOut.transform(time / half);
    return minValue + (maxValue - minValue) * eased;
  }

  final eased = Curves.easeInOut.transform((time - half) / half);
  return maxValue + (minValue - maxValue) * eased;
}

HomeOrbLayerSample homeOrbSampleLayer({
  required HomeOrbLayerDescriptor descriptor,
  required double elapsed,
  required bool animate,
}) {
  if (!animate) {
    return HomeOrbLayerSample(
      position: HomeOrbMetrics.center,
      opacity: descriptor.restOpacity,
      scale: descriptor.restScale,
      rotation: 0,
    );
  }

  final driftPosition = descriptor.driftRadius > 0
      ? homeOrbSamplePacedPath(
          descriptor.driftPoints(),
          homeOrbLoopedProgress(elapsed, descriptor.driftDuration, descriptor.phaseOffset),
        )
      : HomeOrbMetrics.center;

  final rotation = descriptor.rotationRange > 0
      ? homeOrbSamplePingPong(
          elapsed: elapsed,
          duration: descriptor.rotationDuration,
          phaseOffset: descriptor.phaseOffset,
          minValue: -descriptor.rotationRange,
          maxValue: descriptor.rotationRange,
        )
      : 0.0;

  final minScale = (descriptor.restScale - descriptor.scaleRange).clamp(0.01, double.infinity);
  final maxScale = descriptor.restScale + descriptor.scaleRange;
  final scale = descriptor.scaleRange > 0
      ? homeOrbSampleKeyframes(
          values: [
            descriptor.restScale,
            maxScale,
            descriptor.restScale,
            minScale,
            descriptor.restScale,
          ],
          keyTimes: const [0, 0.28, 0.55, 0.78, 1],
          progress: homeOrbLoopedProgress(
            elapsed,
            descriptor.scaleDuration,
            descriptor.phaseOffset * 0.9,
          ),
        )
      : descriptor.restScale;

  final minOpacity = (descriptor.restOpacity - descriptor.opacityRange).clamp(0.02, 1.0);
  final maxOpacity = (descriptor.restOpacity + descriptor.opacityRange).clamp(0.0, 1.0);
  final opacity = descriptor.opacityRange > 0
      ? homeOrbSampleKeyframes(
          values: [
            descriptor.restOpacity,
            maxOpacity,
            descriptor.restOpacity,
            minOpacity,
            descriptor.restOpacity,
          ],
          keyTimes: const [0, 0.26, 0.56, 0.80, 1],
          progress: homeOrbLoopedProgress(
            elapsed,
            descriptor.opacityDuration,
            descriptor.phaseOffset * 1.1,
          ),
        )
      : descriptor.restOpacity;

  return HomeOrbLayerSample(
    position: driftPosition,
    opacity: opacity,
    scale: scale,
    rotation: rotation,
  );
}

HomeOrbOrbitDotSample homeOrbSampleOrbitDot({
  required HomeOrbOrbitDotDescriptor descriptor,
  required double elapsed,
  required bool animate,
}) {
  if (!animate) {
    return HomeOrbOrbitDotSample(
      position: descriptor.position(progress: 0),
      opacity: descriptor.restOpacity,
      scale: descriptor.restScale,
    );
  }

  final position = homeOrbSamplePacedPath(
    descriptor.orbitPoints(),
    homeOrbLoopedProgress(elapsed, descriptor.orbitDuration, descriptor.phaseOffset),
  );

  final lowOpacity = (descriptor.restOpacity * 0.64).clamp(0.02, 1.0);
  final highOpacity = (descriptor.restOpacity * 1.22).clamp(0.0, 0.30);
  final opacity = homeOrbSampleKeyframes(
    values: [
      descriptor.restOpacity,
      highOpacity,
      descriptor.restOpacity,
      lowOpacity,
      descriptor.restOpacity,
    ],
    keyTimes: const [0, 0.25, 0.52, 0.78, 1],
    progress: homeOrbLoopedProgress(
      elapsed,
      descriptor.opacityDuration,
      descriptor.phaseOffset * 0.8,
    ),
  );

  final scale = homeOrbSampleKeyframes(
    values: [
      descriptor.restScale,
      descriptor.restScale + descriptor.scaleRange,
      descriptor.restScale,
      (descriptor.restScale - descriptor.scaleRange * 0.36).clamp(0.01, double.infinity),
      descriptor.restScale,
    ],
    keyTimes: const [0, 0.28, 0.54, 0.80, 1],
    progress: homeOrbLoopedProgress(
      elapsed,
      descriptor.scaleDuration,
      descriptor.phaseOffset * 0.55,
    ),
  );

  return HomeOrbOrbitDotSample(
    position: position,
    opacity: opacity,
    scale: scale,
  );
}

HomeOrbSparkSample homeOrbSampleSpark({
  required HomeOrbSparkDescriptor descriptor,
  required double elapsed,
  required bool animate,
}) {
  if (!animate) {
    return HomeOrbSparkSample(
      position: descriptor.position(progress: 0),
      opacity: descriptor.restOpacity,
      scale: descriptor.restScale,
    );
  }

  final position = homeOrbSamplePacedPath(
    descriptor.orbitPoints(),
    homeOrbLoopedProgress(elapsed, descriptor.orbitDuration, descriptor.phaseOffset),
  );

  final lowOpacity = (descriptor.restOpacity * 0.58).clamp(0.03, 1.0);
  final highOpacity = (descriptor.restOpacity * 1.18).clamp(0.0, 0.42);
  final opacity = homeOrbSampleKeyframes(
    values: [
      descriptor.restOpacity,
      highOpacity,
      descriptor.restOpacity * 0.82,
      lowOpacity,
      descriptor.restOpacity,
    ],
    keyTimes: const [0, 0.24, 0.52, 0.78, 1],
    progress: homeOrbLoopedProgress(
      elapsed,
      descriptor.opacityDuration,
      descriptor.phaseOffset * 0.7,
    ),
  );

  final lowScale = (descriptor.restScale - descriptor.scaleRange * 0.24).clamp(0.01, double.infinity);
  final highScale = descriptor.restScale + descriptor.scaleRange * 0.46;
  final scale = homeOrbSampleKeyframes(
    values: [
      descriptor.restScale,
      highScale,
      descriptor.restScale,
      lowScale,
      descriptor.restScale,
    ],
    keyTimes: const [0, 0.27, 0.54, 0.78, 1],
    progress: homeOrbLoopedProgress(
      elapsed,
      descriptor.scaleDuration,
      descriptor.phaseOffset,
    ),
  );

  return HomeOrbSparkSample(
    position: position,
    opacity: opacity,
    scale: scale,
  );
}
