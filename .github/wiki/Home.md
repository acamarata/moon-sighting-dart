# moon_sighting

Lunar crescent visibility for Dart and Flutter. Computes moon phase, topocentric position, illumination, and Yallop/Odeh crescent visibility criteria using Meeus algorithms. Zero dependencies.

Uses Meeus lite algorithms with approximately 0.3 degree accuracy. The companion JavaScript
package (`moon-sighting` on npm) uses JPL DE442S ephemeris for sub-arcminute precision.

## Install

```yaml
dependencies:
  moon_sighting: ^1.0.0
```

```dart
import 'package:moon_sighting/moon_sighting.dart';

final phase = getMoonPhase();
print('${phase.phaseName} (${phase.illumination.toStringAsFixed(1)}%)');

final vis = getMoonVisibilityEstimate(
  DateTime.utc(2025, 3, 31, 18, 30),
  21.4225, 39.8262, // Makkah
);
print('Zone: ${vis.zone.label}');
print('Visible naked eye: ${vis.isVisibleNakedEye}');
```

## Contents

- [Quickstart Guide](guides/quickstart) — install, first call, phase and position
- [Advanced Usage](guides/advanced) — visibility criteria, new moon finding
- [API Reference](API-Reference) — full function and type reference
- [Examples](examples/basic-usage) — real-world snippets
- [Contributing](CONTRIBUTING)
