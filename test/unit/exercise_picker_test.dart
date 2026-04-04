import 'package:flutter_test/flutter_test.dart';
import 'package:workout_planner/models/exercise.dart';
import 'package:workout_planner/models/workout_type.dart';
import 'package:workout_planner/widgets/exercise_picker.dart';

void main() {
  group('US-021: Exercise Picker', () {
    final testExercises = [
      const Exercise(
        id: 'bench-press',
        name: 'Barbell Bench Press',
        primaryMuscles: ['chest', 'triceps'],
        secondaryMuscles: ['shoulders'],
        equipment: 'barbells',
        category: WorkoutType.push,
      ),
      const Exercise(
        id: 'overhead-press',
        name: 'Overhead Press',
        primaryMuscles: ['shoulders', 'triceps'],
        secondaryMuscles: ['chest'],
        equipment: 'barbells',
        category: WorkoutType.push,
      ),
      const Exercise(
        id: 'barbell-row',
        name: 'Barbell Row',
        primaryMuscles: ['back', 'biceps'],
        secondaryMuscles: ['core'],
        equipment: 'barbells',
        category: WorkoutType.pull,
      ),
      const Exercise(
        id: 'lat-pulldown',
        name: 'Lat Pulldown',
        primaryMuscles: ['back'],
        secondaryMuscles: ['biceps'],
        equipment: 'cables',
        category: WorkoutType.pull,
      ),
      const Exercise(
        id: 'squat',
        name: 'Barbell Squat',
        primaryMuscles: ['quads', 'glutes'],
        secondaryMuscles: ['hamstrings', 'core'],
        equipment: 'barbells',
        category: WorkoutType.legs,
      ),
      const Exercise(
        id: 'leg-press',
        name: 'Leg Press',
        primaryMuscles: ['quads'],
        secondaryMuscles: ['glutes'],
        equipment: 'machines',
        category: WorkoutType.legs,
      ),
      const Exercise(
        id: 'jump-rope',
        name: 'Jump Rope',
        primaryMuscles: ['calves'],
        secondaryMuscles: ['core'],
        equipment: 'bodyweight',
        category: WorkoutType.cardio,
      ),
      const Exercise(
        id: 'custom-exercise-1',
        name: 'My Custom Exercise',
        primaryMuscles: ['chest'],
        secondaryMuscles: [],
        equipment: 'bodyweight',
        category: WorkoutType.push,
      ),
    ];

    group('Search filtering', () {
      test('filterExercises returns all exercises when query is empty', () {
        final result = ExercisePickerHelper.filterExercises(
          testExercises,
          '',
          excludeIds: {},
        );
        expect(result.length, equals(testExercises.length));
      });

      test('filterExercises filters by name case-insensitively', () {
        final result = ExercisePickerHelper.filterExercises(
          testExercises,
          'barbell',
          excludeIds: {},
        );
        expect(result.length, equals(3));
        expect(result.every((e) => e.name.toLowerCase().contains('barbell')),
            isTrue);
      });

      test('filterExercises handles mixed case queries', () {
        final result = ExercisePickerHelper.filterExercises(
          testExercises,
          'BENCH',
          excludeIds: {},
        );
        expect(result.length, equals(1));
        expect(result.first.id, equals('bench-press'));
      });

      test('filterExercises returns empty for no matches', () {
        final result = ExercisePickerHelper.filterExercises(
          testExercises,
          'zzzzz',
          excludeIds: {},
        );
        expect(result, isEmpty);
      });

      test('filterExercises handles partial name matches', () {
        final result = ExercisePickerHelper.filterExercises(
          testExercises,
          'press',
          excludeIds: {},
        );
        // Bench Press, Overhead Press, Leg Press
        expect(result.length, equals(3));
      });
    });

    group('Category grouping', () {
      test('groupByCategory groups exercises into correct categories', () {
        final grouped = ExercisePickerHelper.groupByCategory(testExercises);

        expect(grouped.containsKey('Push'), isTrue);
        expect(grouped.containsKey('Pull'), isTrue);
        expect(grouped.containsKey('Legs'), isTrue);
        expect(grouped.containsKey('Cardio'), isTrue);
      });

      test('groupByCategory assigns correct exercises to each category', () {
        final grouped = ExercisePickerHelper.groupByCategory(testExercises);

        expect(grouped['Push']!.length, equals(3)); // bench, overhead, custom
        expect(grouped['Pull']!.length, equals(2)); // row, pulldown
        expect(grouped['Legs']!.length, equals(2)); // squat, leg press
        expect(grouped['Cardio']!.length, equals(1)); // jump rope
      });

      test('groupByCategory omits empty categories', () {
        final pushOnly = testExercises
            .where((e) => e.category == WorkoutType.push)
            .toList();
        final grouped = ExercisePickerHelper.groupByCategory(pushOnly);

        expect(grouped.containsKey('Pull'), isFalse);
        expect(grouped.containsKey('Legs'), isFalse);
        expect(grouped.containsKey('Push'), isTrue);
      });

      test('groupByCategory returns empty map for empty list', () {
        final grouped = ExercisePickerHelper.groupByCategory([]);
        expect(grouped, isEmpty);
      });
    });

    group('Exclusion list', () {
      test('filterExercises excludes exercises by ID', () {
        final result = ExercisePickerHelper.filterExercises(
          testExercises,
          '',
          excludeIds: {'bench-press', 'squat'},
        );
        expect(result.length, equals(testExercises.length - 2));
        expect(result.any((e) => e.id == 'bench-press'), isFalse);
        expect(result.any((e) => e.id == 'squat'), isFalse);
      });

      test('filterExercises works with empty excludeIds', () {
        final result = ExercisePickerHelper.filterExercises(
          testExercises,
          '',
          excludeIds: {},
        );
        expect(result.length, equals(testExercises.length));
      });

      test('filterExercises combines search and exclusion', () {
        final result = ExercisePickerHelper.filterExercises(
          testExercises,
          'barbell',
          excludeIds: {'bench-press'},
        );
        // Barbell Row and Barbell Squat (Bench Press excluded)
        expect(result.length, equals(2));
        expect(result.any((e) => e.id == 'bench-press'), isFalse);
      });

      test('filterExercises handles non-existent exclude IDs gracefully', () {
        final result = ExercisePickerHelper.filterExercises(
          testExercises,
          '',
          excludeIds: {'non-existent-id'},
        );
        expect(result.length, equals(testExercises.length));
      });
    });

    group('Category display name mapping', () {
      test('getCategoryDisplayName maps workout types correctly', () {
        expect(
            ExercisePickerHelper.getCategoryDisplayName(WorkoutType.push),
            equals('Push'));
        expect(
            ExercisePickerHelper.getCategoryDisplayName(WorkoutType.pull),
            equals('Pull'));
        expect(
            ExercisePickerHelper.getCategoryDisplayName(WorkoutType.legs),
            equals('Legs'));
        expect(
            ExercisePickerHelper.getCategoryDisplayName(WorkoutType.cardio),
            equals('Cardio'));
        expect(
            ExercisePickerHelper.getCategoryDisplayName(WorkoutType.core),
            equals('Core'));
      });
    });
  });
}
