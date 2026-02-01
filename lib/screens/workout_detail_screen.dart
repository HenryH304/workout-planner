import 'package:flutter/material.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final String workoutType;
  final int daysAgo;
  final int volume;
  final int exerciseCount;
  final int duration;

  const WorkoutDetailScreen({
    Key? key,
    required this.workoutType,
    required this.daysAgo,
    required this.volume,
    required this.exerciseCount,
    required this.duration,
  }) : super(key: key);

  static const Color primaryBlue = Color(0xFF3B5BDB);
  static const Color pullGreen = Color(0xFF10B981);
  static const Color legsOrange = Color(0xFFF59E0B);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGray = Color(0xFF6B7280);

  Color get _workoutColor {
    switch (workoutType) {
      case 'Push':
        return primaryBlue;
      case 'Pull':
        return pullGreen;
      case 'Legs':
        return legsOrange;
      default:
        return textGray;
    }
  }

  List<Map<String, dynamic>> get _exercises {
    switch (workoutType) {
      case 'Push':
        return [
          {'name': 'Bench Press', 'sets': 4, 'reps': 8, 'weight': 80.0},
          {'name': 'Incline Dumbbell Press', 'sets': 3, 'reps': 10, 'weight': 30.0},
          {'name': 'Overhead Press', 'sets': 3, 'reps': 8, 'weight': 50.0},
          {'name': 'Lateral Raises', 'sets': 3, 'reps': 12, 'weight': 12.0},
          {'name': 'Tricep Pushdowns', 'sets': 3, 'reps': 12, 'weight': 25.0},
          {'name': 'Overhead Tricep Extension', 'sets': 3, 'reps': 10, 'weight': 20.0},
        ];
      case 'Pull':
        return [
          {'name': 'Deadlift', 'sets': 4, 'reps': 5, 'weight': 120.0},
          {'name': 'Barbell Rows', 'sets': 4, 'reps': 8, 'weight': 70.0},
          {'name': 'Lat Pulldowns', 'sets': 3, 'reps': 10, 'weight': 55.0},
          {'name': 'Face Pulls', 'sets': 3, 'reps': 15, 'weight': 20.0},
          {'name': 'Barbell Curls', 'sets': 3, 'reps': 10, 'weight': 30.0},
          {'name': 'Hammer Curls', 'sets': 3, 'reps': 12, 'weight': 14.0},
        ];
      case 'Legs':
        return [
          {'name': 'Squats', 'sets': 4, 'reps': 6, 'weight': 100.0},
          {'name': 'Romanian Deadlift', 'sets': 3, 'reps': 10, 'weight': 80.0},
          {'name': 'Leg Press', 'sets': 3, 'reps': 12, 'weight': 150.0},
          {'name': 'Leg Curls', 'sets': 3, 'reps': 12, 'weight': 40.0},
          {'name': 'Calf Raises', 'sets': 4, 'reps': 15, 'weight': 60.0},
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = daysAgo == 1 ? 'Yesterday' : '$daysAgo days ago';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_workoutColor, _workoutColor.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$workoutType Day',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateText,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatBadge(Icons.fitness_center, '$exerciseCount exercises'),
                      const SizedBox(width: 12),
                      _buildStatBadge(Icons.timer, '$duration min'),
                      const SizedBox(width: 12),
                      _buildStatBadge(Icons.bar_chart, '${volume}kg'),
                    ],
                  ),
                ],
              ),
            ),
            // Stats row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(child: _buildStatCard('Volume', '${volume}kg', Icons.bar_chart)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('Duration', '$duration min', Icons.timer)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard('XP', '+${(volume / 10).round()}', Icons.star)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Exercises
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Exercises',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _exercises.length,
              itemBuilder: (context, index) {
                final exercise = _exercises[index];
                final exerciseVolume = (exercise['sets'] as int) *
                    (exercise['reps'] as int) *
                    (exercise['weight'] as double);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _workoutColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.fitness_center, color: _workoutColor),
                    ),
                    title: Text(
                      exercise['name'] as String,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${exercise['sets']} sets × ${exercise['reps']} reps @ ${exercise['weight']}kg',
                      style: const TextStyle(color: textGray, fontSize: 12),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${exerciseVolume.toStringAsFixed(0)}kg',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          'volume',
                          style: TextStyle(color: textGray, fontSize: 10),
                        ),
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

  Widget _buildStatBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: _workoutColor, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: textGray, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
