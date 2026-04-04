# PRD: Workout Plan Editing & Custom Exercise Management

## Introduction

Currently the app generates a recommended workout plan and lets users tick off exercises as they complete them. There is no way to modify the plan — users can't add an exercise they want to do, remove one they want to skip, swap a suggested exercise for something else, or create their own custom exercises.

This PRD covers a full-featured plan editing system: users can add/remove/swap exercises on today's plan, build custom exercises from scratch, and pick from the full exercise database. Edits to today's plan are isolated to today (they don't override the recommendation engine's future behaviour), but custom exercises are saved to the user's profile and become available for selection going forward.

**Target User:** Derrick, training at Llanishen Leisure Centre

**Tech Stack:** Flutter + Firebase (Firestore)

---

## Goals

- Let users freely add, remove, and swap exercises on today's workout plan
- Allow users to create custom exercises (name, muscle groups, equipment) saved to their profile
- Make adding an exercise fast — quick search/pick from the full database or custom list
- Make swapping easy — tap a suggested exercise → pick a replacement
- Keep today's edits isolated (don't corrupt future recommendation logic)
- Custom exercises are available for future selection just like database exercises

---

## User Stories

### US-021: Exercise Picker Component
**Description:** As a developer, I need a reusable exercise picker widget that lets users search and select an exercise from the combined database + custom exercise list.

**Acceptance Criteria:**
- [ ] Picker is a bottom sheet modal
- [ ] Shows all exercises from the exercise database + user's custom exercises
- [ ] Search bar at the top filters by name in real time (case-insensitive)
- [ ] Exercises grouped by category (Push / Pull / Legs / Cardio / Custom)
- [ ] Each item shows: exercise name, primary muscle group(s), equipment tag
- [ ] Tap an exercise to select it (closes picker, returns selected exercise)
- [ ] Picker accepts an optional `excludeIds` list to hide already-added exercises
- [ ] Unit tests: search filtering, category grouping, exclusion list
- [ ] Typecheck passes (`flutter analyze`)

### US-022: Add Exercise to Today's Plan
**Description:** As a user, I want to add an exercise to today's workout so I can include something the app didn't suggest.

**Acceptance Criteria:**
- [ ] "Add Exercise" button visible on the Today screen below the exercise list
- [ ] Tapping it opens the Exercise Picker (US-021)
- [ ] Selected exercise is appended to the bottom of today's plan
- [ ] Added exercise shows a visual tag (e.g., "Added by you") to distinguish it from recommended ones
- [ ] Added exercise supports full logging (sets/reps/weight/RPE) via the existing exercise logging modal
- [ ] Addition is persisted to the workout log in Firestore (field: `isCustomAdded: true`)
- [ ] Already-added exercises are excluded from the picker so duplicates can't be added
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-023: Remove Exercise from Today's Plan
**Description:** As a user, I want to remove an exercise from today's plan if I don't want to do it.

**Acceptance Criteria:**
- [ ] Each exercise card on the Today screen has a remove option (e.g., swipe left or long-press → "Remove")
- [ ] Confirmation is NOT required (this is a low-stakes, reversible action — see US-024 for undo)
- [ ] Removed exercise disappears from the list immediately
- [ ] If the exercise was already logged (marked complete), a confirmation dialog appears: "This exercise has been logged. Remove it and its log?"
- [ ] Removal persisted to Firestore
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-024: Undo Remove (Snackbar)
**Description:** As a user, I want a quick undo option after removing an exercise so I don't lose it by accident.

**Acceptance Criteria:**
- [ ] After removing an exercise, a snackbar appears: "[Exercise Name] removed. Undo"
- [ ] Tapping "Undo" re-adds the exercise to its original position in the list
- [ ] Snackbar dismisses after 5 seconds
- [ ] Undo is not available if user navigates away before snackbar dismisses
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-025: Swap Exercise on Today's Plan
**Description:** As a user, I want to swap a suggested exercise for a different one so I can adjust for equipment availability or preference.

