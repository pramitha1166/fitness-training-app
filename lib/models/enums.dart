enum Gender { male, female, other }

enum FitnessGoal {
  leanAndToned,
  muscularAndBulky,
  balancedAesthetic,
  fatLoss,
  recomposition,
}

enum ActivityLevel { sedentary, lightlyActive, moderatelyActive, veryActive }

enum EquipmentAccess { fullGym, homeBasic, bodyweightOnly }

enum DietaryPreference {
  none,
  vegetarian,
  vegan,
  pescatarian,
  glutenFree,
  dairyFree,
  keto,
}

enum MuscleGroup { chest, back, shoulders, arms, legs, glutes, core, fullBody }

enum WeekDay { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

enum MealType { breakfast, lunch, dinner, snack }

enum LogStatus { pending, completed, skipped, rescheduled }

enum SubscriptionTier { free, trial, subscribed, expired }

extension WeekDayX on WeekDay {
  String get label {
    switch (this) {
      case WeekDay.monday:
        return 'Monday';
      case WeekDay.tuesday:
        return 'Tuesday';
      case WeekDay.wednesday:
        return 'Wednesday';
      case WeekDay.thursday:
        return 'Thursday';
      case WeekDay.friday:
        return 'Friday';
      case WeekDay.saturday:
        return 'Saturday';
      case WeekDay.sunday:
        return 'Sunday';
    }
  }

  /// DateTime.weekday is 1 (Monday) - 7 (Sunday).
  int get dateTimeWeekday => WeekDay.values.indexOf(this) + 1;

  static WeekDay fromDateTimeWeekday(int weekday) =>
      WeekDay.values[weekday - 1];
}

extension FitnessGoalX on FitnessGoal {
  String get label {
    switch (this) {
      case FitnessGoal.leanAndToned:
        return 'Lean & Toned';
      case FitnessGoal.muscularAndBulky:
        return 'Muscular & Bulky';
      case FitnessGoal.balancedAesthetic:
        return 'Balanced Aesthetic Physique';
      case FitnessGoal.fatLoss:
        return 'Fat Loss';
      case FitnessGoal.recomposition:
        return 'Body Recomposition';
    }
  }
}

extension MealTypeX on MealType {
  String get label {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }
}
