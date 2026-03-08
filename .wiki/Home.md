# moon_sighting

Lunar crescent visibility for Dart and Flutter. Computes moon phase, topocentric position, illumination, and Yallop/Odeh crescent visibility criteria using Meeus algorithms. Zero dependencies.

## Quick Start

```dart
import 'package:moon_sighting/moon_sighting.dart';

final phase = getMoonPhase();
print('${phase.phaseName} (${phase.illumination.toStringAsFixed(1)}%)');

final vis = getMoonVisibilityEstimate(
  DateTime.utc(2025, 3, 31, 18, 30),
  21.4225, 39.8262, // Mecca
);
print('Zone: ${vis.zone.label}');
print('Visible naked eye: ${vis.isVisibleNakedEye}');
```

## Pages

- [API Reference](API-Reference) — Full function and type reference
- [Visibility Criteria](Visibility-Criteria) — Yallop and Odeh crescent visibility criteria
