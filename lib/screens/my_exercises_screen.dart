import 'package:flutter/material.dart';
import '../models/custom_exercise.dart';
import '../models/workout_type.dart';
import '../services/custom_exercise_service.dart';
import '../widgets/custom_exercise_form_modal.dart';

class MyExercisesScreen extends StatefulWidget {
  final CustomExerciseService? customExerciseService;

  const MyExercisesScreen({Key? key, this.customExerciseService})
      : super(key: key);

  @override
  State<MyExercisesScreen> createState() => MyExercisesScreenState();
}

class MyExercisesScreenState extends State<MyExercisesScreen> {
  static const Color primaryBlue = Color(0xFF3B5BDB);
  static const Color textGray = Color(0xFF6B7280);
  static const Color textDark = Color(0xFF1A1A2E);

  CustomExerciseService get _customExerciseService =>
      widget.customExerciseService ?? CustomExerciseService();

  // TODO: Replace with actual user ID from AuthService
  String get _userId => 'demo-user';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Exercises'),
      ),
      body: StreamBuilder<List<CustomExercise>>(
        stream: _customExerciseService.getCustomExercises(_userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final exercises = snapshot.data ?? [];

          if (exercises.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: exercises.length,
            itemBuilder: (context, index) =>
                _buildExerciseCard(exercises[index], exercises),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'No custom exercises yet.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add one from the workout screen.',
              style: TextStyle(fontSize: 14, color: textGray),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(
      CustomExercise exercise, List<CustomExercise> allExercises) {
    final muscleText = exercise.primaryMuscles
        .map((m) => m[0].toUpperCase() + m.substring(1))
        .join(', ');
    final categoryName = _categoryDisplayName(exercise.category);

    return Dismissible(
      key: ValueKey(exercise.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(exercise);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () => _editExercise(exercise, allExercises),
        onLongPress: () => _showDeleteConfirmationAndRemove(exercise),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    const Icon(Icons.star, color: primaryBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$muscleText • $categoryName',
                      style: const TextStyle(
                        fontSize: 12,
                        color: textGray,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: textGray, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(CustomExercise exercise) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Exercise'),
        content: Text(
            'Delete ${exercise.name}? It will be removed from future selection.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _customExerciseService.deleteCustomExercise(
          _userId, exercise.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${exercise.name} deleted'),
            backgroundColor: textGray,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
      return true;
    }
    return false;
  }

  Future<void> _showDeleteConfirmationAndRemove(
      CustomExercise exercise) async {
    await _showDeleteConfirmation(exercise);
  }

  void _editExercise(
      CustomExercise exercise, List<CustomExercise> allExercises) {
    final otherNames = allExercises
        .where((e) => e.id != exercise.id)
        .map((e) => e.name)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomExerciseFormModal(
        existingNames: otherNames,
        initialExercise: exercise,
        onSave: (updated) async {
          Navigator.pop(context);
          await _customExerciseService.updateCustomExercise(
            _userId,
            exercise.id,
            updated.toJson(),
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${updated.name} updated'),
                backgroundColor: primaryBlue,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        },
      ),
    );
  }

  String _categoryDisplayName(WorkoutType type) {
    switch (type) {
      case WorkoutType.push:
        return 'Push';
      case WorkoutType.pull:
        return 'Pull';
      case WorkoutType.legs:
        return 'Legs';
      case WorkoutType.cardio:
        return 'Cardio';
      case WorkoutType.core:
        return 'Core';
      case WorkoutType.rest:
        return 'Other';
    }
  }
}
