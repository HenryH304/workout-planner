import 'package:flutter_test/flutter_test.dart';
import 'package:workout_planner/services/activity_impact.dart';

void main() {
  group('US-008: External activity impact definitions', () {
    test('ActivityType enum has all required types', () {
      final types = ActivityType.values.map((t) => t.name).toList();
      expect(types, containsAll([
        'running',
        'cycling',
        'swimming',
        'walking',
        'hiit',
        'sports',
      ]));
      expect(types.length, equals(6));
    });

    test('Intensity multipliers are defined', () {
      expect(INTENSITY_LIGHT, equals(0.5));
      expect(INTENSITY_MODERATE, equals(1.0));
      expect(INTENSITY_INTENSE, equals(1.5));
    });

    test('Running affects legs and glutes', () {
      final impact = ACTIVITY_IMPACT_MAP[ActivityType.running]!;
      expect(impact.containsKey('quads'), isTrue);
      expect(impact.containsKey('hamstrings'), isTrue);
      expect(impact.containsKey('calves'), isTrue);
      expect(impact.containsKey('glutes'), isTrue);
    });

    test('Running has high impact (70+)', () {
      final impact = ACTIVITY_IMPACT_MAP[ActivityType.running]!;
      expect(impact['quads'], greaterThanOrEqualTo(70));
      expect(impact['hamstrings'], greaterThanOrEqualTo(70));
      expect(impact['glutes'], greaterThanOrEqualTo(70));
    });

    test('Cycling affects legs with medium-high impact', () {
      final impact = ACTIVITY_IMPACT_MAP[ActivityType.cycling]!;
      expect(impact.containsKey('quads'), isTrue);
      expect(impact.containsKey('hamstrings'), isTrue);
      expect(impact['quads'], greaterThanOrEqualTo(50));
      expect(impact['quads'], lessThanOrEqualTo(70));
    });

    test('Swimming affects full body with medium impact', () {
      final impact = ACTIVITY_IMPACT_MAP[ActivityType.swimming]!;
      expect(impact.keys.length, greaterThan(4));
      for (final muscleImpact in impact.values) {
        expect(muscleImpact, greaterThanOrEqualTo(40));
        expect(muscleImpact, lessThanOrEqualTo(60));
      }
    });

    test('Walking has low impact', () {
      final impact = ACTIVITY_IMPACT_MAP[ActivityType.walking]!;
      expect(impact, isNotEmpty);
      for (final muscleImpact in impact.values) {
        expect(muscleImpact, lessThanOrEqualTo(30));
      }
    });

    test('HIIT has high impact on multiple muscles', () {
      final impact = ACTIVITY_IMPACT_MAP[ActivityType.hiit]!;
      expect(impact.keys.length, greaterThan(3));
      final maxImpact = impact.values.reduce((a, b) => a > b ? a : b);
      expect(maxImpact, greaterThanOrEqualTo(60));
    });

    test('All activity types are defined in impact map', () {
      for (final activityType in ActivityType.values) {
        expect(ACTIVITY_IMPACT_MAP.containsKey(activityType), isTrue);
      }
    });

    test('All impact maps have string keys for muscles', () {
      for (final activityImpact in ACTIVITY_IMPACT_MAP.values) {
        for (final muscle in activityImpact.keys) {
          expect(muscle, isA<String>());
        }
      }
    });

    test('All impact values are between 0 and 100', () {
      for (final activityImpact in ACTIVITY_IMPACT_MAP.values) {
        for (final impact in activityImpact.values) {
          expect(impact, greaterThanOrEqualTo(0));
          expect(impact, lessThanOrEqualTo(100));
        }
      }
    });
  });
}
