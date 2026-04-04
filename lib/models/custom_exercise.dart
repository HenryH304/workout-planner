import 'package:cloud_firestore/cloud_firestore.dart';
import 'exercise.dart';
import 'workout_type.dart';

class CustomExercise extends Exercise {
  final bool isCustom;
  final String notes;
  final DateTime createdAt;

  const CustomExercise({
    required super.id,
    required super.name,
    required super.primaryMuscles,
    required super.secondaryMuscles,
    required super.equipment,
    required super.category,
    this.isCustom = true,
    this.notes = '',
    required this.createdAt,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'isCustom': isCustom,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CustomExercise.fromJson(Map<String, dynamic> json) {
    return CustomExercise(
      id: json['id'] as String,
      name: json['name'] as String,
      primaryMuscles: List<String>.from(json['primaryMuscles'] as List),
      secondaryMuscles: List<String>.from(json['secondaryMuscles'] as List),
      equipment: (json['equipment'] as String?) ?? '',
      category: WorkoutType.values.firstWhere(
        (e) => e.name == json['category'],
      ),
      isCustom: (json['isCustom'] as bool?) ?? true,
      notes: (json['notes'] as String?) ?? '',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt'] as String),
    );
  }

  CustomExercise copyWith({
    String? id,
    String? name,
    List<String>? primaryMuscles,
    List<String>? secondaryMuscles,
    String? equipment,
    WorkoutType? category,
    String? notes,
    DateTime? createdAt,
  }) {
    return CustomExercise(
      id: id ?? this.id,
      name: name ?? this.name,
      primaryMuscles: primaryMuscles ?? this.primaryMuscles,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
      equipment: equipment ?? this.equipment,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
