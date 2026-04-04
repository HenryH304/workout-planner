import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:workout_planner/models/exercise.dart';
import 'package:workout_planner/models/exercise_set.dart';
import 'package:workout_planner/models/workout_type.dart';
import 'package:workout_planner/models/plan_edits.dart';
import 'package:workout_planner/providers/today_workout_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('US-029: Workout Plan Edit State Management', () {
    late FakeFirebaseFirestore fakeFirestore;
    late TodayWorkoutNotifier notifier;
    const testUserId = 'test-user-123';

    final benchPress = Exercise(
      id: 'bench-press',
      name: 'Bench Press',
      primaryMuscles: ['chest'],
      secondaryMuscles: ['triceps', 'shoulders'],
      equipment: 'barbell',
      category: WorkoutType.push,
    );

    final overheadPress = Exercise(
      id: 'overhead-press',
      name: 'Overhead Press',
      primaryMuscles: ['shoulders'],
      secondaryMuscles: ['triceps'],
      equipment: 'barbell',
      category: WorkoutType.push,
    );

    final inclineDumbbellPress = Exercise(
      id: 'incline-db-press',
      name: 'Incline Dumbbell Press',
      primaryMuscles: ['chest'],
      secondaryMuscles: ['shoulders', 'triceps'],
      equipment: 'dumbbells',
      category: WorkoutType.push,
    );

    final tricepPushdown = Exercise(
      id: 'tricep-pushdown',
      name: 'Tricep Pushdown',
      primaryMuscles: ['triceps'],
      secondaryMuscles: [],
      equipment: 'cable',
      category: WorkoutType.push,
    );

    final lateralRaise = Exercise(
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
    });

    group('PlanEdits model', () {
      test('empty PlanEdits has no changes', () {
        const edits = PlanEdits();
        expect(edits.added, isEmpty);
        expect(edits.removed, isEmpty);
        expect(edits.swapped, isEmpty);
        expect(edits.hasEdits, false);
      });

      test('toJson and fromJson round-trip', () {
        final edits = PlanEdits(
          added: ['ex-1', 'ex-2'],
          removed: ['ex-3'],
          swapped: [SwapRecord(originalId: 'ex-4', replacementId: 'ex-5')],
        );

        final json = edits.toJson();
        final restored = PlanEdits.fromJson(json);

        expect(restored.added, ['ex-1', 'ex-2']);
        expect(restored.removed, ['ex-3']);
        expect(restored.swapped.length, 1);
        expect(restored.swapped.first.originalId, 'ex-4');
        expect(restored.swapped.first.replacementId, 'ex-5');
        expect(restored.hasEdits, true);
      });
    });

    group('initialization', () {
      test('initializes with recommended exercises', () {
        final recommended = [benchPress, overheadPress, inclineDumbbellPress];
        notifier.initializePlan(
          workoutId: 'workout-1',
          recommendedExercises: recommended,
        );

        final state = notifier.state;
        expect(state.currentExercises.length, 3);
        expect(state.recommendedExercises.length, 3);
        expect(state.edits.hasEdits, false);
        expect(state.workoutId, 'workout-1');
      });
    });

    group('add exercise to state', () {
      test('adds exercise to the end of the plan', () {
        notifier.initializePlan(
          workoutId: 'workout-1',
          recommendedExercises: [benchPress, overheadPress],
        );

        notifier.addExercise(tricepPushdown);

        final state = notifier.state;
        expect(state.currentExercises.length, 3);
        expect(state.currentExercises.last.id, 'tricep-pushdown');
        expect(state.edits.added, contains('tricep-pushdown'));
        expect(state.edits.hasEdits, true);
      });

      test('adding multiple exercises appends each', () {
        notifier.initializePlan(
          workoutId: 'workout-1',
          recommendedExercises: [benchPress],
        );

        notifier.addExercise(tricepPushdown);
        notifier.addExercise(lateralRaise);

        final state = notifier.state;
        expect(state.currentExercises.length, 3);
        expect(state.edits.added, ['tricep-pushdown', 'lateral-raise']);
      });

      test('recommended exercises list is not modified when adding', () {
        notifier.initializePlan(
          workoutId: 'workout-1',
          recommendedExercises: [benchPress],
        );

        notifier.addExercise(tricepPushdown);

        expect(notifier.state.recommendedExercises.length, 1);
      });
    });

    group('remove exercise from state', () {
      test('removes exercise from the plan', () {
        notifier.initializePlan(
          workoutId: 'workout-1',
          recommendedExercises: [benchPress, overheadPress, inclineDumbbellPress],
        );

        notifier.removeExercise('overhead-press');

        final state = notifier.state;
        expect(state.currentExercises.length, 2);
        expect(
          state.currentExercises.any((e) => e.id == 'overhead-press'),
          false,
        );
        expect(state.edits.removed, contains('overhead-press'));
        expect(state.edits.hasEdits, true);
      });

      test('removing a user-added exercise removes it from added list too', () {
        notifier.initializePlan(
          workoutId: 'workout-1',
          recommendedExercises: [benchPress],
        );

        notifier.addExercise(tricepPushdown);
        expect(notifier.state.edits.added, contains('tricep-pushdown'));

        notifier.removeExercise('tricep-pushdown');

        final state = notifier.state;
        expect(state.currentExercises.length, 1);
        expect(state.edits.added, isNot(contains('tricep-pushdown')));
        // Should not be in removed either since it was user-added
        expect(state.edits.removed, isNot(contains('tricep-pushdown')));
      });
    });

    group('swap exercise', () {
      test('replaces exercise at the same position', () {
        notifier.initializePlan(
          workoutId: 'workout-1',
          recommendedExercises: [benchPress, overheadPress, inclineDumbbellPress],
        );

        notifier.swapExercise(
          originalId: 'overhead-press',
          replacement: lateralRaise,
        );

        final state = notifier.state;
        expect(state.currentExercises.length, 3);
        expect(state.currentExercises[1].id, 'lateral-raise');
        expect(state.edits.swapped.length, 1);
        expect(state.edits.swapped.first.originalId, 'overhead-press');
        expect(state.edits.swapped.first.replacementId, 'lateral-raise');
        expect(state.edits.hasEdits, true);
      });

      test('swap preserves order of other exercises', () {
        notifier.initializePlan(
          workoutId: 'workout-1',
          recommendedExercises: [benchPress, overheadPress, inclineDumbbellPress],
        );

        notifier.swapExercise(
          originalId: 'overhead-press',
          replacement: lateralRaise,
        );

        final state = notifier.state;
        expect(state.currentExercises[0].id, 'bench-press');
        expect(state.currentExercises[1].id, 'lateral-raise');
        expect(state.currentExercises[2].id, 'incline-db-press');
      });
    });

    group('completion calculates from logged exercises only', () {
      test('getLoggedExerciseIds returns only exercises with logged sets', () {
        notifier.initializePlan(
          workoutId: 'workout-1',
          recommendedExercises: [benchPress, overheadPress, inclineDumbbellPress],
        );

        // Simulate adding exercise sets (logged data)
        final loggedSets = [
          ExerciseSet(
            exerciseId: 'bench-press',
            sets: 3,
            reps: 8,
            weight: 80.0,
            rpe: 7,
            timestamp: DateTime.now(),
          ),
          ExerciseSet(
            exerciseId: 'incline-db-press',
            sets: 3,
            reps: 10,
            weight: 30.0,
            rpe: 6,
            timestamp: DateTime.now(),
          ),
        ];

        // overhead-press was recommended but not logged
        final loggedIds = TodayWorkoutNotifier.getLoggedExerciseIds(loggedSets);
        expect(loggedIds, contains('bench-press'));
        expect(loggedIds, contains('incline-db-press'));
        expect(loggedIds, isNot(contains('overhead-press')));
      });

      test('getLoggedExerciseIds includes added exercises that were logged', () {
        notifier.initializePlan(
          workoutId: 'workout-1',
          recommendedExercises: [benchPress],
        );
        notifier.addExercise(tricepPushdown);

        final loggedSets = [
          ExerciseSet(
            exerciseId: 'bench-press',
            sets: 3,
            reps: 8,
            weight: 80.0,
            rpe: 7,
            timestamp: DateTime.now(),
          ),
          ExerciseSet(
            exerciseId: 'tricep-pushdown',
            sets: 3,
            reps: 12,
            weight: 25.0,
            rpe: 6,
            timestamp: DateTime.now(),
          ),
        ];

        final loggedIds = TodayWorkoutNotifier.getLoggedExerciseIds(loggedSets);
        expect(loggedIds, contains('bench-press'));
        expect(loggedIds, contains('tricep-pushdown'));
      });

      test('getLoggedExerciseIds includes swapped exercises that were logged', () {
        notifier.initializePlan(
          workoutId: 'workout-1',
          recommendedExercises: [benchPress, overheadPress],
        );
        notifier.swapExercise(
          originalId: 'overhead-press',
          replacement: lateralRaise,
        );

        final loggedSets = [
          ExerciseSet(
            exerciseId: 'bench-press',
            sets: 3,
            reps: 8,
            weight: 80.0,
            rpe: 7,
            timestamp: DateTime.now(),
          ),
          ExerciseSet(
            exerciseId: 'lateral-raise',
            sets: 3,
            reps: 15,
            weight: 10.0,
            rpe: 6,
            timestamp: DateTime.now(),
          ),
        ];

        final loggedIds = TodayWorkoutNotifier.getLoggedExerciseIds(loggedSets);
        expect(loggedIds, contains('bench-press'));
        expect(loggedIds, contains('lateral-raise'));
        // Original was swapped out — should not appear
        expect(loggedIds, isNot(contains('overhead-press')));
      });
    });

    group('Firestore persistence of edits', () {
      test('persistEdits saves edits sub-field to workout document', () async {
        // Create a workout document first
        await fakeFirestore.collection('workouts').doc('workout-1').set({
          'userId': testUserId,
          'id': 'workout-1',
          'date': DateTime.now().toIso8601String(),
          'type': 'push',
          'exercises': [],
          'completed': false,
          'notes': '',
        });

        notifier.initializePlan(
          workoutId: 'workout-1',
          recommendedExercises: [benchPress, overheadPress],
        );

        notifier.addExercise(tricepPushdown);
        notifier.removeExercise('overhead-press');
        notifier.swapExercise(
          originalId: 'bench-press',
          replacement: inclineDumbbellPress,
        );

        await notifier.persistEdits();

        final doc = await fakeFirestore
            .collection('workouts')
            .doc('workout-1')
            .get();
        final data = doc.data()!;

        expect(data['edits'], isNotNull);
        final edits = PlanEdits.fromJson(
          Map<String, dynamic>.from(data['edits'] as Map),
        );
        expect(edits.added, contains('tricep-pushdown'));
        expect(edits.removed, contains('overhead-press'));
        expect(edits.swapped.length, 1);
      });

      test('recommendation service fields remain unaffected by edits', () async {
        // Create a workout document
        await fakeFirestore.collection('workouts').doc('workout-1').set({
          'userId': testUserId,
          'id': 'workout-1',
          'date': DateTime.now().toIso8601String(),
          'type': 'push',
          'exercises': [],
          'completed': false,
          'notes': '',
        });

        notifier.initializePlan(
          workoutId: 'workout-1',
          recommendedExercises: [benchPress],
        );
        notifier.addExercise(tricepPushdown);
        await notifier.persistEdits();

        // Verify that the core workout fields are unchanged
        final doc = await fakeFirestore
            .collection('workouts')
            .doc('workout-1')
            .get();
        final data = doc.data()!;

        // These fields are what RecommendationService/FatigueService read
        expect(data['exercises'], isList);
        expect(data['type'], 'push');
        expect(data['completed'], false);
        // edits is a separate field — services don't read it
        expect(data['edits'], isNotNull);
      });
    });

    group('undo support', () {
      test('undoRemove restores exercise at original position', () {
        notifier.initializePlan(
          workoutId: 'workout-1',
          recommendedExercises: [benchPress, overheadPress, inclineDumbbellPress],
        );

        notifier.removeExercise('overhead-press');
        expect(notifier.state.currentExercises.length, 2);

        notifier.undoRemove('overhead-press', 1, overheadPress);

        final state = notifier.state;
        expect(state.currentExercises.length, 3);
        expect(state.currentExercises[1].id, 'overhead-press');
        expect(state.edits.removed, isNot(contains('overhead-press')));
      });
    });
  });
}
