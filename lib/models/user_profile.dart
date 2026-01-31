import 'package:intl/intl.dart';

class UserProfile {
  final String id;
  final String name;
  final int level;
  final int xp;
  final int currentStreak;
  final int longestStreak;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.level,
    required this.xp,
    required this.currentStreak,
    required this.longestStreak,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'xp': xp,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      level: json['level'] as int,
      xp: json['xp'] as int,
      currentStreak: json['currentStreak'] as int,
      longestStreak: json['longestStreak'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
