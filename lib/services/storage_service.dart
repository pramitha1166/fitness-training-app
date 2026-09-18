import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/exercise_library.dart';
import '../data/food_library.dart';
import '../models/app_settings.dart';
import '../models/meal.dart';
import '../models/progress_log.dart';
import '../models/subscription_status.dart';
import '../models/user_profile.dart';
import '../models/workout_session.dart';

/// Local, offline-first persistence (NFR-10). All app state is cached on
/// device so plans and progress remain viewable without a network
/// connection; a production build would additionally sync this through the
/// backend API described in the SRS (section 2.1) for cross-device access.
class StorageService {
  static const _keyUserProfile = 'user_profile';
  static const _keyWorkoutPlan = 'workout_plan';
  static const _keyMealPlan = 'meal_plan';
  static const _keyProgressLogs = 'progress_logs';
  static const _keySettings = 'app_settings';
  static const _keySubscription = 'subscription_status';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // --- User profile ---
  Future<void> saveUserProfile(UserProfile profile) =>
      _prefs.setString(_keyUserProfile, jsonEncode(profile.toJson()));

  UserProfile? loadUserProfile() {
    final raw = _prefs.getString(_keyUserProfile);
    if (raw == null) return null;
    return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  // --- Workout plan ---
  Future<void> saveWorkoutPlan(WorkoutPlan plan) =>
      _prefs.setString(_keyWorkoutPlan, jsonEncode(plan.toJson()));

  WorkoutPlan? loadWorkoutPlan() {
    final raw = _prefs.getString(_keyWorkoutPlan);
    if (raw == null) return null;
    return WorkoutPlan.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
      ExerciseLibrary.byId,
    );
  }

  // --- Meal plan ---
  Future<void> saveMealPlan(MealPlan plan) =>
      _prefs.setString(_keyMealPlan, jsonEncode(plan.toJson()));

  MealPlan? loadMealPlan() {
    final raw = _prefs.getString(_keyMealPlan);
    if (raw == null) return null;
    return MealPlan.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
      FoodLibrary.byId,
    );
  }

  // --- Progress logs ---
  Future<void> saveProgressLogs(List<ProgressLog> logs) => _prefs.setString(
    _keyProgressLogs,
    jsonEncode(logs.map((e) => e.toJson()).toList()),
  );

  List<ProgressLog> loadProgressLogs() {
    final raw = _prefs.getString(_keyProgressLogs);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => ProgressLog.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // --- Settings ---
  Future<void> saveSettings(AppSettings settings) =>
      _prefs.setString(_keySettings, jsonEncode(settings.toJson()));

  AppSettings loadSettings() {
    final raw = _prefs.getString(_keySettings);
    if (raw == null) return const AppSettings();
    return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  // --- Subscription ---
  Future<void> saveSubscriptionStatus(SubscriptionStatus status) =>
      _prefs.setString(_keySubscription, jsonEncode(status.toJson()));

  SubscriptionStatus loadSubscriptionStatus() {
    final raw = _prefs.getString(_keySubscription);
    if (raw == null) return SubscriptionStatus.free();
    return SubscriptionStatus.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  /// Account deletion / data export compliance (FR-7.3).
  Future<void> clearAllData() async {
    await Future.wait([
      _prefs.remove(_keyUserProfile),
      _prefs.remove(_keyWorkoutPlan),
      _prefs.remove(_keyMealPlan),
      _prefs.remove(_keyProgressLogs),
      _prefs.remove(_keySettings),
      _prefs.remove(_keySubscription),
    ]);
  }

  Map<String, dynamic> exportAllData() => {
    'userProfile': loadUserProfile()?.toJson(),
    'workoutPlan': loadWorkoutPlan()?.toJson(),
    'mealPlan': loadMealPlan()?.toJson(),
    'progressLogs': loadProgressLogs().map((e) => e.toJson()).toList(),
    'settings': loadSettings().toJson(),
    'subscription': loadSubscriptionStatus().toJson(),
  };
}
