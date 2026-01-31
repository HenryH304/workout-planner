import 'package:flutter/material.dart';

class WorkoutDetailScreen extends StatelessWidget {
  const WorkoutDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Details')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('Push Day - Jan 31, 2025', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text('Exercises:', style: TextStyle(fontWeight: FontWeight.bold)),
          ListTile(
            title: const Text('Bench Press'),
            subtitle: const Text('4x8 @ 185 lbs'),
          ),
          const SizedBox(height: 16),
          const Text('Total Volume: 5,920 lbs'),
          const Text('Duration: 58 minutes'),
          const Text('XP Earned: 150'),
        ],
      ),
    );
  }
}
