import 'dart:math' as math;

class HomeOrbMath {
  static double noise(double value, double seed) {
    final mixed = math.sin(value * 12.9898 + seed * 78.233) * 43758.5453;
    return mixed - mixed.floorToDouble();
  }

  static double gaussian2D({
    required double x,
    required double y,
    required double sigmaX,
    required double sigmaY,
  }) {
    return math.exp(-0.5 * (math.pow(x / sigmaX, 2) + math.pow(y / sigmaY, 2)));
  }
}
