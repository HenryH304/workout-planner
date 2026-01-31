import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalRecord {
  final String exerciseId;
  final int repRange; // 1, 5, 10 rep ranges
  final double weight;
  final DateTime date;

  PersonalRecord({
    required this.exerciseId,
    required this.repRange,
    required this.weight,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'repRange': repRange,
        'weight': weight,
        'date': date.toIso8601String(),
      };

  factory PersonalRecord.fromJson(Map<String, dynamic> json) => PersonalRecord(
        exerciseId: json['exerciseId'] as String,
        repRange: json['repRange'] as int,
        weight: (json['weight'] as num).toDouble(),
        date: DateTime.parse(json['date'] as String),
      );
}

class PRService {
  static const String _prsCollection = 'personal_records';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> checkForPR(
    String userId,
    String exerciseId,
    double weight,
    int reps,
  ) async {
    try {
      final repRange = _getRepRange(reps);
      final existing = await getPRs(userId, exerciseId);

      final existingPR = existing.firstWhere(
        (pr) => pr.repRange == repRange,
        orElse: () => PersonalRecord(
          exerciseId: exerciseId,
          repRange: repRange,
          weight: 0,
          date: DateTime.now(),
        ),
      );

      if (weight > existingPR.weight) {
        await _firestore
            .collection(_prsCollection)
            .doc('${userId}_${exerciseId}_$repRange')
            .set({
          'userId': userId,
          'exerciseId': exerciseId,
          'repRange': repRange,
          'weight': weight,
          'date': DateTime.now().toIso8601String(),
        });
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to check for PR: $e');
    }
  }

  Future<List<PersonalRecord>> getPRs(
    String userId,
    String exerciseId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_prsCollection)
          .where('userId', isEqualTo: userId)
          .where('exerciseId', isEqualTo: exerciseId)
          .get();

      return querySnapshot.docs
          .map((doc) => PersonalRecord.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get PRs: $e');
    }
  }

  Future<Map<String, PersonalRecord>> getAllPRs(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_prsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      final Map<String, PersonalRecord> prs = {};
      for (final doc in querySnapshot.docs) {
        final pr = PersonalRecord.fromJson(doc.data());
        prs['${pr.exerciseId}_${pr.repRange}'] = pr;
      }
      return prs;
    } catch (e) {
      throw Exception('Failed to get all PRs: $e');
    }
  }

  int _getRepRange(int reps) {
    if (reps <= 3) return 1;
    if (reps <= 8) return 5;
    return 10;
  }
}
