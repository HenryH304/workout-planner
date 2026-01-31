# PRD: Workout Planner - Smart Muscle Rotation App

## Introduction

A mobile app that intelligently plans daily workouts based on muscle recovery science. The app tracks exercises you've completed, considers recovery windows for each muscle group, and dynamically adjusts recommendations to maximise muscle development. Includes gamification elements to drive consistency and progress.

**Target User:** Derrick, training daily at Llanishen Leisure Centre (Cardiff)

**Tech Stack:** Flutter + Firebase (Firestore for real-time sync)

## Goals

- Recommend optimal daily workout based on muscle recovery status
- Track completed exercises with sets, reps, weight, and RPE
- Account for non-gym activities (running, cycling) that impact muscle fatigue
- Provide 7-day workout forecast that dynamically adjusts
- Gamify progress with XP, levels, streaks, and achievements
- Work offline with cloud sync when connected
- Show exercises available at Llanishen Leisure Centre

## User Stories

### US-001: Project Setup & Firebase Configuration
**Description:** As a developer, I need the Flutter project scaffolded with Firebase integration so I have a foundation to build on.

**Acceptance Criteria:**
- [ ] Flutter project created with `flutter create workout_planner`
- [ ] Firebase project created and configured (Auth, Firestore)
- [ ] `firebase_core`, `firebase_auth`, `cloud_firestore` packages added
- [ ] Firebase initialized in `main.dart`
- [ ] Basic folder structure: `lib/models/`, `lib/services/`, `lib/screens/`, `lib/widgets/`
- [ ] App runs on emulator without errors
- [ ] Typecheck passes (`flutter analyze`)

### US-002: Data Models
**Description:** As a developer, I need Dart models for users, workouts, exercises, and muscle fatigue so data is structured consistently.

**Acceptance Criteria:**
- [ ] `UserProfile` model: id, name, level, xp, currentStreak, longestStreak, createdAt
- [ ] `Exercise` model: id, name, muscleGroups (primary/secondary), equipment, category (push/pull/legs)
- [ ] `WorkoutLog` model: id, date, exercises[], completed, notes
- [ ] `ExerciseSet` model: exerciseId, sets, reps, weight, rpe, timestamp
- [ ] `MuscleFatigue` model: muscle, lastWorked, fatigueScore, recoveryEta
- [ ] `Achievement` model: id, name, description, icon, unlockedAt
- [ ] All models have `toJson()` and `fromJson()` methods
- [ ] Typecheck passes

### US-003: Exercise Database with Llanishen Equipment
**Description:** As a user, I want to see exercises available at my gym so I can plan realistic workouts.

**Acceptance Criteria:**
- [ ] JSON file with 50+ exercises covering all muscle groups
- [ ] Each exercise tagged with: name, primary muscles, secondary muscles, equipment needed, category (push/pull/legs/cardio)
- [ ] Equipment filtered to Llanishen Leisure Centre availability (free weights, machines, cardio)
- [ ] Service to load and query exercises by muscle group or equipment
- [ ] Unit tests for exercise filtering
- [ ] Typecheck passes

### US-004: Authentication Screen
**Description:** As a user, I want to sign in so my workout data syncs across devices.

**Acceptance Criteria:**
- [ ] Login screen with email/password fields
- [ ] Sign up option for new users
- [ ] Google Sign-In button (optional but included)
- [ ] Error handling for invalid credentials
- [ ] Auto-navigate to home screen after successful auth
- [ ] Typecheck passes
- [ ] Verify login flow in emulator

### US-005: Muscle Recovery Calculation Service
**Description:** As a developer, I need a service that calculates muscle recovery status based on exercise history.

**Acceptance Criteria:**
- [ ] `calculateRecoveryStatus(userId)` returns recovery % for each muscle group
- [ ] Recovery formula: `recoveryPct = min(100, (hoursSinceWorked / recoveryHours) * 100)`
- [ ] Recovery hours by muscle: small=48, medium=60, large=72
- [ ] Considers compound movement overlap (bench press fatigues triceps too)
- [ ] Returns list of "ready" muscles (>= 85% recovered)
- [ ] Unit tests covering: fresh user (all ready), recent workout (some tired), edge cases
- [ ] Typecheck passes

