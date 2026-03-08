/// Moon and Sun positions using Meeus Ch. 25/47, illumination geometry.
///
/// References:
///   Meeus, J. (1998). Astronomical Algorithms, 2nd ed. Willmann-Bell.
///   Odeh, M. (2006). New Criterion for Lunar Crescent Visibility.
library;

import 'dart:math' as math;

import 'math.dart';
import 'time.dart';

/// AU in km.
const double _auKm = 149597870.7;

/// Mean radius of the Moon in km (IAU 2015).
const double moonRadiusKm = 1737.4;

/// Low-accuracy Sun and Moon positions using Meeus Ch. 25/47.
///
/// Error budget:
///   Sun: < 0.01 deg in ecliptic longitude
///   Moon: < 0.3 deg in ecliptic longitude, < 0.2 deg in latitude
({Vec3 moonGCRS, Vec3 sunGCRS}) getMoonSunApproximate(double jdTT) {
  final t = (jdTT - j2000) / daysPerJulianCentury;

  // Sun (Meeus Ch. 25)
  final l0 = 280.46646 + 36000.76983 * t + 0.0003032 * t * t;
  final mSun = 357.52911 + 35999.05029 * t - 0.0001537 * t * t;
  final mSunRad = (mSun % 360) * deg2rad;
  final eSun = 0.016708634 - 0.000042037 * t - 0.0000001267 * t * t;

  final c =
      (1.914602 - 0.004817 * t - 0.000014 * t * t) * math.sin(mSunRad) +
      (0.019993 - 0.000101 * t) * math.sin(2 * mSunRad) +
      0.000289 * math.sin(3 * mSunRad);

  final sunLonDeg = l0 + c;
  final nuRad = mSunRad + c * deg2rad;
  final rAU = (1.000001018 * (1 - eSun * eSun)) / (1 + eSun * math.cos(nuRad));
  final rKm = rAU * _auKm;

  final omega = (125.04 - 1934.136 * t) * deg2rad;
  final sunLonApp = sunLonDeg - 0.00569 - 0.00478 * math.sin(omega);
  final sunLonRad = sunLonApp * deg2rad;

  final eps =
      (23.439291111 -
          0.013004167 * t -
          0.0000001638 * t * t +
          0.0000005036 * t * t * t) *
      deg2rad;

  final sunGCRS = (
    rKm * math.cos(sunLonRad),
    rKm * math.sin(sunLonRad) * math.cos(eps),
    rKm * math.sin(sunLonRad) * math.sin(eps),
  );

  // Moon (Meeus Ch. 47)
  final lp =
      218.3164477 +
      481267.88123421 * t -
      0.0015786 * t * t +
      (t * t * t) / 538841 -
      (t * t * t * t) / 65194000;
  final d =
      297.8501921 +
      445267.1114034 * t -
      0.0018819 * t * t +
      (t * t * t) / 545868 -
      (t * t * t * t) / 113065000;
  final m =
      357.5291092 +
      35999.0502909 * t -
      0.0001536 * t * t +
      (t * t * t) / 24490000;
  final mp =
      134.9633964 +
      477198.8675055 * t +
      0.0087414 * t * t +
      (t * t * t) / 69699 -
      (t * t * t * t) / 14712000;
  final f =
      93.272095 +
      483202.0175233 * t -
      0.0036539 * t * t -
      (t * t * t) / 3526000 +
      (t * t * t * t) / 863310000;

  final a1 = (119.75 + 131.849 * t) * deg2rad;
  final a2 = (53.09 + 479264.29 * t) * deg2rad;
  final a3 = (313.45 + 481266.484 * t) * deg2rad;

  final dR = (d % 360) * deg2rad;
  final mR = (m % 360) * deg2rad;
  final mpR = (mp % 360) * deg2rad;
  final fR = (f % 360) * deg2rad;

  final e = 1 - 0.002516 * t - 0.0000074 * t * t;

  // Longitude and distance: 30 terms from Meeus Table 47.A
  // [d, m, mp, f, Sl (1e-6 deg), Sr (1e-3 km)]
  const ld = <(int, int, int, int, int, int)>[
    (0, 0, 1, 0, 6288774, -20905355),
    (2, 0, -1, 0, 1274027, -3699111),
    (2, 0, 0, 0, 658314, -2955968),
    (0, 0, 2, 0, 213618, -569925),
    (0, 1, 0, 0, -185116, 48888),
    (0, 0, 0, 2, -114332, -3149),
    (2, 0, -2, 0, 58793, 246158),
    (2, -1, -1, 0, 57066, -152138),
    (2, 0, 1, 0, 53322, -170733),
    (2, -1, 0, 0, 45758, -204586),
    (0, 1, -1, 0, -40923, -129620),
    (1, 0, 0, 0, -34720, 108743),
    (0, 1, 1, 0, -30383, 104755),
    (2, 0, 0, -2, 15327, 10321),
    (0, 0, 1, 2, -12528, 0),
    (0, 0, 1, -2, 10980, 79661),
    (4, 0, -1, 0, 10675, -34782),
    (0, 0, 3, 0, 10034, -23210),
    (4, 0, -2, 0, 8548, -21636),
    (2, 1, -1, 0, -7888, 24208),
    (2, 1, 0, 0, -6766, 30824),
    (1, 0, -1, 0, -5163, -8379),
    (1, 1, 0, 0, 4987, -16675),
    (2, -1, 1, 0, 4036, -12831),
    (2, 0, 2, 0, 3994, -10445),
    (4, 0, 0, 0, 3861, -11650),
    (2, 0, -3, 0, 3665, 14403),
    (0, 1, -2, 0, -2689, -7003),
    (2, 0, -1, 2, -2602, 0),
    (2, -1, -2, 0, 2390, 10056),
  ];

  var sl = 0.0;
  var sr = 0.0;
  for (final (di, mi, mpi, fi, slc, src) in ld) {
    final arg = di * dR + mi * mR + mpi * mpR + fi * fR;
    final eCorr =
        mi.abs() == 2
            ? e * e
            : mi.abs() == 1
            ? e
            : 1.0;
    sl += slc * eCorr * math.sin(arg);
    sr += src * eCorr * math.cos(arg);
  }

  sl +=
      3958 * math.sin(a1) +
      1962 * math.sin((lp - f) * deg2rad) +
      318 * math.sin(a2);

  // Latitude: 20 terms from Meeus Table 47.B
  const fb = <(int, int, int, int, int)>[
    (0, 0, 0, 1, 5128122),
    (0, 0, 1, 1, 280602),
    (0, 0, 1, -1, 277693),
    (2, 0, 0, -1, 173237),
    (2, 0, -1, 1, 55413),
    (2, 0, -1, -1, 46271),
    (2, 0, 0, 1, 32573),
    (0, 0, 2, 1, 17198),
    (2, 0, 1, -1, 9266),
    (0, 0, 2, -1, 8822),
    (2, -1, 0, -1, 8216),
    (2, 0, -2, -1, 4324),
    (2, 0, 1, 1, 4200),
    (2, 1, 0, -1, -3359),
    (2, -1, -1, 1, 2463),
    (2, -1, 0, 1, 2211),
    (2, -1, -1, -1, 2065),
    (0, 1, -1, -1, -1870),
    (4, 0, -1, -1, 1828),
    (0, 1, 0, 1, -1794),
  ];

  var sb = 0.0;
  for (final (di, mi, mpi, fi, sbc) in fb) {
    final arg = di * dR + mi * mR + mpi * mpR + fi * fR;
    final eCorr =
        mi.abs() == 2
            ? e * e
            : mi.abs() == 1
            ? e
            : 1.0;
    sb += sbc * eCorr * math.sin(arg);
  }

  sb +=
      -2235 * math.sin(lp * deg2rad) +
      382 * math.sin(a3) +
      175 * math.sin(a1 - fR) +
      175 * math.sin(a1 + fR) +
      127 * math.sin((lp - mp) * deg2rad) -
      115 * math.sin((lp + mp) * deg2rad);

  final moonLonDeg = lp + sl * 1e-6;
  final moonLatDeg = sb * 1e-6;
  final moonDistKm = 385000.56 + sr * 0.001;

  final moonLonRad = moonLonDeg * deg2rad;
  final moonLatRad = moonLatDeg * deg2rad;

  final moonGCRS = (
    moonDistKm * math.cos(moonLatRad) * math.cos(moonLonRad),
    moonDistKm *
        (math.cos(eps) * math.cos(moonLatRad) * math.sin(moonLonRad) -
            math.sin(eps) * math.sin(moonLatRad)),
    moonDistKm *
        (math.sin(eps) * math.cos(moonLatRad) * math.sin(moonLonRad) +
            math.cos(eps) * math.sin(moonLatRad)),
  );

  return (moonGCRS: moonGCRS, sunGCRS: sunGCRS);
}

