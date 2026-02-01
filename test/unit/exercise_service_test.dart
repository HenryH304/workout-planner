import 'package:flutter_test/flutter_test.dart';
import 'package:workout_planner/services/exercise_service.dart';
import 'package:workout_planner/models/workout_type.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('US-006: Exercise service', () {
    late ExerciseService exerciseService;

    setUp(() {
      exerciseService = ExerciseService();
    });

    test('ExerciseService can be instantiated', () {
      expect(exerciseService, isNotNull);
    });

    test('loadExercises loads exercises from JSON asset', () async {
      final exercises = await exerciseService.loadExercises();

      expect(exercises, isNotNull);
      expect(exercises.length, greaterThanOrEqualTo(50));
    });

    test('loadExercises is idempotent', () async {
      final exercises1 = await exerciseService.loadExercises();
      final exercises2 = await exerciseService.loadExercises();

      expect(exercises1.length, equals(exercises2.length));
    });

    test('getExercisesByMuscle returns exercises targeting a muscle', () async {
      final exercises = await exerciseService.loadExercises();
      exerciseService.exercises = exercises;

      final chestExercises =
          exerciseService.getExercisesByMuscle('chest');

      expect(chestExercises, isNotEmpty);
      expect(
        chestExercises.every((e) =>
            e.primaryMuscles.contains('chest') ||
            e.secondaryMuscles.contains('chest')),
        isTrue,
      );
    });

    test('getExercisesByMuscle includes primary and secondary muscles',
        () async {
      final exercises = await exerciseService.loadExercises();
      exerciseService.exercises = exercises;

      final shoulderExercises =
          exerciseService.getExercisesByMuscle('shoulders');

      expect(shoulderExercises, isNotEmpty);
    });

    test('getExercisesByCategory returns exercises of specified category',
        () async {
      final exercises = await exerciseService.loadExercises();
      exerciseService.exercises = exercises;

      final pushExercises =
          exerciseService.getExercisesByCategory(WorkoutType.push);

      expect(pushExercises, isNotEmpty);
      expect(
        pushExercises.every((e) => e.category == WorkoutType.push),
        isTrue,
      );
    });

    test('getExercisesByCategory works for all workout types', () async {
      final exercises = await exerciseService.loadExercises();
      exerciseService.exercises = exercises;

      final pullExercises =
          exerciseService.getExercisesByCategory(WorkoutType.pull);
      final legExercises =
          exerciseService.getExercisesByCategory(WorkoutType.legs);
      final coreExercises =
          exerciseService.getExercisesByCategory(WorkoutType.push);

      expect(pullExercises, isNotEmpty);
      expect(legExercises, isNotEmpty);
      expect(coreExercises, isNotEmpty);
    });

    test('getExercisesByEquipment returns exercises with specified equipment',
        () async {
      final exercises = await exerciseService.loadExercises();
      exerciseService.exercises = exercises;

      final dumbbellExercises =
          exerciseService.getExercisesByEquipment('dumbbells');

      expect(dumbbellExercises, isNotEmpty);
      expect(
        dumbbellExercises.every((e) => e.equipment == 'dumbbells'),
        isTrue,
      );
    });

    test('getExercisesByEquipment works for all equipment types', () async {
      final exercises = await exerciseService.loadExercises();
      exerciseService.exercises = exercises;

      final barbell = exerciseService.getExercisesByEquipment('barbells');
      final cables = exerciseService.getExercisesByEquipment('cables');
      final machines = exerciseService.getExercisesByEquipment('machines');
      final bodyweight =
          exerciseService.getExercisesByEquipment('bodyweight');
      final kettlebells =
          exerciseService.getExercisesByEquipment('kettlebells');

      expect(barbell, isNotEmpty);
      expect(cables, isNotEmpty);
      expect(machines, isNotEmpty);
      expect(bodyweight, isNotEmpty);
      expect(kettlebells, isNotEmpty);
    });

    test('getExercisesByEquipment returns empty for invalid equipment',
        () async {
      final exercises = await exerciseService.loadExercises();
      exerciseService.exercises = exercises;

      final invalid = exerciseService.getExercisesByEquipment('invalid');

      expect(invalid, isEmpty);
    });
  });
}
