# Quickstart

## Install

Add to `pubspec.yaml`:

```yaml
dependencies:
  moon_sighting: ^1.0.0
```

Run `dart pub get`.

## Moon Phase

```dart
import 'package:moon_sighting/moon_sighting.dart';

void main() {
  final phase = getMoonPhase();
  print('Phase:        ${phase.phaseName}');
  print('Illumination: ${phase.illumination.toStringAsFixed(1)}%');
}
```

Pass a specific date for historical or future phases:

```dart
final phase = getMoonPhase(DateTime.utc(2025, 3, 31));
```

## Moon Position

```dart
final position = getMoonPosition(
  DateTime.utc(2025, 3, 31, 18, 30),
  21.4225,  // Makkah latitude
  39.8262,  // longitude
);

print('Altitude:  ${position.altitude.toStringAsFixed(2)}°');
print('Azimuth:   ${position.azimuth.toStringAsFixed(2)}°');
print('Distance:  ${position.distanceKm.toStringAsFixed(0)} km');
```

## Crescent Visibility

```dart
final vis = getMoonVisibilityEstimate(
  DateTime.utc(2025, 3, 31, 18, 30),
  21.4225, 39.8262,
);

print('Zone:            ${vis.zone.label}');
print('Visible (naked): ${vis.isVisibleNakedEye}');
print('Visible (aided): ${vis.isVisibleWithAid}');
```

## Accuracy Note

This package uses Meeus lite algorithms with approximately 0.3 degree positional accuracy. The companion JavaScript package (`moon-sighting` on npm) uses JPL DE442S ephemeris for sub-arcminute precision. Use the JS package when observatory-grade accuracy is required.
