import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/home/home_orb/home_orb_layout.dart';
import 'package:opencore_flutterians/home/home_orb/home_orb_metrics.dart';

void main() {
  test('layout factories return Swift particle counts', () {
    expect(
      HomeOrbLayout.makeOuterDots(seedOffset: 0, count: 138, radiusBias: 0.72),
      hasLength(138),
    );
    expect(
      HomeOrbLayout.makeOuterDots(
        seedOffset: 1200,
        count: 126,
        radiusBias: 0.66,
      ),
      hasLength(126),
    );
    expect(HomeOrbLayout.makePulseDots(seedOffset: 1800, count: 86), hasLength(86));
    expect(HomeOrbLayout.makeOrbDust(seedOffset: 9600, count: 132), hasLength(132));
    expect(
      HomeOrbLayout.makeCoreBlocks(
        seedOffset: 2400,
        count: 236,
        prominence: 0.96,
      ),
      hasLength(236),
    );
    expect(
      HomeOrbLayout.makeCoreBlocks(
        seedOffset: 4800,
        count: 220,
        prominence: 0.78,
      ),
      hasLength(220),
    );
    expect(
      HomeOrbLayout.makeCoreBlocks(
        seedOffset: 7200,
        count: 158,
        prominence: 0.58,
      ),
      hasLength(158),
    );
    expect(
      HomeOrbLayout.makeOuterOrbitDotSeeds(seedOffset: 12800, count: 42),
      hasLength(42),
    );
    expect(HomeOrbLayout.makeSparkSeeds(seedOffset: 11200, count: 28), hasLength(28));
  });

  test('metrics match Swift canvas', () {
    expect(HomeOrbMetrics.canvasSize, const Size(360, 240));
    expect(HomeOrbMetrics.glyphRamp, ['░', '▒', '▓', '█']);
  });
}
