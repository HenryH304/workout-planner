import 'package:flutter/material.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  static const Color primaryBlue = Color(0xFF3B5BDB);
  static const Color successGreen = Color(0xFF10B981);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGray = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    final achievements = [
      {'name': 'First Workout', 'icon': '💪', 'desc': 'Complete your first workout', 'unlocked': true},
      {'name': 'Week Warrior', 'icon': '🔥', 'desc': 'Complete 7 workouts in 7 days', 'unlocked': true},
      {'name': 'Push Master', 'icon': '🏋️', 'desc': 'Complete 25 push workouts', 'unlocked': false, 'progress': 12},
      {'name': 'Pull Power', 'icon': '💎', 'desc': 'Complete 25 pull workouts', 'unlocked': false, 'progress': 10},
      {'name': 'Leg Legend', 'icon': '🦵', 'desc': 'Complete 25 leg workouts', 'unlocked': false, 'progress': 8},
      {'name': 'Streak Starter', 'icon': '⚡', 'desc': '7-day streak', 'unlocked': true},
      {'name': 'Streak Lord', 'icon': '👑', 'desc': '30-day streak', 'unlocked': false, 'progress': 10},
      {'name': 'Volume King', 'icon': '🏆', 'desc': 'Lift 10,000kg in a single week', 'unlocked': false, 'progress': 65},
      {'name': 'Century Club', 'icon': '💯', 'desc': 'Complete 100 total workouts', 'unlocked': false, 'progress': 45},
      {'name': 'Iron Will', 'icon': '🎯', 'desc': 'Complete 365 workouts', 'unlocked': false, 'progress': 45},
      {'name': 'Early Bird', 'icon': '🌅', 'desc': 'Complete a workout before 7am', 'unlocked': true},
      {'name': 'Night Owl', 'icon': '🌙', 'desc': 'Complete a workout after 9pm', 'unlocked': false},
      {'name': 'Personal Best', 'icon': '📈', 'desc': 'Set a new PR on any exercise', 'unlocked': true},
      {'name': 'Balanced Builder', 'icon': '⚖️', 'desc': 'Train all muscle groups in one week', 'unlocked': true},
      {'name': 'Rest Champion', 'icon': '😴', 'desc': 'Take exactly 2 rest days in a week', 'unlocked': false},
    ];

    final unlockedCount = achievements.where((a) => a['unlocked'] == true).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Summary card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryBlue, primaryBlue.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 48)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$unlockedCount / ${achievements.length}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'Achievements Unlocked',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Achievements grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final achievement = achievements[index];
                final isUnlocked = achievement['unlocked'] as bool;

                return GestureDetector(
                  onTap: () => _showAchievementDetails(context, achievement),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUnlocked ? Colors.white : Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: isUnlocked
                          ? Border.all(color: successGreen, width: 2)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          achievement['icon'] as String,
                          style: TextStyle(
                            fontSize: 32,
                            color: isUnlocked ? null : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          achievement['name'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isUnlocked ? textDark : textGray,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (isUnlocked)
                          Icon(Icons.check_circle, color: successGreen, size: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showAchievementDetails(BuildContext context, Map<String, dynamic> achievement) {
    final isUnlocked = achievement['unlocked'] as bool;
    final progress = achievement['progress'] as int?;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              achievement['icon'] as String,
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 12),
            Text(
              achievement['name'] as String,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              achievement['desc'] as String,
              style: const TextStyle(color: textGray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (isUnlocked)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: successGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: successGreen, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Unlocked',
                      style: TextStyle(
                        color: successGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else if (progress != null)
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$progress% complete',
                    style: const TextStyle(color: textGray),
                  ),
                ],
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Not yet unlocked',
                  style: TextStyle(color: textGray),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
