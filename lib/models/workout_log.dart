import 'exercise_set.dart';
import 'workout_type.dart';

class WorkoutLog {
  final String id;
  final DateTime date;
  final WorkoutType type;
  final List<ExerciseSet> exercises;
  final bool completed;
  final String notes;

  WorkoutLog({
    required this.id,
    required this.date,
    required this.type,
    required this.exercises,
    required this.completed,
    required this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'type': type.name,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'completed': completed,
      'notes': notes,
    };
  }

  factory WorkoutLog.fromJson(Map<String, dynamic> json) {
    return WorkoutLog(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      type: WorkoutType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      exercises: (json['exercises'] as List)
          .map((e) => ExerciseSet.fromJson(e as Map<String, dynamic>))
          .toList(),
      completed: json['completed'] as bool,
      notes: json['notes'] as String? ?? '',
    );
  }
}
