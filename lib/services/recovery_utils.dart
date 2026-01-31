// Recovery time constants (in hours)
const int SMALL_MUSCLE_RECOVERY_HOURS = 48;
const int MEDIUM_MUSCLE_RECOVERY_HOURS = 60;
const int LARGE_MUSCLE_RECOVERY_HOURS = 72;

const double RECOVERY_THRESHOLD = 0.85; // 85%

// Muscle size mappings
const List<String> SMALL_MUSCLES = ['biceps', 'triceps', 'calves'];
const List<String> MEDIUM_MUSCLES = ['shoulders', 'core'];
const List<String> LARGE_MUSCLES = [
  'chest',
  'back',
  'quads',
  'glutes',
  'hamstrings'
];

// Compound movement fatigue overlap map
// Maps exercise ID to map of muscle -> fatigue multiplier (0.0-1.0)
final Map<String, Map<String, double>> COMPOUND_OVERLAP_MAP = {
  'barbell-bench-press': {
    'triceps': 0.5,
    'shoulders': 0.3,
  },
  'incline-bench-press': {
    'triceps': 0.4,
    'shoulders': 0.4,
  },
  'overhead-press': {
    'triceps': 0.6,
    'chest': 0.2,
  },
  'barbell-squat': {
    'core': 0.3,
  },
  'barbell-deadlift': {
    'core': 0.4,
    'back': 0.3,
  },
  'barbell-row': {
    'biceps': 0.4,
  },
};

/// Gets the size category of a muscle
String getMuscleSize(String muscle) {
  if (SMALL_MUSCLES.contains(muscle)) {
    return 'small';
  } else if (MEDIUM_MUSCLES.contains(muscle)) {
    return 'medium';
  } else if (LARGE_MUSCLES.contains(muscle)) {
    return 'large';
  }
  return 'unknown';
}

/// Gets recovery hours for a muscle size
int getRecoveryHours(String muscleSize) {
  switch (muscleSize) {
    case 'small':
      return SMALL_MUSCLE_RECOVERY_HOURS;
    case 'medium':
      return MEDIUM_MUSCLE_RECOVERY_HOURS;
    case 'large':
      return LARGE_MUSCLE_RECOVERY_HOURS;
    default:
      return LARGE_MUSCLE_RECOVERY_HOURS;
  }
}

/// Calculates recovery percentage (0-100+)
/// Returns percentage of recovery since last worked
double calculateRecoveryPercentage(
  DateTime lastWorked,
  String muscleSize,
) {
  final now = DateTime.now();
  final hoursSinceWorked = now.difference(lastWorked).inHours;
  final recoveryHours = getRecoveryHours(muscleSize);

  final percentage = (hoursSinceWorked / recoveryHours) * 100;
  return percentage;
}

/// Checks if a muscle is recovered (>= 85%)
bool isRecovered(double recoveryPercentage) {
  return recoveryPercentage >= (RECOVERY_THRESHOLD * 100);
}

/// Gets the secondary fatigue multiplier for a muscle affected by a compound movement
double getCompoundOverlapMultiplier(String exerciseId, String muscleId) {
  return COMPOUND_OVERLAP_MAP[exerciseId]?[muscleId] ?? 0.0;
}
