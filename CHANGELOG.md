## 1.1.0

### Fixed
- **`MoonPhaseResult.age` could be negative, and `prevNewMoon` could be a future date.** `nearestNewMoon` rounds to the closest lunation, which is frequently the NEXT one. Both call sites compensated by biasing the input 15 days backwards, but the lunation number comes from a decimal-year approximation and that bias does not hold near a boundary: for roughly five days before every new moon it still selected the upcoming lunation. `age`, documented as "hours since last new moon", came back down to -120 hours on about 60 days a year, every year. `getMoonSightingReport` used the same biased call and is fixed with it.
- This was fixed in the JavaScript `moon-sighting` package as 1.1.4; the Dart port carried the identical defect and was missed on that pass. Both now agree: age ranges 0.12 to 712.12 hours across a two-year sweep, against a synodic month of about 708 hours.

# Changelog

All notable changes to this project will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
This project adheres to [Semantic Versioning](https://semver.org/).

## [1.0.0] - 2026-05-25

### Added

- Initial public release.
- `getMoonPhase` — returns moon phase name and illumination percentage for any date.
- `getMoonPosition` — computes topocentric altitude and azimuth using Meeus Chapter 47 algorithms.
- `getMoon` — combined output: phase, position, and illumination in one call.
- `getMoonVisibilityEstimate` — Yallop and Odeh crescent visibility criteria.
- `nearestNewMoon` — finds the next or previous new moon from a given date.
- `arcvMinimum` — polynomial helper for Yallop arc of vision minimum.
- `distanceKm` — lunar distance in kilometres.
- Meeus lite algorithms (Astronomical Algorithms, Jean Meeus, 2nd ed.) — no JPL ephemeris dependency.
- Pure Dart implementation. Zero runtime dependencies.
- Dart SDK `^3.7.0` compatibility.
- 64 unit tests covering all 7 SPORT features.

### Notes

This package uses Meeus lite algorithms with approximately 0.3 degree positional accuracy.
The companion JavaScript package (`moon-sighting` on npm) uses JPL DE442S ephemeris for
sub-arcminute precision. Use the JS package when observatory-grade accuracy is required.
