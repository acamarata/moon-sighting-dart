/// User-facing API: 5 lite-mode functions.
///
/// All functions work without a kernel (Meeus-based approximations).
library;

import 'dart:math' as math;

import 'math.dart';
import 'time.dart';
import 'types.dart';
import 'bodies.dart';
import 'observer.dart';
import 'visibility.dart';

// ── Phase display lookup ─────────────────────────────────────────────────────

const _phaseDisplay = <MoonPhaseName, ({String name, String symbol})>{
  MoonPhaseName.newMoon: (name: 'New Moon', symbol: '\u{1F311}'),
  MoonPhaseName.waxingCrescent: (name: 'Waxing Crescent', symbol: '\u{1F312}'),
  MoonPhaseName.firstQuarter: (name: 'First Quarter', symbol: '\u{1F313}'),
  MoonPhaseName.waxingGibbous: (name: 'Waxing Gibbous', symbol: '\u{1F314}'),
  MoonPhaseName.fullMoon: (name: 'Full Moon', symbol: '\u{1F315}'),
  MoonPhaseName.waningGibbous: (name: 'Waning Gibbous', symbol: '\u{1F316}'),
  MoonPhaseName.lastQuarter: (name: 'Last Quarter', symbol: '\u{1F317}'),
  MoonPhaseName.waningCrescent: (name: 'Waning Crescent', symbol: '\u{1F318}'),
};

/// Map elongation and waxing direction to a named phase.
MoonPhaseName _elongationToPhase(double elongationDeg, bool isWaxing) {
  if (elongationDeg < 5) return MoonPhaseName.newMoon;
  if (elongationDeg > 175) return MoonPhaseName.fullMoon;
  if (elongationDeg < 85) {
    return isWaxing
        ? MoonPhaseName.waxingCrescent
        : MoonPhaseName.waningCrescent;
  }
  if (elongationDeg < 95) {
    return isWaxing ? MoonPhaseName.firstQuarter : MoonPhaseName.lastQuarter;
  }
  return isWaxing ? MoonPhaseName.waxingGibbous : MoonPhaseName.waningGibbous;
}

// ── Validation ───────────────────────────────────────────────────────────────

void _validateLatitude(double lat, String label) {
  if (!lat.isFinite || lat < -90 || lat > 90) {
    throw RangeError('$label: latitude must be in [-90, 90], got $lat');
  }
}

void _validateLongitude(double lon, String label) {
  if (!lon.isFinite || lon < -180 || lon > 180) {
    throw RangeError('$label: longitude must be in [-180, 180], got $lon');
  }
}

// ── getMoonPhase ─────────────────────────────────────────────────────────────

/// Compute the Moon's current phase, illumination, and next phase times.
///
/// Works without a kernel (uses Meeus approximation).
///
/// ```dart
/// final phase = getMoonPhase();
/// print(phase.phaseName);    // 'Waxing Crescent'
/// print(phase.illumination); // 14.3 (percent)
/// print(phase.nextFullMoon); // DateTime
/// ```
MoonPhaseResult getMoonPhase([DateTime? date]) {
  final d = date ?? DateTime.now();
  final ts = computeTimeScales(d);
  final (:moonGCRS, :sunGCRS) = getMoonSunApproximate(ts.jdTT);

  final illum = computeIllumination(moonGCRS, sunGCRS);
  final illuminationPct = illum.illumination * 100;

  final prevNewMoonJD = nearestNewMoon(ts.jdTT - 15);
  final age = (ts.jdTT - prevNewMoonJD) * 24;

  final phaseKey = _elongationToPhase(illum.elongationDeg, illum.isWaxing);
  final display = _phaseDisplay[phaseKey]!;

  final nextNewMoonJD = nearestNewMoon(ts.jdTT + 15);
  final nextFullMoonJD = nearestFullMoon(ts.jdTT);

  return MoonPhaseResult(
    phase: phaseKey,
    phaseName: display.name,
    phaseSymbol: display.symbol,
    illumination: illuminationPct,
    age: age,
    elongationDeg: illum.elongationDeg,
    isWaxing: illum.isWaxing,
    nextNewMoon: jdToDate(nextNewMoonJD),
    nextFullMoon: jdToDate(nextFullMoonJD),
    prevNewMoon: jdToDate(prevNewMoonJD),
  );
}

