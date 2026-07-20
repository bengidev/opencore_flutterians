import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/home/home_orb/home_orb_baker.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(HomeOrbBakeCache.clear);

  test('bake produces 7 layers, 42 orbit dots, 28 sparks', () async {
    final pack = await HomeOrbBaker.bake(
      tint: const Color(0xFF141414),
      accent: const Color(0xFF2B2B2B),
    );
    expect(pack.layers, hasLength(7));
    expect(pack.outerOrbitDots, hasLength(42));
    expect(pack.sparks, hasLength(28));
    for (final layer in pack.layers) {
      expect(layer.image.width, greaterThan(0));
      expect(layer.image.height, greaterThan(0));
    }
  });
}
