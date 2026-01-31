class ExerciseSet {
  final String exerciseId;
  final int sets;
  final int reps;
  final double weight;
  final int rpe;
  final DateTime timestamp;

  ExerciseSet({
    required this.exerciseId,
    required this.sets,
    required this.reps,
    required this.weight,
    required this.rpe,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'rpe': rpe,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ExerciseSet.fromJson(Map<String, dynamic> json) {
    return ExerciseSet(
      exerciseId: json['exerciseId'] as String,
      sets: json['sets'] as int,
      reps: json['reps'] as int,
      weight: (json['weight'] as num).toDouble(),
      rpe: json['rpe'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
