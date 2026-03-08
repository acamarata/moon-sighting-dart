import 'package:moon_sighting/moon_sighting.dart';
import 'package:test/test.dart';

void main() {
  // ── Constants ────────────────────────────────────────────────────────────

  group('Constants', () {
    test('Yallop threshold A is 0.216', () {
      expect(yallopThresholds[YallopCategory.a], equals(0.216));
    });

    test('Yallop threshold E is -0.293', () {
      expect(yallopThresholds[YallopCategory.e], equals(-0.293));
    });

    test('All Yallop thresholds are defined', () {
      for (final cat in [
        YallopCategory.a,
        YallopCategory.b,
        YallopCategory.c,
        YallopCategory.d,
        YallopCategory.e,
      ]) {
        expect(yallopThresholds[cat], isNotNull);
      }
    });

    test('Yallop thresholds descend A > B > C > D > E', () {
      expect(
        yallopThresholds[YallopCategory.a]!,
        greaterThan(yallopThresholds[YallopCategory.b]!),
      );
      expect(
        yallopThresholds[YallopCategory.b]!,
        greaterThan(yallopThresholds[YallopCategory.c]!),
      );
      expect(
        yallopThresholds[YallopCategory.c]!,
        greaterThan(yallopThresholds[YallopCategory.d]!),
      );
      expect(
        yallopThresholds[YallopCategory.d]!,
        greaterThan(yallopThresholds[YallopCategory.e]!),
      );
    });

    test('Odeh threshold A is 5.65', () {
      expect(odehThresholds[OdehZone.a], equals(5.65));
    });

    test('Odeh threshold C is -0.96', () {
      expect(odehThresholds[OdehZone.c], equals(-0.96));
    });

    test('Odeh thresholds descend A > B > C', () {
      expect(
        odehThresholds[OdehZone.a]!,
        greaterThan(odehThresholds[OdehZone.b]!),
      );
      expect(
        odehThresholds[OdehZone.b]!,
        greaterThan(odehThresholds[OdehZone.c]!),
      );
    });

    test('WGS84.a is 6378137.0', () {
      expect(WGS84.a, equals(6378137.0));
    });

    test('WGS84.e2 is positive and < 1', () {
      expect(WGS84.e2, greaterThan(0));
      expect(WGS84.e2, lessThan(1));
    });

    test('WGS84.b < WGS84.a (oblate spheroid)', () {
      expect(WGS84.b, lessThan(WGS84.a));
    });

    test('Yallop descriptions are non-empty strings', () {
      for (final cat in YallopCategory.values) {
        expect(yallopDescriptions[cat], isNotEmpty);
      }
    });

    test('Odeh descriptions are non-empty strings', () {
      for (final zone in OdehZone.values) {
        expect(odehDescriptions[zone], isNotEmpty);
      }
    });
  });

  // ── getMoonPhase ───────────────────────────────────────────────────────

  final dateMarch1 = DateTime.utc(2025, 3, 1, 12);
  final phaseMarch1 = getMoonPhase(dateMarch1);

  group('getMoonPhase structure', () {
    test('illumination is in [0, 100]', () {
      expect(phaseMarch1.illumination, greaterThanOrEqualTo(0));
      expect(phaseMarch1.illumination, lessThanOrEqualTo(100));
    });

    test('age is >= 0', () {
      expect(phaseMarch1.age, greaterThanOrEqualTo(0));
    });

    test('elongationDeg is in [0, 180]', () {
      expect(phaseMarch1.elongationDeg, greaterThanOrEqualTo(0));
      expect(phaseMarch1.elongationDeg, lessThanOrEqualTo(180));
    });

    test('nextNewMoon is a DateTime', () {
      expect(phaseMarch1.nextNewMoon, isA<DateTime>());
    });

    test('prevNewMoon is before reference date', () {
      expect(phaseMarch1.prevNewMoon.isBefore(dateMarch1), isTrue);
    });

    test('nextNewMoon is after prevNewMoon', () {
      expect(phaseMarch1.nextNewMoon.isAfter(phaseMarch1.prevNewMoon), isTrue);
    });
  });

  group('getMoonPhase phase boundaries', () {
    test('near full moon: illumination > 85%', () {
      final phaseFull = getMoonPhase(DateTime.utc(2025, 3, 14, 12));
      expect(phaseFull.illumination, greaterThan(85));
    });

    test('near full moon: elongation > 120 deg', () {
      final phaseFull = getMoonPhase(DateTime.utc(2025, 3, 14, 12));
      expect(phaseFull.elongationDeg, greaterThan(120));
    });

    test('near new moon: illumination < 10%', () {
      final phaseNew = getMoonPhase(DateTime.utc(2025, 3, 29, 12));
      expect(phaseNew.illumination, lessThan(10));
    });

    test('near new moon: elongation < 30 deg', () {
      final phaseNew = getMoonPhase(DateTime.utc(2025, 3, 29, 12));
      expect(phaseNew.elongationDeg, lessThan(30));
    });
  });

  group('getMoonPhase consistency', () {
    test('5 days after new moon: isWaxing = true', () {
      expect(getMoonPhase(DateTime.utc(2025, 3, 5, 12)).isWaxing, isTrue);
    });

    test('6 days after full moon: isWaxing = false', () {
      expect(getMoonPhase(DateTime.utc(2025, 3, 20, 12)).isWaxing, isFalse);
    });

    test('default date (now) returns valid result', () {
      final nowPhase = getMoonPhase();
      expect(nowPhase.illumination, greaterThanOrEqualTo(0));
      expect(nowPhase.illumination, lessThanOrEqualTo(100));
    });

    test('synodic month duration is ~29.5 days', () {
      final synodicMs =
          phaseMarch1.nextNewMoon
              .difference(phaseMarch1.prevNewMoon)
              .inMilliseconds;
      final synodicDays = synodicMs / 86400000;
      expect(synodicDays, greaterThan(29.0));
      expect(synodicDays, lessThan(30.1));
    });
  });

  group('getMoonPhase phaseName and phaseSymbol', () {
    test('waxing crescent: phaseName is Waxing Crescent', () {
      final p = getMoonPhase(DateTime.utc(2025, 3, 5, 12));
      expect(p.phaseName, equals('Waxing Crescent'));
    });

    test('phaseName is a valid string', () {
      final validNames = {
        'New Moon',
        'Waxing Crescent',
        'First Quarter',
        'Waxing Gibbous',
        'Full Moon',
        'Waning Gibbous',
        'Last Quarter',
        'Waning Crescent',
      };
      final p = getMoonPhase(dateMarch1);
      expect(validNames.contains(p.phaseName), isTrue);
    });
  });

  // ── getMoonPosition ────────────────────────────────────────────────────

  group('getMoonPosition', () {
    final moonPos = getMoonPosition(
      DateTime.utc(2025, 3, 14, 20),
      51.5074,
      -0.1278,
      elevation: 10,
    );

    test('azimuth in [0, 360)', () {
      expect(moonPos.azimuth, greaterThanOrEqualTo(0));
      expect(moonPos.azimuth, lessThan(360));
    });

    test('altitude in [-90, 90]', () {
      expect(moonPos.altitude, greaterThanOrEqualTo(-90));
      expect(moonPos.altitude, lessThanOrEqualTo(90));
    });

    test('distance in lunar orbit range [356000, 407000] km', () {
      expect(moonPos.distance, greaterThanOrEqualTo(356000));
      expect(moonPos.distance, lessThanOrEqualTo(407000));
    });

    test('parallacticAngle is finite', () {
      expect(moonPos.parallacticAngle.isFinite, isTrue);
    });

    test('default date returns valid result', () {
      final pos = getMoonPosition(null, 21.4225, 39.8262);
      expect(pos.azimuth, greaterThanOrEqualTo(0));
      expect(pos.azimuth, lessThan(360));
      expect(pos.distance, greaterThan(350000));
      expect(pos.distance, lessThan(410000));
    });
  });

  // ── getMoonIllumination ────────────────────────────────────────────────

  group('getMoonIllumination', () {
    final illumFull = getMoonIllumination(DateTime.utc(2025, 3, 14, 12));
    final illumNew = getMoonIllumination(DateTime.utc(2025, 3, 29, 12));
    final illumWaxing = getMoonIllumination(DateTime.utc(2025, 3, 5, 12));

    test('near full moon: fraction > 0.85', () {
      expect(illumFull.fraction, greaterThan(0.85));
    });

    test('near full moon: phase close to 0.5', () {
      expect(illumFull.phase, greaterThan(0.4));
      expect(illumFull.phase, lessThan(0.6));
    });

    test('near new moon: fraction < 0.05', () {
      expect(illumNew.fraction, lessThan(0.05));
    });

    test('near new moon: phase close to 0 or 1', () {
      expect(illumNew.phase < 0.08 || illumNew.phase > 0.92, isTrue);
    });

    test('waxing: isWaxing = true', () {
      expect(illumWaxing.isWaxing, isTrue);
    });

    test('fraction in [0, 1]', () {
      expect(illumFull.fraction, greaterThanOrEqualTo(0));
      expect(illumFull.fraction, lessThanOrEqualTo(1));
      expect(illumNew.fraction, greaterThanOrEqualTo(0));
      expect(illumNew.fraction, lessThanOrEqualTo(1));
    });

    test('phase in [0, 1)', () {
      expect(illumFull.phase, greaterThanOrEqualTo(0));
      expect(illumFull.phase, lessThan(1));
    });

    test('angle is finite', () {
      expect(illumFull.angle.isFinite, isTrue);
    });

    test('default date returns valid result', () {
      final illum = getMoonIllumination();
      expect(illum.fraction, greaterThanOrEqualTo(0));
      expect(illum.fraction, lessThanOrEqualTo(1));
    });
  });

  // ── getMoonVisibilityEstimate ──────────────────────────────────────────

  group('getMoonVisibilityEstimate', () {
    final vis = getMoonVisibilityEstimate(
      DateTime.utc(2025, 3, 2, 18, 30),
      51.5074,
      -0.1278,
      elevation: 10,
    );

    test('zone is A, B, C, or D', () {
      expect(OdehZone.values.contains(vis.zone), isTrue);
    });

    test('V is finite', () {
      expect(vis.v.isFinite, isTrue);
    });

    test('ARCL is in [0, 180]', () {
      expect(vis.arcl, greaterThanOrEqualTo(0));
      expect(vis.arcl, lessThanOrEqualTo(180));
    });

    test('W >= 0', () {
      expect(vis.w, greaterThanOrEqualTo(0));
    });

    test('isApproximate is true', () {
      expect(vis.isApproximate, isTrue);
    });

    test('isVisibleNakedEye matches zone A', () {
      expect(vis.isVisibleNakedEye, equals(vis.zone == OdehZone.a));
    });

    test('isVisibleWithOpticalAid matches zone A or B', () {
      expect(
        vis.isVisibleWithOpticalAid,
        equals(vis.zone == OdehZone.a || vis.zone == OdehZone.b),
      );
    });

    test('near new moon: zone is D or C', () {
      final nearNew = getMoonVisibilityEstimate(
        DateTime.utc(2025, 3, 29, 18),
        21.4225,
        39.8262,
      );
      expect(nearNew.zone == OdehZone.c || nearNew.zone == OdehZone.d, isTrue);
    });
  });

  // ── getMoon ────────────────────────────────────────────────────────────

  group('getMoon', () {
    final moon = getMoon(
      DateTime.utc(2025, 3, 5, 20),
      51.5074,
      -0.1278,
      elevation: 10,
    );

    test('returns object with phase, position, illumination, visibility', () {
      expect(moon.phase, isNotNull);
      expect(moon.position, isNotNull);
      expect(moon.illumination, isNotNull);
      expect(moon.visibility, isNotNull);
    });

    test('phase is consistent with getMoonPhase standalone', () {
      final standalone = getMoonPhase(DateTime.utc(2025, 3, 5, 20));
      expect(moon.phase.phase, equals(standalone.phase));
      expect(moon.phase.phaseName, equals(standalone.phaseName));
    });

    test('illumination.isWaxing matches phase.isWaxing', () {
      expect(moon.illumination.isWaxing, equals(moon.phase.isWaxing));
    });

    test('visibility.isApproximate is true', () {
      expect(moon.visibility.isApproximate, isTrue);
    });

    test('position has valid azimuth and altitude', () {
      expect(moon.position.azimuth, greaterThanOrEqualTo(0));
      expect(moon.position.azimuth, lessThan(360));
      expect(moon.position.altitude, greaterThanOrEqualTo(-90));
      expect(moon.position.altitude, lessThanOrEqualTo(90));
    });
  });

  // ── Input validation ──────────────────────────────────────────────────

  group('Input validation', () {
    test('getMoonPosition rejects latitude out of range', () {
      expect(() => getMoonPosition(DateTime.now(), 91, 0), throwsRangeError);
    });

    test('getMoonPosition rejects longitude out of range', () {
      expect(() => getMoonPosition(DateTime.now(), 0, 181), throwsRangeError);
    });

    test('getMoonPosition rejects NaN latitude', () {
      expect(
        () => getMoonPosition(DateTime.now(), double.nan, 0),
        throwsRangeError,
      );
    });

    test('getMoonVisibilityEstimate rejects invalid coordinates', () {
      expect(
        () => getMoonVisibilityEstimate(DateTime.now(), -91, 0),
        throwsRangeError,
      );
    });

    test('getMoon rejects invalid coordinates', () {
      expect(() => getMoon(DateTime.now(), 0, 200), throwsRangeError);
    });
  });

  // ── arcvMinimum polynomial ─────────────────────────────────────────────

  group('arcvMinimum polynomial', () {
    test('arcvMinimum(0) = 11.8371', () {
      expect(arcvMinimum(0), closeTo(11.8371, 0.0001));
    });

    test('arcvMinimum decreases with moderate W', () {
      expect(arcvMinimum(1), lessThan(arcvMinimum(0)));
    });
  });

  // ── nearestNewMoon accuracy ────────────────────────────────────────────

  group('nearestNewMoon accuracy', () {
    test('2024-04-08 solar eclipse near new moon', () {
      // Known new moon: 2024-04-08 ~18:21 UTC
      final knownNewMoon = DateTime.utc(2024, 4, 8, 18, 21);
      final phase = getMoonPhase(knownNewMoon);
      // Near new moon: illumination should be very low
      expect(phase.illumination, lessThan(1.0));
      expect(phase.elongationDeg, lessThan(5));
    });
  });

  // ── distanceKm range ──────────────────────────────────────────────────

  group('distanceKm', () {
    test('distance stays within lunar orbit bounds over a month', () {
      for (var day = 1; day <= 30; day++) {
        final pos = getMoonPosition(DateTime.utc(2025, 3, day, 12), 0, 0);
        expect(pos.distance, greaterThan(355000));
        expect(pos.distance, lessThan(410000));
      }
    });
  });
}
