import 'package:uuid/uuid.dart';

import '../data/exercise_library.dart';
import '../data/food_library.dart';
import '../models/enums.dart';
import '../models/exercise.dart';
import '../models/meal.dart';
import '../models/user_profile.dart';
import '../models/workout_session.dart';

class _SplitDay {
  final String label;
  final List<MuscleGroup> groups;
  const _SplitDay(this.label, this.groups);
}

/// Rule-based generator for aesthetic-focused workout plans (FR-2.1-FR-2.3)
/// and meal plans (FR-3.1-FR-3.3), both constrained to the user's declared
/// available time slots.
class PlanGeneratorService {
  final _uuid = const Uuid();

  /// Splits scale with how many days/week the user has time for, following
  /// common hypertrophy/physique programming (push/pull/legs, upper/lower,
  /// bro-split) rather than pure strength or sport-performance templates.
  static const List<_SplitDay> _oneDay = [
    _SplitDay('Full Body Sculpt', [
      MuscleGroup.chest,
      MuscleGroup.back,
      MuscleGroup.legs,
      MuscleGroup.core,
    ]),
  ];

  static const List<_SplitDay> _twoDay = [
    _SplitDay('Upper Body', [
      MuscleGroup.chest,
      MuscleGroup.back,
      MuscleGroup.shoulders,
      MuscleGroup.arms,
    ]),
    _SplitDay('Lower Body & Core', [
      MuscleGroup.legs,
      MuscleGroup.glutes,
      MuscleGroup.core,
    ]),
  ];

  static const List<_SplitDay> _threeDay = [
    _SplitDay('Push (Chest, Shoulders, Triceps)', [
      MuscleGroup.chest,
      MuscleGroup.shoulders,
      MuscleGroup.arms,
    ]),
    _SplitDay('Pull (Back, Biceps)', [MuscleGroup.back, MuscleGroup.arms]),
    _SplitDay('Legs & Glutes', [
      MuscleGroup.legs,
      MuscleGroup.glutes,
      MuscleGroup.core,
    ]),
  ];

  static const List<_SplitDay> _fourDay = [
    _SplitDay('Chest & Arms', [MuscleGroup.chest, MuscleGroup.arms]),
    _SplitDay('Back & Shoulders', [MuscleGroup.back, MuscleGroup.shoulders]),
    _SplitDay('Legs & Glutes', [MuscleGroup.legs, MuscleGroup.glutes]),
    _SplitDay('Core & Conditioning', [MuscleGroup.core, MuscleGroup.fullBody]),
  ];

  static const List<_SplitDay> _fiveDayPlus = [
    _SplitDay('Chest', [MuscleGroup.chest]),
    _SplitDay('Back', [MuscleGroup.back]),
    _SplitDay('Shoulders & Arms', [MuscleGroup.shoulders, MuscleGroup.arms]),
    _SplitDay('Legs', [MuscleGroup.legs]),
    _SplitDay('Glutes & Core', [MuscleGroup.glutes, MuscleGroup.core]),
    _SplitDay('Conditioning & Full Body', [MuscleGroup.fullBody]),
  ];

  List<_SplitDay> _splitFor(int sessionCount) {
    if (sessionCount <= 1) return _oneDay;
    if (sessionCount == 2) return _twoDay;
    if (sessionCount == 3) return _threeDay;
    if (sessionCount == 4) return _fourDay;
    return _fiveDayPlus;
  }

  ({int sets, int reps, int restSeconds}) _prescriptionFor(FitnessGoal goal) {
    switch (goal) {
      case FitnessGoal.muscularAndBulky:
        return (sets: 4, reps: 8, restSeconds: 90);
      case FitnessGoal.recomposition:
        return (sets: 4, reps: 10, restSeconds: 75);
      case FitnessGoal.balancedAesthetic:
        return (sets: 3, reps: 10, restSeconds: 60);
      case FitnessGoal.leanAndToned:
      case FitnessGoal.fatLoss:
        return (sets: 3, reps: 14, restSeconds: 40);
    }
  }

  WorkoutPlan generateWorkoutPlan(UserProfile profile) {
    final slots = [...profile.workoutAvailability]
      ..sort((a, b) => a.day.dateTimeWeekday.compareTo(b.day.dateTimeWeekday));
    final split = _splitFor(slots.length);
    final prescription = _prescriptionFor(profile.goal);

    final sessions = <WorkoutSession>[];
    for (var i = 0; i < slots.length; i++) {
      final template = split[i % split.length];
      final exercises = <WorkoutExercise>[];

      for (final group in template.groups) {
        final available = ExerciseLibrary.forMuscleGroup(
          group,
          profile.equipmentAccess,
        );
        if (available.isEmpty) continue;
        final perGroup = template.groups.length <= 2 ? 2 : 1;
        final picks = available.take(perGroup);
        for (final Exercise ex in picks) {
          exercises.add(
            WorkoutExercise(
              exercise: ex,
              sets: prescription.sets,
              reps: prescription.reps,
              restSeconds: prescription.restSeconds,
            ),
          );
        }
      }

      sessions.add(
        WorkoutSession(
          id: _uuid.v4(),
          title: template.label,
          focus: template.groups.first,
          slot: slots[i],
          exercises: exercises,
        ),
      );
    }

    return WorkoutPlan(
      id: _uuid.v4(),
      generatedAt: DateTime.now(),
      sessions: sessions,
    );
  }

  MealPlan generateMealPlan(UserProfile profile) {
    final meals = <Meal>[];
    var rotation = 0;

    for (final mealSlot in profile.mealAvailability) {
      final candidates = FoodLibrary.forCategory(
        mealSlot.type,
        profile.dietaryPreferences,
        profile.dislikedFoods,
      );
      if (candidates.isEmpty) continue;
      final food = candidates[rotation % candidates.length];
      rotation++;

      meals.add(
        Meal(
          id: _uuid.v4(),
          type: mealSlot.type,
          slot: mealSlot.slot,
          food: food,
        ),
      );
    }

    return MealPlan(id: _uuid.v4(), generatedAt: DateTime.now(), meals: meals);
  }
}
