/// Crescent visibility criteria: Yallop and Odeh.
///
/// Both criteria transform the geometric quantities (ARCL, ARCV, DAZ, W)
/// into a single score that maps to a visibility category.
///
/// References:
///   Yallop (1997), NAO Technical Note No. 69
///   Odeh (2006), Experimental Astronomy 18(1), 39-64
library;

import 'math.dart';
import 'bodies.dart';
import 'types.dart';

/// The polynomial ARCV minimum as a function of crescent width W (arc minutes).
///
/// arcv_min(W) = 11.8371 - 6.3226*W + 0.7319*W^2 - 0.1018*W^3
///
/// Represents the minimum arc of vision required for detection, derived
/// empirically from historical observations.
double arcvMinimum(double w) {
  return 11.8371 - 6.3226 * w + 0.7319 * w * w - 0.1018 * w * w * w;
}

/// Compute the Yallop q parameter.
///
/// q = (ARCV - arcv_min(W')) / 10
double computeYallopQ(double arcv, double wprime) {
  return (arcv - arcvMinimum(wprime)) / 10;
}

/// Map a q value to Yallop category.
YallopCategory yallopCategoryFromQ(double q) {
  if (q > yallopThresholds[YallopCategory.a]!) return YallopCategory.a;
  if (q > yallopThresholds[YallopCategory.b]!) return YallopCategory.b;
  if (q > yallopThresholds[YallopCategory.c]!) return YallopCategory.c;
  if (q > yallopThresholds[YallopCategory.d]!) return YallopCategory.d;
  if (q > yallopThresholds[YallopCategory.e]!) return YallopCategory.e;
  return YallopCategory.f;
}

/// Compute the full Yallop result from crescent geometry.
YallopResult computeYallop(CrescentGeometry geometry, double wprime) {
  final q = computeYallopQ(geometry.arcv, wprime);
  final category = yallopCategoryFromQ(q);

  return YallopResult(
    q: q,
    category: category,
    description: yallopDescriptions[category]!,
    isVisibleNakedEye:
        category == YallopCategory.a || category == YallopCategory.b,
    requiresOpticalAid:
        category == YallopCategory.c || category == YallopCategory.d,
    isBelowDanjonLimit: category == YallopCategory.f,
    wprime: wprime,
  );
}

/// Compute the Odeh V parameter.
///
/// V = ARCV - arcv_min(W)
double computeOdehV(double arcv, double w) {
  return arcv - arcvMinimum(w);
}

/// Map a V value to the Odeh zone.
OdehZone odehZoneFromV(double v) {
  if (v >= odehThresholds[OdehZone.a]!) return OdehZone.a;
  if (v >= odehThresholds[OdehZone.b]!) return OdehZone.b;
  if (v >= odehThresholds[OdehZone.c]!) return OdehZone.c;
  return OdehZone.d;
}

/// Compute the full Odeh result from crescent geometry.
OdehResult computeOdeh(CrescentGeometry geometry) {
  final v = computeOdehV(geometry.arcv, geometry.w);
  final zone = odehZoneFromV(v);

  return OdehResult(
    v: v,
    zone: zone,
    description: odehDescriptions[zone]!,
    isVisibleNakedEye: zone == OdehZone.a,
    isVisibleWithOpticalAid: zone == OdehZone.a || zone == OdehZone.b,
  );
}

/// Compute crescent geometry quantities from airless topocentric positions.
CrescentGeometry computeCrescentGeometry({
  required AzAlt moonAirless,
  required AzAlt sunAirless,
  required Vec3 moonTopo,
  required Vec3 sunTopo,
}) {
  final arcv = moonAirless.altitude - sunAirless.altitude;

  var daz = sunAirless.azimuth - moonAirless.azimuth;
  if (daz > 180) daz -= 360;
  if (daz < -180) daz += 360;

  final arcl = angularSep(moonTopo, sunTopo) * (180 / 3.141592653589793);
  final (:w, wprime: _) = computeCrescentWidth(moonTopo, arcl);

  return CrescentGeometry(arcl: arcl, arcv: arcv, daz: daz, w: w);
}