### US-006: External Activity Impact Service
**Description:** As a user, I want to log non-gym activities so the app adjusts my workout recommendations.

**Acceptance Criteria:**
- [ ] `logExternalActivity(type, duration, intensity)` function
- [ ] Activity types: running, cycling, swimming, walking, HIIT, sports
- [ ] Each activity has predefined muscle impact map (e.g., running → high leg fatigue)
- [ ] Intensity multiplier: light (0.5), moderate (1.0), intense (1.5)
- [ ] Fatigue added to relevant muscle groups in Firestore
- [ ] Unit tests for fatigue calculation
- [ ] Typecheck passes

### US-007: Daily Workout Recommendation Engine
**Description:** As a user, I want to see what workout I should do today based on my recovery status.

**Acceptance Criteria:**
- [ ] `getRecommendedWorkout(userId)` returns top workout type (Push/Pull/Legs/Rest)
- [ ] Algorithm scores options by: recovery status, days since last trained, weekly volume deficit
- [ ] Returns "Rest Day" if no muscle groups are adequately recovered
- [ ] Returns top recommendation + 2 alternatives
- [ ] Considers yesterday's logged workout
- [ ] Unit tests covering: all muscles ready (pick least recent), some tired (skip those), all tired (rest day)
- [ ] Typecheck passes

### US-008: Today's Workout Screen
**Description:** As a user, I want to see my recommended workout for today with specific exercises.

**Acceptance Criteria:**
- [ ] Screen shows: workout type (e.g., "Push Day"), muscle groups targeted, estimated duration
- [ ] Lists 6-8 recommended exercises with sets/reps suggestions
- [ ] "Alternative" button shows other workout options
- [ ] "Log Activity" button for non-gym activities done today
- [ ] Pull-to-refresh recalculates recommendation
- [ ] Typecheck passes
- [ ] Verify screen renders correctly in emulator

### US-009: Exercise Logging UI
**Description:** As a user, I want to log each exercise I complete with sets, reps, and weight.

**Acceptance Criteria:**
- [ ] Tap exercise to open logging modal
- [ ] Input fields: sets completed, reps per set, weight used, RPE (1-10 slider)
- [ ] "Complete" button saves to Firestore and marks exercise done
- [ ] Visual checkmark on completed exercises
- [ ] Running total of volume (sets × reps × weight) shown
- [ ] Typecheck passes
- [ ] Verify logging flow in emulator

### US-010: Workout Completion & Fatigue Update
**Description:** As a user, when I finish my workout, the app should update my muscle fatigue status.

**Acceptance Criteria:**
- [ ] "Finish Workout" button on today's screen
- [ ] Calculates fatigue for each muscle worked based on volume and RPE
- [ ] Updates `muscle_fatigue` collection in Firestore
- [ ] Awards XP based on workout completion (base + volume bonus)
- [ ] Updates streak if this is consecutive day
- [ ] Shows completion summary: muscles worked, total volume, XP earned
- [ ] Typecheck passes
- [ ] Verify completion flow in emulator

### US-011: 7-Day Workout Forecast
**Description:** As a user, I want to see a forecast of my week so I can plan ahead.

**Acceptance Criteria:**
- [ ] Screen shows next 7 days with predicted workout type per day
- [ ] Forecast dynamically recalculates after each logged workout
- [ ] Visual indicators: Push (blue), Pull (green), Legs (orange), Rest (gray)
- [ ] Tapping a day shows predicted muscle groups and reasoning
- [ ] Shows "forecast may change based on your activity" disclaimer
- [ ] Typecheck passes
- [ ] Verify forecast screen in emulator

### US-012: Workout History Screen
**Description:** As a user, I want to see my past workouts so I can track what I've done.

