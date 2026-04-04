import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/exercise.dart';
import '../models/exercise_set.dart';
import '../models/plan_edits.dart';

class TodayWorkoutState {
  final String? workoutId;
  final List<Exercise> recommendedExercises;
  final List<Exercise> currentExercises;
  final PlanEdits edits;

  const TodayWorkoutState({
    this.workoutId,
    this.recommendedExercises = const [],
    this.currentExercises = const [],
    this.edits = const PlanEdits(),
  });

  TodayWorkoutState copyWith({
    String? workoutId,
    List<Exercise>? recommendedExercises,
    List<Exercise>? currentExercises,
    PlanEdits? edits,
  }) {
    return TodayWorkoutState(
      workoutId: workoutId ?? this.workoutId,
      recommendedExercises: recommendedExercises ?? this.recommendedExercises,
      currentExercises: currentExercises ?? this.currentExercises,
      edits: edits ?? this.edits,
    );
  }
}

class TodayWorkoutNotifier extends StateNotifier<TodayWorkoutState> {
  final String userId;
  final FirebaseFirestore? _injectedFirestore;
  FirebaseFirestore get _firestore =>
      _injectedFirestore ?? FirebaseFirestore.instance;

  TodayWorkoutNotifier({
    required this.userId,
    FirebaseFirestore? firestore,
  })  : _injectedFirestore = firestore,
        super(const TodayWorkoutState());

  /// Public read-only access to current state for UI consumers.
  TodayWorkoutState get currentState => state;

  void initializePlan({
    required String workoutId,
    required List<Exercise> recommendedExercises,
  }) {
    state = TodayWorkoutState(
      workoutId: workoutId,
      recommendedExercises: List.unmodifiable(recommendedExercises),
      currentExercises: List.of(recommendedExercises),
      edits: const PlanEdits(),
    );
  }

  void addExercise(Exercise exercise) {
    final updatedExercises = [...state.currentExercises, exercise];
    final updatedAdded = [...state.edits.added, exercise.id];

    state = state.copyWith(
      currentExercises: updatedExercises,
      edits: state.edits.copyWith(added: updatedAdded),
    );
  }

  void removeExercise(String exerciseId) {
    final updatedExercises =
        state.currentExercises.where((e) => e.id != exerciseId).toList();

    // If the exercise was user-added, just remove from added list
    if (state.edits.added.contains(exerciseId)) {
      final updatedAdded =
          state.edits.added.where((id) => id != exerciseId).toList();
      state = state.copyWith(
        currentExercises: updatedExercises,
        edits: state.edits.copyWith(added: updatedAdded),
      );
    } else {
      // It was a recommended exercise — track in removed
      final updatedRemoved = [...state.edits.removed, exerciseId];
      state = state.copyWith(
        currentExercises: updatedExercises,
        edits: state.edits.copyWith(removed: updatedRemoved),
      );
    }
  }

  void swapExercise({
    required String originalId,
    required Exercise replacement,
  }) {
    final index =
        state.currentExercises.indexWhere((e) => e.id == originalId);
    if (index == -1) return;

    final updatedExercises = List<Exercise>.from(state.currentExercises);
    updatedExercises[index] = replacement;

    final updatedSwapped = [
      ...state.edits.swapped,
      SwapRecord(originalId: originalId, replacementId: replacement.id),
    ];

    state = state.copyWith(
      currentExercises: updatedExercises,
      edits: state.edits.copyWith(swapped: updatedSwapped),
    );
  }

  void undoRemove(String exerciseId, int position, Exercise exercise) {
    final updatedExercises = List<Exercise>.from(state.currentExercises);
    final insertAt = position.clamp(0, updatedExercises.length);
    updatedExercises.insert(insertAt, exercise);

    final updatedRemoved =
        state.edits.removed.where((id) => id != exerciseId).toList();

    state = state.copyWith(
      currentExercises: updatedExercises,
      edits: state.edits.copyWith(removed: updatedRemoved),
    );
  }

  Future<void> persistEdits() async {
    if (state.workoutId == null) return;

    await _firestore
        .collection('workouts')
        .doc(state.workoutId)
        .update({'edits': state.edits.toJson()});
  }

  /// Returns the set of exercise IDs that were actually logged (have sets data).
  /// This is what fatigue calculation should use — not the plan, not the edits.
  static Set<String> getLoggedExerciseIds(List<ExerciseSet> loggedSets) {
    return loggedSets.map((s) => s.exerciseId).toSet();
  }
}
