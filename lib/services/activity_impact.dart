enum ActivityType {
  running,
  cycling,
  swimming,
  walking,
  hiit,
  sports,
}

// Intensity multipliers
const double INTENSITY_LIGHT = 0.5;
const double INTENSITY_MODERATE = 1.0;
const double INTENSITY_INTENSE = 1.5;

// Activity type impact on muscle groups (base fatigue score, 0-100)
final Map<ActivityType, Map<String, double>> ACTIVITY_IMPACT_MAP = {
  ActivityType.running: {
    'quads': 80,
    'hamstrings': 75,
    'calves': 70,
    'glutes': 75,
    'core': 30,
  },
  ActivityType.cycling: {
    'quads': 65,
    'hamstrings': 55,
    'glutes': 50,
    'core': 25,
  },
  ActivityType.swimming: {
    'chest': 50,
    'back': 55,
    'shoulders': 60,
    'biceps': 40,
    'triceps': 45,
    'core': 50,
    'quads': 40,
    'glutes': 40,
  },
  ActivityType.walking: {
    'quads': 20,
    'hamstrings': 15,
    'glutes': 20,
    'calves': 15,
  },
  ActivityType.hiit: {
    'quads': 70,
    'hamstrings': 65,
    'glutes': 70,
    'core': 60,
    'shoulders': 40,
    'chest': 35,
    'back': 35,
  },
  ActivityType.sports: {
    'quads': 60,
    'hamstrings': 55,
    'glutes': 60,
    'shoulders': 50,
    'core': 45,
    'back': 45,
  },
};

extension ActivityTypeExtension on ActivityType {
  String get displayName {
    switch (this) {
      case ActivityType.running:
        return 'Running';
      case ActivityType.cycling:
        return 'Cycling';
      case ActivityType.swimming:
        return 'Swimming';
      case ActivityType.walking:
        return 'Walking';
      case ActivityType.hiit:
        return 'HIIT';
      case ActivityType.sports:
        return 'Sports';
    }
  }
}

/// Gets muscle impacts for an activity at specified intensity
Map<String, double> getActivityImpact(
  ActivityType activity,
  double intensityMultiplier,
) {
  final baseImpact = ACTIVITY_IMPACT_MAP[activity] ?? {};
  return baseImpact.map(
    (muscle, impact) => MapEntry(
      muscle,
      (impact * intensityMultiplier).clamp(0, 100),
    ),
  );
}

/// Gets intensity multiplier from intensity level
double getIntensityMultiplier(String intensity) {
  switch (intensity.toLowerCase()) {
    case 'light':
      return INTENSITY_LIGHT;
    case 'moderate':
      return INTENSITY_MODERATE;
    case 'intense':
      return INTENSITY_INTENSE;
    default:
      return INTENSITY_MODERATE;
  }
}
