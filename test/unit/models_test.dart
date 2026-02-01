import 'package:flutter_test/flutter_test.dart';
import 'package:workout_planner/models/user_profile.dart';
import 'package:workout_planner/models/muscle_fatigue.dart';
import 'package:workout_planner/models/muscle_group.dart';

void main() {
  group('US-002: Core data models', () {
    group('UserProfile model', () {
      test('UserProfile can be created with all required fields', () {
        final profile = UserProfile(
          id: 'user-123',
          name: 'John Doe',
          level: 5,
          xp: 2500,
          currentStreak: 10,
          longestStreak: 15,
          createdAt: DateTime(2025, 1, 1),
        );

        expect(profile.id, equals('user-123'));
        expect(profile.name, equals('John Doe'));
        expect(profile.level, equals(5));
        expect(profile.xp, equals(2500));
        expect(profile.currentStreak, equals(10));
        expect(profile.longestStreak, equals(15));
        expect(profile.createdAt, equals(DateTime(2025, 1, 1)));
      });

      test('UserProfile has toJson method', () {
        final profile = UserProfile(
          id: 'user-123',
          name: 'John Doe',
          level: 5,
          xp: 2500,
          currentStreak: 10,
          longestStreak: 15,
          createdAt: DateTime(2025, 1, 1),
        );

        final json = profile.toJson();

        expect(json, isA<Map<String, dynamic>>());
        expect(json['id'], equals('user-123'));
        expect(json['name'], equals('John Doe'));
        expect(json['level'], equals(5));
        expect(json['xp'], equals(2500));
        expect(json['currentStreak'], equals(10));
        expect(json['longestStreak'], equals(15));
        expect(json.containsKey('createdAt'), isTrue);
      });

      test('UserProfile has fromJson factory', () {
        final json = {
          'id': 'user-456',
          'name': 'Jane Smith',
          'level': 3,
          'xp': 1200,
          'currentStreak': 5,
          'longestStreak': 8,
          'createdAt': '2025-01-15T10:00:00.000Z',
        };

        final profile = UserProfile.fromJson(json);

        expect(profile.id, equals('user-456'));
        expect(profile.name, equals('Jane Smith'));
        expect(profile.level, equals(3));
        expect(profile.xp, equals(1200));
        expect(profile.currentStreak, equals(5));
        expect(profile.longestStreak, equals(8));
      });

      test('UserProfile toJson/fromJson round-trip works', () {
        final original = UserProfile(
          id: 'user-789',
          name: 'Test User',
          level: 2,
          xp: 500,
          currentStreak: 3,
          longestStreak: 5,
          createdAt: DateTime(2025, 1, 10),
        );

        final json = original.toJson();
        final restored = UserProfile.fromJson(json);

        expect(restored.id, equals(original.id));
        expect(restored.name, equals(original.name));
        expect(restored.level, equals(original.level));
        expect(restored.xp, equals(original.xp));
        expect(restored.currentStreak, equals(original.currentStreak));
        expect(restored.longestStreak, equals(original.longestStreak));
      });
    });

    group('MuscleGroup enum', () {
      test('MuscleGroup enum has all required muscles', () {
        // Verify all muscle groups are defined
        expect(MuscleGroup.values.length, greaterThanOrEqualTo(10));

        // Check for specific muscle groups
        final muscleNames = MuscleGroup.values.map((m) => m.name).toList();
        expect(muscleNames, containsAll([
          'chest',
          'back',
          'shoulders',
          'biceps',
          'triceps',
          'core',
          'quads',
          'hamstrings',
          'glutes',
          'calves',
        ]));
      });
    });

    group('MuscleFatigue model', () {
      test('MuscleFatigue can be created with all required fields', () {
        final fatigue = MuscleFatigue(
          muscle: MuscleGroup.chest,
          lastWorked: DateTime(2025, 1, 30),
          fatigueScore: 75.5,
          recoveryEta: DateTime(2025, 2, 2),
        );

        expect(fatigue.muscle, equals(MuscleGroup.chest));
        expect(fatigue.lastWorked, equals(DateTime(2025, 1, 30)));
        expect(fatigue.fatigueScore, equals(75.5));
        expect(fatigue.recoveryEta, equals(DateTime(2025, 2, 2)));
      });

      test('MuscleFatigue has toJson method', () {
        final fatigue = MuscleFatigue(
          muscle: MuscleGroup.back,
          lastWorked: DateTime(2025, 1, 29),
          fatigueScore: 60.0,
          recoveryEta: DateTime(2025, 2, 1),
        );

        final json = fatigue.toJson();

        expect(json, isA<Map<String, dynamic>>());
        expect(json.containsKey('muscle'), isTrue);
        expect(json.containsKey('lastWorked'), isTrue);
        expect(json['fatigueScore'], equals(60.0));
        expect(json.containsKey('recoveryEta'), isTrue);
      });

      test('MuscleFatigue has fromJson factory', () {
        final json = {
          'muscle': 'shoulders',
          'lastWorked': '2025-01-28T10:00:00.000Z',
          'fatigueScore': 45.5,
          'recoveryEta': '2025-01-30T10:00:00.000Z',
        };

        final fatigue = MuscleFatigue.fromJson(json);

        expect(fatigue.muscle, equals(MuscleGroup.shoulders));
        expect(fatigue.fatigueScore, equals(45.5));
      });

      test('MuscleFatigue toJson/fromJson round-trip works', () {
        final original = MuscleFatigue(
          muscle: MuscleGroup.quads,
          lastWorked: DateTime(2025, 1, 25),
          fatigueScore: 85.0,
          recoveryEta: DateTime(2025, 1, 28),
        );

        final json = original.toJson();
        final restored = MuscleFatigue.fromJson(json);

        expect(restored.muscle, equals(original.muscle));
        expect(restored.fatigueScore, equals(original.fatigueScore));
      });
    });
  });
}