**Acceptance Criteria:**
- [ ] Calendar view with workout indicators on trained days
- [ ] List view alternative showing recent workouts
- [ ] Tap date to see workout details (exercises, sets, reps, weight)
- [ ] Filter by workout type (Push/Pull/Legs/All)
- [ ] Shows streak and total workouts this week/month
- [ ] Typecheck passes
- [ ] Verify history screen in emulator

### US-013: Progress Statistics Dashboard
**Description:** As a user, I want to see my progress over time with charts and stats.

**Acceptance Criteria:**
- [ ] Total volume lifted (weekly/monthly/all-time)
- [ ] Workouts completed (weekly/monthly/all-time)
- [ ] Personal records per exercise (most weight, most reps)
- [ ] Line chart showing volume trend over last 4 weeks
- [ ] Muscle group distribution pie chart
- [ ] Current streak prominently displayed
- [ ] Typecheck passes
- [ ] Verify stats screen in emulator

### US-014: XP and Leveling System
**Description:** As a user, I want to earn XP and level up so I feel rewarded for consistency.

**Acceptance Criteria:**
- [ ] XP earned per workout: base (100) + volume bonus (1 XP per 100kg lifted) + streak multiplier
- [ ] Level thresholds: L1=0, L2=500, L3=1500, L4=3500, L5=7000, etc. (exponential)
- [ ] Level-up animation/celebration when threshold crossed
- [ ] Current level and XP shown in profile/header
- [ ] XP breakdown shown after each workout
- [ ] Typecheck passes
- [ ] Verify XP awards in emulator

### US-015: Achievement System
**Description:** As a user, I want to unlock achievements for milestones so I stay motivated.

**Acceptance Criteria:**
- [ ] 15+ achievements defined (see list below)
- [ ] Achievement unlock triggers on relevant events
- [ ] Toast notification when achievement unlocked
- [ ] Achievements screen showing locked/unlocked with progress
- [ ] Unlocked achievements show date earned
- [ ] Typecheck passes
- [ ] Verify achievement unlock in emulator

**Achievement List:**
- First Workout - Complete your first workout
- Week Warrior - Complete 7 workouts in 7 days
- Push Master - Complete 25 push workouts
- Pull Power - Complete 25 pull workouts
- Leg Legend - Complete 25 leg workouts
- Streak Starter - 7-day streak
- Streak Lord - 30-day streak
- Volume King - Lift 10,000kg in a single week
- Century Club - Complete 100 total workouts
- Iron Will - Complete 365 workouts
- Early Bird - Complete a workout before 7am
- Night Owl - Complete a workout after 9pm
- Personal Best - Set a new PR on any exercise
- Balanced Builder - Train all muscle groups in one week
- Rest Champion - Take exactly 2 rest days in a week (not more, not less)

### US-016: Streak Tracking & Recovery
**Description:** As a user, I want my streak tracked accurately with grace for rest days.

**Acceptance Criteria:**
- [ ] Streak = consecutive days with workout OR planned rest
- [ ] Streak breaks only if user misses workout on non-rest day
- [ ] "Rest Day" can be logged to maintain streak
- [ ] Streak freeze option: 1 free freeze per week (skip one day without breaking)
- [ ] Longest streak tracked separately from current streak
- [ ] Typecheck passes

### US-017: Profile Screen
**Description:** As a user, I want to see my profile with stats and settings.

**Acceptance Criteria:**
- [ ] Shows: name, level, XP, current streak, longest streak
- [ ] Member since date
- [ ] Total workouts, total volume lifted
- [ ] Settings: notification preferences, units (kg/lbs), theme
- [ ] Sign out button
- [ ] Typecheck passes
- [ ] Verify profile screen in emulator

### US-018: Offline Support with Sync
**Description:** As a user, I want the app to work offline so I can log workouts without internet.

**Acceptance Criteria:**
- [ ] Firestore offline persistence enabled
- [ ] Exercises and recommendations cached locally
- [ ] Workout logs saved locally when offline
- [ ] Syncs automatically when connection restored
- [ ] Visual indicator showing offline/syncing status
- [ ] Typecheck passes

