enum WorkoutType {
  push,
  pull,
  legs,
  core,
  rest,
  cardio,
}

extension WorkoutTypeExtension on WorkoutType {
  String get displayName {
    switch (this) {
      case WorkoutType.push:
        return 'Push Day';
      case WorkoutType.pull:
        return 'Pull Day';
      case WorkoutType.legs:
        return 'Leg Day';
      case WorkoutType.core:
        return 'Core Day';
      case WorkoutType.rest:
        return 'Rest Day';
      case WorkoutType.cardio:
        return 'Cardio';
    }
  }

  int get estimatedDurationMinutes {
    switch (this) {
      case WorkoutType.push:
      case WorkoutType.pull:
      case WorkoutType.legs:
        return 60;
      case WorkoutType.core:
        return 30;
      case WorkoutType.cardio:
        return 45;
      case WorkoutType.rest:
        return 0;
    }
  }
}
