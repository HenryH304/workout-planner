import 'package:flutter/material.dart';
import '../models/custom_exercise.dart';
import '../models/muscle_group.dart';
import '../models/workout_type.dart';

/// Pure validation and builder logic, extracted for testability.
class CustomExerciseFormHelper {
  static const int maxNameLength = 50;

  static const List<String> equipmentOptions = [
    'barbells',
    'dumbbells',
    'cables',
    'machines',
    'bodyweight',
    'kettlebells',
  ];

  static const List<WorkoutType> categoryOptions = [
    WorkoutType.push,
    WorkoutType.pull,
    WorkoutType.legs,
    WorkoutType.cardio,
    WorkoutType.core,
  ];

  static String? validateName(String name, List<String> existingNames) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'Name is required';
    if (trimmed.length > maxNameLength) {
      return 'Name must be $maxNameLength characters or less';
    }
    final nameLower = trimmed.toLowerCase();
    if (existingNames.any((n) => n.toLowerCase() == nameLower)) {
      return 'A custom exercise with this name already exists';
    }
    return null;
  }

  static String? validatePrimaryMuscles(List<String> muscles) {
    if (muscles.isEmpty) return 'At least one primary muscle group is required';
    return null;
  }

  static String? validateCategory(WorkoutType? category) {
    if (category == null) return 'Category is required';
    return null;
  }

  static bool isFormValid({
    required String name,
    required List<String> primaryMuscles,
    required WorkoutType? category,
    required List<String> existingNames,
  }) {
    return validateName(name, existingNames) == null &&
        validatePrimaryMuscles(primaryMuscles) == null &&
        validateCategory(category) == null;
  }

  static CustomExercise buildExercise({
    required String name,
    required List<String> primaryMuscles,
    required List<String> secondaryMuscles,
    required String equipment,
    required WorkoutType category,
    required String notes,
  }) {
    return CustomExercise(
      id: '',
      name: name.trim(),
      primaryMuscles: primaryMuscles,
      secondaryMuscles: secondaryMuscles,
      equipment: equipment,
      category: category,
      notes: notes.trim(),
      createdAt: DateTime.now(),
    );
  }
}

/// A form modal for creating (or editing) a custom exercise.
class CustomExerciseFormModal extends StatefulWidget {
  final List<String> existingNames;
  final ValueChanged<CustomExercise> onSave;
  final CustomExercise? initialExercise;

  const CustomExerciseFormModal({
    super.key,
    required this.existingNames,
    required this.onSave,
    this.initialExercise,
  });

  @override
  State<CustomExerciseFormModal> createState() =>
      _CustomExerciseFormModalState();
}

class _CustomExerciseFormModalState extends State<CustomExerciseFormModal> {
  static const Color primaryBlue = Color(0xFF3B5BDB);
  static const Color textGray = Color(0xFF6B7280);
  static const Color errorRed = Color(0xFFEF4444);

