import 'package:flutter_test/flutter_test.dart';
import 'package:workout_planner/models/workout_type.dart';
import 'package:workout_planner/widgets/custom_exercise_form_modal.dart';

void main() {
  group('CustomExerciseFormHelper validation', () {
    test('returns error when name is empty', () {
      final error = CustomExerciseFormHelper.validateName('', []);
      expect(error, 'Name is required');
    });

    test('returns error when name is whitespace only', () {
      final error = CustomExerciseFormHelper.validateName('   ', []);
      expect(error, 'Name is required');
    });

    test('returns error when name exceeds 50 characters', () {
      final longName = 'A' * 51;
      final error = CustomExerciseFormHelper.validateName(longName, []);
      expect(error, 'Name must be 50 characters or less');
    });

    test('returns null when name is valid and unique', () {
      final error = CustomExerciseFormHelper.validateName('My Exercise', []);
      expect(error, isNull);
    });

    test('returns error when name is duplicate (case-insensitive)', () {
      final existingNames = ['Bench Press', 'Squat'];
      final error =
          CustomExerciseFormHelper.validateName('bench press', existingNames);
      expect(error, 'A custom exercise with this name already exists');
    });

    test('allows name that is not a duplicate', () {
      final existingNames = ['Bench Press', 'Squat'];
      final error =
          CustomExerciseFormHelper.validateName('Deadlift', existingNames);
      expect(error, isNull);
    });

    test('returns error when primary muscles is empty', () {
      final error = CustomExerciseFormHelper.validatePrimaryMuscles([]);
      expect(error, 'At least one primary muscle group is required');
    });

    test('returns null when primary muscles has entries', () {
      final error =
          CustomExerciseFormHelper.validatePrimaryMuscles(['chest']);
      expect(error, isNull);
    });

    test('returns error when category is null', () {
      final error = CustomExerciseFormHelper.validateCategory(null);
      expect(error, 'Category is required');
    });

    test('returns null when category is set', () {
      final error =
          CustomExerciseFormHelper.validateCategory(WorkoutType.push);
      expect(error, isNull);
    });
  });

  group('CustomExerciseFormHelper buildExercise', () {
    test('builds a CustomExercise from form data', () {
      final exercise = CustomExerciseFormHelper.buildExercise(
        name: 'My Custom Move',
        primaryMuscles: ['chest', 'triceps'],
        secondaryMuscles: ['shoulders'],
        equipment: 'dumbbells',
        category: WorkoutType.push,
        notes: 'A test exercise',
      );

      expect(exercise.name, 'My Custom Move');
      expect(exercise.primaryMuscles, ['chest', 'triceps']);
      expect(exercise.secondaryMuscles, ['shoulders']);
      expect(exercise.equipment, 'dumbbells');
      expect(exercise.category, WorkoutType.push);
      expect(exercise.notes, 'A test exercise');
      expect(exercise.isCustom, true);
      expect(exercise.id, isEmpty);
    });

    test('builds exercise with empty optional fields', () {
      final exercise = CustomExerciseFormHelper.buildExercise(
        name: 'Minimal Exercise',
        primaryMuscles: ['back'],
        secondaryMuscles: [],
        equipment: '',
        category: WorkoutType.pull,
        notes: '',
      );

      expect(exercise.name, 'Minimal Exercise');
      expect(exercise.secondaryMuscles, isEmpty);
      expect(exercise.equipment, '');
      expect(exercise.notes, '');
    });
  });

  group('CustomExerciseFormHelper isFormValid', () {
    test('returns true when all required fields are valid', () {
      final valid = CustomExerciseFormHelper.isFormValid(
        name: 'Good Exercise',
        primaryMuscles: ['chest'],
        category: WorkoutType.push,
        existingNames: [],
      );
      expect(valid, true);
    });

    test('returns false when name is empty', () {
      final valid = CustomExerciseFormHelper.isFormValid(
        name: '',
        primaryMuscles: ['chest'],
        category: WorkoutType.push,
        existingNames: [],
      );
      expect(valid, false);
    });

    test('returns false when primary muscles is empty', () {
      final valid = CustomExerciseFormHelper.isFormValid(
        name: 'Good Exercise',
        primaryMuscles: [],
        category: WorkoutType.push,
        existingNames: [],
      );
      expect(valid, false);
    });

    test('returns false when category is null', () {
      final valid = CustomExerciseFormHelper.isFormValid(
        name: 'Good Exercise',
        primaryMuscles: ['chest'],
        category: null,
        existingNames: [],
      );
      expect(valid, false);
    });

    test('returns false when name is duplicate', () {
      final valid = CustomExerciseFormHelper.isFormValid(
        name: 'Existing',
        primaryMuscles: ['chest'],
        category: WorkoutType.push,
        existingNames: ['existing'],
      );
      expect(valid, false);
    });
  });
}
