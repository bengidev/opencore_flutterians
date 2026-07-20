import 'package:flutter_test/flutter_test.dart';
import 'package:opencore_flutterians/home/home_orb/home_orb_math.dart';

void main() {
  test('noise is deterministic and in unit range', () {
    final a = HomeOrbMath.noise(12, 3);
    final b = HomeOrbMath.noise(12, 3);
    expect(a, b);
    expect(a, greaterThanOrEqualTo(0));
    expect(a, lessThan(1));
  });

  test('gaussian2D peaks at origin', () {
    final peak = HomeOrbMath.gaussian2D(x: 0, y: 0, sigmaX: 0.3, sigmaY: 0.3);
    final side = HomeOrbMath.gaussian2D(x: 1, y: 1, sigmaX: 0.3, sigmaY: 0.3);
    expect(peak, greaterThan(side));
    expect(peak, closeTo(1.0, 1e-9));
  });
}
