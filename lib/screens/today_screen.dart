import 'package:flutter/material.dart';
import 'exercise_logging_modal.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({Key? key}) : super(key: key);

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  static const Color primaryBlue = Color(0xFF3B5BDB);
  static const Color lightBlue = Color(0xFF6B8DD6);
  static const Color successGreen = Color(0xFF10B981);
  static const Color textGray = Color(0xFF6B7280);

  bool _workoutStarted = false;
  final Set<int> _completedExercises = {};

  String _currentWorkoutType = 'Push';

  final Map<String, List<Map<String, String>>> _workoutExercises = {
    'Push': [
      {'name': 'Bench Press', 'sets': '4', 'reps': '8'},
      {'name': 'Incline Dumbbell Press', 'sets': '3', 'reps': '10'},
      {'name': 'Overhead Press', 'sets': '3', 'reps': '8'},
      {'name': 'Lateral Raises', 'sets': '3', 'reps': '12'},
      {'name': 'Tricep Pushdowns', 'sets': '3', 'reps': '12'},
      {'name': 'Overhead Tricep Extension', 'sets': '3', 'reps': '10'},
    ],
    'Pull': [
      {'name': 'Deadlift', 'sets': '4', 'reps': '5'},
      {'name': 'Barbell Rows', 'sets': '4', 'reps': '8'},
      {'name': 'Lat Pulldowns', 'sets': '3', 'reps': '10'},
      {'name': 'Face Pulls', 'sets': '3', 'reps': '15'},
      {'name': 'Barbell Curls', 'sets': '3', 'reps': '10'},
      {'name': 'Hammer Curls', 'sets': '3', 'reps': '12'},
    ],
    'Legs': [
      {'name': 'Squats', 'sets': '4', 'reps': '6'},
      {'name': 'Romanian Deadlift', 'sets': '3', 'reps': '10'},
      {'name': 'Leg Press', 'sets': '3', 'reps': '12'},
      {'name': 'Leg Curls', 'sets': '3', 'reps': '12'},
      {'name': 'Calf Raises', 'sets': '4', 'reps': '15'},
      {'name': 'Leg Extensions', 'sets': '3', 'reps': '12'},
    ],
  };

  final Map<String, String> _workoutMuscles = {
    'Push': 'Chest, Shoulders, Triceps',
    'Pull': 'Back, Biceps, Rear Delts',
    'Legs': 'Quads, Hamstrings, Glutes, Calves',
  };

  final Map<String, Color> _workoutColors = {
    'Push': primaryBlue,
    'Pull': const Color(0xFF10B981),
    'Legs': const Color(0xFFF59E0B),
  };

  List<Map<String, String>> get _exercises => _workoutExercises[_currentWorkoutType]!;

  void _showAlternativeWorkouts() {
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
            const Text(
              'Choose Workout Type',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select an alternative workout for today',
              style: TextStyle(color: textGray),
            ),
            const SizedBox(height: 20),
            ...['Push', 'Pull', 'Legs'].map((type) => _buildWorkoutOption(type)),
            const SizedBox(height: 12),
            _buildRestDayOption(),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutOption(String type) {
    final isSelected = _currentWorkoutType == type;
    final color = _workoutColors[type]!;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? color.withValues(alpha: 0.1) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: isSelected ? Border.all(color: color, width: 2) : null,
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.fitness_center, color: color, size: 20),
        ),
        title: Text('$type Day', style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(_workoutMuscles[type]!, style: const TextStyle(fontSize: 12)),
        trailing: isSelected
          ? Icon(Icons.check_circle, color: color)
          : const Icon(Icons.chevron_right, color: textGray),
        onTap: () {
          setState(() {
            _currentWorkoutType = type;
            _completedExercises.clear();
            _workoutStarted = false;
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Switched to $type Day'),
              backgroundColor: color,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRestDayOption() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: textGray.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.bed, color: textGray, size: 20),
        ),
        title: const Text('Rest Day', style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: const Text('Take a recovery day', style: TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: textGray),
        onTap: () {
          Navigator.pop(context);
          _logRestDay();
        },
      ),
    );
  }

  void _logRestDay() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.bed, color: textGray),
            SizedBox(width: 8),
            Text('Log Rest Day'),
          ],
        ),
        content: const Text('Rest days are important for recovery. Your streak will be maintained!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Rest day logged! Streak maintained 🔥'),
                  backgroundColor: successGreen,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: const Text('Log Rest Day'),
          ),
        ],
      ),
    );
  }

  void _showExternalActivityModal() {
    String selectedActivity = 'Running';
    int duration = 30;
    String intensity = 'Moderate';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
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
              const Text(
                'Log External Activity',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Activities affect muscle recovery',
                style: TextStyle(color: textGray),
              ),
              const SizedBox(height: 20),
              const Text('Activity Type', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['Running', 'Cycling', 'Swimming', 'Walking', 'HIIT', 'Sports'].map((activity) {
                  final isSelected = selectedActivity == activity;
                  return ChoiceChip(
                    label: Text(activity),
                    selected: isSelected,
                    onSelected: (selected) => setModalState(() => selectedActivity = activity),
                    backgroundColor: Colors.white,
                    selectedColor: primaryBlue,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : textGray,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Text('Duration (minutes)', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    onPressed: () => setModalState(() => duration = duration > 5 ? duration - 5 : 5),
                    icon: const Icon(Icons.remove_circle_outline, color: primaryBlue),
                  ),
                  Expanded(
                    child: Slider(
                      value: duration.toDouble(),
                      min: 5,
                      max: 120,
                      divisions: 23,
                      activeColor: primaryBlue,
                      label: '$duration min',
                      onChanged: (value) => setModalState(() => duration = value.toInt()),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setModalState(() => duration = duration < 120 ? duration + 5 : 120),
                    icon: const Icon(Icons.add_circle_outline, color: primaryBlue),
                  ),
                ],
              ),
              Center(child: Text('$duration minutes', style: const TextStyle(fontWeight: FontWeight.bold))),
              const SizedBox(height: 20),
              const Text('Intensity', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: ['Light', 'Moderate', 'Intense'].map((level) {
                  final isSelected = intensity == level;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(level),
                        selected: isSelected,
                        onSelected: (selected) => setModalState(() => intensity = level),
                        backgroundColor: Colors.white,
                        selectedColor: primaryBlue,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : textGray,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Logged $duration min $intensity $selectedActivity'),
                        backgroundColor: primaryBlue,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  child: const Text('Log Activity'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startWorkout() {
    setState(() {
      _workoutStarted = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Workout started! Tap exercises to log them.'),
        backgroundColor: primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _openExerciseModal(int index) {
    if (!_workoutStarted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Start your workout first!'),
          backgroundColor: textGray,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ExerciseLoggingModal(
          exerciseName: _exercises[index]['name']!,
          onComplete: () {
            setState(() {
              _completedExercises.add(index);
            });
          },
        ),
      ),
    );
  }

  void _finishWorkout() {
    if (_completedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Log at least one exercise first!'),
          backgroundColor: textGray,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.celebration, color: successGreen),
            const SizedBox(width: 8),
            const Text('Workout Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryRow('Exercises', '${_completedExercises.length}/${_exercises.length}'),
            _buildSummaryRow('Muscles', 'Chest, Shoulders, Triceps'),
            _buildSummaryRow('Est. Volume', '2,450 kg'),
            const Divider(),
            _buildSummaryRow('XP Earned', '+150 XP', highlight: true),
            _buildSummaryRow('Streak', '11 days 🔥', highlight: true),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _workoutStarted = false;
                _completedExercises.clear();
              });
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: textGray)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: highlight ? primaryBlue : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: _showAlternativeWorkouts,
            tooltip: 'Alternative workout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Workout type with gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _workoutColors[_currentWorkoutType]!,
                    _workoutColors[_currentWorkoutType]!.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$_currentWorkoutType Day',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (_workoutStarted)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: successGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'In Progress',
                                style: TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _workoutMuscles[_currentWorkoutType]!,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _workoutStarted
                      ? '${_completedExercises.length}/${_exercises.length} exercises done'
                      : 'Est. 60 minutes',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  if (!_workoutStarted)
                    ElevatedButton(
                      onPressed: _startWorkout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: primaryBlue,
                      ),
                      child: const Text('Start Workout'),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _finishWorkout,
                            icon: const Icon(Icons.check_circle, size: 18),
                            label: const Text('Finish'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: successGreen,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _workoutStarted = false;
                              _completedExercises.clear();
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _workoutStarted ? 'Tap to log exercises' : 'Exercises',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // Exercise list
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _exercises.length,
              itemBuilder: (context, index) {
                final exercise = _exercises[index];
                final isCompleted = _completedExercises.contains(index);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: isCompleted
                      ? Border.all(color: successGreen, width: 2)
                      : null,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isCompleted
                          ? successGreen.withValues(alpha: 0.15)
                          : primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isCompleted ? Icons.check : Icons.fitness_center,
                        color: isCompleted ? successGreen : primaryBlue,
                      ),
                    ),
                    title: Text(
                      exercise['name']!,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted ? textGray : null,
                      ),
                    ),
                    subtitle: Text('${exercise['sets']} sets × ${exercise['reps']} reps'),
                    trailing: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isCompleted ? successGreen : primaryBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isCompleted ? Icons.check : Icons.arrow_forward,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    onTap: isCompleted ? null : () => _openExerciseModal(index),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showExternalActivityModal,
        tooltip: 'Log External Activity',
        child: const Icon(Icons.directions_run),
      ),
    );
  }
}
