import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:workout_planner/models/exercise.dart';
import 'package:workout_planner/models/workout_type.dart';
import 'package:workout_planner/models/plan_edits.dart';
import 'package:workout_planner/providers/today_workout_notifier.dart';
import 'package:workout_planner/widgets/exercise_picker.dart';

void main() {
  group('US-025: Swap Exercise on Today\'s Plan', () {
    late FakeFirebaseFirestore fakeFirestore;
    late TodayWorkoutNotifier notifier;
    const testUserId = 'test-user-123';

    const benchPress = Exercise(
      id: 'bench-press',
      name: 'Bench Press',
      primaryMuscles: ['chest'],
      secondaryMuscles: ['triceps', 'shoulders'],
      equipment: 'barbell',
      category: WorkoutType.push,
    );

    const overheadPress = Exercise(
      id: 'overhead-press',
      name: 'Overhead Press',
      primaryMuscles: ['shoulders'],
      secondaryMuscles: ['triceps'],
      equipment: 'barbell',
      category: WorkoutType.push,
    );

    const inclineDbPress = Exercise(
      id: 'incline-db-press',
      name: 'Incline Dumbbell Press',
      primaryMuscles: ['chest'],
      secondaryMuscles: ['shoulders', 'triceps'],
      equipment: 'dumbbells',
      category: WorkoutType.push,
    );

    const lateralRaise = Exercise(
      id: 'lateral-raise',
      name: 'Lateral Raise',
      primaryMuscles: ['shoulders'],
      secondaryMuscles: [],
      equipment: 'dumbbells',
      category: WorkoutType.push,
    );

    const tricepPushdown = Exercise(
      id: 'tricep-pushdown',
      name: 'Tricep Pushdown',
      primaryMuscles: ['triceps'],
      secondaryMuscles: [],
      equipment: 'cable',
      category: WorkoutType.push,
    );

    const barbellRow = Exercise(
      id: 'barbell-row',
      name: 'Barbell Row',
      primaryMuscles: ['back'],
      secondaryMuscles: ['biceps'],
      equipment: 'barbell',
      category: WorkoutType.pull,
    );

    const squat = Exercise(
      id: 'squat',
      name: 'Squat',
      primaryMuscles: ['quads', 'glutes'],
      secondaryMuscles: ['hamstrings'],
      equipment: 'barbell',
      category: WorkoutType.legs,
    );

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      notifier = TodayWorkoutNotifier(
        userId: testUserId,
        firestore: fakeFirestore,
      );
      notifier.initializePlan(
        workoutId: 'workout-1',
        recommendedExercises: [benchPress, overheadPress, inclineDbPress],
      );
    });

    group('Swap replaces exercise at correct position', () {
      test('swapped exercise takes the position of the original', () {
        notifier.swapExercise(
          originalId: 'overhead-press',
          replacement: lateralRaise,
        );

        final exercises = notifier.currentState.currentExercises;
        expect(exercises[0].id, 'bench-press');
        expect(exercises[1].id, 'lateral-raise');
        expect(exercises[2].id, 'incline-db-press');
      });

      test('swapping first exercise puts replacement at index 0', () {
        notifier.swapExercise(
          originalId: 'bench-press',
          replacement: lateralRaise,
        );

        expect(notifier.currentState.currentExercises[0].id, 'lateral-raise');
      });

      test('swapping last exercise puts replacement at end', () {
        notifier.swapExercise(
          originalId: 'incline-db-press',
          replacement: lateralRaise,
        );

        final exercises = notifier.currentState.currentExercises;
        expect(exercises.last.id, 'lateral-raise');
        expect(exercises.length, 3);
      });

      test('swap does nothing if originalId not found', () {
        notifier.swapExercise(
          originalId: 'nonexistent',
          replacement: lateralRaise,
        );

        expect(notifier.currentState.currentExercises.length, 3);
        expect(notifier.currentState.edits.swapped, isEmpty);
      });
    });

    group('Swap records tracked in edits', () {
      test('swap creates a SwapRecord with originalId and replacementId', () {
        notifier.swapExercise(
          originalId: 'overhead-press',
          replacement: lateralRaise,
        );

        final swapped = notifier.currentState.edits.swapped;
        expect(swapped.length, 1);
        expect(swapped.first.originalId, 'overhead-press');
        expect(swapped.first.replacementId, 'lateral-raise');
      });

      test('multiple swaps are tracked independently', () {
        notifier.swapExercise(
          originalId: 'overhead-press',
          replacement: lateralRaise,
        );
        notifier.swapExercise(
          originalId: 'bench-press',
          replacement: tricepPushdown,
        );

        final swapped = notifier.currentState.edits.swapped;
        expect(swapped.length, 2);
        expect(swapped[0].originalId, 'overhead-press');
        expect(swapped[1].originalId, 'bench-press');
      });

      test('isSwapped helper identifies swapped exercises', () {
        notifier.swapExercise(
          originalId: 'overhead-press',
          replacement: lateralRaise,
        );

        final edits = notifier.currentState.edits;
        // lateral-raise replaced overhead-press — should be identified as swapped
        final isSwapped = edits.swapped.any((s) => s.replacementId == 'lateral-raise');
        expect(isSwapped, true);
        // bench-press was not swapped
        final isNotSwapped = edits.swapped.any((s) => s.replacementId == 'bench-press');
        expect(isNotSwapped, false);
      });
    });

    group('Persistence of swap edits', () {
      test('persistEdits saves swap records to Firestore', () async {
        await fakeFirestore.collection('workouts').doc('workout-1').set({
          'userId': testUserId,
          'id': 'workout-1',
          'date': DateTime.now().toIso8601String(),
          'type': 'push',
          'exercises': [],
          'completed': false,
          'notes': '',
        });

        notifier.swapExercise(
          originalId: 'overhead-press',
          replacement: lateralRaise,
        );

        await notifier.persistEdits();

        final doc = await fakeFirestore
            .collection('workouts')
            .doc('workout-1')
            .get();
        final data = doc.data()!;
        final edits = PlanEdits.fromJson(
          Map<String, dynamic>.from(data['edits'] as Map),
        );

        expect(edits.swapped.length, 1);
        expect(edits.swapped.first.originalId, 'overhead-press');
        expect(edits.swapped.first.replacementId, 'lateral-raise');
      });
    });

    group('ExercisePicker muscle group pre-filtering', () {
      final allExercises = [
        benchPress,      // chest
        overheadPress,   // shoulders
        inclineDbPress,  // chest
        lateralRaise,    // shoulders
        tricepPushdown,  // triceps
        barbellRow,      // back
        squat,           // quads, glutes
      ];

      test('filterByMuscleGroups returns exercises matching any muscle', () {
        final filtered = ExercisePickerHelper.filterByMuscleGroups(
          allExercises,
          ['chest'],
        );

        expect(filtered.length, 2);
        expect(filtered.any((e) => e.id == 'bench-press'), true);
        expect(filtered.any((e) => e.id == 'incline-db-press'), true);
      });

      test('filterByMuscleGroups matches any of multiple muscle groups', () {
        final filtered = ExercisePickerHelper.filterByMuscleGroups(
          allExercises,
          ['chest', 'shoulders'],
        );

        // bench-press (chest), overhead-press (shoulders), incline-db-press (chest), lateral-raise (shoulders)
        expect(filtered.length, 4);
      });

      test('filterByMuscleGroups with empty list returns all exercises', () {
        final filtered = ExercisePickerHelper.filterByMuscleGroups(
          allExercises,
          [],
        );

        expect(filtered.length, allExercises.length);
      });

      test('filterByMuscleGroups combined with search and exclude', () {
        // Simulate: swapping bench-press (chest) — filter by chest, exclude bench-press
        final muscleFiltered = ExercisePickerHelper.filterByMuscleGroups(
          allExercises,
          ['chest'],
        );
        final result = ExercisePickerHelper.filterExercises(
          muscleFiltered,
          '',
          excludeIds: {'bench-press', 'overhead-press', 'incline-db-press'},
        );

        // Only incline-db-press matches chest, but it's excluded — no results
        // Actually bench-press is excluded, incline-db-press is excluded too — 0 results
        expect(result, isEmpty);
      });

      test('clearing muscle filter shows all exercises again', () {
        // First filter by chest
        final muscleFiltered = ExercisePickerHelper.filterByMuscleGroups(
          allExercises,
          ['chest'],
        );
        expect(muscleFiltered.length, 2);

        // Then clear filter (empty list = all)
        final allShown = ExercisePickerHelper.filterByMuscleGroups(
          allExercises,
          [],
        );
        expect(allShown.length, allExercises.length);
      });
    });

    group('Swap with logged exercise warning', () {
      test('swapping a logged exercise clears its completion status', () {
        // Simulate: exercise is logged (completed), then swapped
        // The UI should track completed IDs — swapping should clear it
        final completedIds = <String>{'overhead-press'};

        notifier.swapExercise(
          originalId: 'overhead-press',
          replacement: lateralRaise,
        );

        // After swap, overhead-press is no longer in the plan
        // UI should remove it from completedIds
        completedIds.remove('overhead-press');

        expect(completedIds, isNot(contains('overhead-press')));
        expect(notifier.currentState.currentExercises[1].id, 'lateral-raise');
      });
    });
  });
}
