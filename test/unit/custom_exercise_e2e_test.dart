import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:workout_planner/models/custom_exercise.dart';
import 'package:workout_planner/models/workout_type.dart';
import 'package:workout_planner/services/custom_exercise_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('US-028: Custom Exercise Service - Golden Path E2E', () {
    late FakeFirebaseFirestore fakeFirestore;
    late CustomExerciseService service;
    const userId = 'e2e-user';

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      service = CustomExerciseService(firestore: fakeFirestore);
    });

    test(
        'create custom exercise → appears in getCustomExercises stream',
        () async {
      // 1. Verify stream starts empty
      final initialExercises =
          await service.getCustomExercises(userId).first;
      expect(initialExercises, isEmpty);

      // 2. Create a custom exercise
      final exercise = CustomExercise(
        id: '',
        name: 'Landmine Press',
        primaryMuscles: ['shoulders', 'chest'],
        secondaryMuscles: ['triceps', 'core'],
        equipment: 'barbells',
        category: WorkoutType.push,
        notes: 'Great shoulder exercise',
        createdAt: DateTime.now(),
      );
      final created = await service.createCustomExercise(userId, exercise);

      expect(created.id, isNotEmpty);
      expect(created.isCustom, isTrue);

      // 3. Verify it appears in the stream
      final exercises = await service.getCustomExercises(userId).first;
      expect(exercises, hasLength(1));

      final fetched = exercises.first;
      expect(fetched.name, equals('Landmine Press'));
      expect(fetched.primaryMuscles, equals(['shoulders', 'chest']));
      expect(fetched.secondaryMuscles, equals(['triceps', 'core']));
      expect(fetched.equipment, equals('barbells'));
      expect(fetched.category, equals(WorkoutType.push));
      expect(fetched.notes, equals('Great shoulder exercise'));
      expect(fetched.isCustom, isTrue);

      // 4. Update the exercise
      await service.updateCustomExercise(
        userId,
        created.id,
        {'name': 'Landmine Shoulder Press', 'notes': 'Updated notes'},
      );

      final updated = await service.getCustomExercises(userId).first;
      expect(updated.first.name, equals('Landmine Shoulder Press'));
      expect(updated.first.notes, equals('Updated notes'));

      // 5. Delete the exercise
      await service.deleteCustomExercise(userId, created.id);

      final afterDelete = await service.getCustomExercises(userId).first;
      expect(afterDelete, isEmpty);
    });

    test('multiple custom exercises appear in stream', () async {
      final exercise1 = CustomExercise(
        id: '',
        name: 'Exercise One',
        primaryMuscles: ['chest'],
        secondaryMuscles: [],
        equipment: 'bodyweight',
        category: WorkoutType.push,
        createdAt: DateTime.now(),
      );
      final exercise2 = CustomExercise(
        id: '',
        name: 'Exercise Two',
        primaryMuscles: ['back'],
        secondaryMuscles: [],
        equipment: 'cables',
        category: WorkoutType.pull,
        createdAt: DateTime.now(),
      );

      await service.createCustomExercise(userId, exercise1);
      await service.createCustomExercise(userId, exercise2);

      final exercises = await service.getCustomExercises(userId).first;
      expect(exercises, hasLength(2));

      final names = exercises.map((e) => e.name).toSet();
      expect(names, containsAll(['Exercise One', 'Exercise Two']));
    });
  });
}
