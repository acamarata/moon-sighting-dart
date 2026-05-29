# Basic Usage Examples

## Tonight's Moon

```dart
import 'package:moon_sighting/moon_sighting.dart';

void main() {
  final now = DateTime.now().toUtc();
  final phase = getMoonPhase(now);
  final position = getMoonPosition(now, 40.7128, -74.0060);

  print('Moon tonight (New York):');
  print('  Phase:        ${phase.phaseName}');
  print('  Illumination: ${phase.illumination.toStringAsFixed(1)}%');
  print('  Altitude:     ${position.altitude.toStringAsFixed(2)}°');
  print('  Azimuth:      ${position.azimuth.toStringAsFixed(2)}°');
  print('  Distance:     ${position.distanceKm.toStringAsFixed(0)} km');
}
```

## Ramadan Crescent Visibility Check

```dart
import 'package:moon_sighting/moon_sighting.dart';

void main() {
  // Check crescent visibility for major Muslim cities on Ramadan eve
  final eveningOfCheck = DateTime.utc(2026, 2, 17, 18, 0);

  final cities = [
    ('Makkah',   21.4225,  39.8262,  3.0),
    ('Istanbul', 41.0082,  28.9784,  3.0),
    ('London',   51.5074,  -0.1278,  0.0),
    ('New York', 40.7128, -74.0060, -5.0),
  ];

  print('City              Zone');
  print('${'─' * 30}');
  for (final (city, lat, lng, _) in cities) {
    final vis = getMoonVisibilityEstimate(eveningOfCheck, lat, lng);
    print('${city.padRight(18)}${vis.zone.label}');
  }
}
```

## Moon Phase Calendar

```dart
import 'package:moon_sighting/moon_sighting.dart';

void main() {
  print('Date,Phase,Illumination');
  for (int day = 1; day <= 30; day++) {
    final date = DateTime.utc(2025, 3, day, 12, 0);
    final phase = getMoonPhase(date);
    print('2025-03-${day.toString().padLeft(2, "0")},'
          '${phase.phaseName},${phase.illumination.toStringAsFixed(1)}%');
  }
}
```
