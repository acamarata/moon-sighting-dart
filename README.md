# moon_sighting

[![pub package](https://img.shields.io/pub/v/moon_sighting.svg)](https://pub.dev/packages/moon_sighting)
[![CI](https://github.com/acamarata/moon-sighting-dart/actions/workflows/ci.yml/badge.svg)](https://github.com/acamarata/moon-sighting-dart/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Wiki](https://img.shields.io/badge/docs-wiki-blue)](https://github.com/acamarata/moon-sighting-dart/wiki)

Lunar crescent visibility for Dart and Flutter. Moon phase, topocentric position, illumination, and Yallop/Odeh crescent criteria using Meeus algorithms. Zero dependencies.

Uses Meeus lite algorithms (~0.3 degree accuracy). The companion TypeScript package (`moon-sighting` on npm) uses JPL DE442S ephemeris for sub-arcminute precision.

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

// Moon position for an observer
final pos = getMoonPosition(DateTime.now(), 51.5074, -0.1278, elevation: 10);
print('Azimuth:  ${pos.azimuth.toStringAsFixed(1)}');
print('Altitude: ${pos.altitude.toStringAsFixed(1)}');

// Crescent visibility estimate (pass a post-sunset time)
final vis = getMoonVisibilityEstimate(
  DateTime.utc(2025, 3, 31, 18, 30),
  21.4225, 39.8262, // Makkah
);
print('Zone: ${vis.zone.label}');            // A through D
print('Visible naked eye: ${vis.isVisibleNakedEye}');
```

## API

Five public functions. See the [API Reference](https://github.com/acamarata/moon-sighting-dart/wiki/API-Reference) for full field tables.

| Function | Returns | Description |
| --- | --- | --- |
| `getMoonPhase([DateTime?])` | `MoonPhaseResult` | Phase name, illumination, age, next events |
| `getMoonPosition(DateTime?, lat, lon)` | `MoonPosition` | Topocentric az/alt, distance |
| `getMoonIllumination([DateTime?])` | `MoonIlluminationResult` | Fraction, phase cycle, bright limb angle |
| `getMoonVisibilityEstimate(DateTime?, lat, lon)` | `MoonVisibilityEstimate` | Odeh V parameter, visibility zone A-D |
| `getMoon(DateTime?, lat, lon)` | `MoonSnapshot` | All four results combined |

## Accuracy

All positions use Meeus (1998) approximations: Moon longitude < 0.3 deg, latitude < 0.2 deg, distance ~300 km. New/full moon times are within ~2 hours.

## Related

- [moon-sighting](https://github.com/acamarata/moon-sighting) (TypeScript) - Full accuracy with DE442S ephemeris
- [nrel-spa](https://github.com/acamarata/nrel-spa) (TypeScript) - NREL Solar Position Algorithm
- [pray-calc](https://github.com/acamarata/pray-calc) (TypeScript) - Islamic prayer times

## Acknowledgments

Crescent visibility criteria from:

- B.D. Yallop, "A Method for Predicting the First Sighting of the New Crescent Moon," NAO Technical Note No. 69, 1997.
- M.Sh. Odeh, "New Criterion for Lunar Crescent Visibility," Experimental Astronomy 18(1), 39-64, 2006.
- Jean Meeus, "Astronomical Algorithms," 2nd ed., Chapters 47 and 48.

## License

MIT