// ── getMoonPosition ──────────────────────────────────────────────────────────

/// Compute the Moon's topocentric position for an observer.
///
/// Works without a kernel (Meeus Ch. 47 approximation).
/// Accuracy: azimuth/altitude ~0.3 deg, distance ~300 km.
///
/// ```dart
/// final pos = getMoonPosition(DateTime.now(), 51.5, -0.1);
/// print('${pos.azimuth}, ${pos.altitude}');
/// ```
MoonPosition getMoonPosition(
  DateTime? date,
  double lat,
  double lon, {
  double elevation = 0,
}) {
  final d = date ?? DateTime.now();
  _validateLatitude(lat, 'getMoonPosition');
  _validateLongitude(lon, 'getMoonPosition');

  final ts = computeTimeScales(d);
  final (:moonGCRS, sunGCRS: _) = getMoonSunApproximate(ts.jdTT);

  final azAlt = computeAzAlt(moonGCRS, lat, lon, elevation, ts);
  final distance = vnorm(moonGCRS);

  // Equatorial coordinates for parallactic angle
  final raMoon = math.atan2(moonGCRS.$2, moonGCRS.$1);
  final decMoon = math.asin((moonGCRS.$3 / distance).clamp(-1.0, 1.0));

  final era = computeERA(ts.jdUT1);
  final ha = era + lon * deg2rad - raMoon;

  final parallacticAngle = math.atan2(
    math.sin(ha),
    math.cos(lat * deg2rad) * math.tan(decMoon) -
        math.sin(lat * deg2rad) * math.cos(ha),
  );

  return MoonPosition(
    azimuth: azAlt.azimuth,
    altitude: azAlt.altitude,
    distance: distance,
    parallacticAngle: parallacticAngle,
  );
}

// ── getMoonIllumination ──────────────────────────────────────────────────────

/// Compute the Moon's illumination fraction, phase cycle, and bright limb angle.
///
/// Works without a kernel (Meeus Ch. 47/48 approximation).
/// Accuracy: fraction ~0.5%, phase fraction ~0.003.
///
/// ```dart
/// final illum = getMoonIllumination();
/// print(illum.fraction); // e.g. 0.43
/// ```
MoonIlluminationResult getMoonIllumination([DateTime? date]) {
  final d = date ?? DateTime.now();
  final ts = computeTimeScales(d);
  final (:moonGCRS, :sunGCRS) = getMoonSunApproximate(ts.jdTT);

  final illum = computeIllumination(moonGCRS, sunGCRS);

  // Phase fraction: 0 = new, 0.25 = first quarter, 0.5 = full, 0.75 = last quarter
  final phase =
      illum.isWaxing
          ? illum.elongationDeg / 360
          : 1 - illum.elongationDeg / 360;

  // Bright limb position angle
  final moonDist = vnorm(moonGCRS);
  final sunDist = vnorm(sunGCRS);
  final raMoon = math.atan2(moonGCRS.$2, moonGCRS.$1);
  final decMoon = math.asin((moonGCRS.$3 / moonDist).clamp(-1.0, 1.0));
  final raSun = math.atan2(sunGCRS.$2, sunGCRS.$1);
  final decSun = math.asin((sunGCRS.$3 / sunDist).clamp(-1.0, 1.0));

  final dRA = raSun - raMoon;
  final angle = math.atan2(
    math.cos(decSun) * math.sin(dRA),
    math.sin(decSun) * math.cos(decMoon) -
        math.cos(decSun) * math.sin(decMoon) * math.cos(dRA),
  );

  return MoonIlluminationResult(
    fraction: illum.illumination,
    phase: phase,
    angle: angle,
    isWaxing: illum.isWaxing,
  );
}