**Acceptance Criteria:**
- [ ] Each exercise card has a "Swap" option (e.g., tap a swap icon or long-press → "Swap")
- [ ] Tapping "Swap" opens the Exercise Picker (US-021) filtered to the same primary muscle group(s) as the exercise being swapped
- [ ] User can clear the muscle filter to see all exercises
- [ ] Selected replacement takes the position of the original in the list
- [ ] Replacement exercise pre-fills set/rep/weight values from the original exercise's suggestions; all fields are editable
- [ ] Swapped exercise shows a visual tag (e.g., "Swapped") to distinguish it
- [ ] Swap persisted to Firestore (`isSwapped: true`, `replacedExerciseId: <original id>`)
- [ ] If the original exercise had been logged, that log data is cleared and user is warned
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-026: Custom Exercise Creation
**Description:** As a user, I want to create my own exercise so I can track activities not in the database.

**Acceptance Criteria:**
- [ ] "Create Custom Exercise" option available inside the Exercise Picker (US-021) — visible as a button at the top or bottom of the list
- [ ] Opens a form modal with fields:
  - Name (required, text, max 50 chars)
  - Primary muscle group(s) (required, multi-select from standard muscle group list)
  - Secondary muscle group(s) (optional, multi-select)
  - Equipment (optional, single-select from standard equipment list)
  - Category (required: Push / Pull / Legs / Cardio / Other)
  - Notes (optional, text area)
- [ ] Name must be unique within the user's custom exercises (case-insensitive check)
- [ ] Saved to Firestore: `users/{userId}/custom_exercises/{exerciseId}`
- [ ] After saving, the new exercise is automatically selected in the picker (closes picker + creation form, returns the new exercise)
- [ ] Custom exercises are tracked in the PR system (US-013) — personal records are recorded and updated on the same basis as database exercises
- [ ] Custom exercises appear in the Exercise Picker under "Custom" category with a distinct visual indicator (e.g., star icon)
- [ ] Unit tests: validation (missing name, duplicate name, no muscle group), save logic
- [ ] Typecheck passes
- [ ] Verify in browser using dev-browser skill

### US-027: Manage Custom Exercises (Library)
**Description:** As a user, I want to view, edit, and delete my custom exercises so I can keep my library tidy.

**Acceptance Criteria:**
- [x] "My Exercises" section accessible from Profile screen
- [x] Lists all user-created custom exercises (name, muscle groups, category)
- [x] Tap exercise to edit it (same form as creation, pre-filled)
- [x] Swipe left or long-press → "Delete" to remove a custom exercise
- [x] Deletion confirmation dialog: "Delete [Name]? It will be removed from future selection."
- [x] Deleted custom exercise is removed from Firestore
- [x] If deleted exercise is currently on today's plan, it remains there for the day but is flagged as "Deleted" and cannot be added again
- [x] Empty state: "No custom exercises yet. Add one from the workout screen."
- [x] Typecheck passes
- [x] Verify in browser using dev-browser skill

### US-028: Custom Exercise Service
**Description:** As a developer, I need a service layer to manage CRUD operations for custom exercises in Firestore.

**Acceptance Criteria:**
- [ ] `CustomExerciseService` class with methods:
  - `getCustomExercises(userId)` → Stream of custom exercises
  - `createCustomExercise(userId, exercise)` → returns new exercise ID
  - `updateCustomExercise(userId, exerciseId, updates)` → void
  - `deleteCustomExercise(userId, exerciseId)` → void
- [ ] `getCustomExercises` returns combined stream: database exercises + custom exercises
- [ ] Name uniqueness validated at service level (throws if duplicate)
- [ ] Unit tests for all methods (create, read, update, delete, duplicate name check)
- [ ] Golden path e2e test: create custom exercise → appears in picker → add to workout → logged correctly
- [ ] Typecheck passes

### US-029: Workout Plan Edit State Management
**Description:** As a developer, I need state management for today's plan edits so changes are tracked cleanly without corrupting recommendation data.

