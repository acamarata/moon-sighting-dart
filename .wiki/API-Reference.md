# API Reference

## getMoonPhase

```dart
MoonPhaseResult getMoonPhase([DateTime? date])
```

Returns the moon phase for the given UTC date, or the current moment if `date` is null.

### MoonPhaseResult fields

| Field | Type | Description |
| --- | --- | --- |
| `phase` | `MoonPhaseName` | Enum: `newMoon`, `waxingCrescent`, `firstQuarter`, `waxingGibbous`, `fullMoon`, `waningGibbous`, `lastQuarter`, `waningCrescent` |
| `phaseName` | `String` | Human-readable phase name |
| `phaseSymbol` | `String` | Moon emoji for the current phase |
| `illumination` | `double` | Percent illuminated (0-100) |
| `age` | `double` | Hours since the last new moon |
| `elongationDeg` | `double` | Moon-Sun elongation in degrees |
| `isWaxing` | `bool` | True when illumination is increasing |
| `nextNewMoon` | `DateTime` | Next new moon (UTC) |
| `nextFullMoon` | `DateTime` | Next full moon (UTC) |
| `prevNewMoon` | `DateTime` | Previous new moon (UTC) |

---

## getMoonPosition

```dart
MoonPosition getMoonPosition(
  DateTime? date,
  double lat,
  double lon, {
  double elevation = 0,
})
```

Computes the topocentric position of the moon for an observer at the given location. Applies atmospheric refraction to the altitude.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `date` | `DateTime?` | now | UTC date and time |
| `lat` | `double` | required | Observer latitude (-90 to 90) |
| `lon` | `double` | required | Observer longitude (-180 to 180) |
| `elevation` | `double` | 0 | Observer elevation in meters |

### MoonPosition fields

| Field | Type | Description |
| --- | --- | --- |
| `azimuth` | `double` | Degrees from North, clockwise (0-360) |
| `altitude` | `double` | Degrees above horizon (refraction applied) |
| `distance` | `double` | Earth-Moon distance in km |
| `parallacticAngle` | `double` | Parallactic angle in radians |

---

## getMoonIllumination

```dart
MoonIlluminationResult getMoonIllumination([DateTime? date])
```

Returns illumination data for the given UTC date, or now if null.

### MoonIlluminationResult fields

| Field | Type | Description |
| --- | --- | --- |
| `fraction` | `double` | Illuminated fraction (0-1) |
| `phase` | `double` | Phase cycle position (0=new, 0.25=first quarter, 0.5=full, 0.75=last quarter) |
| `angle` | `double` | Bright limb position angle in radians |
| `isWaxing` | `bool` | True when waxing |

---

## getMoonVisibilityEstimate

```dart
MoonVisibilityEstimate getMoonVisibilityEstimate(
  DateTime? date,
  double lat,
  double lon, {
  double elevation = 0,
})
```

Estimates lunar crescent visibility using the Odeh (2006) criterion. Pass a post-sunset time for meaningful results.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `date` | `DateTime?` | now | UTC date and time (use post-sunset) |
| `lat` | `double` | required | Observer latitude |
| `lon` | `double` | required | Observer longitude |
| `elevation` | `double` | 0 | Observer elevation in meters |

### MoonVisibilityEstimate fields

| Field | Type | Description |
| --- | --- | --- |
| `v` | `double` | Odeh V parameter |
| `zone` | `OdehZone` | Visibility zone (a, b, c, or d) |
| `description` | `String` | Human-readable zone description |
| `isVisibleNakedEye` | `bool` | True for zone A |
| `isVisibleWithOpticalAid` | `bool` | True for zones A and B |
| `arcl` | `double` | Sun-Moon elongation in degrees |
| `arcv` | `double` | Arc of vision in degrees |
| `w` | `double` | Crescent width in arc minutes |
| `moonAboveHorizon` | `bool` | True if the moon is above the horizon at the given time |

### OdehZone values

| Zone | V threshold | Meaning |
| --- | --- | --- |
| A | V >= 5.65 | Visible with naked eye |
| B | V >= 2.00 | Visible with optical aid, may be naked-eye visible |
| C | V >= -0.96 | Visible with optical aid only |
| D | V < -0.96 | Not visible even with optical aid |

---

## getMoon

```dart
MoonSnapshot getMoon(
  DateTime? date,
  double lat,
  double lon, {
  double elevation = 0,
})
```

Convenience function that runs all four computations in one call.

### MoonSnapshot fields

| Field | Type | Description |
| --- | --- | --- |
| `phase` | `MoonPhaseResult` | Phase result |
| `position` | `MoonPosition` | Position result |
| `illumination` | `MoonIlluminationResult` | Illumination result |
| `visibility` | `MoonVisibilityEstimate` | Visibility estimate |

---

[Home](Home)
