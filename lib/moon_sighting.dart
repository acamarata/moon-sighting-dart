/// Lunar crescent visibility for Dart and Flutter.
///
/// Moon phase, position, illumination, and Yallop/Odeh visibility criteria
/// using Meeus algorithms. Zero dependencies.
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
