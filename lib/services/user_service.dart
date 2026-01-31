import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class UserService {
  static const String _usersCollection = 'users';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Level thresholds (exponential)
  static const Map<int, int> levelThresholds = {
    1: 0,
    2: 500,
    3: 1500,
    4: 3500,
    5: 7000,
  };

  Future<void> createProfile(String userId, String name) async {
    final profile = UserProfile(
      id: userId,
      name: name,
      level: 1,
      xp: 0,
      currentStreak: 0,
      longestStreak: 0,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection(_usersCollection)
        .doc(userId)
        .set(profile.toJson());
  }

  Future<UserProfile?> getProfile(String userId) async {
    try {
      final doc =
          await _firestore.collection(_usersCollection).doc(userId).get();

      if (doc.exists) {
        return UserProfile.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }

  Future<void> updateXP(String userId, int amount) async {
    try {
      final profile = await getProfile(userId);
      if (profile == null) return;

      int newXP = profile.xp + amount;
      int newLevel = calculateLevelFromXP(newXP);

      await _firestore.collection(_usersCollection).doc(userId).update({
        'xp': newXP,
        'level': newLevel,
      });
    } catch (e) {
      throw Exception('Failed to update XP: $e');
    }
  }

  Future<void> updateStreak(String userId, {bool increment = true}) async {
    try {
      final profile = await getProfile(userId);
      if (profile == null) return;

      int newStreak = increment ? profile.currentStreak + 1 : 0;
      int newLongestStreak = newStreak > profile.longestStreak
          ? newStreak
          : profile.longestStreak;

      await _firestore.collection(_usersCollection).doc(userId).update({
        'currentStreak': newStreak,
        'longestStreak': newLongestStreak,
      });
    } catch (e) {
      throw Exception('Failed to update streak: $e');
    }
  }

  int calculateLevelFromXP(int totalXP) {
    for (int level = 5; level >= 1; level--) {
      if (totalXP >= levelThresholds[level]!) {
        return level;
      }
    }
    return 1;
  }

  int getXPForNextLevel(int currentXP) {
    final currentLevel = calculateLevelFromXP(currentXP);
    final nextLevel = currentLevel + 1;
    if (levelThresholds.containsKey(nextLevel)) {
      return levelThresholds[nextLevel]! - currentXP;
    }
    return 0; // Max level reached
  }
}
