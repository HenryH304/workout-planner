# Workout Planner

A smart workout planning app with muscle recovery tracking, dynamic recommendations, and gamification.

## Features

### 🏋️ Smart Workout Recommendations
- **Muscle recovery tracking** — Tracks fatigue levels for each muscle group
- **Dynamic workout suggestions** — Recommends exercises based on which muscles are recovered
- **7-day forecast** — See your optimal workout schedule for the week ahead

### 📊 Progress Tracking
- **Workout history** — Log and review past workouts
- **Personal records** — Track PRs for each exercise
- **Statistics dashboard** — Visualize your progress over time

### 🎮 Gamification
- **XP & leveling system** — Earn experience for completing workouts
- **Achievements** — Unlock badges for milestones
- **Streak tracking** — Maintain your workout streak with smart rest day handling

### 💪 Exercise Database
- **50+ exercises** covering all muscle groups
- **Equipment filtering** — Dumbbells, barbells, cables, machines, bodyweight, kettlebells
- **Category organization** — Push, pull, legs, core, cardio

## Tech Stack

- **Flutter** — Cross-platform mobile framework
- **Firebase** — Authentication & Firestore database
- **Riverpod** — State management
- **Hive** — Local offline storage
- **FL Chart** — Progress visualizations

## Getting Started

### Prerequisites

- Flutter SDK 3.0+
- Firebase project configured
- Android Studio / Xcode for device emulation

### Installation

```bash
# Clone the repository
git clone https://github.com/HenryH304/workout-planner.git
cd workout-planner

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Firebase Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable Authentication (Email/Password)
3. Create a Firestore database
4. Download and add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)

## Project Structure

```
lib/
├── models/          # Data models (User, Exercise, Workout, etc.)
├── services/        # Business logic & Firebase services
├── screens/         # UI screens
└── main.dart        # App entry point

assets/
└── exercises.json   # Exercise database

test/
└── unit/            # Unit tests
```

## Running Tests

```bash
flutter test
```

## License

MIT

## Contributing

Pull requests welcome. For major changes, please open an issue first.