/// Estimate the nearest new moon JD using Meeus Ch. 49.
/// Accurate to within ~2 hours.
double nearestNewMoon(double jdTT) {
  final y = 2000.0 + (jdTT - j2000) / 365.25;
  final k = ((y - 2000.0) * 12.3685).round().toDouble();
  final t = k / 1236.85;

  var jde =
      2451550.09766 +
      29.530588861 * k +
      0.00015437 * t * t -
      0.00000015 * t * t * t +
      0.00000000073 * t * t * t * t;

  final mArg =
      (2.5534 + 29.1053567 * k - 0.0000014 * t * t - 0.00000011 * t * t * t) *
      deg2rad;
  final mpArg =
      (201.5643 +
          385.81693528 * k +
          0.0107582 * t * t +
          0.00001238 * t * t * t) *
      deg2rad;
  final fc =
      (160.7108 +
          390.67050284 * k -
          0.0016118 * t * t -
          0.00000227 * t * t * t) *
      deg2rad;
  final om =
      (124.7746 - 1.56375588 * k + 0.0020672 * t * t + 0.00000215 * t * t * t) *
      deg2rad;
  final eCorr = 1 - 0.002516 * t - 0.0000074 * t * t;

  jde +=
      -0.4072 * math.sin(mpArg) +
      0.17241 * eCorr * math.sin(mArg) +
      0.01608 * math.sin(2 * mpArg) +
      0.01039 * math.sin(2 * fc) +
      0.00739 * eCorr * math.sin(mpArg - mArg) -
      0.00514 * eCorr * math.sin(mpArg + mArg) +
      0.00208 * eCorr * eCorr * math.sin(2 * mArg) -
      0.00111 * math.sin(mpArg - 2 * fc) -
      0.00057 * math.sin(mpArg + 2 * fc) +
      0.00056 * eCorr * math.sin(2 * mpArg + mArg) -
      0.00042 * math.sin(3 * mpArg) +
      0.00042 * eCorr * math.sin(mArg + 2 * fc) +
      0.00038 * eCorr * math.sin(mArg - 2 * fc) -
      0.00024 * eCorr * math.sin(2 * mpArg - mArg) -
      0.00017 * math.sin(om) -
      0.00007 * math.sin(mpArg + 2 * mArg) +
      0.00004 * math.sin(2 * mpArg - 2 * fc) +
      0.00004 * math.sin(3 * mArg) +
      0.00003 * math.sin(mpArg + mArg - 2 * fc) +
      0.00003 * math.sin(2 * mpArg + 2 * fc) -
      0.00003 * math.sin(mpArg + mArg + 2 * fc) +
      0.00003 * math.sin(mpArg - mArg + 2 * fc) -
      0.00002 * math.sin(mpArg - mArg - 2 * fc) -
      0.00002 * math.sin(3 * mpArg + mArg) +
      0.00002 * math.sin(4 * mpArg);

  return jde;
}

