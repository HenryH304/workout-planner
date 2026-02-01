import 'package:flutter/material.dart';

class ForecastScreen extends StatelessWidget {
  const ForecastScreen({Key? key}) : super(key: key);

  static const Color primaryBlue = Color(0xFF3B5BDB);
  static const Color pullGreen = Color(0xFF10B981);
  static const Color legsOrange = Color(0xFFF59E0B);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGray = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    final days = ['Today', 'Tomorrow', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final workoutTypes = ['Push', 'Rest', 'Pull', 'Legs', 'Push', 'Pull', 'Rest'];
    final muscles = [
      'Chest, Shoulders, Triceps',
      'Recovery day',
      'Back, Biceps, Rear Delts',
      'Quads, Hamstrings, Glutes',
      'Chest, Shoulders, Triceps',
      'Back, Biceps, Rear Delts',
      'Recovery day',
    ];
    final reasons = [
      'Push muscles are fully recovered (96%)',
      'All muscle groups need recovery time',
      'Pull muscles recovered, 3 days since last pull workout',
      'Leg muscles at 92% recovery, due for leg day',
      'Push muscles will be fully recovered',
      'Maintaining pull frequency for balanced training',
      'Weekly rest day for optimal recovery',
    ];
    final colors = [
      primaryBlue,
      textGray,
      pullGreen,
      legsOrange,
      primaryBlue,
      pullGreen,
      textGray,
    ];

    void showDayDetails(int index) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: colors[index].withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      workoutTypes[index] == 'Rest' ? Icons.bed : Icons.fitness_center,
                      color: colors[index],
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${workoutTypes[index]} Day',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          days[index],
                          style: const TextStyle(color: textGray),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Target Muscles',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: textGray,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      muscles[index],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors[index].withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: colors[index], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Why this workout?',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: textGray,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            reasons[index],
                            style: TextStyle(
                              color: colors[index],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (index == 0)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigate to Today tab
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Switch to Today tab to start your workout'),
                          backgroundColor: primaryBlue,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                    child: const Text('Go to Today\'s Workout'),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('7-Day Forecast')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Week overview
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (index) {
                final isToday = index == 0;
                return GestureDetector(
                  onTap: () => showDayDetails(index),
                  child: Column(
                    children: [
                      Text(
                        days[index].substring(0, 3),
                        style: TextStyle(
                          color: isToday ? primaryBlue : textGray,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isToday ? primaryBlue : colors[index].withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: isToday ? null : Border.all(
                            color: colors[index].withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            workoutTypes[index][0],
                            style: TextStyle(
                              color: isToday ? Colors.white : colors[index],
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Upcoming Workouts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 7,
              itemBuilder: (context, index) {
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
                        color: colors[index].withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        workoutTypes[index] == 'Rest'
                            ? Icons.bed
                            : Icons.fitness_center,
                        color: colors[index],
                      ),
                    ),
                    title: Text(
                      '${workoutTypes[index]} Day',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${days[index]} • ${muscles[index]}',
                      style: const TextStyle(color: textGray, fontSize: 12),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: textGray,
                    ),
                    onTap: () => showDayDetails(index),
                  ),
                );
              },
            ),
          ),
          // Disclaimer
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: primaryBlue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Forecast updates based on your activity',
                    style: TextStyle(color: primaryBlue, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
