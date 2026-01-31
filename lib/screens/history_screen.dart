import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout History')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                children: const [
                  Chip(label: Text('All')),
                  Chip(label: Text('Push')),
                  Chip(label: Text('Pull')),
                  Chip(label: Text('Legs')),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: 10,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Workout ${index + 1}'),
                  subtitle: const Text('Total volume'),
                  trailing: const Icon(Icons.arrow_forward),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
