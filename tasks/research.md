# Research: Workout Planner App

## 1. Llanishen Leisure Centre - Typical Equipment

Based on Better UK leisure centres (Cardiff), typical gym equipment includes:

### Free Weights
- Dumbbells (1kg - 50kg range)
- Barbells (Olympic bars)
- EZ curl bars
- Weight plates
- Kettlebells

### Machines - Upper Body
- Cable crossover machine
- Lat pulldown
- Seated row
- Chest press machine
- Shoulder press machine
- Pec deck / fly machine
- Assisted pull-up/dip machine

### Machines - Lower Body
- Leg press
- Leg extension
- Leg curl (seated/lying)
- Hip abductor/adductor
- Calf raise machine
- Smith machine

### Cardio Equipment
- Treadmills
- Exercise bikes (upright + recumbent)
- Cross trainers / ellipticals
- Rowing machines
- Stair climbers

### Functional/Other
- Pull-up bars
- Dip station
- Cable machines
- Resistance bands
- Medicine balls
- Plyo boxes
- TRX suspension trainers
- Benches (flat, incline, decline)

---

## 2. Muscle Group Science - Recovery & Rotation

### Primary Muscle Groups
1. **Chest** (Pectorals)
2. **Back** (Lats, Rhomboids, Traps)
3. **Shoulders** (Deltoids - anterior, lateral, posterior)
4. **Biceps**
5. **Triceps**
6. **Core** (Abs, Obliques, Lower back)
7. **Quadriceps**
8. **Hamstrings**
9. **Glutes**
10. **Calves**

### Recovery Windows (Science-Based)
| Muscle Group | Minimum Recovery | Optimal Recovery |
|--------------|------------------|------------------|
| Small (Biceps, Triceps, Calves) | 24-48 hours | 48 hours |
| Medium (Shoulders, Core) | 48 hours | 48-72 hours |
| Large (Chest, Back, Legs) | 48-72 hours | 72 hours |

### Compound Movement Overlap
When a muscle is **secondarily** worked, it still needs recovery:
- Bench Press → Chest (primary), Triceps + Front Delts (secondary)
- Rows → Back (primary), Biceps + Rear Delts (secondary)
- Squats → Quads + Glutes (primary), Hamstrings + Core (secondary)
- Deadlifts → Back + Hamstrings (primary), Glutes + Core (secondary)

---

## 3. Workout Split Patterns

### Push/Pull/Legs (PPL) - Recommended for App
**Best for:** 3-6 days/week training

| Day | Focus | Primary Muscles | Secondary |
|-----|-------|-----------------|-----------|
| Push | Pressing movements | Chest, Shoulders, Triceps | - |
| Pull | Pulling movements | Back, Biceps, Rear Delts | - |
| Legs | Lower body | Quads, Hamstrings, Glutes, Calves | Core |

**Recovery Logic:**
- After Push → Pull or Legs next (chest/triceps recover)
- After Pull → Push or Legs next (back/biceps recover)
- After Legs → Push or Pull next (legs recover)
- Min 48h before repeating same category

### Upper/Lower Split
**Best for:** 4 days/week

| Day | Focus |
|-----|-------|
| Upper | Chest, Back, Shoulders, Arms |
| Lower | Quads, Hamstrings, Glutes, Calves |

### Full Body
**Best for:** 2-3 days/week beginners
- Hit all muscle groups each session
- Requires 48-72h between sessions

---

## 4. Activity Impact Rules

### Cardio Impact on Lifting
| Activity | Legs Impact | Upper Impact | Recovery Needed |
|----------|-------------|--------------|-----------------|
| Running (long) | High | Low | 24-48h for legs |
| Cycling | Medium-High | Low | 24h for legs |
| Swimming | Medium | Medium | 24h full body |
| Rowing | Medium | Medium | 24h full body |
| Walking | Low | None | None |
| HIIT | High | Medium | 48h |

### Fatigue Scoring System (for app logic)
```
fatigue_score = base_fatigue × intensity_multiplier × duration_factor

Where:
- base_fatigue: 1-10 per muscle group
- intensity_multiplier: 0.5 (light) to 1.5 (heavy)
- duration_factor: 1.0 (normal) + 0.1 per 10min over standard
```

