import 'workout_type.dart';

class Exercise {
  final String id;
  final String name;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final String equipment;
  final WorkoutType category;

  const Exercise({
    required this.id,
    required this.name,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.equipment,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'primaryMuscles': primaryMuscles,
      'secondaryMuscles': secondaryMuscles,
      'equipment': equipment,
      'category': category.name,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      primaryMuscles: List<String>.from(json['primaryMuscles'] as List),
      secondaryMuscles: List<String>.from(json['secondaryMuscles'] as List),
      equipment: json['equipment'] as String,
      category: WorkoutType.values.firstWhere(
        (e) => e.name == json['category'],
      ),
    );
  }
}