**Acceptance Criteria:**
- [ ] `TodayWorkoutNotifier` (Riverpod) manages the mutable state of today's plan
- [ ] State tracks: original recommended exercises + user additions/removals/swaps separately
- [ ] Plan edits persisted to the existing `WorkoutLog` in Firestore under an `edits` sub-field: `{ added: [], removed: [], swapped: [] }`
- [ ] Recommendation engine reads from its own data (muscle fatigue logs) — never reads `edits` field — so future recommendations are not affected by today's plan changes
- [ ] On workout completion (`US-010`), fatigue is calculated from *actually logged* exercises (regardless of whether they were recommended, added, or swapped)
- [ ] Unit tests: add exercise to state, remove exercise from state, swap exercise, completion calculates from logged exercises only
- [ ] Typecheck passes

---

## Functional Requirements

- FR-1: Users can add any exercise from the database or their custom list to today's workout
- FR-2: Users can remove any exercise from today's workout (with undo within 5s)
- FR-3: Users can swap any exercise for another, with smart filtering by muscle group
- FR-4: Users can create custom exercises with name, muscle groups, equipment, and category
- FR-5: Custom exercises are stored per user in Firestore and persist across sessions
- FR-6: Custom exercises appear in the Exercise Picker alongside database exercises
- FR-7: Users can edit and delete custom exercises from their profile
- FR-8: Today's plan edits are isolated — they do not influence future recommendation outputs
- FR-9: Muscle fatigue after workout completion is based on exercises actually logged, not the original recommended list
- FR-10: Added/swapped exercises are visually differentiated from recommended ones on the Today screen
- FR-11: The Exercise Picker supports real-time search and category filtering

---

## Non-Goals

- No reordering of exercises via drag-and-drop (out of scope for this iteration)
- No saving a modified plan as a "template" for future use
- No persistent overrides to the recommendation engine (e.g., "always suggest bench press on push days")
- No sharing or exporting custom exercises
- No bulk import of custom exercises
- No video or image attachments to custom exercises

---

## Design Considerations

- **Exercise Picker** should be a bottom sheet (not a full screen) to feel lightweight and quick
- **"Added by you"** and **"Swapped"** tags should be subtle (small chip/badge) — don't clutter the card
- **Custom exercises** in the picker should have a visible indicator (e.g., ⭐ or "Custom" badge) so users can tell them apart
- **Remove action**: prefer swipe-left gesture on mobile for familiarity; long-press as a fallback
- **Swap action**: a swap icon (↔) on the exercise card is cleaner than a long-press-only interaction
- **Form validation**: inline errors (under each field), not a dialog
- Reuse existing `ExerciseLoggingModal` for logging added/swapped exercises — no new logging UI needed

---

## Technical Considerations

- **Firestore path for custom exercises:** `users/{userId}/custom_exercises/{exerciseId}`
- **Custom exercise model** should extend or mirror the existing `Exercise` model with an added `isCustom: true` field and `createdAt` timestamp
- **Exercise Picker** fetches from two sources: static exercise database (local JSON/cache) + Firestore custom exercises (real-time stream) — merge and deduplicate before rendering
- **Recommendation engine isolation**: the `RecommendationService` and `FatigueService` must continue to read only from `workout_logs` exercise sets and `muscle_fatigue` — never from the `edits` sub-field
- **State**: `TodayWorkoutNotifier` should hold the merged list (recommended + added - removed, with swaps applied) as a single ordered list for the UI to consume
- **Offline support**: custom exercises should be cached via Firestore offline persistence (already enabled per US-018)

---

## Success Metrics

- User can add an exercise to today's plan in under 10 seconds
- User can create a new custom exercise in under 60 seconds
- Exercise picker search returns filtered results within 200ms
- Plan edits do not affect the next day's recommendation (verified by unit test)
- Zero data loss: if user removes then undoes, exercise returns to original position

---

## Resolved Questions

1. **Swap inherits set/rep suggestions?** Yes — the replacement exercise pre-fills with the original's set/rep/weight values, but all fields remain fully editable before and after logging.
2. **Cap on added exercises?** No — users can add as many exercises as they want to a single workout.
3. **Custom exercises contribute to PR tracking?** Yes — custom exercises feed into the PR tracking system (US-013) on the same basis as database exercises.
