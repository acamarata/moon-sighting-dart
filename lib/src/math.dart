/// Vector math and angle utilities.
///
/// All computation is pure (no I/O, no state).
library;

import 'dart:math' as math;

/// Degrees to radians conversion factor.
const double deg2rad = math.pi / 180;

/// Radians to degrees conversion factor.
const double rad2deg = 180 / math.pi;

/// A three-element vector (position or velocity).
typedef Vec3 = (double, double, double);

/// Add two 3-vectors.
Vec3 vadd(Vec3 a, Vec3 b) => (a.$1 + b.$1, a.$2 + b.$2, a.$3 + b.$3);

/// Subtract b from a.
Vec3 vsub(Vec3 a, Vec3 b) => (a.$1 - b.$1, a.$2 - b.$2, a.$3 - b.$3);

/// Scale a 3-vector.
Vec3 vscale(Vec3 a, double s) => (a.$1 * s, a.$2 * s, a.$3 * s);

/// Dot product.
double vdot(Vec3 a, Vec3 b) => a.$1 * b.$1 + a.$2 * b.$2 + a.$3 * b.$3;

/// Euclidean norm.
double vnorm(Vec3 a) => math.sqrt(vdot(a, a));

/// Cross product.
Vec3 vcross(Vec3 a, Vec3 b) => (
  a.$2 * b.$3 - a.$3 * b.$2,
  a.$3 * b.$1 - a.$1 * b.$3,
  a.$1 * b.$2 - a.$2 * b.$1,
);

/// Unit vector (normalized). Throws if zero vector.
Vec3 vunit(Vec3 a) {
  final n = vnorm(a);
  if (n == 0) throw RangeError('Cannot normalize a zero vector');
  return vscale(a, 1 / n);
}

/// Angular separation between two direction vectors in radians.
double angularSep(Vec3 a, Vec3 b) {
  final cosAngle = (vdot(vunit(a), vunit(b))).clamp(-1.0, 1.0);
  return math.acos(cosAngle);
}

/// Normalize an angle to [0, 2*pi).
double mod2pi(double angle) {
  const twoPi = 2 * math.pi;
  return ((angle % twoPi) + twoPi) % twoPi;
}

/// Normalize an angle in degrees to [0, 360).
double mod360(double deg) => ((deg % 360) + 360) % 360;

/// Normalize an angle in degrees to [-180, 180).
double normalizeDeg180(double deg) {
  deg = mod360(deg);
  return deg >= 180 ? deg - 360 : deg;
}
