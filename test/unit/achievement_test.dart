import 'package:flutter_test/flutter_test.dart';
import 'package:workout_planner/models/achievement.dart';

void main() {
  group('US-004: Achievement model and definitions', () {
    group('AchievementType enum', () {
      test('AchievementType has all 15 required types', () {
        final types = AchievementType.values.map((t) => t.name).toList();
        expect(types.length, equals(15));
        expect(types, containsAll([
          'firstWorkout',
          'weekWarrior',
          'pushMaster',
          'pullPower',
          'legLegend',
          'streakStarter',
          'streakLord',
          'volumeKing',
          'centuryClub',
          'ironWill',
          'earlyBird',
          'nightOwl',
          'personalBest',
          'balancedBuilder',
          'restChampion',
        ]));
      });
    });

    group('Achievement model', () {
      test('Achievement can be created with all required fields', () {
        final unlockedAt = DateTime(2025, 1, 15);
        final achievement = Achievement(
          id: 'ach-1',
          name: 'First Workout',
          description: 'Complete your first workout',
          icon: '🏋️',
          requirement: 'Complete 1 workout',
          unlockedAt: unlockedAt,
        );

        expect(achievement.id, equals('ach-1'));
        expect(achievement.name, equals('First Workout'));
        expect(achievement.description, equals('Complete your first workout'));
        expect(achievement.icon, equals('🏋️'));
        expect(achievement.requirement, equals('Complete 1 workout'));
        expect(achievement.unlockedAt, equals(unlockedAt));
      });

      test('Achievement can be created without unlockedAt for locked achievements', () {
        final achievement = Achievement(
          id: 'ach-2',
          name: 'Week Warrior',
          description: 'Complete 7 workouts in a week',
          icon: '⚔️',
          requirement: 'Complete 7 workouts in a calendar week',
          unlockedAt: null,
        );

        expect(achievement.id, equals('ach-2'));
        expect(achievement.unlockedAt, isNull);
      });

      test('Achievement has toJson method', () {
        final unlockedAt = DateTime(2025, 1, 20);
        final achievement = Achievement(
          id: 'ach-3',
          name: 'Push Master',
          description: 'Complete 20 push workouts',
          icon: '💪',
          requirement: 'Complete 20 push workouts',
          unlockedAt: unlockedAt,
        );

        final json = achievement.toJson();

        expect(json, isA<Map<String, dynamic>>());
        expect(json['id'], equals('ach-3'));
        expect(json['name'], equals('Push Master'));
        expect(json.containsKey('unlockedAt'), isTrue);
      });

      test('Achievement has fromJson factory', () {
        final json = {
          'id': 'ach-4',
          'name': 'Pull Power',
          'description': 'Complete 15 pull workouts',
          'icon': '🔗',
          'requirement': 'Complete 15 pull workouts',
          'unlockedAt': '2025-01-18T10:00:00.000Z',
        };

        final achievement = Achievement.fromJson(json);

        expect(achievement.id, equals('ach-4'));
        expect(achievement.name, equals('Pull Power'));
        expect(achievement.unlockedAt, isNotNull);
      });

      test('Achievement fromJson handles null unlockedAt', () {
        final json = {
          'id': 'ach-5',
          'name': 'Leg Legend',
          'description': 'Complete 20 leg workouts',
          'icon': '🦵',
          'requirement': 'Complete 20 leg workouts',
          'unlockedAt': null,
        };

        final achievement = Achievement.fromJson(json);

        expect(achievement.unlockedAt, isNull);
      });

      test('Achievement toJson/fromJson round-trip works', () {
        final unlockedAt = DateTime(2025, 1, 25);
        final original = Achievement(
          id: 'ach-6',
          name: 'Streak Starter',
          description: 'Build a 7-day streak',
          icon: '🔥',
          requirement: 'Build a 7-day streak',
          unlockedAt: unlockedAt,
        );

        final json = original.toJson();
        final restored = Achievement.fromJson(json);

        expect(restored.id, equals(original.id));
        expect(restored.name, equals(original.name));
        expect(restored.unlockedAt, equals(original.unlockedAt));
      });
    });

    group('Achievement definitions', () {
      test('All achievement definitions are properly configured', () {
        final definitions = achievementDefinitions;

        expect(definitions.length, equals(15));

        // Verify all types are defined
        final definedTypes =
            definitions.map((d) => d.type).toSet();
        expect(definedTypes.length, equals(15));
      });

      test('Each achievement definition has required fields', () {
        final definitions = achievementDefinitions;

        for (final def in definitions) {
          expect(def.type, isNotNull);
          expect(def.name, isNotEmpty);
          expect(def.description, isNotEmpty);
          expect(def.icon, isNotEmpty);
          expect(def.requirement, isNotEmpty);
        }
      });

      test('FirstWorkout achievement is defined', () {
        final firstWorkout = achievementDefinitions
            .firstWhere((d) => d.type == AchievementType.firstWorkout);

        expect(firstWorkout.name, isNotEmpty);
        expect(firstWorkout.icon, isNotEmpty);
      });

      test('StreakLord achievement is defined', () {
        final streakLord = achievementDefinitions
            .firstWhere((d) => d.type == AchievementType.streakLord);

        expect(streakLord.name, isNotEmpty);
        expect(streakLord.icon, isNotEmpty);
      });

      test('VolumeKing achievement is defined', () {
        final volumeKing = achievementDefinitions
            .firstWhere((d) => d.type == AchievementType.volumeKing);

        expect(volumeKing.name, isNotEmpty);
        expect(volumeKing.icon, isNotEmpty);
      });
    });
  });
}