### US-019: Push Notifications (Optional)
**Description:** As a user, I want reminders to work out so I stay consistent.

**Acceptance Criteria:**
- [ ] Daily reminder notification at user-configured time
- [ ] "Time to train [Workout Type]!" message with today's recommendation
- [ ] Notification tapping opens app to today's workout
- [ ] Can disable in settings
- [ ] Typecheck passes

### US-020: Onboarding Flow
**Description:** As a new user, I want a quick setup so the app understands my baseline.

**Acceptance Criteria:**
- [ ] 3-4 screen onboarding after signup
- [ ] Screen 1: Welcome + name entry
- [ ] Screen 2: Experience level (beginner/intermediate/advanced)
- [ ] Screen 3: Training frequency goal (3/4/5/6 days per week)
- [ ] Screen 4: Confirm gym (Llanishen pre-selected, option to change)
- [ ] Saves preferences and creates initial profile
- [ ] Skippable for returning users
- [ ] Typecheck passes
- [ ] Verify onboarding flow in emulator

## Functional Requirements

- FR-1: Calculate muscle recovery based on time since last worked and exercise intensity
- FR-2: Recommend workout type (Push/Pull/Legs/Rest) based on recovery algorithm
- FR-3: Allow logging external activities (running, cycling) that impact recovery
- FR-4: Generate 7-day forecast that updates dynamically after each workout
- FR-5: Track exercise completion with sets, reps, weight, and RPE
- FR-6: Award XP based on workout completion with volume and streak bonuses
- FR-7: Level up users when XP thresholds crossed
- FR-8: Unlock achievements based on specific triggers
- FR-9: Maintain workout streaks with rest day grace periods
- FR-10: Sync all data to Firebase for cross-device access
- FR-11: Work offline with local caching and background sync
- FR-12: Filter exercises by Llanishen Leisure Centre equipment

## Non-Goals

- No social features (friends, leaderboards, sharing) in v1
- No workout video demonstrations
- No diet/nutrition tracking
- No heart rate or wearable integration
- No custom workout builder (follows recommendation only)
- No trainer/coaching features
- No payment or premium tiers

## Technical Considerations

### Architecture
- **State Management:** Riverpod (recommended for Firebase integration)
- **Local Storage:** Hive for exercise database caching
- **Charts:** fl_chart package for progress visualization
- **Notifications:** firebase_messaging + flutter_local_notifications

### Firestore Structure
```
users/{userId}/
  profile: { name, level, xp, streak, longestStreak, preferences }
  workouts/{workoutId}: { date, type, exercises[], completed }
  muscle_fatigue/{muscle}: { lastWorked, fatigueScore }
  achievements/{achievementId}: { unlockedAt }
  
exercises/ (global collection)
  {exerciseId}: { name, muscles, equipment, category }
```

### Recovery Algorithm Constants
- Small muscles (biceps, triceps, calves): 48h recovery
- Medium muscles (shoulders, core): 60h recovery
- Large muscles (chest, back, quads, glutes): 72h recovery
- Secondary muscle fatigue: 50% of primary

## Design Considerations

- **Color Scheme:** Energetic but not overwhelming (blues, greens, oranges)
- **Typography:** Clear, readable, motivational
- **Workout Types:** Push (blue), Pull (green), Legs (orange), Rest (gray)
- **Priority Indicators:** Recovery % shown as progress bars per muscle
- **Gamification:** XP gains animated, level-ups celebrated, achievements pop

## Success Metrics

- User can see today's recommendation within 2 seconds of opening app
- Logging a complete workout takes under 3 minutes
- 7-day forecast updates immediately after workout completion
- App works fully offline for up to 7 days
- Achievement unlocks feel rewarding (animation + sound)

## Resolved Questions

1. **Rest days count toward streak** — Yes, logging a rest day maintains the streak
2. **Streak freeze limits** — 1 freeze per week maximum
3. **Deload week suggestions** — Yes, suggest deload after 4-6 consecutive weeks of training
4. **PR tracking** — Per exercise + rep range (e.g., Bench Press 5RM vs Bench Press 10RM)
