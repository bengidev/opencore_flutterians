import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/home/home_orb/home_orb_animator.dart';
import 'package:opencore_flutterians/home/home_orb/home_orb_baker.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(HomeOrbBakeCache.clear);

  test('spark freeze uses rest opacity at progress 0', () async {
    final pack = await HomeOrbBaker.bake(
      tint: const Color(0xFF141414),
      accent: const Color(0xFF2B2B2B),
    );
    final descriptor = pack.sparks.first;

    final sample = homeOrbSampleSpark(
      descriptor: descriptor,
      elapsed: 99,
      animate: false,
    );

    expect(sample.opacity, descriptor.restOpacity);
    expect(sample.position, descriptor.position(progress: 0));
    expect(sample.scale, descriptor.restScale);
  });

  test('layer samples stay continuous across former 20s controller wrap', () async {
    final pack = await HomeOrbBaker.bake(
      tint: const Color(0xFF141414),
      accent: const Color(0xFF2B2B2B),
    );

    // Dust layer (driftDuration 12.4) was the worst wrap teleport (~14px).
    final dust = pack.layers.last;
    final before = homeOrbSampleLayer(
      descriptor: dust,
      elapsed: 19.999,
      animate: true,
    );
    final after = homeOrbSampleLayer(
      descriptor: dust,
      elapsed: 20.001,
      animate: true,
    );
    expect(
      (before.position - after.position).distance,
      lessThan(0.5),
      reason: 'monotonic elapsed must not teleport at t=20',
    );

    // Old AnimationController.repeat() snapped elapsed 20→0; that path still jumps.
    final reset = homeOrbSampleLayer(
      descriptor: dust,
      elapsed: 0,
      animate: true,
    );
    expect(
      (before.position - reset.position).distance,
      greaterThan(5),
      reason: 'documents the discontinuity the wrap used to cause',
    );
  });
}
