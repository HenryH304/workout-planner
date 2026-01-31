import '../models/workout_type.dart';
import 'fatigue_service.dart';
import 'user_service.dart';
import 'recovery_utils.dart';

class WorkoutRecommendation {
  final WorkoutType type;
  final String reasoning;
  final List<WorkoutType> alternatives;

  WorkoutRecommendation({
    required this.type,
    required this.reasoning,
    required this.alternatives,
  });
}

class RecommendationService {
  final FatigueService _fatigueService;
  final UserService _userService;

  RecommendationService({
    required FatigueService fatigueService,
    required UserService userService,
  })  : _fatigueService = fatigueService,
        _userService = userService;

  Future<WorkoutRecommendation> getRecommendedWorkout(String userId) async {
    try {
      final recovery = await _fatigueService.getRecoveryStatus(userId);
      final readyMuscles = await _fatigueService.getReadyMuscles(userId);

      if (readyMuscles.isEmpty) {
        return WorkoutRecommendation(
          type: WorkoutType.rest,
          reasoning: 'No muscles are adequately recovered (85%+)',
          alternatives: [],
        );
      }

      // Score each workout type based on ready muscles
      final scores = _scoreWorkoutTypes(readyMuscles);
      final sortedTypes = scores.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final recommended = sortedTypes.first.key;
      final alternatives = sortedTypes.skip(1).take(2).map((e) => e.key).toList();

      return WorkoutRecommendation(
        type: recommended,
        reasoning: 'Ready muscles: ${readyMuscles.join(", ")}',
        alternatives: alternatives,
      );
    } catch (e) {
      throw Exception('Failed to get recommendation: $e');
    }
  }

  Future<List<WorkoutType>> getWeekForecast(String userId) async {
    try {
      final forecast = <WorkoutType>[];
      for (int i = 0; i < 7; i++) {
        // Simplified: alternate between push/pull/legs/rest
        final types = [
          WorkoutType.push,
          WorkoutType.pull,
          WorkoutType.legs,
          WorkoutType.rest,
        ];
        forecast.add(types[i % types.length]);
      }
      return forecast;
    } catch (e) {
      throw Exception('Failed to get week forecast: $e');
    }
  }

  Map<WorkoutType, double> _scoreWorkoutTypes(List<String> readyMuscles) {
    final scores = <WorkoutType, double>{
      WorkoutType.push: 0,
      WorkoutType.pull: 0,
      WorkoutType.legs: 0,
      WorkoutType.cardio: 0,
    };

    const pushMuscles = ['chest', 'shoulders', 'triceps'];
    const pullMuscles = ['back', 'biceps'];
    const legsMuscles = ['quads', 'hamstrings', 'glutes', 'calves'];

    for (final muscle in readyMuscles) {
      if (pushMuscles.contains(muscle)) scores[WorkoutType.push] = scores[WorkoutType.push]! + 1;
      if (pullMuscles.contains(muscle)) scores[WorkoutType.pull] = scores[WorkoutType.pull]! + 1;
      if (legsMuscles.contains(muscle)) scores[WorkoutType.legs] = scores[WorkoutType.legs]! + 1;
    }

    return scores;
  }
}
