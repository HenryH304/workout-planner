import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:workout_planner/models/exercise.dart';
import 'package:workout_planner/models/workout_type.dart';
import 'package:workout_planner/providers/today_workout_notifier.dart';
import 'package:workout_planner/widgets/exercise_picker.dart';

void main() {
  group('US-022: Add Exercise to Today\'s Plan', () {
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

    final barbellRow = const Exercise(
      id: 'barbell-row',
      name: 'Barbell Row',
      primaryMuscles: ['back'],
      secondaryMuscles: ['biceps'],
      equipment: 'barbell',
      category: WorkoutType.pull,
    );

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      notifier = TodayWorkoutNotifier(
        userId: testUserId,
        firestore: fakeFirestore,
      );
      notifier.initializePlan(
        workoutId: 'workout-1',
        recommendedExercises: [benchPress, overheadPress],
      );
    });

    group('Adding exercises appends to plan', () {
      test('added exercise appears at the bottom of currentExercises', () {
        notifier.addExercise(tricepPushdown);

        expect(notifier.state.currentExercises.length, 3);
        expect(notifier.state.currentExercises.last.id, 'tricep-pushdown');
        expect(notifier.state.currentExercises.last.name, 'Tricep Pushdown');
      });

      test('multiple added exercises append in order', () {
        notifier.addExercise(tricepPushdown);
        notifier.addExercise(lateralRaise);
        notifier.addExercise(barbellRow);

        final exercises = notifier.state.currentExercises;
        expect(exercises.length, 5);
        expect(exercises[2].id, 'tricep-pushdown');
        expect(exercises[3].id, 'lateral-raise');
        expect(exercises[4].id, 'barbell-row');
      });

      test('no cap on number of added exercises', () {
        for (int i = 0; i < 20; i++) {
          notifier.addExercise(Exercise(
            id: 'added-$i',
            name: 'Exercise $i',
            primaryMuscles: ['chest'],
            secondaryMuscles: [],
            equipment: 'bodyweight',
            category: WorkoutType.push,
          ));
        }

        expect(notifier.state.currentExercises.length, 22); // 2 recommended + 20 added
      });
    });

    group('Added exercise is tracked in edits with isCustomAdded', () {
      test('added exercise ID is recorded in edits.added', () {
        notifier.addExercise(tricepPushdown);

        expect(notifier.state.edits.added, contains('tricep-pushdown'));
        expect(notifier.state.edits.hasEdits, true);
      });

      test('isUserAdded helper correctly identifies added exercises', () {
        notifier.addExercise(tricepPushdown);

        final edits = notifier.state.edits;
        // Recommended exercise — not user added
        expect(edits.added.contains('bench-press'), false);
        // User-added exercise
        expect(edits.added.contains('tricep-pushdown'), true);
      });

      test('recommended exercises are NOT marked as added', () {
        notifier.addExercise(tricepPushdown);

        final edits = notifier.state.edits;
        expect(edits.added.contains('bench-press'), false);
        expect(edits.added.contains('overhead-press'), false);
      });
    });

    group('Exclude IDs prevents duplicate additions', () {
      test('current exercise IDs can be used as excludeIds for picker', () {
        notifier.addExercise(tricepPushdown);

        final excludeIds =
            notifier.state.currentExercises.map((e) => e.id).toSet();

        expect(excludeIds, contains('bench-press'));
        expect(excludeIds, contains('overhead-press'));
        expect(excludeIds, contains('tricep-pushdown'));
      });

      test('ExercisePickerHelper excludes current exercises from selection', () {
        notifier.addExercise(tricepPushdown);

        final allExercises = [
          benchPress,
          overheadPress,
          tricepPushdown,
          lateralRaise,
          barbellRow,
        ];
        final excludeIds =
            notifier.state.currentExercises.map((e) => e.id).toSet();
        final available = ExercisePickerHelper.filterExercises(
          allExercises,
          '',
          excludeIds: excludeIds,
        );

        // Only lateral-raise and barbell-row should be available
        expect(available.length, 2);
        expect(available.any((e) => e.id == 'lateral-raise'), true);
        expect(available.any((e) => e.id == 'barbell-row'), true);
        // Already in plan should be excluded
        expect(available.any((e) => e.id == 'bench-press'), false);
        expect(available.any((e) => e.id == 'tricep-pushdown'), false);
      });
    });

    group('Persistence of added exercises', () {
      test('persistEdits saves added exercise IDs to Firestore', () async {
        await fakeFirestore.collection('workouts').doc('workout-1').set({
          'userId': testUserId,
          'id': 'workout-1',
          'date': DateTime.now().toIso8601String(),
          'type': 'push',
          'exercises': [],
          'completed': false,
          'notes': '',
        });

        notifier.addExercise(tricepPushdown);
        notifier.addExercise(lateralRaise);

        await notifier.persistEdits();

        final doc = await fakeFirestore
            .collection('workouts')
            .doc('workout-1')
            .get();
        final data = doc.data()!;
        final edits = data['edits'] as Map;
        final added = List<String>.from(edits['added'] as List);

        expect(added, contains('tricep-pushdown'));
        expect(added, contains('lateral-raise'));
      });
    });

    group('Added exercises support logging', () {
      test('added exercise has name for ExerciseLoggingModal', () {
        notifier.addExercise(tricepPushdown);

        final addedExercise = notifier.state.currentExercises.last;
        expect(addedExercise.name, isNotEmpty);
        expect(addedExercise.name, 'Tricep Pushdown');
      });

      test('added exercise retains all Exercise model fields', () {
        notifier.addExercise(tricepPushdown);

        final addedExercise = notifier.state.currentExercises.last;
        expect(addedExercise.id, 'tricep-pushdown');
        expect(addedExercise.primaryMuscles, ['triceps']);
        expect(addedExercise.equipment, 'cable');
        expect(addedExercise.category, WorkoutType.push);
      });
    });
  });
}
