enum AchievementType {
  firstWorkout,
  weekWarrior,
  pushMaster,
  pullPower,
  legLegend,
  streakStarter,
  streakLord,
  volumeKing,
  centuryClub,
  ironWill,
  earlyBird,
  nightOwl,
  personalBest,
  balancedBuilder,
  restChampion,
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String requirement;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.requirement,
    required this.unlockedAt,
  });

  bool get isUnlocked => unlockedAt != null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'requirement': requirement,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      requirement: json['requirement'] as String,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
    );
  }
}

class AchievementDefinition {
  final AchievementType type;
  final String name;
  final String description;
  final String icon;
  final String requirement;

  const AchievementDefinition({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.requirement,
  });
}

final achievementDefinitions = [
  AchievementDefinition(
    type: AchievementType.firstWorkout,
    name: 'First Workout',
    description: 'Complete your first workout',
    icon: '🏋️',
    requirement: 'Complete 1 workout',
  ),
  AchievementDefinition(
    type: AchievementType.weekWarrior,
    name: 'Week Warrior',
    description: 'Complete 7 workouts in a week',
    icon: '⚔️',
    requirement: '7 workouts in calendar week',
  ),
  AchievementDefinition(
    type: AchievementType.pushMaster,
    name: 'Push Master',
    description: 'Complete 20 push workouts',
    icon: '💪',
    requirement: '20 push workouts',
  ),
  AchievementDefinition(
    type: AchievementType.pullPower,
    name: 'Pull Power',
    description: 'Complete 15 pull workouts',
    icon: '🔗',
    requirement: '15 pull workouts',
  ),
  AchievementDefinition(
    type: AchievementType.legLegend,
    name: 'Leg Legend',
    description: 'Complete 20 leg workouts',
    icon: '🦵',
    requirement: '20 leg workouts',
  ),
  AchievementDefinition(
    type: AchievementType.streakStarter,
    name: 'Streak Starter',
    description: 'Build a 7-day streak',
    icon: '🔥',
    requirement: '7-day streak',
  ),
  AchievementDefinition(
    type: AchievementType.streakLord,
    name: 'Streak Lord',
    description: 'Build a 30-day streak',
    icon: '👑',
    requirement: '30-day streak',
  ),
  AchievementDefinition(
    type: AchievementType.volumeKing,
    name: 'Volume King',
    description: 'Achieve 50,000 lbs total volume',
    icon: '👸',
    requirement: '50,000 lbs volume',
  ),
  AchievementDefinition(
    type: AchievementType.centuryClub,
    name: 'Century Club',
    description: 'Complete 100 workouts',
    icon: '💯',
    requirement: '100 workouts',
  ),
  AchievementDefinition(
    type: AchievementType.ironWill,
    name: 'Iron Will',
    description: 'Complete 50 consecutive scheduled workouts',
    icon: '⚙️',
    requirement: '50 consecutive workouts',
  ),
  AchievementDefinition(
    type: AchievementType.earlyBird,
    name: 'Early Bird',
    description: 'Complete 5 workouts before 7 AM',
    icon: '🌅',
    requirement: '5 workouts before 7 AM',
  ),
  AchievementDefinition(
    type: AchievementType.nightOwl,
    name: 'Night Owl',
    description: 'Complete 5 workouts after 8 PM',
    icon: '🌙',
    requirement: '5 workouts after 8 PM',
  ),
  AchievementDefinition(
    type: AchievementType.personalBest,
    name: 'Personal Best',
    description: 'Set a new personal record',
    icon: '🏆',
    requirement: 'Set new PR',
  ),
  AchievementDefinition(
    type: AchievementType.balancedBuilder,
    name: 'Balanced Builder',
    description: 'Train all muscle groups evenly',
    icon: '⚖️',
    requirement: 'Equal volume per muscle',
  ),
  AchievementDefinition(
    type: AchievementType.restChampion,
    name: 'Rest Champion',
    description: 'Complete 10 properly logged rest days',
    icon: '😴',
    requirement: '10 rest days logged',
  ),
];
