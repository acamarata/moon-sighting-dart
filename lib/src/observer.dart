/// Geodetic transforms, topocentric ENU, atmospheric refraction, az/alt.
///
/// Observer position chain:
///   geodetic (lat, lon, elev) -> ECEF (ITRS) -> GCRS -> topocentric ENU -> az/alt
///
/// References:
///   WGS84: NIMA TR8350.2, 3rd edition
///   Bennett (1982), Astronomical Refraction
///   Saemundsson (1986), Sky & Telescope 72, 70
library;

import 'dart:math' as math;

import 'math.dart';
import 'time.dart';
import 'types.dart';

/// Convert geodetic coordinates to ECEF position in meters.
Vec3 geodeticToECEF(double lat, double lon, double elev) {
  final phi = lat * math.pi / 180;
  final lam = lon * math.pi / 180;
  final sinPhi = math.sin(phi);
  final cosPhi = math.cos(phi);
  final n = WGS84.a / math.sqrt(1 - WGS84.e2 * sinPhi * sinPhi);
  return (
    (n + elev) * cosPhi * math.cos(lam),
    (n + elev) * cosPhi * math.sin(lam),
    (n * (1 - WGS84.e2) + elev) * sinPhi,
  );
}

/// Compute ENU basis vectors at a geodetic location.
({Vec3 east, Vec3 north, Vec3 up}) computeENUBasis(double lat, double lon) {
  final phi = lat * math.pi / 180;
  final lam = lon * math.pi / 180;
  final sinPhi = math.sin(phi);
  final cosPhi = math.cos(phi);
  final sinLam = math.sin(lam);
  final cosLam = math.cos(lam);

  return (
    east: (-sinLam, cosLam, 0.0),
    north: (-sinPhi * cosLam, -sinPhi * sinLam, cosPhi),
    up: (cosPhi * cosLam, cosPhi * sinLam, sinPhi),
  );
}

/// Convert ECEF displacement to local ENU.
Vec3 ecefToENU(Vec3 ecefDelta, double lat, double lon) {
  final basis = computeENUBasis(lat, lon);
  return (
    vdot(ecefDelta, basis.east),
    vdot(ecefDelta, basis.north),
    vdot(ecefDelta, basis.up),
  );
}

/// Convert ENU vector to azimuth and altitude.
AzAlt enuToAzAlt(Vec3 enu) {
  final e = enu.$1;
  final n = enu.$2;
  final u = enu.$3;
  final horiz = math.sqrt(e * e + n * n);
  final altitude = math.atan2(u, horiz) * 180 / math.pi;
  var azimuth = math.atan2(e, n) * 180 / math.pi;
  if (azimuth < 0) azimuth += 360;
  return AzAlt(azimuth: azimuth, altitude: altitude);
}

/// Compute Earth Rotation Angle from JD in UT1.
double computeERA(double jdUT1) {
  final du = jdUT1 - 2451545.0;
  final era = 2 * math.pi * (0.779057273264 + 1.0027378119113546 * du);
  return ((era % (2 * math.pi)) + 2 * math.pi) % (2 * math.pi);
}

/// Simplified GCRS to ITRS rotation (Earth rotation only, no nutation/precession).
///
/// For lite mode: rotate GCRS by -GMST around the z-axis.
/// This is accurate to ~1 deg, sufficient for phase/visibility estimates.
Vec3 gcrsToItrsSimple(Vec3 gcrs, TimeScales ts) {
  // Use ERA (Earth Rotation Angle) from UT1 as the rotation angle
  final era = computeERA(ts.jdUT1);
  final cosR = math.cos(era);
  final sinR = math.sin(era);
  // Rotation around z-axis by +ERA (GCRS -> ITRS)
  return (
    cosR * gcrs.$1 + sinR * gcrs.$2,
    -sinR * gcrs.$1 + cosR * gcrs.$2,
    gcrs.$3,
  );
}

/// Simplified ITRS to GCRS rotation (inverse of [gcrsToItrsSimple]).
Vec3 itrsToGcrsSimple(Vec3 itrs, TimeScales ts) {
  final era = computeERA(ts.jdUT1);
  final cosR = math.cos(era);
  final sinR = math.sin(era);
  return (
    cosR * itrs.$1 - sinR * itrs.$2,
    sinR * itrs.$1 + cosR * itrs.$2,
    itrs.$3,
  );
}

/// Compute topocentric azimuth and altitude for a body.
///
/// Pipeline:
///   1. body GCRS -> body ITRS (simplified Earth rotation)
///   2. observer geodetic -> observer ECEF (ITRS, m -> km)
///   3. delta_ITRS = body_ITRS - observer_ITRS
///   4. delta_ITRS -> ENU
///   5. ENU -> az/alt
///   6. Apply Bennett refraction if not airless
AzAlt computeAzAlt(
  Vec3 bodyGCRS,
  double lat,
  double lon,
  double elevation,
  TimeScales ts, {
  bool airless = false,
  double pressure = 1013.25,
  double temperature = 15,
}) {
  final bodyITRS = gcrsToItrsSimple(bodyGCRS, ts);

  final obsECEF = geodeticToECEF(lat, lon, elevation);
  final obsITRS = (obsECEF.$1 / 1000, obsECEF.$2 / 1000, obsECEF.$3 / 1000);

  final delta = vsub(bodyITRS, obsITRS);
  final enu = ecefToENU(delta, lat, lon);
  final azAlt = enuToAzAlt(enu);

  if (!airless) {
    azAlt.altitude = applyRefraction(azAlt.altitude, pressure, temperature);
  }

  return azAlt;
}

/// Bennett (1982) atmospheric refraction correction in degrees.
///
/// Formula: R = cot(h + 7.31/(h + 4.4)) / 60
/// with pressure/temperature correction.
double bennettRefraction(
  double altitudeDeg, {
  double pressure = 1013.25,
  double temperature = 15,
}) {
  if (altitudeDeg < -1) return 0;
  final h = altitudeDeg;
  final argDeg = h + 7.31 / (h + 4.4);
  final argRad = argDeg * math.pi / 180;
  final r = 1 / (math.tan(argRad) * 60);
  final corrected = r * (pressure / 1010) * (283 / (273 + temperature));
  return math.max(0, corrected);
}

/// Apply refraction correction to an airless altitude.
double applyRefraction(
  double airlessAlt, [
  double pressure = 1013.25,
  double temperature = 15,
]) {
  return airlessAlt +
      bennettRefraction(
        airlessAlt,
        pressure: pressure,
        temperature: temperature,
      );
}
