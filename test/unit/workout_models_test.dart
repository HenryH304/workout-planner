import 'package:flutter_test/flutter_test.dart';
import 'package:workout_planner/models/exercise.dart';
import 'package:workout_planner/models/exercise_set.dart';
import 'package:workout_planner/models/workout_log.dart';

void main() {
  group('US-003: Exercise and workout models', () {
    group('WorkoutType enum', () {
      test('WorkoutType has all required types', () {
        final types = WorkoutType.values.map((t) => t.name).toList();
        expect(types, containsAll(['push', 'pull', 'legs', 'rest', 'cardio']));
        expect(WorkoutType.values.length, equals(5));
      });
    });

    group('Exercise model', () {
      test('Exercise can be created with all required fields', () {
        final exercise = Exercise(
          id: 'ex-1',
          name: 'Bench Press',
          primaryMuscles: const ['chest', 'triceps'],
          secondaryMuscles: const ['shoulders'],
          equipment: 'barbell',
          category: WorkoutType.push,
        );

        expect(exercise.id, equals('ex-1'));
        expect(exercise.name, equals('Bench Press'));
        expect(exercise.primaryMuscles, equals(const ['chest', 'triceps']));
        expect(exercise.secondaryMuscles, equals(const ['shoulders']));
        expect(exercise.equipment, equals('barbell'));
        expect(exercise.category, equals(WorkoutType.push));
      });

      test('Exercise has toJson method', () {
        final exercise = Exercise(
          id: 'ex-2',
          name: 'Squat',
          primaryMuscles: const ['quads', 'glutes'],
          secondaryMuscles: const ['hamstrings', 'core'],
          equipment: 'barbell',
          category: WorkoutType.legs,
        );

        final json = exercise.toJson();

        expect(json, isA<Map<String, dynamic>>());
        expect(json['id'], equals('ex-2'));
        expect(json['name'], equals('Squat'));
        expect(json['equipment'], equals('barbell'));
        expect(json['category'], equals('legs'));
      });

      test('Exercise has fromJson factory', () {
        final json = {
          'id': 'ex-3',
          'name': 'Pull-ups',
          'primaryMuscles': ['back', 'biceps'],
          'secondaryMuscles': ['shoulders'],
          'equipment': 'bodyweight',
          'category': 'pull',
        };

        final exercise = Exercise.fromJson(json);

        expect(exercise.id, equals('ex-3'));
        expect(exercise.name, equals('Pull-ups'));
        expect(exercise.category, equals(WorkoutType.pull));
      });

      test('Exercise toJson/fromJson round-trip works', () {
        final original = Exercise(
          id: 'ex-4',
          name: 'Deadlift',
          primaryMuscles: const ['back', 'glutes'],
          secondaryMuscles: const ['hamstrings', 'quads'],
          equipment: 'barbell',
          category: WorkoutType.pull,
        );

        final json = original.toJson();
        final restored = Exercise.fromJson(json);

        expect(restored.id, equals(original.id));
        expect(restored.name, equals(original.name));
        expect(restored.equipment, equals(original.equipment));
        expect(restored.category, equals(original.category));
      });
    });

    group('ExerciseSet model', () {
      test('ExerciseSet can be created with all required fields', () {
        final now = DateTime.now();
        final set = ExerciseSet(
          exerciseId: 'ex-1',
          sets: 4,
          reps: 8,
          weight: 100.0,
          rpe: 8,
          timestamp: now,
        );

        expect(set.exerciseId, equals('ex-1'));
        expect(set.sets, equals(4));
        expect(set.reps, equals(8));
        expect(set.weight, equals(100.0));
        expect(set.rpe, equals(8));
        expect(set.timestamp, equals(now));
      });

      test('ExerciseSet has toJson method', () {
        final now = DateTime.now();
        final set = ExerciseSet(
          exerciseId: 'ex-2',
          sets: 3,
          reps: 10,
          weight: 80.0,
          rpe: 7,
          timestamp: now,
        );

        final json = set.toJson();

        expect(json, isA<Map<String, dynamic>>());
        expect(json['exerciseId'], equals('ex-2'));
        expect(json['sets'], equals(3));
        expect(json['weight'], equals(80.0));
        expect(json['rpe'], equals(7));
      });

      test('ExerciseSet has fromJson factory', () {
        final json = {
          'exerciseId': 'ex-3',
          'sets': 5,
          'reps': 5,
          'weight': 120.0,
          'rpe': 9,
          'timestamp': DateTime.now().toIso8601String(),
        };

        final set = ExerciseSet.fromJson(json);

        expect(set.exerciseId, equals('ex-3'));
        expect(set.sets, equals(5));
        expect(set.reps, equals(5));
      });

      test('ExerciseSet toJson/fromJson round-trip works', () {
        final now = DateTime(2025, 1, 31, 10, 30);
        final original = ExerciseSet(
          exerciseId: 'ex-4',
          sets: 4,
          reps: 6,
          weight: 150.0,
          rpe: 8,
          timestamp: now,
        );

        final json = original.toJson();
        final restored = ExerciseSet.fromJson(json);

        expect(restored.exerciseId, equals(original.exerciseId));
        expect(restored.sets, equals(original.sets));
        expect(restored.weight, equals(original.weight));
      });
    });

    group('WorkoutLog model', () {
      test('WorkoutLog can be created with all required fields', () {
        final date = DateTime(2025, 1, 31);
        final exercises = [
          ExerciseSet(
            exerciseId: 'ex-1',
            sets: 4,
            reps: 8,
            weight: 100.0,
            rpe: 8,
            timestamp: date,
          ),
        ];

        final log = WorkoutLog(
          id: 'wl-1',
          date: date,
          type: WorkoutType.push,
          exercises: exercises,
          completed: true,
          notes: 'Great workout!',
        );

        expect(log.id, equals('wl-1'));
        expect(log.date, equals(date));
        expect(log.type, equals(WorkoutType.push));
        expect(log.exercises, equals(exercises));
        expect(log.completed, isTrue);
        expect(log.notes, equals('Great workout!'));
      });

      test('WorkoutLog has toJson method', () {
        final date = DateTime(2025, 1, 30);
        final exercises = [
          ExerciseSet(
            exerciseId: 'ex-2',
            sets: 3,
            reps: 10,
            weight: 80.0,
            rpe: 7,
            timestamp: date,
          ),
        ];

        final log = WorkoutLog(
          id: 'wl-2',
          date: date,
          type: WorkoutType.pull,
          exercises: exercises,
          completed: false,
          notes: 'In progress',
        );

        final json = log.toJson();

        expect(json, isA<Map<String, dynamic>>());
        expect(json['id'], equals('wl-2'));
        expect(json['type'], equals('pull'));
        expect(json['completed'], isFalse);
      });

      test('WorkoutLog has fromJson factory', () {
        final json = {
          'id': 'wl-3',
          'date': '2025-01-29T10:00:00.000Z',
          'type': 'legs',
          'exercises': [
            {
              'exerciseId': 'ex-3',
              'sets': 4,
              'reps': 8,
              'weight': 100.0,
              'rpe': 8,
              'timestamp': '2025-01-29T10:00:00.000Z',
            }
          ],
          'completed': true,
          'notes': 'Leg day complete',
        };

        final log = WorkoutLog.fromJson(json);

        expect(log.id, equals('wl-3'));
        expect(log.type, equals(WorkoutType.legs));
        expect(log.completed, isTrue);
        expect(log.exercises.length, equals(1));
      });

      test('WorkoutLog toJson/fromJson round-trip works', () {
        final date = DateTime(2025, 1, 28);
        final exercises = [
          ExerciseSet(
            exerciseId: 'ex-4',
            sets: 3,
            reps: 5,
            weight: 200.0,
            rpe: 9,
            timestamp: date,
          ),
        ];

        final original = WorkoutLog(
          id: 'wl-4',
          date: date,
          type: WorkoutType.rest,
          exercises: exercises,
          completed: true,
          notes: 'Rest day',
        );

        final json = original.toJson();
        final restored = WorkoutLog.fromJson(json);

        expect(restored.id, equals(original.id));
        expect(restored.type, equals(original.type));
        expect(restored.exercises.length, equals(original.exercises.length));
      });
    });
  });
}
