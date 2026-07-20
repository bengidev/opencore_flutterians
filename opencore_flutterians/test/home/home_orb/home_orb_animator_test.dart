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
}
