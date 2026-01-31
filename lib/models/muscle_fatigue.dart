import 'muscle_group.dart';

class MuscleFatigue {
  final MuscleGroup muscle;
  final DateTime lastWorked;
  final double fatigueScore;
  final DateTime recoveryEta;

  MuscleFatigue({
    required this.muscle,
    required this.lastWorked,
    required this.fatigueScore,
    required this.recoveryEta,
  });

  Map<String, dynamic> toJson() {
    return {
      'muscle': muscle.name,
      'lastWorked': lastWorked.toIso8601String(),
      'fatigueScore': fatigueScore,
      'recoveryEta': recoveryEta.toIso8601String(),
    };
  }

  factory MuscleFatigue.fromJson(Map<String, dynamic> json) {
    return MuscleFatigue(
      muscle: MuscleGroup.values.firstWhere(
        (e) => e.name == json['muscle'],
      ),
      lastWorked: DateTime.parse(json['lastWorked'] as String),
      fatigueScore: (json['fatigueScore'] as num).toDouble(),
      recoveryEta: DateTime.parse(json['recoveryEta'] as String),
    );
  }
}