/// Estimate the nearest full moon JD using Meeus Ch. 49.
double nearestFullMoon(double jdTT) {
  final y = 2000 + (jdTT - j2000) / 365.25;
  final kBase = ((y - 2000.0) * 12.3685).round().toDouble();
  final k1 = kBase - 0.5;
  final k2 = kBase + 0.5;
  final jde1 = _fullMoonJDE(k1);
  final jde2 = _fullMoonJDE(k2);
  final d1 = (jde1 - jdTT).abs();
  final d2 = (jde2 - jdTT).abs();
  return d1 < d2 ? jde1 : jde2;
}

double _fullMoonJDE(double k) {
  final t = k / 1236.85;
  var jde =
      2451550.09766 +
      29.530588861 * k +
      0.00015437 * t * t -
      0.00000015 * t * t * t +
      0.00000000073 * t * t * t * t;

  final mArg = (2.5534 + 29.1053567 * k - 0.0000014 * t * t) * deg2rad;
  final mpArg = (201.5643 + 385.81693528 * k + 0.0107582 * t * t) * deg2rad;
  final fc = (160.7108 + 390.67050284 * k - 0.0016118 * t * t) * deg2rad;
  final om = (124.7746 - 1.56375588 * k + 0.0020672 * t * t) * deg2rad;
  final eCorr = 1 - 0.002516 * t - 0.0000074 * t * t;

  jde +=
      -0.40614 * math.sin(mpArg) +
      0.17302 * eCorr * math.sin(mArg) +
      0.01614 * math.sin(2 * mpArg) +
      0.01043 * math.sin(2 * fc) +
      0.00734 * eCorr * math.sin(mpArg - mArg) -
      0.00515 * eCorr * math.sin(mpArg + mArg) +
      0.00209 * eCorr * eCorr * math.sin(2 * mArg) -
      0.00111 * math.sin(mpArg - 2 * fc) -
      0.00057 * math.sin(mpArg + 2 * fc) +
      0.00056 * eCorr * math.sin(2 * mpArg + mArg) -
      0.00042 * math.sin(3 * mpArg) +
      0.00042 * eCorr * math.sin(mArg + 2 * fc) +
      0.00038 * eCorr * math.sin(mArg - 2 * fc) -
      0.00024 * eCorr * math.sin(2 * mpArg - mArg) -
      0.00017 * math.sin(om) -
      0.00007 * math.sin(mpArg + 2 * mArg) +
      0.00004 * math.sin(2 * mpArg - 2 * fc) +
      0.00004 * math.sin(3 * mArg) +
      0.00003 * math.sin(mpArg + mArg - 2 * fc) +
      0.00003 * math.sin(2 * mpArg + 2 * fc) -
      0.00003 * math.sin(mpArg + mArg + 2 * fc) +
      0.00003 * math.sin(mpArg - mArg + 2 * fc) -
      0.00002 * math.sin(mpArg - mArg - 2 * fc) -
      0.00002 * math.sin(3 * mpArg + mArg) +
      0.00002 * math.sin(4 * mpArg);

  return jde;
}

