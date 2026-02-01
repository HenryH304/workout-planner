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
  static const Color primaryBlue = Color(0xFF3B5BDB);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGray = Color(0xFF6B7280);

  int _sets = 3;
  int _reps = 8;
  double _weight = 60.0;
  int _rpe = 7;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
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
          // Exercise name
          Text(
            widget.exerciseName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 24),
          // Input fields
          Row(
            children: [
              Expanded(child: _buildNumberInput('Sets', _sets, (v) => setState(() => _sets = v))),
              const SizedBox(width: 12),
              Expanded(child: _buildNumberInput('Reps', _reps, (v) => setState(() => _reps = v))),
              const SizedBox(width: 12),
              Expanded(child: _buildWeightInput()),
            ],
          ),
          const SizedBox(height: 24),
          // RPE Slider
          Text(
            'RPE (Rate of Perceived Exertion)',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: textDark,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('1', style: TextStyle(color: textGray)),
              Expanded(
                child: Slider(
                  value: _rpe.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  activeColor: primaryBlue,
                  label: _rpe.toString(),
                  onChanged: (value) => setState(() => _rpe = value.toInt()),
                ),
              ),
              const Text('10', style: TextStyle(color: textGray)),
            ],
          ),
          Center(
            child: Text(
              _getRpeDescription(_rpe),
              style: TextStyle(color: textGray, fontSize: 12),
            ),
          ),
          const SizedBox(height: 24),
          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onComplete();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Complete Exercise'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildNumberInput(String label, int value, Function(int) onChanged) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: textGray, fontSize: 12)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => onChanged(value > 1 ? value - 1 : 1),
                child: const Icon(Icons.remove_circle_outline, color: primaryBlue, size: 20),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => onChanged(value + 1),
                child: const Icon(Icons.add_circle_outline, color: primaryBlue, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeightInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text('Weight', style: TextStyle(color: textGray, fontSize: 12)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => setState(() => _weight = _weight > 2.5 ? _weight - 2.5 : 0),
                child: const Icon(Icons.remove_circle_outline, color: primaryBlue, size: 20),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '${_weight.toStringAsFixed(1)}kg',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _weight += 2.5),
                child: const Icon(Icons.add_circle_outline, color: primaryBlue, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getRpeDescription(int rpe) {
    switch (rpe) {
      case 1:
      case 2:
        return 'Very light - Could do many more reps';
      case 3:
      case 4:
        return 'Light - Comfortable pace';
      case 5:
      case 6:
        return 'Moderate - Starting to feel it';
      case 7:
      case 8:
        return 'Hard - Could do 2-3 more reps';
      case 9:
        return 'Very hard - Could do 1 more rep';
      case 10:
        return 'Maximum effort - Could not do another rep';
      default:
        return '';
    }
  }
}
