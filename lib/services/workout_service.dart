import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout_log.dart';
import '../models/workout_type.dart';
import '../models/exercise_set.dart';

class WorkoutService {
  static const String _workoutsCollection = 'workouts';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> startWorkout(String userId, WorkoutType type) async {
    try {
      final workoutLog = WorkoutLog(
        id: '',
        date: DateTime.now(),
        type: type,
        exercises: [],
        completed: false,
        notes: '',
      );

      final docRef = await _firestore
          .collection(_workoutsCollection)
          .add({
        'userId': userId,
        ...workoutLog.toJson(),
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to start workout: $e');
    }
  }

  Future<void> logExercise(
    String workoutId,
    String exerciseId,
    int sets,
    int reps,
    double weight,
    int rpe,
  ) async {
    try {
      final now = DateTime.now();
      final exerciseSet = ExerciseSet(
        exerciseId: exerciseId,
        sets: sets,
        reps: reps,
        weight: weight,
        rpe: rpe,
        timestamp: now,
      );

      await _firestore
          .collection(_workoutsCollection)
          .doc(workoutId)
          .update({
        'exercises': FieldValue.arrayUnion([exerciseSet.toJson()])
      });
    } catch (e) {
      throw Exception('Failed to log exercise: $e');
    }
  }

  Future<void> completeWorkout(String workoutId) async {
    try {
      await _firestore
          .collection(_workoutsCollection)
          .doc(workoutId)
          .update({
        'completed': true,
      });
    } catch (e) {
      throw Exception('Failed to complete workout: $e');
    }
  }

  Future<List<WorkoutLog>> getWorkoutHistory(
    String userId, {
    int limit = 10,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(_workoutsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => WorkoutLog.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to get workout history: $e');
    }
  }

  Future<WorkoutLog?> getTodayWorkout(String userId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await _firestore
          .collection(_workoutsCollection)
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThan: endOfDay)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final doc = querySnapshot.docs.first;
      return WorkoutLog.fromJson({
        'id': doc.id,
        ...doc.data(),
      });
    } catch (e) {
      throw Exception('Failed to get today workout: $e');
    }
  }
}