**Recovery Formula:**
```
hours_to_recover = fatigue_score × 8

Ready when: current_time - exercise_time >= hours_to_recover
```

---

## 5. Optimal Weekly Volume (Hypertrophy)

### Sets Per Week Per Muscle Group
| Experience | Min Sets | Optimal | Max (before diminishing) |
|------------|----------|---------|--------------------------|
| Beginner | 6-8 | 10 | 12 |
| Intermediate | 10-12 | 15 | 20 |
| Advanced | 12-16 | 18-22 | 25+ |

### Progressive Overload Tracking
Track per exercise:
- Weight lifted
- Reps completed
- Sets completed
- RPE (Rate of Perceived Exertion) 1-10

---

## 6. Gamification Strategies

### Effective Mechanics for Fitness Apps
1. **Streaks** - Consecutive training days/weeks
2. **XP System** - Points for completing workouts
3. **Levels** - Rank up based on total XP
4. **Achievements/Badges** - Milestone rewards
5. **Progress Visualization** - Charts, personal records
6. **Weekly Challenges** - Time-limited goals
7. **Rest Day Rewards** - Encourage recovery (not just more training)

### Proven Engagement Patterns
- **Daily login bonus** - Check-in even on rest days
- **Workout completion multiplier** - 1.5x XP for finishing full plan
- **Consistency bonuses** - Weekly completion rewards
- **Personal record celebrations** - New PR = special animation + XP
- **Social comparison** (optional) - Leaderboards

### Badge Ideas
- "First Workout" - Complete first session
- "Week Warrior" - Complete 7 days of planned workouts
- "Push Master" - 100 push workouts
- "Iron Legs" - Complete 50 leg days
- "Streak Lord" - 30-day streak
- "Volume King" - Lift 10,000kg in a week
- "Recovery Champion" - Take 8 proper rest days in a month

---

## 7. Tech Stack Decisions

### Flutter + Firebase
- **Auth:** Firebase Authentication
- **Database:** Cloud Firestore (real-time sync)
- **State Management:** Riverpod or Bloc
- **Local Storage:** Hive (for offline caching)
- **Charts:** fl_chart package

### Data Schema (High-Level)
```
users/
  {userId}/
    profile: { name, level, xp, streaks }
    workouts/
      {workoutId}: { date, exercises[], completed, fatigue_logged }
    exercises_log/
      {logId}: { exercise, sets, reps, weight, rpe, timestamp }
    muscle_fatigue/
      {muscle}: { last_worked, fatigue_score, recovery_eta }
```

---

## 8. Recommendation Algorithm

### Daily Workout Selection Logic
```python
def get_todays_workout(user):
    # 1. Get all muscle groups with recovery status
    muscle_status = calculate_recovery_status(user.muscle_fatigue)
    
    # 2. Filter to "ready" muscles (>= 90% recovered)
    ready_muscles = [m for m in muscle_status if m.recovery >= 0.9]
    
    # 3. Score each workout type by:
    #    - Days since last trained (higher = priority)
    #    - Weekly volume deficit (under-trained = priority)
    #    - User preferences
    scored_options = score_workout_options(ready_muscles, user)
    
    # 4. Return top recommendation + alternatives
    return {
        "recommended": scored_options[0],
        "alternatives": scored_options[1:3]
    }
```

### External Activity Adjustment
```python
def adjust_for_activity(user, activity):
    """When user logs non-gym activity (e.g., 10km run)"""
    
    impact = ACTIVITY_IMPACT[activity.type]
    
    for muscle, fatigue in impact.items():
        user.muscle_fatigue[muscle] += fatigue * activity.intensity
        
    # Recalculate today's recommendation
    return get_todays_workout(user)
```

---

## Sources & References
- Schoenfeld, B.J. (2010) - Mechanisms of muscle hypertrophy
- ACSM Guidelines for resistance training
- Renaissance Periodization volume landmarks
- StrongLifts 5x5, nSuns, GZCLP program structures
- Gamification research: Yu-kai Chou's Octalysis framework
