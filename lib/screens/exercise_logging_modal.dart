import 'package:flutter/material.dart';

class ExerciseLoggingModal extends StatefulWidget {
  final String exerciseName;
  final VoidCallback onComplete;

  const ExerciseLoggingModal({
    Key? key,
    required this.exerciseName,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<ExerciseLoggingModal> createState() => _ExerciseLoggingModalState();
}

class _ExerciseLoggingModalState extends State<ExerciseLoggingModal> {
  int _sets = 3;
  int _reps = 8;
  double _weight = 185.0;
  int _rpe = 7;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(widget.exerciseName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildInput('Sets', _sets.toString(), () {}),
            _buildInput('Reps', _reps.toString(), () {}),
            _buildInput('Weight (kg)', _weight.toString(), () {}),
            const SizedBox(height: 16),
            const Text('RPE: ', style: TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: _rpe.toDouble(),
              min: 1,
              max: 10,
              onChanged: (value) => setState(() => _rpe = value.toInt()),
            ),
            ElevatedButton(
              onPressed: () {
                widget.onComplete();
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, String value, VoidCallback onTap) {
    return ListTile(
      title: Text(label),
      trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      onTap: onTap,
    );
  }
}
