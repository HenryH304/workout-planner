import 'package:flutter/material.dart';
import 'workout_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  static const Color primaryBlue = Color(0xFF3B5BDB);
  static const Color pullGreen = Color(0xFF10B981);
  static const Color legsOrange = Color(0xFFF59E0B);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGray = Color(0xFF6B7280);

  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Push', 'Pull', 'Legs'];

  // Mock workout history data
  final List<Map<String, dynamic>> _workouts = [
    {'type': 'Push', 'daysAgo': 1, 'volume': 2450, 'exercises': 6, 'duration': 58},
    {'type': 'Pull', 'daysAgo': 2, 'volume': 2180, 'exercises': 6, 'duration': 52},
    {'type': 'Legs', 'daysAgo': 3, 'volume': 3200, 'exercises': 5, 'duration': 48},
    {'type': 'Push', 'daysAgo': 5, 'volume': 2380, 'exercises': 6, 'duration': 55},
    {'type': 'Pull', 'daysAgo': 6, 'volume': 2050, 'exercises': 6, 'duration': 50},
    {'type': 'Legs', 'daysAgo': 7, 'volume': 3100, 'exercises': 5, 'duration': 45},
    {'type': 'Push', 'daysAgo': 9, 'volume': 2300, 'exercises': 6, 'duration': 54},
    {'type': 'Pull', 'daysAgo': 10, 'volume': 2100, 'exercises': 6, 'duration': 51},
    {'type': 'Legs', 'daysAgo': 11, 'volume': 2950, 'exercises': 5, 'duration': 46},
    {'type': 'Push', 'daysAgo': 13, 'volume': 2250, 'exercises': 6, 'duration': 53},
  ];

  Color _getColorForType(String type) {
    switch (type) {
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

  List<Map<String, dynamic>> get _filteredWorkouts {
    if (_selectedFilter == 0) return _workouts;
    final filterType = _filters[_selectedFilter];
    return _workouts.where((w) => w['type'] == filterType).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout History')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_filters.length, (index) {
                    final isSelected = _selectedFilter == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(_filters[index]),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => _selectedFilter = index);
                        },
                        backgroundColor: Colors.white,
                        selectedColor: textDark,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : textGray,
                          fontWeight: FontWeight.w500,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        side: BorderSide.none,
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredWorkouts.length,
              itemBuilder: (context, index) {
                final workout = _filteredWorkouts[index];
                final type = workout['type'] as String;
                final color = _getColorForType(type);
                final daysAgo = workout['daysAgo'] as int;
                final volume = workout['volume'] as int;

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
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.fitness_center, color: color),
                    ),
                    title: Text(
                      '$type Day',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${daysAgo == 1 ? 'Yesterday' : '$daysAgo days ago'} • ${volume.toStringAsFixed(0)} kg volume',
                      style: const TextStyle(color: textGray, fontSize: 12),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: textGray),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WorkoutDetailScreen(
                            workoutType: type,
                            daysAgo: daysAgo,
                            volume: volume,
                            exerciseCount: workout['exercises'] as int,
                            duration: workout['duration'] as int,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
