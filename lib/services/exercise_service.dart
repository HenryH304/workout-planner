import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/exercise.dart';
import '../models/workout_type.dart';

class ExerciseService {
  List<Exercise> exercises = [];
  bool _loaded = false;

  Future<List<Exercise>> loadExercises() async {
    if (_loaded) {
      return exercises;
    }

    try {
      final jsonString =
          await rootBundle.loadString('assets/exercises.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);

      exercises = jsonList
          .map((json) => Exercise.fromJson(json as Map<String, dynamic>))
          .toList();

      _loaded = true;
      return exercises;
    } catch (e) {
      throw Exception('Failed to load exercises: $e');
    }
  }

  List<Exercise> getExercisesByMuscle(String muscle) {
    return exercises
        .where((exercise) =>
            exercise.primaryMuscles.contains(muscle) ||
            exercise.secondaryMuscles.contains(muscle))
        .toList();
  }

  List<Exercise> getExercisesByCategory(WorkoutType category) {
    return exercises
        .where((exercise) => exercise.category == category)
        .toList();
  }

  List<Exercise> getExercisesByEquipment(String equipment) {
    return exercises
        .where((exercise) => exercise.equipment == equipment)
        .toList();
  }

  Exercise? getExerciseById(String id) {
    try {
      return exercises.firstWhere((exercise) => exercise.id == id);
    } catch (e) {
      return null;
    }
  }
}
