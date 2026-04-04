import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../models/workout_type.dart';
import '../providers/today_workout_notifier.dart';
import '../services/exercise_service.dart';
import '../widgets/exercise_picker.dart';
import 'exercise_logging_modal.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({Key? key}) : super(key: key);

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  static const Color primaryBlue = Color(0xFF3B5BDB);
  static const Color successGreen = Color(0xFF10B981);
  static const Color textGray = Color(0xFF6B7280);
  static const Color addedTagColor = Color(0xFF8B5CF6);

  bool _workoutStarted = false;
  final Set<String> _completedExerciseIds = {};
  final ExerciseService _exerciseService = ExerciseService();
  List<Exercise> _allExercises = [];

  String _currentWorkoutType = 'Push';
  late TodayWorkoutNotifier _notifier;

  final Map<String, List<Exercise>> _workoutExercises = {};

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

  @override
  void initState() {
    super.initState();
    _notifier = TodayWorkoutNotifier(userId: 'current-user');
    _initializeExercises();
  }

  Future<void> _initializeExercises() async {
    try {
      _allExercises = await _exerciseService.loadExercises();
    } catch (_) {
      // Fall back to built-in defaults if asset loading fails
      _allExercises = _defaultExercises();
    }

    _workoutExercises['Push'] = _allExercises
        .where((e) => e.category == WorkoutType.push)
        .take(6)
        .toList();
    _workoutExercises['Pull'] = _allExercises
        .where((e) => e.category == WorkoutType.pull)
        .take(6)
        .toList();
    _workoutExercises['Legs'] = _allExercises
        .where((e) => e.category == WorkoutType.legs)
        .take(6)
        .toList();

    // Fill defaults if exercise database is empty for a category
    if (_workoutExercises['Push']?.isEmpty ?? true) {
      _workoutExercises['Push'] = _defaultPushExercises();
    }
    if (_workoutExercises['Pull']?.isEmpty ?? true) {
      _workoutExercises['Pull'] = _defaultPullExercises();
    }
    if (_workoutExercises['Legs']?.isEmpty ?? true) {
      _workoutExercises['Legs'] = _defaultLegExercises();
    }

    if (_allExercises.isEmpty) {
      _allExercises = [
        ..._workoutExercises['Push']!,
        ..._workoutExercises['Pull']!,
        ..._workoutExercises['Legs']!,
      ];
    }

    _initializeNotifier();

    if (mounted) {
      setState(() {});
    }
  }

  void _initializeNotifier() {
    final recommended = _workoutExercises[_currentWorkoutType] ?? [];
    _notifier.initializePlan(
      workoutId: 'workout-${DateTime.now().toIso8601String().substring(0, 10)}',
      recommendedExercises: recommended,
    );
  }

  List<Exercise> get _currentExercises =>
      _notifier.currentState.currentExercises;

  bool _isUserAdded(String exerciseId) =>
      _notifier.currentState.edits.added.contains(exerciseId);

  void _removeExercise(Exercise exercise, int index) {
    final isLogged = _completedExerciseIds.contains(exercise.id);

    if (isLogged) {
      _showLoggedRemoveConfirmation(exercise, index);
    } else {
      _performRemove(exercise, index);
    }
  }

  void _showLoggedRemoveConfirmation(Exercise exercise, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Logged Exercise?'),
        content: Text(
          'This exercise has been logged. Remove ${exercise.name} and its log?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performRemove(exercise, index);
              _completedExerciseIds.remove(exercise.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _performRemove(Exercise exercise, int index) {
    setState(() {
      _notifier.removeExercise(exercise.id);
    });
    _notifier.persistEdits();

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${exercise.name} removed.'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _notifier.undoRemove(exercise.id, index, exercise);
            });
            _notifier.persistEdits();
          },
        ),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  List<Exercise> _defaultExercises() => [
        ..._defaultPushExercises(),
        ..._defaultPullExercises(),
        ..._defaultLegExercises(),
      ];

  List<Exercise> _defaultPushExercises() => const [
        Exercise(id: 'bench-press', name: 'Bench Press', primaryMuscles: ['chest'], secondaryMuscles: ['triceps', 'shoulders'], equipment: 'barbell', category: WorkoutType.push),
        Exercise(id: 'incline-db-press', name: 'Incline Dumbbell Press', primaryMuscles: ['chest'], secondaryMuscles: ['shoulders', 'triceps'], equipment: 'dumbbells', category: WorkoutType.push),
        Exercise(id: 'overhead-press', name: 'Overhead Press', primaryMuscles: ['shoulders'], secondaryMuscles: ['triceps'], equipment: 'barbell', category: WorkoutType.push),
        Exercise(id: 'lateral-raises', name: 'Lateral Raises', primaryMuscles: ['shoulders'], secondaryMuscles: [], equipment: 'dumbbells', category: WorkoutType.push),
        Exercise(id: 'tricep-pushdowns', name: 'Tricep Pushdowns', primaryMuscles: ['triceps'], secondaryMuscles: [], equipment: 'cable', category: WorkoutType.push),
        Exercise(id: 'overhead-tricep-ext', name: 'Overhead Tricep Extension', primaryMuscles: ['triceps'], secondaryMuscles: [], equipment: 'dumbbells', category: WorkoutType.push),
      ];

  List<Exercise> _defaultPullExercises() => const [
        Exercise(id: 'deadlift', name: 'Deadlift', primaryMuscles: ['back', 'hamstrings'], secondaryMuscles: ['glutes'], equipment: 'barbell', category: WorkoutType.pull),
        Exercise(id: 'barbell-rows', name: 'Barbell Rows', primaryMuscles: ['back'], secondaryMuscles: ['biceps'], equipment: 'barbell', category: WorkoutType.pull),
        Exercise(id: 'lat-pulldowns', name: 'Lat Pulldowns', primaryMuscles: ['back'], secondaryMuscles: ['biceps'], equipment: 'cable', category: WorkoutType.pull),
        Exercise(id: 'face-pulls', name: 'Face Pulls', primaryMuscles: ['rear delts'], secondaryMuscles: ['traps'], equipment: 'cable', category: WorkoutType.pull),
        Exercise(id: 'barbell-curls', name: 'Barbell Curls', primaryMuscles: ['biceps'], secondaryMuscles: [], equipment: 'barbell', category: WorkoutType.pull),
        Exercise(id: 'hammer-curls', name: 'Hammer Curls', primaryMuscles: ['biceps'], secondaryMuscles: ['forearms'], equipment: 'dumbbells', category: WorkoutType.pull),
      ];

  List<Exercise> _defaultLegExercises() => const [
        Exercise(id: 'squats', name: 'Squats', primaryMuscles: ['quads', 'glutes'], secondaryMuscles: ['hamstrings'], equipment: 'barbell', category: WorkoutType.legs),
        Exercise(id: 'romanian-deadlift', name: 'Romanian Deadlift', primaryMuscles: ['hamstrings'], secondaryMuscles: ['glutes', 'back'], equipment: 'barbell', category: WorkoutType.legs),
        Exercise(id: 'leg-press', name: 'Leg Press', primaryMuscles: ['quads'], secondaryMuscles: ['glutes'], equipment: 'machine', category: WorkoutType.legs),
        Exercise(id: 'leg-curls', name: 'Leg Curls', primaryMuscles: ['hamstrings'], secondaryMuscles: [], equipment: 'machine', category: WorkoutType.legs),
        Exercise(id: 'calf-raises', name: 'Calf Raises', primaryMuscles: ['calves'], secondaryMuscles: [], equipment: 'machine', category: WorkoutType.legs),
        Exercise(id: 'leg-extensions', name: 'Leg Extensions', primaryMuscles: ['quads'], secondaryMuscles: [], equipment: 'machine', category: WorkoutType.legs),
      ];

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
            _completedExerciseIds.clear();
            _workoutStarted = false;
            _initializeNotifier();
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

  void _openExerciseModal(Exercise exercise) {
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
          exerciseName: exercise.name,
          onComplete: () {
            setState(() {
              _completedExerciseIds.add(exercise.id);
            });
          },
        ),
      ),
    );
  }

  Future<void> _openAddExercisePicker() async {
    final excludeIds =
        _currentExercises.map((e) => e.id).toSet();

    final selected = await ExercisePicker.show(
      context,
      exercises: _allExercises,
      excludeIds: excludeIds,
    );

    if (selected != null && mounted) {
      setState(() {
        _notifier.addExercise(selected);
      });
      _notifier.persistEdits();
    }
  }

  void _finishWorkout() {
    if (_completedExerciseIds.isEmpty) {
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
            _buildSummaryRow('Exercises', '${_completedExerciseIds.length}/${_currentExercises.length}'),
            _buildSummaryRow('Muscles', _workoutMuscles[_currentWorkoutType] ?? ''),
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
                _completedExerciseIds.clear();
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
    final exercises = _currentExercises;

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
                      ? '${_completedExerciseIds.length}/${exercises.length} exercises done'
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
                              _completedExerciseIds.clear();
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
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                final isCompleted = _completedExerciseIds.contains(exercise.id);
                final isAdded = _isUserAdded(exercise.id);

                return Dismissible(
                  key: ValueKey(exercise.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    if (isCompleted) {
                      _showLoggedRemoveConfirmation(exercise, index);
                      return false; // Dialog handles removal
                    }
                    return true;
                  },
                  onDismissed: (_) => _performRemove(exercise, index),
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: GestureDetector(
                    onLongPress: () => _removeExercise(exercise, index),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: isCompleted
                          ? Border.all(color: successGreen, width: 2)
                          : isAdded
                            ? Border.all(color: addedTagColor.withValues(alpha: 0.3), width: 1)
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
                              : isAdded
                                ? addedTagColor.withValues(alpha: 0.1)
                                : primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isCompleted ? Icons.check : Icons.fitness_center,
                            color: isCompleted
                              ? successGreen
                              : isAdded
                                ? addedTagColor
                                : primaryBlue,
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                exercise.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                                  color: isCompleted ? textGray : null,
                                ),
                              ),
                            ),
                            if (isAdded)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: addedTagColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Added by you',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: addedTagColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Text(
                          exercise.primaryMuscles.join(', '),
                          style: const TextStyle(fontSize: 12),
                        ),
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
                        onTap: isCompleted ? null : () => _openExerciseModal(exercise),
                      ),
                    ),
                  ),
                );
              },
            ),
            // Add Exercise button
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openAddExercisePicker,
                icon: const Icon(Icons.add_circle_outline, size: 20),
                label: const Text('Add Exercise'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryBlue,
                  side: BorderSide(color: primaryBlue.withValues(alpha: 0.3)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
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
