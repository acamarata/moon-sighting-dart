# moon_sighting

[![pub package](https://img.shields.io/pub/v/moon_sighting.svg)](https://pub.dev/packages/moon_sighting)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Lunar crescent visibility for Dart and Flutter. Computes moon phase, topocentric position, illumination, and Yallop/Odeh crescent visibility criteria using Meeus algorithms. Zero dependencies.

## Installation

```yaml
dependencies:
  moon_sighting: ^1.0.0
```

## Quick Start

```dart
import 'package:moon_sighting/moon_sighting.dart';

// Current moon phase
final phase = getMoonPhase();
print('${phase.phaseName} ${phase.phaseSymbol}');
print('Illumination: ${phase.illumination.toStringAsFixed(1)}%');
print('Age: ${phase.age.toStringAsFixed(1)} hours');

// Moon position for an observer
final pos = getMoonPosition(DateTime.now(), 51.5074, -0.1278, elevation: 10);
print('Azimuth: ${pos.azimuth.toStringAsFixed(1)}');
print('Altitude: ${pos.altitude.toStringAsFixed(1)}');
print('Distance: ${pos.distance.toStringAsFixed(0)} km');

// Crescent visibility estimate (pass a post-sunset time)
final vis = getMoonVisibilityEstimate(
  DateTime.utc(2025, 3, 31, 18, 30),
  21.4225, 39.8262, // Mecca
);
print('Zone: ${vis.zone.label}'); // A through D
print('Visible naked eye: ${vis.isVisibleNakedEye}');
```

## API

### getMoonPhase([DateTime? date])

Returns `MoonPhaseResult` with:

| Field | Type | Description |
| --- | --- | --- |
| `phase` | `MoonPhaseName` | Enum: newMoon, waxingCrescent, firstQuarter, etc. |
| `phaseName` | `String` | Human-readable name |
| `phaseSymbol` | `String` | Moon emoji |
| `illumination` | `double` | Percent illuminated (0-100) |
| `age` | `double` | Hours since last new moon |
| `elongationDeg` | `double` | Moon-Sun elongation in degrees |
| `isWaxing` | `bool` | True when illumination is increasing |
| `nextNewMoon` | `DateTime` | Next new moon (UTC) |
| `nextFullMoon` | `DateTime` | Next full moon (UTC) |
| `prevNewMoon` | `DateTime` | Previous new moon (UTC) |

### getMoonPosition(DateTime? date, double lat, double lon, {double elevation = 0})

Returns `MoonPosition` with:

| Field | Type | Description |
| --- | --- | --- |
| `azimuth` | `double` | Degrees from North, clockwise |
| `altitude` | `double` | Degrees above horizon (refraction applied) |
| `distance` | `double` | Earth-Moon distance in km |
| `parallacticAngle` | `double` | Parallactic angle in radians |

### getMoonIllumination([DateTime? date])

Returns `MoonIlluminationResult` with:

| Field | Type | Description |
| --- | --- | --- |
| `fraction` | `double` | Illuminated fraction (0-1) |
| `phase` | `double` | Phase cycle (0=new, 0.25=Q1, 0.5=full, 0.75=Q3) |
| `angle` | `double` | Bright limb position angle (radians) |
| `isWaxing` | `bool` | True when waxing |

### getMoonVisibilityEstimate(DateTime? date, double lat, double lon, {double elevation = 0})

Returns `MoonVisibilityEstimate` with:

| Field | Type | Description |
| --- | --- | --- |
| `v` | `double` | Odeh V parameter |
| `zone` | `OdehZone` | Visibility zone (a through d) |
| `description` | `String` | Zone description |
| `isVisibleNakedEye` | `bool` | True for zone A |
| `isVisibleWithOpticalAid` | `bool` | True for zones A and B |
| `arcl` | `double` | Sun-Moon elongation (degrees) |
| `arcv` | `double` | Arc of vision (degrees) |
| `w` | `double` | Crescent width (arc minutes) |
| `moonAboveHorizon` | `bool` | Moon above horizon at given time |

### getMoon(DateTime? date, double lat, double lon, {double elevation = 0})

Returns `MoonSnapshot` combining all four results: `phase`, `position`, `illumination`, `visibility`.

## Visibility Criteria

The Odeh criterion (2006) classifies crescent visibility into four zones:

| Zone | V threshold | Meaning |
| --- | --- | --- |
| A | V >= 5.65 | Visible with naked eye |
| B | V >= 2.00 | Visible with optical aid, may be seen naked eye |
| C | V >= -0.96 | Visible with optical aid only |
| D | V < -0.96 | Not visible even with optical aid |

The Yallop q-test (1997) uses six categories A through F with different threshold semantics. Both criteria use the same underlying polynomial for the minimum arc of vision as a function of crescent width.

## Accuracy

All positions use Meeus (1998) approximations:

- **Sun:** < 0.01 deg ecliptic longitude error
- **Moon:** < 0.3 deg longitude, < 0.2 deg latitude
- **Distance:** ~300 km error (~0.08%)
- **New/full moon times:** within ~2 hours

The GCRS-to-topocentric conversion uses a simplified Earth rotation (ERA only, no nutation/precession), adding ~1 deg systematic error. This is acceptable for phase displays, illumination calculations, and approximate visibility estimates.

For high-precision crescent sighting reports with DE442S ephemeris accuracy, see the TypeScript [moon-sighting](https://github.com/acamarata/moon-sighting) package.

## Lite Mode vs Full Mode

This Dart package implements lite mode only. It covers moon phase, position, illumination, and quick visibility estimates using analytical Meeus algorithms with no external data files.

The full-mode features (DE442S JPL ephemeris, sub-arcsecond accuracy, rise/set event finding, best-time optimization, full sighting reports) are available in the TypeScript package.

## Compatibility

- Dart SDK >= 3.7.0
- Works in Flutter, Dart CLI, and server-side Dart
- Zero runtime dependencies

## Related Packages

- [moon-sighting](https://github.com/acamarata/moon-sighting) (TypeScript) - Full-accuracy lunar crescent visibility with DE442S ephemeris
- [nrel-spa](https://github.com/acamarata/nrel-spa) (TypeScript) - Pure JS NREL Solar Position Algorithm
- [pray-calc](https://github.com/acamarata/pray-calc) (JavaScript) - Islamic prayer time calculation
- [luxon-hijri](https://github.com/acamarata/luxon-hijri) (TypeScript) - Hijri/Gregorian calendar conversion

## License

MIT