// ── getMoonVisibilityEstimate ────────────────────────────────────────────────

/// Quick kernel-free crescent visibility estimate using the Odeh criterion.
///
/// Computes approximate crescent geometry from Meeus positions at the given
/// observation time and applies the Odeh V-parameter formula.
///
/// ```dart
/// final est = getMoonVisibilityEstimate(obsTime, 21.42, 39.83);
/// print(est.zone.label); // 'A' through 'D'
/// ```
MoonVisibilityEstimate getMoonVisibilityEstimate(
  DateTime? date,
  double lat,
  double lon, {
  double elevation = 0,
}) {
  final d = date ?? DateTime.now();
  _validateLatitude(lat, 'getMoonVisibilityEstimate');
  _validateLongitude(lon, 'getMoonVisibilityEstimate');

  final ts = computeTimeScales(d);
  final (:moonGCRS, :sunGCRS) = getMoonSunApproximate(ts.jdTT);

  // Airless positions (no refraction)
  final moonAirless = computeAzAlt(
    moonGCRS,
    lat,
    lon,
    elevation,
    ts,
    airless: true,
  );
  final sunAirless = computeAzAlt(
    sunGCRS,
    lat,
    lon,
    elevation,
    ts,
    airless: true,
  );

  // ARCL = elongation
  final illumData = computeIllumination(moonGCRS, sunGCRS);
  final arcl = illumData.elongationDeg;

  // ARCV = Moon airless alt minus Sun airless alt
  final arcv = moonAirless.altitude - sunAirless.altitude;

  // Topocentric Moon vector for crescent width
  final obsECEF = geodeticToECEF(lat, lon, elevation);
  final obsITRS = (obsECEF.$1 / 1000, obsECEF.$2 / 1000, obsECEF.$3 / 1000);
  final obsGCRS = itrsToGcrsSimple(obsITRS, ts);
  final moonTopo = vsub(moonGCRS, obsGCRS);

  final (:w, wprime: _) = computeCrescentWidth(moonTopo, arcl);

  final v = arcv - arcvMinimum(w);

  final zone =
      v >= odehThresholds[OdehZone.a]!
          ? OdehZone.a
          : v >= odehThresholds[OdehZone.b]!
          ? OdehZone.b
          : v >= odehThresholds[OdehZone.c]!
          ? OdehZone.c
          : OdehZone.d;

  return MoonVisibilityEstimate(
    v: v,
    zone: zone,
    description: odehDescriptions[zone]!,
    isVisibleNakedEye: zone == OdehZone.a,
    isVisibleWithOpticalAid: zone == OdehZone.a || zone == OdehZone.b,
    arcl: arcl,
    arcv: arcv,
    w: w,
    moonAboveHorizon: moonAirless.altitude > 0,
  );
}

// ── getMoon ──────────────────────────────────────────────────────────────────

/// Combined kernel-free moon snapshot for a time and location.
///
/// Calls [getMoonPhase], [getMoonPosition], [getMoonIllumination], and
/// [getMoonVisibilityEstimate] in a single request.
///
/// ```dart
/// final moon = getMoon(DateTime.now(), 51.5, -0.1);
/// print(moon.phase.phaseName);
/// print(moon.visibility.zone.label);
/// ```
MoonSnapshot getMoon(
  DateTime? date,
  double lat,
  double lon, {
  double elevation = 0,
}) {
  final d = date ?? DateTime.now();
  _validateLatitude(lat, 'getMoon');
  _validateLongitude(lon, 'getMoon');

  return MoonSnapshot(
    phase: getMoonPhase(d),
    position: getMoonPosition(d, lat, lon, elevation: elevation),
    illumination: getMoonIllumination(d),
    visibility: getMoonVisibilityEstimate(d, lat, lon, elevation: elevation),
  );
}
