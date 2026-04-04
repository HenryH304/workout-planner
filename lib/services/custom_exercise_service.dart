import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/custom_exercise.dart';

class CustomExerciseService {
  static const String _customExercisesSubcollection = 'custom_exercises';
  final FirebaseFirestore _firestore;

  CustomExerciseService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userCustomExercises(
      String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection(_customExercisesSubcollection);
  }

  Stream<List<CustomExercise>> getCustomExercises(String userId) {
    return _userCustomExercises(userId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return CustomExercise.fromJson(data);
      }).toList();
    });
  }

  Future<CustomExercise> createCustomExercise(
    String userId,
    CustomExercise exercise,
  ) async {
    await _checkDuplicateName(userId, exercise.name);

    final docRef = _userCustomExercises(userId).doc();
    final created = exercise.copyWith(
      id: docRef.id,
      createdAt: DateTime.now(),
    );

    await docRef.set(created.toJson());
    return created;
  }

  Future<void> updateCustomExercise(
    String userId,
    String exerciseId,
    Map<String, dynamic> updates,
  ) async {
    if (updates.containsKey('name')) {
      await _checkDuplicateName(
        userId,
        updates['name'] as String,
        excludeId: exerciseId,
      );
    }

    await _userCustomExercises(userId).doc(exerciseId).update(updates);
  }

  Future<void> deleteCustomExercise(
    String userId,
    String exerciseId,
  ) async {
    await _userCustomExercises(userId).doc(exerciseId).delete();
  }

  Future<void> _checkDuplicateName(
    String userId,
    String name, {
    String? excludeId,
  }) async {
    final snapshot = await _userCustomExercises(userId).get();
    final nameLower = name.toLowerCase();

    for (final doc in snapshot.docs) {
      if (excludeId != null && doc.id == excludeId) continue;
      final existingName = (doc.data()['name'] as String).toLowerCase();
      if (existingName == nameLower) {
        throw Exception(
          'A custom exercise with a duplicate name already exists: $name',
        );
      }
    }
  }
}
