import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../models/workout_type.dart';

/// Helper class with pure logic for filtering and grouping exercises.
/// Extracted for testability.
class ExercisePickerHelper {
  /// Filters exercises by search query and exclusion list.
  static List<Exercise> filterExercises(
    List<Exercise> exercises,
    String query, {
    required Set<String> excludeIds,
  }) {
    return exercises.where((exercise) {
      if (excludeIds.contains(exercise.id)) return false;
      if (query.isEmpty) return true;
      return exercise.name.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  /// Groups exercises by their category display name.
  static Map<String, List<Exercise>> groupByCategory(
      List<Exercise> exercises) {
    final Map<String, List<Exercise>> grouped = {};
    for (final exercise in exercises) {
      final categoryName = getCategoryDisplayName(exercise.category);
      grouped.putIfAbsent(categoryName, () => []);
      grouped[categoryName]!.add(exercise);
    }
    return grouped;
  }

  /// Filters exercises whose primaryMuscles overlap with the given muscle groups.
  /// Returns all exercises if muscleGroups is empty.
  static List<Exercise> filterByMuscleGroups(
    List<Exercise> exercises,
    List<String> muscleGroups,
  ) {
    if (muscleGroups.isEmpty) return exercises;
    final muscleSet = muscleGroups.map((m) => m.toLowerCase()).toSet();
    return exercises.where((exercise) {
      return exercise.primaryMuscles
          .any((m) => muscleSet.contains(m.toLowerCase()));
    }).toList();
  }

  /// Maps WorkoutType to a short display name for picker categories.
  static String getCategoryDisplayName(WorkoutType type) {
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
        return 'Rest';
    }
  }
}

/// A bottom sheet exercise picker that lets users search, browse by category,
/// and select an exercise.
class ExercisePicker extends StatefulWidget {
  final List<Exercise> exercises;
  final Set<String> excludeIds;
  final ValueChanged<Exercise> onSelected;
  final List<String> initialMuscleFilter;

  const ExercisePicker({
    super.key,
    required this.exercises,
    this.excludeIds = const {},
    required this.onSelected,
    this.initialMuscleFilter = const [],
  });

  /// Shows the picker as a modal bottom sheet and returns the selected exercise.
  static Future<Exercise?> show(
    BuildContext context, {
    required List<Exercise> exercises,
    Set<String> excludeIds = const {},
    List<String> initialMuscleFilter = const [],
  }) {
    return showModalBottomSheet<Exercise>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExercisePicker(
        exercises: exercises,
        excludeIds: excludeIds,
        initialMuscleFilter: initialMuscleFilter,
        onSelected: (exercise) => Navigator.of(context).pop(exercise),
      ),
    );
  }

  @override
  State<ExercisePicker> createState() => _ExercisePickerState();
}

class _ExercisePickerState extends State<ExercisePicker> {
  static const Color primaryBlue = Color(0xFF3B5BDB);
  static const Color textGray = Color(0xFF6B7280);

  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  late List<String> _muscleFilter;

  @override
  void initState() {
    super.initState();
    _muscleFilter = List.of(widget.initialMuscleFilter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Exercise> get _filteredExercises {
    final muscleFiltered = ExercisePickerHelper.filterByMuscleGroups(
      widget.exercises,
      _muscleFilter,
    );
    return ExercisePickerHelper.filterExercises(
      muscleFiltered,
      _query,
      excludeIds: widget.excludeIds,
    );
  }

  Map<String, List<Exercise>> get _groupedExercises =>
      ExercisePickerHelper.groupByCategory(_filteredExercises);

  // Consistent category ordering
  static const _categoryOrder = ['Push', 'Pull', 'Legs', 'Core', 'Cardio', 'Custom', 'Rest'];

  List<String> get _sortedCategories {
    final keys = _groupedExercises.keys.toSet();
    return _categoryOrder.where(keys.contains).toList();
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Push':
        return Icons.fitness_center;
      case 'Pull':
        return Icons.back_hand;
      case 'Legs':
        return Icons.directions_walk;
      case 'Cardio':
        return Icons.directions_run;
      case 'Core':
        return Icons.accessibility_new;
      case 'Custom':
        return Icons.star;
      default:
        return Icons.fitness_center;
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Push':
        return const Color(0xFF3B5BDB);
      case 'Pull':
        return const Color(0xFF10B981);
      case 'Legs':
        return const Color(0xFFF59E0B);
      case 'Cardio':
        return const Color(0xFFEF4444);
      case 'Core':
        return const Color(0xFF8B5CF6);
      case 'Custom':
        return const Color(0xFFF97316);
      default:
        return textGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          // Title
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Text(
              'Choose Exercise',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: const Icon(Icons.search, color: textGray),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: textGray),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          // Muscle filter chip (shown when initialMuscleFilter is set)
          if (widget.initialMuscleFilter.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  FilterChip(
                    label: Text(
                      _muscleFilter.isNotEmpty
                          ? 'Filtered: ${_muscleFilter.join(", ")}'
                          : 'All exercises',
                    ),
                    selected: _muscleFilter.isNotEmpty,
                    onSelected: (selected) {
                      setState(() {
                        _muscleFilter = selected
                            ? List.of(widget.initialMuscleFilter)
                            : [];
                      });
                    },
                    selectedColor: primaryBlue.withValues(alpha: 0.15),
                    checkmarkColor: primaryBlue,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: _muscleFilter.isNotEmpty ? primaryBlue : textGray,
                    ),
                  ),
                  if (_muscleFilter.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() => _muscleFilter = []),
                      child: Text(
                        'Show all',
                        style: TextStyle(
                          fontSize: 12,
                          color: primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          // Exercise list grouped by category
          Expanded(
            child: _filteredExercises.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 8),
                        Text(
                          'No exercises found',
                          style: TextStyle(color: textGray, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _buildListItems().length,
                    itemBuilder: (context, index) => _buildListItems()[index],
                  ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildListItems() {
    final items = <Widget>[];
    for (final category in _sortedCategories) {
      final exercises = _groupedExercises[category]!;
      final color = _categoryColor(category);

      // Category header
      items.add(
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Row(
            children: [
              Icon(_categoryIcon(category), size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                category,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${exercises.length})',
                style: TextStyle(fontSize: 12, color: textGray),
              ),
            ],
          ),
        ),
      );

      // Exercise items in this category
      for (final exercise in exercises) {
        items.add(
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              dense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              title: Text(
                exercise.name,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              subtitle: Text(
                exercise.primaryMuscles.join(', '),
                style: const TextStyle(fontSize: 12, color: textGray),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  exercise.equipment,
                  style: const TextStyle(
                    fontSize: 11,
                    color: primaryBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              onTap: () => widget.onSelected(exercise),
            ),
          ),
        );
      }
    }
    return items;
  }
}
