import 'package:flutter/foundation.dart';

import '../models/app_settings.dart';
import '../models/enums.dart';
import '../models/food_item.dart';
import '../models/meal.dart';
import '../models/user_profile.dart';
import '../models/workout_session.dart';
import '../services/notification_service.dart';
import '../services/plan_generator_service.dart';
import '../services/storage_service.dart';

/// Owns the generated workout and meal plans (FR-2.x, FR-3.x) and keeps
/// scheduled notifications in sync with them (FR-5.1, FR-5.2).
class PlanProvider extends ChangeNotifier {
  final StorageService _storage;
  final NotificationService _notifications;
  final PlanGeneratorService _generator = PlanGeneratorService();

  WorkoutPlan? _workoutPlan;
  MealPlan? _mealPlan;

  WorkoutPlan? get workoutPlan => _workoutPlan;
  MealPlan? get mealPlan => _mealPlan;
  bool get hasPlans => _workoutPlan != null && _mealPlan != null;

  PlanProvider(this._storage, this._notifications) {
    _workoutPlan = _storage.loadWorkoutPlan();
    _mealPlan = _storage.loadMealPlan();
  }

  /// FR-2.1/FR-3.1 initial generation, and FR-7.1/FR-2.4 regeneration
  /// whenever the user's profile or availability changes.
  Future<void> generateAndSchedule(
    UserProfile profile,
    AppSettings settings,
  ) async {
    _workoutPlan = _generator.generateWorkoutPlan(profile);
    _mealPlan = _generator.generateMealPlan(profile);
    await _storage.saveWorkoutPlan(_workoutPlan!);
    await _storage.saveMealPlan(_mealPlan!);
    notifyListeners();
    await rescheduleNotifications(settings);
  }

  /// Clears in-memory plan state (used on account deletion, FR-7.3).
  /// Assumes the caller has already cleared persisted storage.
  Future<void> clearAll() async {
    _workoutPlan = null;
    _mealPlan = null;
    await _notifications.cancelAll();
    notifyListeners();
  }

  Future<void> rescheduleNotifications(AppSettings settings) async {
    if (_workoutPlan == null || _mealPlan == null) return;
    await _notifications.rescheduleAll(
      sessions: _workoutPlan!.sessions,
      meals: _mealPlan!.meals,
      settings: settings,
    );
  }

  Future<void> setWorkoutStatus(String sessionId, LogStatus status) async {
    final plan = _workoutPlan;
    if (plan == null) return;
    final session = plan.sessions.firstWhere((s) => s.id == sessionId);
    session.status = status;
    await _storage.saveWorkoutPlan(plan);
    notifyListeners();
  }

  Future<void> setMealStatus(String mealId, LogStatus status) async {
    final plan = _mealPlan;
    if (plan == null) return;
    final meal = plan.meals.firstWhere((m) => m.id == mealId);
    meal.status = status;
    await _storage.saveMealPlan(plan);
    notifyListeners();
  }

  Future<void> swapMeal(String mealId, FoodItem foodItem) async {
    final plan = _mealPlan;
    if (plan == null) return;
    final meal = plan.meals.firstWhere((m) => m.id == mealId);
    meal.food = foodItem;
    await _storage.saveMealPlan(plan);
    notifyListeners();
  }

  List<WorkoutSession> sessionsFor(WeekDay day) =>
      _workoutPlan?.sessions.where((s) => s.slot.day == day).toList() ?? [];

  List<Meal> mealsFor(WeekDay day) =>
      _mealPlan?.meals.where((m) => m.slot.day == day).toList() ?? [];

  double get weeklyWorkoutAdherence {
    final sessions = _workoutPlan?.sessions ?? [];
    if (sessions.isEmpty) return 0;
    final completed = sessions
        .where((s) => s.status == LogStatus.completed)
        .length;
    return completed / sessions.length;
  }

  double get weeklyMealAdherence {
    final meals = _mealPlan?.meals ?? [];
    if (meals.isEmpty) return 0;
    final completed = meals
        .where((m) => m.status == LogStatus.completed)
        .length;
    return completed / meals.length;
  }
}
