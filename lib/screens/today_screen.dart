import 'package:flutter/material.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () {},
            tooltip: 'Alternative workout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Workout type
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Push Day', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Chest, Shoulders, Triceps'),
                    Text('Est. 60 minutes'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Recommended Exercises', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            // Exercise list
            ListView.builder(
              shrinkWrap: true,
              itemCount: 6,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text('Exercise ${index + 1}'),
                    subtitle: const Text('3x8 @ 185 lbs'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {},
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Finish Workout'),
              onPressed: () {},
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Log Activity',
        child: const Icon(Icons.add),
      ),
    );
  }
}
