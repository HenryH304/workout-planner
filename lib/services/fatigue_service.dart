import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/muscle_fatigue.dart';
import '../models/muscle_group.dart';
import 'recovery_utils.dart';
import 'activity_impact.dart';

class FatigueService {
  static const String _fatigueCollection = 'fatigue';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, MuscleFatigue>> getFatigueStatus(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_fatigueCollection)
          .where('userId', isEqualTo: userId)
          .get();

      final Map<String, MuscleFatigue> fatigueMap = {};
      for (final doc in querySnapshot.docs) {
        final fatigue = MuscleFatigue.fromJson(doc.data());
        fatigueMap[fatigue.muscle.name] = fatigue;
      }

      return fatigueMap;
    } catch (e) {
      throw Exception('Failed to get fatigue status: $e');
    }
  }

  Future<void> updateFatigue(
    String userId,
    String muscle,
    double fatigueScore,
  ) async {
    try {
      final now = DateTime.now();
      final muscleGroup =
          MuscleGroup.values.firstWhere((m) => m.name == muscle);

      final fatigue = MuscleFatigue(
        muscle: muscleGroup,
        lastWorked: now,
        fatigueScore: fatigueScore,
        recoveryEta: now.add(
          Duration(
            hours: getRecoveryHours(getMuscleSize(muscle)),
          ),
        ),
      );

      await _firestore
          .collection(_fatigueCollection)
          .doc('${userId}_$muscle')
          .set({
        'userId': userId,
        ...fatigue.toJson(),
      });
    } catch (e) {
      throw Exception('Failed to update fatigue: $e');
    }
  }

  Future<void> logExternalActivity(
    String userId,
    ActivityType activityType,
    int durationMinutes,
    String intensity,
  ) async {
    try {
      final impacts = getActivityImpact(
        activityType,
        getIntensityMultiplier(intensity),
      );

      for (final muscleEntry in impacts.entries) {
        await updateFatigue(userId, muscleEntry.key, muscleEntry.value);
      }
    } catch (e) {
      throw Exception('Failed to log external activity: $e');
    }
  }

  Future<Map<String, double>> getRecoveryStatus(String userId) async {
    try {
      final fatigueMap = await getFatigueStatus(userId);
      final Map<String, double> recoveryMap = {};

      for (final fatigue in fatigueMap.values) {
        final recovery = calculateRecoveryPercentage(
          fatigue.lastWorked,
          getMuscleSize(fatigue.muscle.name),
        );
        recoveryMap[fatigue.muscle.name] = recovery;
      }

      return recoveryMap;
    } catch (e) {
      throw Exception('Failed to get recovery status: $e');
    }
  }

  Future<List<String>> getReadyMuscles(String userId) async {
    try {
      final recovery = await getRecoveryStatus(userId);
      return recovery.entries
          .where((e) => isRecovered(e.value))
          .map((e) => e.key)
          .toList();
    } catch (e) {
      throw Exception('Failed to get ready muscles: $e');
    }
  }
}
