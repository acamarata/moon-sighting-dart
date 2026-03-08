# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [1.0.0] - 2026-03-08

### Added

- `getMoonPhase()` returns phase name, emoji symbol, illumination percentage, age in hours, elongation, waxing/waning state, and next/previous new moon and full moon dates
- `getMoonPosition()` returns topocentric azimuth, altitude (with Bennett refraction), geocentric distance, and parallactic angle for any observer location
- `getMoonIllumination()` returns illumination fraction, phase cycle position, bright limb position angle, and waxing/waning indicator
- `getMoonVisibilityEstimate()` computes Odeh crescent visibility criterion (V parameter, zones A through D) from approximate Meeus positions at a given observation time
- `getMoon()` combined snapshot bundling all four functions in a single call
- `arcvMinimum()` the Odeh 2006 polynomial for minimum arc of vision as a function of crescent width
- Meeus Ch. 25 Sun position (geocentric, < 0.01 deg accuracy)
- Meeus Ch. 47 Moon position with 30 longitude terms and 20 latitude terms (< 0.3 deg accuracy)
- Meeus Ch. 49 new moon and full moon time estimation (within ~2 hours)
- Full delta-T polynomial (Espenak & Meeus, piecewise by year)
- Leap-second table through 2017 Jan 1 (37 seconds)
- WGS84 geodetic to ECEF conversion
- Bennett (1982) atmospheric refraction with pressure/temperature correction
- Simplified GCRS to ITRS frame rotation via Earth Rotation Angle (sufficient for lite-mode ~1 deg accuracy)
- Yallop q-test with categories A through F (NAO Technical Note 69)
- Odeh V-parameter with zones A through D (Experimental Astronomy 2006)
- Input validation for latitude, longitude ranges
- Complete type system: `MoonPhaseResult`, `MoonPosition`, `MoonIlluminationResult`, `MoonVisibilityEstimate`, `MoonSnapshot`, `YallopResult`, `OdehResult`, `CrescentGeometry`
