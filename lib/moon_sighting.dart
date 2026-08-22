/// Lunar crescent visibility for Dart and Flutter.
///
/// Moon phase, position, illumination, and Yallop/Odeh visibility criteria
/// using Meeus algorithms. Zero dependencies.
///
/// ## Accuracy of topocentric results
///
/// [getMoonPhase] and [getMoonIllumination] are geocentric and match the reference
/// JavaScript `moon-sighting` package to the last bit.
///
/// [getMoonPosition] and [getMoonVisibilityEstimate] are topocentric, and this port reaches
/// the observer frame with a single rotation by the Earth Rotation Angle. It does not apply
/// precession or nutation, so altitudes can differ from the reference implementation by up
/// to **0.88 degrees** at present epochs, growing as you move away from J2000.
///
/// For orientation, moonrise direction, or a general sense of where the Moon is, that is
/// immaterial. For a crescent-visibility decision it is not: the Yallop and Odeh criteria
/// turn on tenths of a degree, so a zone returned near a boundary should be treated as
/// provisional. Confirmed sightings and local moonsighting authority remain the arbiter,
/// as they should for any computed estimate.
///
/// Five public functions:
/// - [getMoonPhase] - phase name, illumination, age, next events
/// - [getMoonPosition] - topocentric azimuth, altitude, distance
/// - [getMoonIllumination] - illumination fraction, phase cycle, bright limb
/// - [getMoonVisibilityEstimate] - Odeh crescent visibility estimate
/// - [getMoon] - combined snapshot of all four
library;

export 'src/types.dart';
export 'src/api.dart';
export 'src/visibility.dart' show arcvMinimum;
