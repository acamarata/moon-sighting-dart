/// All result types for the moon_sighting package.
library;

/// Azimuth + altitude in degrees.
class AzAlt {
  /// Degrees from North, measured clockwise (0=N, 90=E, 180=S, 270=W).
  double azimuth;

  /// Degrees above the horizon (negative = below).
  double altitude;

  AzAlt({required this.azimuth, required this.altitude});
}

/// Topocentric moon position.
///
/// Computed via Meeus Ch. 47 (no kernel required).
/// Accuracy: azimuth/altitude ~0.3 deg, distance ~300 km.
class MoonPosition {
  /// Azimuth in degrees from North, clockwise.
  final double azimuth;

  /// Apparent altitude in degrees (atmospheric refraction applied).
  final double altitude;

  /// Distance from Earth center to Moon center, km.
  final double distance;

  /// Parallactic angle in radians.
  final double parallacticAngle;

  const MoonPosition({
    required this.azimuth,
    required this.altitude,
    required this.distance,
    required this.parallacticAngle,
  });
}

/// Moon illumination result.
///
/// Computed via Meeus Ch. 47/48 (no kernel required).
class MoonIlluminationResult {
  /// Illuminated fraction 0 (new) to 1 (full).
  final double fraction;

  /// Phase cycle fraction in [0, 1):
  /// 0 = new, 0.25 = first quarter, 0.5 = full, 0.75 = last quarter.
  final double phase;

  /// Position angle of the bright limb midpoint in radians.
  final double angle;

  /// True while elongation is increasing (new toward full).
  final bool isWaxing;

  const MoonIlluminationResult({
    required this.fraction,
    required this.phase,
    required this.angle,
    required this.isWaxing,
  });
}

/// Named moon phase identifiers.
enum MoonPhaseName {
  newMoon('new-moon'),
  waxingCrescent('waxing-crescent'),
  firstQuarter('first-quarter'),
  waxingGibbous('waxing-gibbous'),
  fullMoon('full-moon'),
  waningGibbous('waning-gibbous'),
  lastQuarter('last-quarter'),
  waningCrescent('waning-crescent');

  final String id;
  const MoonPhaseName(this.id);
}

/// Moon phase result from [getMoonPhase].
class MoonPhaseResult {
  /// Named phase.
  final MoonPhaseName phase;

  /// Human-readable name, e.g. "Waxing Crescent".
  final String phaseName;

  /// Moon phase emoji symbol.
  final String phaseSymbol;

  /// Illuminated fraction 0-100 (percent).
  final double illumination;

  /// Hours since last new moon.
  final double age;

  /// Ecliptic longitude of Moon minus Sun, degrees [0, 360).
  final double elongationDeg;

  /// True when illumination is increasing.
  final bool isWaxing;

  /// UTC date of the next new moon.
  final DateTime nextNewMoon;

  /// UTC date of the next full moon.
  final DateTime nextFullMoon;

  /// UTC date of the previous new moon.
  final DateTime prevNewMoon;

  const MoonPhaseResult({
    required this.phase,
    required this.phaseName,
    required this.phaseSymbol,
    required this.illumination,
    required this.age,
    required this.elongationDeg,
    required this.isWaxing,
    required this.nextNewMoon,
    required this.nextFullMoon,
    required this.prevNewMoon,
  });
}

/// Yallop q-test visibility category (NAO Technical Note 69).
enum YallopCategory {
  /// Easily visible to the naked eye.
  a('A'),

  /// Visible under perfect conditions.
  b('B'),

  /// May need optical aid to find; naked eye possible.
  c('C'),

  /// Optical aid needed; naked eye not possible.
  d('D'),

  /// Not visible even with telescope under good conditions.
  e('E'),

  /// Below Danjon limit.
  f('F');

  final String label;
  const YallopCategory(this.label);
}

/// Yallop q-test result.
class YallopResult {
  /// The continuous q parameter (higher = more visible).
  final double q;

  /// Visibility category A through F.
  final YallopCategory category;

  /// Human-readable interpretation.
  final String description;

  /// True for categories A and B.
  final bool isVisibleNakedEye;

  /// True for categories C and D.
  final bool requiresOpticalAid;

  /// True for category F.
  final bool isBelowDanjonLimit;

  /// Topocentric crescent width W' used in the q formula, arc minutes.
  final double wprime;

  const YallopResult({
    required this.q,
    required this.category,
    required this.description,
    required this.isVisibleNakedEye,
    required this.requiresOpticalAid,
    required this.isBelowDanjonLimit,
    required this.wprime,
  });
}

/// Odeh visibility zone (Experimental Astronomy 2006).
enum OdehZone {
  /// Visible with naked eye.
  a('A'),

  /// Visible with optical aid; may be seen with naked eye.
  b('B'),

