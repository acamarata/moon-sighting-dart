/// Julian Date, time scale conversions, and delta-T.
///
/// Conversion chain: UTC -> TAI -> TT -> TDB
///   TAI = UTC + delta_AT    (from leap-second table, integer seconds)
///   TT  = TAI + 32.184s     (exact, by definition)
///   TDB ~ TT + 0.001658*sin(g) + ...  (sub-millisecond correction)
///
/// References:
///   IERS Conventions (2010), Chapter 5
///   NAIF LSK kernel (naif0012.tls)
///   Espenak & Meeus, delta-T polynomial expressions
library;

import 'dart:math' as math;

/// Julian Date of J2000.0 epoch (2000 Jan 1, 12:00 TT).
const double j2000 = 2451545.0;

/// TT - TAI offset in seconds (exact, by definition).
const double ttMinusTai = 32.184;

/// Seconds per day.
const double secondsPerDay = 86400.0;

/// Days per Julian century.
const double daysPerJulianCentury = 36525.0;

/// All relevant time scale values for a single moment.
class TimeScales {
  /// The original UTC [DateTime].
  final DateTime utc;

  /// Julian Date in UTC.
  final double jdUTC;

  /// Julian Date in Terrestrial Time.
  final double jdTT;

  /// Julian Date in Barycentric Dynamical Time.
  final double jdTDB;

  /// Julian Date in UT1.
  final double jdUT1;

  /// TT - UT1 in seconds (delta-T).
  final double deltaT;

  /// TAI - UTC in seconds (leap seconds count).
  final double deltaAT;

  const TimeScales({
    required this.utc,
    required this.jdUTC,
    required this.jdTT,
    required this.jdTDB,
    required this.jdUT1,
    required this.deltaT,
    required this.deltaAT,
  });
}

/// Leap-second table: [JD(UTC), delta_AT].
/// Source: NAIF naif0012.tls.
const List<(double, double)> leapSecondTable = [
  (2441317.5, 10), // 1972 Jan 1
  (2441499.5, 11), // 1972 Jul 1
  (2441683.5, 12), // 1973 Jan 1
  (2442048.5, 13), // 1974 Jan 1
  (2442413.5, 14), // 1975 Jan 1
  (2442778.5, 15), // 1976 Jan 1
  (2443144.5, 16), // 1977 Jan 1
  (2443509.5, 17), // 1978 Jan 1
  (2443874.5, 18), // 1979 Jan 1
  (2444239.5, 19), // 1980 Jan 1
  (2444786.5, 20), // 1981 Jul 1
  (2445151.5, 21), // 1982 Jul 1
  (2445516.5, 22), // 1983 Jul 1
  (2446247.5, 23), // 1985 Jul 1
  (2447161.5, 24), // 1988 Jan 1
  (2447892.5, 25), // 1990 Jan 1
  (2448257.5, 26), // 1991 Jan 1
  (2448804.5, 27), // 1992 Jul 1
  (2449169.5, 28), // 1993 Jul 1
  (2449534.5, 29), // 1994 Jul 1
  (2450083.5, 30), // 1996 Jan 1
  (2450630.5, 31), // 1997 Jul 1
  (2451179.5, 32), // 1999 Jan 1
  (2453736.5, 33), // 2006 Jan 1
  (2454832.5, 34), // 2009 Jan 1
  (2456109.5, 35), // 2012 Jul 1
  (2457204.5, 36), // 2015 Jul 1
  (2457754.5, 37), // 2017 Jan 1
];

/// Get the current leap second count (TAI - UTC) for a given JD in UTC.
double getDeltaAT(double jdUTC) {
  double deltaAT = 10;
  for (final (jd, dat) in leapSecondTable) {
    if (jdUTC >= jd) {
      deltaAT = dat;
    } else {
      break;
    }
  }
  return deltaAT;
}

/// Convert a [DateTime] (UTC) to Julian Date in UTC.
double dateToJD(DateTime date) {
  return date.toUtc().millisecondsSinceEpoch / 86400000.0 + 2440587.5;
}

/// Convert a Julian Date in UTC to a [DateTime].
DateTime jdToDate(double jd) {
  final ms = ((jd - 2440587.5) * 86400000.0).round();
  return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
}

/// Julian centuries from J2000.0 (in TT).
double jdTTtoT(double jdTT) => (jdTT - j2000) / daysPerJulianCentury;

