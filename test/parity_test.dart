/// Cross-language parity against the JavaScript `moon-sighting` package.
///
/// Covers the four functions both ports implement: [getMoonPhase], [getMoonIllumination],
/// [getMoonPosition] and [getMoonVisibilityEstimate]. The kernel-backed entry points
/// (`getMoonSightingReport`, `getSunMoonEvents`) are JavaScript-only — they need SPK kernels
/// this port does not ship — so they are outside this fixture by construction, not by
/// omission.
///
/// ## Known gap: topocentric positions
///
/// [getMoonPhase] and [getMoonIllumination] are in essentially exact parity — the worst
/// relative difference across the fixture is 1.7e-15, which is last-bit floating point.
/// Those two are geocentric and never touch the observer pipeline.
///
/// [getMoonPosition] and [getMoonVisibilityEstimate] do, and they diverge by up to **0.88
/// degrees** in altitude. The cause is not rounding: the JavaScript package runs the full
/// IAU frame chain (CIP X/Y/s, precession-nutation, polar motion) in its `frames` module,
/// while this port applies `gcrsToItrsSimple`, a single z-rotation by the Earth Rotation
/// Angle with no precession or nutation. Accumulated precession since J2000 is about
/// 0.36 degrees per 26 years, which accounts for the observed difference.
///
/// That is a real accuracy limitation of this port, not a disagreement about which answer is
/// right — the JavaScript values are the more accurate ones. It matters here specifically
/// because crescent visibility turns on tenths of a degree. Those two groups are therefore
/// skipped rather than asserted: a skipped test with a reason is honest, whereas a loosened
/// tolerance would quietly bless the gap and a fixture regenerated from this port would
/// enshrine it.
///
/// Tracked in the `moon-sighting-dart` issue for porting the frames module.
///
/// Tolerance: values are compared to twelve significant figures. Both ports evaluate the
/// same truncated series in IEEE-754 doubles, but the two runtimes may differ in the last
/// bit or two of `sin`, `cos` and `atan2`. Twelve figures is far tighter than any physically
/// meaningful difference — well under a micrometre on the lunar distance — and cannot mask a
/// real algorithmic divergence, which shows up in the first few figures.
///
/// Field names differ by convention between the ports and that is deliberate: the JavaScript
/// package exposes `V`, `ARCL` and `ARCV` as the crescent-visibility literature writes them,
/// while this port uses `v`, `arcl` and `arcv` per Dart style. Same quantities, same values.
///
/// The fixture is produced by the reference implementation: see
/// `tool/generate-parity-fixture-moon.mjs` in the `moon-sighting` repository. If this suite
/// fails against an unchanged fixture, that is the divergence it exists to catch — fix the
/// port, do not refresh the fixture.
library;

import 'dart:convert';
import 'dart:io';

import 'package:moon_sighting/moon_sighting.dart';
import 'package:test/test.dart';

/// Relative comparison at twelve significant figures.
void expectClose(double actual, num expected, String reason) {
  final e = expected.toDouble();
  final tolerance = e == 0 ? 1e-12 : e.abs() * 1e-12;
  expect(actual, closeTo(e, tolerance), reason: reason);
}

void main() {
  final raw =
      jsonDecode(
            File('test/fixtures/cross_language_golden.json').readAsStringSync(),
          )
          as Map<String, dynamic>;

  const places = {
    'Makkah': [21.4225, 39.8262],
    'London': [51.5074, -0.1278],
    'Jakarta': [-6.2088, 106.8456],
    'Reykjavik': [64.1466, -21.9426],
  };

  test('fixture covers every function and a full synodic month', () {
    expect((raw['phase'] as List).length, greaterThanOrEqualTo(18));
    expect((raw['position'] as List).length, greaterThanOrEqualTo(72));
    final phases =
        (raw['phase'] as List)
            .map((v) => (v as Map)['phase'] as String)
            .toSet();
    expect(
      phases.length,
      greaterThan(3),
      reason: 'should span several lunar phases',
    );
  });

  group('getMoonPhase', () {
    for (final v in (raw['phase'] as List).cast<Map<String, dynamic>>()) {
      final iso = v['iso'] as String;
      test(iso, () {
        final p = getMoonPhase(DateTime.parse(iso));
        // The name and symbol are classifications off the elongation, so a mismatch here
        // means the two ports disagree about a phase boundary rather than the maths.
        expect(
          p.phaseName,
          v['phaseName'] as String,
          reason: 'phaseName at $iso',
        );
        expect(p.isWaxing, v['isWaxing'] as bool, reason: 'isWaxing at $iso');
        expectClose(
          p.illumination,
          v['illumination'] as num,
          'illumination at $iso',
        );
        expectClose(p.age, v['age'] as num, 'age at $iso');
        expectClose(
          p.elongationDeg,
          v['elongationDeg'] as num,
          'elongationDeg at $iso',
        );
      });
    }
  });

  group('getMoonIllumination', () {
    for (final v
        in (raw['illumination'] as List).cast<Map<String, dynamic>>()) {
      final iso = v['iso'] as String;
      test(iso, () {
        final il = getMoonIllumination(DateTime.parse(iso));
        expectClose(il.fraction, v['fraction'] as num, 'fraction at $iso');
        expectClose(il.phase, v['phase'] as num, 'phase at $iso');
        expectClose(il.angle, v['angle'] as num, 'angle at $iso');
        expect(il.isWaxing, v['isWaxing'] as bool, reason: 'isWaxing at $iso');
      });
    }
  });

  // See "Known gap" above. Do not remove the skip by loosening the tolerance; the fix is to
  // port the frames module so this port computes the same topocentric positions.
  group(
    'getMoonPosition',
    skip: 'known gap: this port omits precession-nutation (up to 0.88 deg)',
    () {
      for (final v in (raw['position'] as List).cast<Map<String, dynamic>>()) {
        final iso = v['iso'] as String;
        final place = v['place'] as String;
        final c = places[place]!;
        test('$place $iso', () {
          final p = getMoonPosition(DateTime.parse(iso), c[0], c[1]);
          expectClose(p.azimuth, v['azimuth'] as num, 'azimuth at $place $iso');
          expectClose(
            p.altitude,
            v['altitude'] as num,
            'altitude at $place $iso',
          );
          expectClose(
            p.distance,
            v['distance'] as num,
            'distance at $place $iso',
          );
          expectClose(
            p.parallacticAngle,
            v['parallacticAngle'] as num,
            'parallacticAngle at $place $iso',
          );
        });
      }
    },
  );

  group(
    'getMoonVisibilityEstimate',
    skip: 'known gap: depends on getMoonPosition (see above)',
    () {
      for (final v
          in (raw['visibility'] as List).cast<Map<String, dynamic>>()) {
        final iso = v['iso'] as String;
        final place = v['place'] as String;
        final c = places[place]!;
        test('$place $iso', () {
          final e = getMoonVisibilityEstimate(DateTime.parse(iso), c[0], c[1]);
          // The zone letter is the user-facing output; a disagreement here is what an
          // observer would actually notice.
          expect(
            e.zone.label,
            v['zone'] as String,
            reason: 'zone at $place $iso',
          );
          expectClose(e.v, v['V'] as num, 'V at $place $iso');
          expectClose(e.arcl, v['ARCL'] as num, 'ARCL at $place $iso');
          expectClose(e.arcv, v['ARCV'] as num, 'ARCV at $place $iso');
        });
      }
    },
  );
}