  late final TextEditingController _nameController;
  late final TextEditingController _notesController;
  final List<String> _primaryMuscles = [];
  final List<String> _secondaryMuscles = [];
  String _equipment = '';
  WorkoutType? _category;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialExercise;
    _nameController = TextEditingController(text: initial?.name ?? '');
    _notesController = TextEditingController(text: initial?.notes ?? '');
    if (initial != null) {
      _primaryMuscles.addAll(initial.primaryMuscles);
      _secondaryMuscles.addAll(initial.secondaryMuscles);
      _equipment = initial.equipment;
      _category = initial.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String? get _nameError => _submitted
      ? CustomExerciseFormHelper.validateName(
          _nameController.text, widget.existingNames)
      : null;

  String? get _primaryMusclesError => _submitted
      ? CustomExerciseFormHelper.validatePrimaryMuscles(_primaryMuscles)
      : null;

  String? get _categoryError =>
      _submitted ? CustomExerciseFormHelper.validateCategory(_category) : null;

  bool get _canSave => CustomExerciseFormHelper.isFormValid(
        name: _nameController.text,
        primaryMuscles: _primaryMuscles,
        category: _category,
        existingNames: widget.existingNames,
      );

  void _handleSave() {
    setState(() => _submitted = true);

    if (!_canSave) return;

    final exercise = CustomExerciseFormHelper.buildExercise(
      name: _nameController.text,
      primaryMuscles: List.of(_primaryMuscles),
      secondaryMuscles: List.of(_secondaryMuscles),
      equipment: _equipment,
      category: _category!,
      notes: _notesController.text,
    );

    widget.onSave(exercise);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
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
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Create Custom Exercise',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: textGray),
                ),
              ],
            ),
          ),
          const Divider(),
          // Form body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name field
                  _buildLabel('Name', required: true),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _nameController,
                    maxLength: CustomExerciseFormHelper.maxNameLength,
                    decoration: InputDecoration(
                      hintText: 'e.g. Cable Lateral Raise',
                      errorText: _nameError,
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: errorRed),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),

                  // Primary muscle groups
                  _buildLabel('Primary Muscle Groups', required: true),
                  if (_primaryMusclesError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _primaryMusclesError!,
                        style: const TextStyle(color: errorRed, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 6),
                  _buildMuscleChips(
                    selected: _primaryMuscles,
                    onToggle: (muscle) {
                      setState(() {
                        if (_primaryMuscles.contains(muscle)) {
                          _primaryMuscles.remove(muscle);
                        } else {
                          _primaryMuscles.add(muscle);
                          _secondaryMuscles.remove(muscle);
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Secondary muscle groups
                  _buildLabel('Secondary Muscle Groups'),
                  const SizedBox(height: 6),
                  _buildMuscleChips(
                    selected: _secondaryMuscles,
                    disabled: _primaryMuscles,
                    onToggle: (muscle) {
                      setState(() {
                        if (_secondaryMuscles.contains(muscle)) {
                          _secondaryMuscles.remove(muscle);
                        } else {
                          _secondaryMuscles.add(muscle);
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Equipment
                  _buildLabel('Equipment'),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        CustomExerciseFormHelper.equipmentOptions.map((eq) {
                      final isSelected = _equipment == eq;
                      return ChoiceChip(
                        label: Text(_capitalize(eq)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _equipment = selected ? eq : '';
                          });
                        },
                        selectedColor: primaryBlue,
                        backgroundColor: Colors.grey[100],
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : textGray,
                          fontSize: 13,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Category
                  _buildLabel('Category', required: true),
                  if (_categoryError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _categoryError!,
                        style: const TextStyle(color: errorRed, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: CustomExerciseFormHelper.categoryOptions.map((cat) {
                      final isSelected = _category == cat;
                      final label = _categoryDisplayName(cat);
                      return ChoiceChip(
                        label: Text(label),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _category = selected ? cat : null;
                          });
                        },
                        selectedColor: primaryBlue,
                        backgroundColor: Colors.grey[100],
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : textGray,
                          fontSize: 13,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Notes
                  _buildLabel('Notes'),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Any tips or notes about this exercise...',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _handleSave,
                      icon: const Icon(Icons.check, size: 20),
                      label: const Text('Save Exercise'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        if (required)
          const Text(' *', style: TextStyle(color: errorRed, fontSize: 14)),
      ],
    );
  }

  Widget _buildMuscleChips({
    required List<String> selected,
    List<String> disabled = const [],
    required ValueChanged<String> onToggle,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: MuscleGroup.values.map((mg) {
        final name = mg.name;
        final displayName = mg.displayName;
        final isSelected = selected.contains(name);
        final isDisabled = disabled.contains(name);
        return FilterChip(
          label: Text(displayName),
          selected: isSelected,
          onSelected: isDisabled ? null : (_) => onToggle(name),
          selectedColor: primaryBlue.withValues(alpha: 0.2),
          backgroundColor: isDisabled ? Colors.grey[200] : Colors.grey[100],
          checkmarkColor: primaryBlue,
          labelStyle: TextStyle(
            color: isDisabled
                ? Colors.grey[400]
                : isSelected
                    ? primaryBlue
                    : textGray,
            fontSize: 13,
          ),
        );
      }).toList(),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

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
