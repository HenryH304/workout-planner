import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:workout_planner/models/custom_exercise.dart';
import 'package:workout_planner/models/workout_type.dart';
import 'package:workout_planner/services/custom_exercise_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('US-028: Custom Exercise Service', () {
    late FakeFirebaseFirestore fakeFirestore;
    late CustomExerciseService service;
    const testUserId = 'test-user-123';

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      service = CustomExerciseService(firestore: fakeFirestore);
    });

    CustomExercise makeExercise({
      String id = 'custom-1',
      String name = 'My Custom Press',
      List<String> primaryMuscles = const ['chest'],
      List<String> secondaryMuscles = const ['triceps'],
      String equipment = 'dumbbells',
      WorkoutType category = WorkoutType.push,
      String notes = '',
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

    group('createCustomExercise', () {
      test('creates a custom exercise in Firestore', () async {
        final exercise = makeExercise();
        final created =
            await service.createCustomExercise(testUserId, exercise);

        expect(created.name, equals('My Custom Press'));
        expect(created.isCustom, isTrue);
        expect(created.primaryMuscles, contains('chest'));

        // Verify it was saved to Firestore
        final doc = await fakeFirestore
            .collection('users')
            .doc(testUserId)
            .collection('custom_exercises')
            .doc(created.id)
            .get();
        expect(doc.exists, isTrue);
        expect(doc.data()!['name'], equals('My Custom Press'));
      });

      test('generates a unique ID for the exercise', () async {
        final exercise = makeExercise();
        final created =
            await service.createCustomExercise(testUserId, exercise);

        expect(created.id, isNotEmpty);
      });

      test('throws on duplicate name (case-insensitive)', () async {
        final exercise1 = makeExercise(name: 'Custom Squat');
        await service.createCustomExercise(testUserId, exercise1);

        final exercise2 = makeExercise(id: 'custom-2', name: 'custom squat');
        expect(
          () => service.createCustomExercise(testUserId, exercise2),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('duplicate'),
          )),
        );
      });

      test('allows same name for different users', () async {
        final exercise = makeExercise(name: 'My Exercise');
        await service.createCustomExercise('user-1', exercise);

        final exercise2 = makeExercise(name: 'My Exercise');
        final created =
            await service.createCustomExercise('user-2', exercise2);
        expect(created.name, equals('My Exercise'));
      });
    });

    group('getCustomExercises', () {
      test('returns stream of custom exercises for a user', () async {
        final exercise = makeExercise(name: 'Exercise A');
        await service.createCustomExercise(testUserId, exercise);

        final exercises =
            await service.getCustomExercises(testUserId).first;

        expect(exercises, hasLength(1));
        expect(exercises.first.name, equals('Exercise A'));
        expect(exercises.first.isCustom, isTrue);
      });

      test('returns empty list when user has no custom exercises', () async {
        final exercises =
            await service.getCustomExercises(testUserId).first;

        expect(exercises, isEmpty);
      });

      test('returns only exercises for the specified user', () async {
        await service.createCustomExercise(
            'user-a', makeExercise(name: 'A Exercise'));
        await service.createCustomExercise(
            'user-b', makeExercise(name: 'B Exercise'));

        final exercisesA =
            await service.getCustomExercises('user-a').first;
        final exercisesB =
            await service.getCustomExercises('user-b').first;

        expect(exercisesA, hasLength(1));
        expect(exercisesA.first.name, equals('A Exercise'));
        expect(exercisesB, hasLength(1));
        expect(exercisesB.first.name, equals('B Exercise'));
      });
    });

    group('updateCustomExercise', () {
      test('updates an existing custom exercise', () async {
        final exercise = makeExercise(name: 'Original Name');
        final created =
            await service.createCustomExercise(testUserId, exercise);

        await service.updateCustomExercise(
          testUserId,
          created.id,
          {'name': 'Updated Name', 'notes': 'Added notes'},
        );

        final doc = await fakeFirestore
            .collection('users')
            .doc(testUserId)
            .collection('custom_exercises')
            .doc(created.id)
            .get();
        expect(doc.data()!['name'], equals('Updated Name'));
        expect(doc.data()!['notes'], equals('Added notes'));
      });

      test('throws on duplicate name when updating', () async {
        final exercise1 = makeExercise(name: 'Exercise One');
        await service.createCustomExercise(testUserId, exercise1);

        final exercise2 = makeExercise(name: 'Exercise Two');
        final created2 =
            await service.createCustomExercise(testUserId, exercise2);

        expect(
          () => service.updateCustomExercise(
            testUserId,
            created2.id,
            {'name': 'exercise one'},
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('duplicate'),
          )),
        );
      });

      test('allows updating name to same name (own exercise)', () async {
        final exercise = makeExercise(name: 'My Exercise');
        final created =
            await service.createCustomExercise(testUserId, exercise);

        // Should not throw — updating own exercise with same name
        await service.updateCustomExercise(
          testUserId,
          created.id,
          {'name': 'My Exercise', 'notes': 'updated'},
        );

        final doc = await fakeFirestore
            .collection('users')
            .doc(testUserId)
            .collection('custom_exercises')
            .doc(created.id)
            .get();
        expect(doc.data()!['notes'], equals('updated'));
      });
    });

    group('deleteCustomExercise', () {
      test('deletes a custom exercise from Firestore', () async {
        final exercise = makeExercise(name: 'To Delete');
        final created =
            await service.createCustomExercise(testUserId, exercise);

        await service.deleteCustomExercise(testUserId, created.id);

        final doc = await fakeFirestore
            .collection('users')
            .doc(testUserId)
            .collection('custom_exercises')
            .doc(created.id)
            .get();
        expect(doc.exists, isFalse);
      });

      test('deleting non-existent exercise does not throw', () async {
        // Should not throw
        await service.deleteCustomExercise(testUserId, 'non-existent-id');
      });
    });

    group('CustomExercise model', () {
      test('toJson includes all fields', () {
        final exercise = makeExercise(notes: 'Some notes');
        final json = exercise.toJson();

        expect(json['id'], equals('custom-1'));
        expect(json['name'], equals('My Custom Press'));
        expect(json['primaryMuscles'], equals(['chest']));
        expect(json['secondaryMuscles'], equals(['triceps']));
        expect(json['equipment'], equals('dumbbells'));
        expect(json['category'], equals('push'));
        expect(json['isCustom'], isTrue);
        expect(json['notes'], equals('Some notes'));
        expect(json['createdAt'], isNotNull);
      });

      test('fromJson round-trip preserves all fields', () {
        final original = makeExercise(notes: 'Round trip test');
        final json = original.toJson();
        final restored = CustomExercise.fromJson(json);

        expect(restored.id, equals(original.id));
        expect(restored.name, equals(original.name));
        expect(restored.primaryMuscles, equals(original.primaryMuscles));
        expect(restored.secondaryMuscles, equals(original.secondaryMuscles));
        expect(restored.equipment, equals(original.equipment));
        expect(restored.category, equals(original.category));
        expect(restored.isCustom, equals(original.isCustom));
        expect(restored.notes, equals(original.notes));
        expect(restored.createdAt, equals(original.createdAt));
      });

      test('copyWith creates modified copy', () {
        final original = makeExercise();
        final modified = original.copyWith(name: 'New Name', notes: 'New notes');

        expect(modified.name, equals('New Name'));
        expect(modified.notes, equals('New notes'));
        expect(modified.id, equals(original.id));
        expect(modified.primaryMuscles, equals(original.primaryMuscles));
      });
    });
  });
}
