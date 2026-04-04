import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:workout_planner/models/exercise.dart';
import 'package:workout_planner/models/workout_type.dart';
import 'package:workout_planner/providers/today_workout_notifier.dart';

void main() {
  group('US-023: Remove Exercise from Today\'s Plan', () {
    late FakeFirebaseFirestore fakeFirestore;
    late TodayWorkoutNotifier notifier;
    const testUserId = 'test-user-123';

    final benchPress = const Exercise(
      id: 'bench-press',
      name: 'Bench Press',
      primaryMuscles: ['chest'],
      secondaryMuscles: ['triceps', 'shoulders'],
      equipment: 'barbell',
      category: WorkoutType.push,
    );

    final overheadPress = const Exercise(
      id: 'overhead-press',
      name: 'Overhead Press',
      primaryMuscles: ['shoulders'],
      secondaryMuscles: ['triceps'],
      equipment: 'barbell',
      category: WorkoutType.push,
    );

    final tricepPushdown = const Exercise(
      id: 'tricep-pushdown',
      name: 'Tricep Pushdown',
      primaryMuscles: ['triceps'],
      secondaryMuscles: [],
      equipment: 'cable',
      category: WorkoutType.push,
    );

    final lateralRaise = const Exercise(
      id: 'lateral-raise',
      name: 'Lateral Raise',
      primaryMuscles: ['shoulders'],
      secondaryMuscles: [],
      equipment: 'dumbbells',
      category: WorkoutType.push,
    );

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      notifier = TodayWorkoutNotifier(
        userId: testUserId,
        firestore: fakeFirestore,
      );
      notifier.initializePlan(
        workoutId: 'workout-1',
        recommendedExercises: [benchPress, overheadPress, tricepPushdown],
      );
    });

    group('Removing a recommended exercise', () {
      test('exercise disappears from currentExercises immediately', () {
        notifier.removeExercise('overhead-press');

        expect(notifier.currentState.currentExercises.length, 2);
        expect(
          notifier.currentState.currentExercises.any((e) => e.id == 'overhead-press'),
          false,
        );
      });

      test('removed exercise ID is tracked in edits.removed', () {
        notifier.removeExercise('overhead-press');

        expect(notifier.currentState.edits.removed, contains('overhead-press'));
        expect(notifier.currentState.edits.hasEdits, true);
      });

      test('remaining exercises preserve their order', () {
        notifier.removeExercise('overhead-press');

        final exercises = notifier.currentState.currentExercises;
        expect(exercises[0].id, 'bench-press');
        expect(exercises[1].id, 'tricep-pushdown');
      });

      test('removing first exercise works correctly', () {
        notifier.removeExercise('bench-press');

        final exercises = notifier.currentState.currentExercises;
        expect(exercises.length, 2);
        expect(exercises[0].id, 'overhead-press');
        expect(exercises[1].id, 'tricep-pushdown');
      });

      test('removing last exercise works correctly', () {
        notifier.removeExercise('tricep-pushdown');

        final exercises = notifier.currentState.currentExercises;
        expect(exercises.length, 2);
        expect(exercises[0].id, 'bench-press');
        expect(exercises[1].id, 'overhead-press');
      });

      test('removing all exercises results in empty list', () {
        notifier.removeExercise('bench-press');
        notifier.removeExercise('overhead-press');
        notifier.removeExercise('tricep-pushdown');

        expect(notifier.currentState.currentExercises, isEmpty);
        expect(notifier.currentState.edits.removed.length, 3);
      });
    });

    group('Removing a user-added exercise', () {
      setUp(() {
        notifier.addExercise(lateralRaise);
      });

      test('user-added exercise is removed from currentExercises', () {
        notifier.removeExercise('lateral-raise');

        expect(
          notifier.currentState.currentExercises.any((e) => e.id == 'lateral-raise'),
          false,
        );
        expect(notifier.currentState.currentExercises.length, 3);
      });

      test('user-added exercise is cleaned from edits.added (not tracked in removed)', () {
        notifier.removeExercise('lateral-raise');

        expect(notifier.currentState.edits.added, isNot(contains('lateral-raise')));
        expect(notifier.currentState.edits.removed, isNot(contains('lateral-raise')));
      });
    });

    group('Undo remove restores exercise to original position', () {
      test('undoRemove restores exercise at original index', () {
        // Remove the middle exercise (index 1)
        notifier.removeExercise('overhead-press');
        expect(notifier.currentState.currentExercises.length, 2);

        // Undo the removal
        notifier.undoRemove('overhead-press', 1, overheadPress);

        final exercises = notifier.currentState.currentExercises;
        expect(exercises.length, 3);
        expect(exercises[1].id, 'overhead-press');
      });

      test('undoRemove removes exercise ID from edits.removed', () {
        notifier.removeExercise('overhead-press');
        expect(notifier.currentState.edits.removed, contains('overhead-press'));

        notifier.undoRemove('overhead-press', 1, overheadPress);
        expect(notifier.currentState.edits.removed, isNot(contains('overhead-press')));
      });

      test('undoRemove clamps position if list has shrunk', () {
        notifier.removeExercise('bench-press');
        notifier.removeExercise('overhead-press');
        notifier.removeExercise('tricep-pushdown');

        // Undo with original position 2 but list is empty — should clamp to 0
        notifier.undoRemove('tricep-pushdown', 2, tricepPushdown);

        expect(notifier.currentState.currentExercises.length, 1);
        expect(notifier.currentState.currentExercises[0].id, 'tricep-pushdown');
      });
    });

    group('Persistence of removal', () {
      test('persistEdits saves removed exercise IDs to Firestore', () async {
        await fakeFirestore.collection('workouts').doc('workout-1').set({
          'userId': testUserId,
          'id': 'workout-1',
          'date': DateTime.now().toIso8601String(),
          'type': 'push',
          'exercises': [],
          'completed': false,
          'notes': '',
        });

        notifier.removeExercise('overhead-press');
        notifier.removeExercise('tricep-pushdown');

        await notifier.persistEdits();

        final doc = await fakeFirestore
            .collection('workouts')
            .doc('workout-1')
            .get();
        final data = doc.data()!;
        final edits = data['edits'] as Map;
        final removed = List<String>.from(edits['removed'] as List);

        expect(removed, contains('overhead-press'));
        expect(removed, contains('tricep-pushdown'));
      });
    });

    group('Recommended exercises unchanged by removal', () {
      test('recommendedExercises list is not modified by removeExercise', () {
        notifier.removeExercise('overhead-press');

        expect(notifier.currentState.recommendedExercises.length, 3);
        expect(
          notifier.currentState.recommendedExercises.any((e) => e.id == 'overhead-press'),
          true,
        );
      });
    });
  });
}
