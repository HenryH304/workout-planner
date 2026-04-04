import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:workout_planner/models/custom_exercise.dart';
import 'package:workout_planner/models/workout_type.dart';
import 'package:workout_planner/services/custom_exercise_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('US-027: Manage Custom Exercises Library', () {
    late FakeFirebaseFirestore fakeFirestore;
    late CustomExerciseService service;
    const testUserId = 'test-user-123';

    CustomExercise makeExercise({
      String id = '',
      String name = 'Cable Lateral Raise',
      List<String> primaryMuscles = const ['shoulders'],
      List<String> secondaryMuscles = const [],
      String equipment = 'cables',
      WorkoutType category = WorkoutType.push,
      String notes = 'My notes',
    }) {
      return CustomExercise(
        id: id,
        name: name,
        primaryMuscles: primaryMuscles,
        secondaryMuscles: secondaryMuscles,
        equipment: equipment,
        category: category,
        notes: notes,
        createdAt: DateTime(2026, 4, 4),
      );
    }

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      service = CustomExerciseService(firestore: fakeFirestore);
    });

    group('List custom exercises', () {
      test('getCustomExercises returns all user-created exercises', () async {
        await service.createCustomExercise(
            testUserId, makeExercise(name: 'Exercise A'));
        await service.createCustomExercise(
            testUserId, makeExercise(name: 'Exercise B'));
        await service.createCustomExercise(
            testUserId, makeExercise(name: 'Exercise C'));

        final exercises =
            await service.getCustomExercises(testUserId).first;
        expect(exercises.length, equals(3));
        expect(exercises.map((e) => e.name),
            containsAll(['Exercise A', 'Exercise B', 'Exercise C']));
      });

      test('each exercise has name, muscle groups, and category', () async {
        await service.createCustomExercise(
          testUserId,
          makeExercise(
            name: 'Hip Thrust',
            primaryMuscles: ['glutes', 'hamstrings'],
            category: WorkoutType.legs,
          ),
        );

        final exercises =
            await service.getCustomExercises(testUserId).first;
        expect(exercises.length, equals(1));
        final exercise = exercises.first;
        expect(exercise.name, equals('Hip Thrust'));
        expect(exercise.primaryMuscles, equals(['glutes', 'hamstrings']));
        expect(exercise.category, equals(WorkoutType.legs));
      });

      test('empty list when no custom exercises exist', () async {
        final exercises =
            await service.getCustomExercises(testUserId).first;
        expect(exercises, isEmpty);
      });
    });

    group('Edit custom exercise', () {
      test('updateCustomExercise changes name', () async {
        final created = await service.createCustomExercise(
            testUserId, makeExercise(name: 'Old Name'));

        await service.updateCustomExercise(
            testUserId, created.id, {'name': 'New Name'});

        final exercises =
            await service.getCustomExercises(testUserId).first;
        expect(exercises.first.name, equals('New Name'));
      });

      test('updateCustomExercise changes muscle groups', () async {
        final created = await service.createCustomExercise(
            testUserId,
            makeExercise(
                name: 'Test Ex', primaryMuscles: ['chest']));

        await service.updateCustomExercise(testUserId, created.id, {
          'primaryMuscles': ['shoulders', 'chest']
        });

        final exercises =
            await service.getCustomExercises(testUserId).first;
        expect(exercises.first.primaryMuscles,
            equals(['shoulders', 'chest']));
      });

      test('updateCustomExercise rejects duplicate name', () async {
        await service.createCustomExercise(
            testUserId, makeExercise(name: 'Exercise A'));
        final exerciseB = await service.createCustomExercise(
            testUserId, makeExercise(name: 'Exercise B'));

        expect(
          () => service.updateCustomExercise(
              testUserId, exerciseB.id, {'name': 'Exercise A'}),
          throwsA(isA<Exception>()
              .having((e) => e.toString(), 'message', contains('duplicate'))),
        );
      });

      test('updateCustomExercise allows keeping same name on same exercise',
          () async {
        final created = await service.createCustomExercise(
            testUserId, makeExercise(name: 'My Exercise'));

        // Should not throw — updating the same exercise with the same name
        await service.updateCustomExercise(
            testUserId, created.id, {'name': 'My Exercise', 'notes': 'Updated'});

        final exercises =
            await service.getCustomExercises(testUserId).first;
        expect(exercises.first.notes, equals('Updated'));
      });
    });

    group('Delete custom exercise', () {
      test('deleteCustomExercise removes from Firestore', () async {
        final created = await service.createCustomExercise(
            testUserId, makeExercise(name: 'To Delete'));

        await service.deleteCustomExercise(testUserId, created.id);

        final exercises =
            await service.getCustomExercises(testUserId).first;
        expect(exercises, isEmpty);
      });

      test('deleting one exercise does not affect others', () async {
        await service.createCustomExercise(
            testUserId, makeExercise(name: 'Keep'));
        final ex2 = await service.createCustomExercise(
            testUserId, makeExercise(name: 'Delete'));

        await service.deleteCustomExercise(testUserId, ex2.id);

        final exercises =
            await service.getCustomExercises(testUserId).first;
        expect(exercises.length, equals(1));
        expect(exercises.first.name, equals('Keep'));
      });
    });

    group('CustomExercise model for display', () {
      test('isCustom is true by default', () {
        final exercise = makeExercise();
        expect(exercise.isCustom, isTrue);
      });

      test('copyWith preserves all fields', () {
        final original = makeExercise(
          name: 'Original',
          primaryMuscles: ['chest'],
          equipment: 'barbells',
          category: WorkoutType.push,
          notes: 'Some notes',
        );

        final updated = original.copyWith(name: 'Updated');
        expect(updated.name, equals('Updated'));
        expect(updated.primaryMuscles, equals(['chest']));
        expect(updated.equipment, equals('barbells'));
        expect(updated.category, equals(WorkoutType.push));
        expect(updated.notes, equals('Some notes'));
        expect(updated.isCustom, isTrue);
      });

      test('toJson and fromJson round-trip', () {
        final original = makeExercise(
          name: 'Round Trip',
          primaryMuscles: ['chest', 'shoulders'],
          secondaryMuscles: ['triceps'],
          equipment: 'dumbbells',
          category: WorkoutType.push,
          notes: 'Test notes',
        );

        final json = original.toJson();
        json['id'] = 'test-id'; // Simulate Firestore doc ID
        final restored = CustomExercise.fromJson(json);

        expect(restored.name, equals('Round Trip'));
        expect(restored.primaryMuscles, equals(['chest', 'shoulders']));
        expect(restored.secondaryMuscles, equals(['triceps']));
        expect(restored.equipment, equals('dumbbells'));
        expect(restored.category, equals(WorkoutType.push));
        expect(restored.notes, equals('Test notes'));
        expect(restored.isCustom, isTrue);
      });
    });
  });
}
