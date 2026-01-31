import 'package:flutter/material.dart';

class ForecastScreen extends StatelessWidget {
  const ForecastScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('7-Day Forecast')),
      body: ListView.builder(
        itemCount: 7,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Day ${index + 1}'),
            subtitle: const Text('Workout recommendation'),
            trailing: const Icon(Icons.info),
          );
        },
      ),
    );
  }
}
