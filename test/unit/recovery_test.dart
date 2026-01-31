import 'package:flutter_test/flutter_test.dart';
import 'package:workout_planner/services/recovery_utils.dart';
import 'package:workout_planner/models/muscle_group.dart';

void main() {
  group('US-007: Muscle recovery constants and utilities', () {
    test('Recovery hours are defined for muscle sizes', () {
      expect(SMALL_MUSCLE_RECOVERY_HOURS, equals(48));
      expect(MEDIUM_MUSCLE_RECOVERY_HOURS, equals(60));
      expect(LARGE_MUSCLE_RECOVERY_HOURS, equals(72));
    });

    test('Muscle size mapping includes all small muscles', () {
      expect(SMALL_MUSCLES, contains('biceps'));
      expect(SMALL_MUSCLES, contains('triceps'));
      expect(SMALL_MUSCLES, contains('calves'));
    });

    test('Muscle size mapping includes all medium muscles', () {
      expect(MEDIUM_MUSCLES, contains('shoulders'));
      expect(MEDIUM_MUSCLES, contains('core'));
    });

    test('Muscle size mapping includes all large muscles', () {
      expect(LARGE_MUSCLES, contains('chest'));
      expect(LARGE_MUSCLES, contains('back'));
      expect(LARGE_MUSCLES, contains('quads'));
      expect(LARGE_MUSCLES, contains('glutes'));
      expect(LARGE_MUSCLES, contains('hamstrings'));
    });

    test('getMuscleSize returns correct size for each muscle', () {
      expect(getMuscleSize('biceps'), equals('small'));
      expect(getMuscleSize('triceps'), equals('small'));
      expect(getMuscleSize('calves'), equals('small'));
      expect(getMuscleSize('shoulders'), equals('medium'));
      expect(getMuscleSize('core'), equals('medium'));
      expect(getMuscleSize('chest'), equals('large'));
      expect(getMuscleSize('back'), equals('large'));
      expect(getMuscleSize('quads'), equals('large'));
      expect(getMuscleSize('glutes'), equals('large'));
      expect(getMuscleSize('hamstrings'), equals('large'));
    });

    test('calculateRecoveryPercentage returns 0-100', () {
      final now = DateTime.now();
      final recovered = calculateRecoveryPercentage(now.subtract(Duration(hours: 72)), 'large');

      expect(recovered, greaterThanOrEqualTo(0));
      expect(recovered, lessThanOrEqualTo(100));
    });

    test('calculateRecoveryPercentage returns 0 for just-worked muscle', () {
      final now = DateTime.now();
      final recovered = calculateRecoveryPercentage(now, 'large');

      expect(recovered, lessThanOrEqualTo(5));
    });

    test('calculateRecoveryPercentage returns 100+ for fully recovered muscle', () {
      final now = DateTime.now();
      final recovered = calculateRecoveryPercentage(
        now.subtract(Duration(days: 5)),
        'small'
      );

      expect(recovered, greaterThanOrEqualTo(100));
    });

    test('calculateRecoveryPercentage scales with muscle size', () {
      final now = DateTime.now();
      final timeAgo = now.subtract(Duration(hours: 48));

      final smallRecovery = calculateRecoveryPercentage(timeAgo, 'small');
      final mediumRecovery = calculateRecoveryPercentage(timeAgo, 'medium');
      final largeRecovery = calculateRecoveryPercentage(timeAgo, 'large');

      // Small muscles recover faster
      expect(smallRecovery, greaterThan(mediumRecovery));
      expect(mediumRecovery, greaterThan(largeRecovery));
    });

    test('isRecovered returns false below 85%', () {
      expect(isRecovered(84), isFalse);
      expect(isRecovered(50), isFalse);
      expect(isRecovered(0), isFalse);
    });

    test('isRecovered returns true at 85% or above', () {
      expect(isRecovered(85), isTrue);
      expect(isRecovered(90), isTrue);
      expect(isRecovered(100), isTrue);
    });

    test('Compound movement overlap map exists', () {
      expect(COMPOUND_OVERLAP_MAP, isNotNull);
      expect(COMPOUND_OVERLAP_MAP, isNotEmpty);
    });

    test('Bench press has tricep overlap defined', () {
      expect(COMPOUND_OVERLAP_MAP.containsKey('bench-press'), isTrue);
      expect(COMPOUND_OVERLAP_MAP['bench-press']!.containsKey('triceps'), isTrue);
    });

    test('Compound movement overlap is between 0 and 1', () {
      for (final exercise in COMPOUND_OVERLAP_MAP.entries) {
        for (final overlap in exercise.value.entries) {
          expect(overlap.value, greaterThanOrEqualTo(0.0));
          expect(overlap.value, lessThanOrEqualTo(1.0));
        }
      }
    });
  });
}