  /// Visible with optical aid only.
  c('C'),

  /// Not visible even with optical aid.
  d('D');

  final String label;
  const OdehZone(this.label);
}

/// Odeh criterion result.
class OdehResult {
  /// Continuous V parameter: V = ARCV - f(W). Positive = exceeds threshold.
  final double v;

  /// Visibility zone A through D.
  final OdehZone zone;

  /// Human-readable interpretation.
  final String description;

  /// True for zone A.
  final bool isVisibleNakedEye;

  /// True for zones A and B.
  final bool isVisibleWithOpticalAid;

  const OdehResult({
    required this.v,
    required this.zone,
    required this.description,
    required this.isVisibleNakedEye,
    required this.isVisibleWithOpticalAid,
  });
}

/// Crescent geometry quantities.
class CrescentGeometry {
  /// Arc of light: Sun-Moon angular separation (elongation), degrees.
  final double arcl;

  /// Arc of vision: Moon airless alt minus Sun airless alt, degrees.
  final double arcv;

  /// Relative azimuth: Sun az minus Moon az, degrees.
  final double daz;

  /// Topocentric crescent width in arc minutes.
  final double w;

  const CrescentGeometry({
    required this.arcl,
    required this.arcv,
    required this.daz,
    required this.w,
  });
}

/// Kernel-free Odeh-based crescent visibility estimate.
class MoonVisibilityEstimate {
  /// Odeh V parameter.
  final double v;

  /// Visibility zone A through D.
  final OdehZone zone;

  /// Human-readable zone description.
  final String description;

  /// True for zone A.
  final bool isVisibleNakedEye;

  /// True for zones A and B.
  final bool isVisibleWithOpticalAid;

  /// Arc of light (Sun-Moon elongation) in degrees.
  final double arcl;

  /// Arc of vision (Moon airless alt minus Sun airless alt) in degrees.
  final double arcv;

  /// Topocentric crescent width in arc minutes.
  final double w;

  /// True when Moon is above the horizon at the given time.
  final bool moonAboveHorizon;

  /// Always true: computed via Meeus approximation.
  final bool isApproximate = true;

  MoonVisibilityEstimate({
    required this.v,
    required this.zone,
    required this.description,
    required this.isVisibleNakedEye,
    required this.isVisibleWithOpticalAid,
    required this.arcl,
    required this.arcv,
    required this.w,
    required this.moonAboveHorizon,
  });
}

/// Combined kernel-free moon snapshot.
class MoonSnapshot {
  /// Phase name, illumination, age, and next events.
  final MoonPhaseResult phase;

  /// Topocentric az/alt, distance, parallactic angle.
  final MoonPosition position;

  /// Illumination fraction, phase cycle, bright limb angle.
  final MoonIlluminationResult illumination;

  /// Quick Odeh-based crescent visibility estimate.
  final MoonVisibilityEstimate visibility;

  const MoonSnapshot({
    required this.phase,
    required this.position,
    required this.illumination,
    required this.visibility,
  });
}

/// Published Yallop q thresholds.
const Map<YallopCategory, double> yallopThresholds = {
  YallopCategory.a: 0.216,
  YallopCategory.b: -0.014,
  YallopCategory.c: -0.16,
  YallopCategory.d: -0.232,
  YallopCategory.e: -0.293,
};

/// Yallop category descriptions.
const Map<YallopCategory, String> yallopDescriptions = {
  YallopCategory.a: 'Easily visible to the naked eye',
  YallopCategory.b: 'Visible under perfect conditions',
  YallopCategory.c: 'May need optical aid to find; naked eye possible',
  YallopCategory.d: 'Optical aid needed; naked eye not possible',
  YallopCategory.e: 'Not visible even with telescope under good conditions',
  YallopCategory.f: 'Below Danjon limit — crescent cannot form',
};

/// Published Odeh V thresholds.
const Map<OdehZone, double> odehThresholds = {
  OdehZone.a: 5.65,
  OdehZone.b: 2.0,
  OdehZone.c: -0.96,
};

/// Odeh zone descriptions.
const Map<OdehZone, String> odehDescriptions = {
  OdehZone.a: 'Visible with naked eye',
  OdehZone.b:
      'Visible with optical aid; may be seen with naked eye under excellent conditions',
  OdehZone.c: 'Visible with optical aid only',
  OdehZone.d: 'Not visible even with optical aid',
};

/// WGS84 reference ellipsoid parameters.
class WGS84 {
  WGS84._();

  /// Semi-major axis in meters.
  static const double a = 6378137.0;

  /// Inverse flattening.
  static const double invF = 298.257223563;

  /// Flattening.
  static const double f = 1 / invF;

  /// Semi-minor axis in meters.
  static final double b = a * (1 - f);

  /// First eccentricity squared.
  static final double e2 = 2 * f - f * f;
}