/// Compute all relevant time scales for a given UTC [DateTime].
TimeScales computeTimeScales(
  DateTime utc, {
  double? ut1utcOverride,
  double? deltaTOverride,
}) {
  final jdUTC = dateToJD(utc);
  final deltaAT = getDeltaAT(jdUTC);

  final jdTAI = jdUTC + deltaAT / secondsPerDay;
  final jdTT = jdTAI + ttMinusTai / secondsPerDay;

  final tdbCorrection = tdbMinusTT(jdTT) / secondsPerDay;
  final jdTDB = jdTT + tdbCorrection;

  double jdUT1;
  double deltaT;

  if (ut1utcOverride != null) {
    jdUT1 = jdUTC + ut1utcOverride / secondsPerDay;
    deltaT = (jdTT - jdUT1) * secondsPerDay;
  } else if (deltaTOverride != null) {
    deltaT = deltaTOverride;
    jdUT1 = jdTT - deltaT / secondsPerDay;
  } else {
    deltaT = deltaTPolynomial(jdTT);
    jdUT1 = jdTT - deltaT / secondsPerDay;
  }

  return TimeScales(
    utc: utc,
    jdUTC: jdUTC,
    jdTT: jdTT,
    jdTDB: jdTDB,
    jdUT1: jdUT1,
    deltaT: deltaT,
    deltaAT: deltaAT,
  );
}

/// Approximate TDB - TT in seconds.
///
/// TDB - TT = 0.001658 * sin(g) + 0.000014 * sin(2g)
/// where g = 357.53 + 0.9856003 * (JD_TT - 2451545.0)
double tdbMinusTT(double jdTT) {
  final d = jdTT - j2000;
  final gDeg = 357.53 + 0.9856003 * d;
  final g = gDeg * math.pi / 180;
  return 0.001658 * math.sin(g) + 0.000014 * math.sin(2 * g);
}

/// Delta-T polynomial: TT - UT1 in seconds.
///
/// Uses Espenak & Meeus expressions, piecewise by year range.
/// Reference: NASA Five Millennium Canon of Solar Eclipses (2009).
double deltaTPolynomial(double jdTT) {
  final y = 2000 + (jdTT - j2000) / 365.25;

  if (y < -500) {
    final u = (y - 1820) / 100;
    return -20 + 32 * u * u;
  } else if (y < 500) {
    final u = y / 100;
    return 10583.6 -
        1014.41 * u +
        33.78311 * u * u -
        5.952053 * u * u * u -
        0.1798452 * math.pow(u, 4) +
        0.022174192 * math.pow(u, 5) +
        0.0090316521 * math.pow(u, 6);
  } else if (y < 1600) {
    final u = (y - 1000) / 100;
    return 1574.2 -
        556.01 * u +
        71.23472 * u * u +
        0.319781 * math.pow(u, 3) -
        0.8503463 * math.pow(u, 4) -
        0.005050998 * math.pow(u, 5) +
        0.0083572073 * math.pow(u, 6);
  } else if (y < 1700) {
    final t = y - 1600;
    return 120 - 0.9808 * t - 0.01532 * t * t + math.pow(t, 3) / 7129;
  } else if (y < 1800) {
    final t = y - 1700;
    return 8.83 +
        0.1603 * t -
        0.0059285 * t * t +
        0.00013336 * math.pow(t, 3) -
        math.pow(t, 4) / 1174000;
  } else if (y < 1860) {
    final t = y - 1800;
    return 13.72 -
        0.332447 * t +
        0.0068612 * t * t +
        0.0041116 * math.pow(t, 3) -
        0.00037436 * math.pow(t, 4) +
        0.0000121272 * math.pow(t, 5) -
        0.0000001699 * math.pow(t, 6) +
        0.000000000875 * math.pow(t, 7);
  } else if (y < 1900) {
    final t = y - 1860;
    return 7.62 +
        0.5737 * t -
        0.251754 * t * t +
        0.01680668 * math.pow(t, 3) -
        0.0004473624 * math.pow(t, 4) +
        math.pow(t, 5) / 233174;
  } else if (y < 1920) {
    final t = y - 1900;
    return -2.79 +
        1.494119 * t -
        0.0598939 * t * t +
        0.0061966 * math.pow(t, 3) -
        0.000197 * math.pow(t, 4);
  } else if (y < 1941) {
    final t = y - 1920;
    return 21.2 + 0.84493 * t - 0.0761 * t * t + 0.0020936 * math.pow(t, 3);
  } else if (y < 1961) {
    final t = y - 1950;
    return 29.07 + 0.407 * t - (t * t) / 233 + math.pow(t, 3) / 2547;
  } else if (y < 1986) {
    final t = y - 1975;
    return 45.45 + 1.067 * t - (t * t) / 260 - math.pow(t, 3) / 718;
  } else if (y < 2005) {
    final t = y - 2000;
    return 63.86 +
        0.3345 * t -
        0.060374 * t * t +
        0.0017275 * math.pow(t, 3) +
        0.000651814 * math.pow(t, 4) +
        0.00002373599 * math.pow(t, 5);
  } else if (y < 2050) {
    final t = y - 2000;
    return 62.92 + 0.32217 * t + 0.005589 * t * t;
  } else if (y < 2150) {
    return -20 + 32 * math.pow((y - 1820) / 100, 2) - 0.5628 * (2150 - y);
  } else {
    final u = (y - 1820) / 100;
    return -20 + 32 * u * u;
  }
}
