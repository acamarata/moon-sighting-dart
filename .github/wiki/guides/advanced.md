# Advanced Usage

## Yallop vs Odeh Criteria

The package implements two published crescent visibility criteria. Both are returned in `getMoonVisibilityEstimate`:

```dart
import 'package:moon_sighting/moon_sighting.dart';

final vis = getMoonVisibilityEstimate(
  DateTime.utc(2025, 3, 31, 18, 30),
  21.4225, 39.8262,
);

print('Yallop zone: ${vis.yallopZone.label}');
print('Odeh zone:   ${vis.odehZone.label}');
print('Combined:    ${vis.zone.label}');
```

Yallop and Odeh zones:

| Zone | Label | Description |
| --- | --- | --- |
| A | Easily visible | Visible to naked eye |
| B | Visible under good conditions | May be visible to naked eye |
| C | May need optical aid | Visible with binoculars |
| D | Optical aid and perfect conditions | Telescope only |
| E | Not visible | Below horizon at sunset |
| F | Below new moon | Moon sets before sun |

## Finding the Next New Moon

```dart
final newMoon = nearestNewMoon(DateTime.utc(2025, 3, 15));
print('Next new moon: ${newMoon.toIso8601String()}');
```

Pass `next: false` for the previous new moon:

```dart
final prev = nearestNewMoon(DateTime.utc(2025, 3, 15), next: false);
```

## Monthly Crescent Calendar

```dart
import 'package:moon_sighting/moon_sighting.dart';

void main() {
  // Find when Ramadan crescent might be visible in 2026
  final newMoon = nearestNewMoon(DateTime.utc(2026, 3, 20));
  print('New moon: ${newMoon.toIso8601String()}');

  // Check 3 successive evenings
  for (int d = 1; d <= 3; d++) {
    final check = newMoon.add(Duration(days: d, hours: 18));
    final vis = getMoonVisibilityEstimate(check, 21.4225, 39.8262);
    print('Day $d: ${vis.zone.label}');
  }
}
```

## Accuracy and JS Comparison

| Aspect | moon_sighting (Dart) | moon-sighting (npm/JS) |
| --- | --- | --- |
| Algorithm | Meeus Chapter 47 | JPL DE442S ephemeris |
| Position accuracy | ~0.3 degrees | Sub-arcminute |
| Bundle size | Minimal | ~500 KB (ephemeris data) |
| Best for | Flutter apps, mobile | Server-side, high precision |