/// Compute Moon illumination quantities from geocentric positions.
///
/// Returns illumination fraction [0-1], phase angle (deg), elongation (deg),
/// and whether the Moon is waxing.
({
  double illumination,
  double phaseAngleDeg,
  double elongationDeg,
  bool isWaxing,
})
computeIllumination(Vec3 moonGCRS, Vec3 sunGCRS) {
  final rMoon = vnorm(moonGCRS);
  final rSun = vnorm(sunGCRS);

  final cosElong = (vdot(moonGCRS, sunGCRS) / (rMoon * rSun)).clamp(-1.0, 1.0);
  final elongationDeg = math.acos(cosElong) / deg2rad;

  final moonToSun = (
    sunGCRS.$1 - moonGCRS.$1,
    sunGCRS.$2 - moonGCRS.$2,
    sunGCRS.$3 - moonGCRS.$3,
  );
  final moonToEarth = (-moonGCRS.$1, -moonGCRS.$2, -moonGCRS.$3);
  final rMoonToSun = vnorm(moonToSun);

  final cosPhase = (vdot(moonToEarth, moonToSun) / (rMoon * rMoonToSun)).clamp(
    -1.0,
    1.0,
  );
  final phaseAngleDeg = math.acos(cosPhase) / deg2rad;

  final illumination = (1 + math.cos(phaseAngleDeg * deg2rad)) / 2;

  final crossZ = sunGCRS.$1 * moonGCRS.$2 - sunGCRS.$2 * moonGCRS.$1;
  final isWaxing = crossZ > 0;

  return (
    illumination: illumination,
    phaseAngleDeg: phaseAngleDeg,
    elongationDeg: elongationDeg,
    isWaxing: isWaxing,
  );
}

/// Compute topocentric crescent width W in arc minutes.
///
/// W = SD * (1 - cos(ARCL)) where SD is the topocentric semi-diameter.
({double w, double wprime}) computeCrescentWidth(
  Vec3 moonTopoVec,
  double arcl,
) {
  final rMoon = vnorm(moonTopoVec);
  final sdArcmin = (math.atan(moonRadiusKm / rMoon) / deg2rad) * 60;
  final arclRad = arcl * deg2rad;
  final w = sdArcmin * (1 - math.cos(arclRad));
  return (w: w, wprime: w);
}
