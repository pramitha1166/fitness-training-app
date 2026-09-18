import 'enums.dart';
import 'meal_slot.dart';
import 'time_slot.dart';

/// Collected during onboarding (FR-1.1 - FR-1.6) and drives plan generation.
class UserProfile {
  final String id;
  final String name;
  final String email;
  final int age;
  final Gender gender;
  final double heightCm;
  final double weightKg;
  final FitnessGoal goal;
  final ActivityLevel activityLevel;
  final List<String> injuriesOrConstraints;
  final List<TimeSlot> workoutAvailability;
  final List<MealSlot> mealAvailability;
  final List<DietaryPreference> dietaryPreferences;
  final List<String> dislikedFoods;
  final EquipmentAccess equipmentAccess;
  final bool onboardingComplete;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.goal,
    required this.activityLevel,
    required this.injuriesOrConstraints,
    required this.workoutAvailability,
    required this.mealAvailability,
    required this.dietaryPreferences,
    required this.dislikedFoods,
    required this.equipmentAccess,
    required this.onboardingComplete,
    required this.createdAt,
  });

  factory UserProfile.empty() => UserProfile(
    id: '',
    name: '',
    email: '',
    age: 25,
    gender: Gender.other,
    heightCm: 170,
    weightKg: 70,
    goal: FitnessGoal.balancedAesthetic,
    activityLevel: ActivityLevel.moderatelyActive,
    injuriesOrConstraints: const [],
    workoutAvailability: const [],
    mealAvailability: const [],
    dietaryPreferences: const [DietaryPreference.none],
    dislikedFoods: const [],
    equipmentAccess: EquipmentAccess.homeBasic,
    onboardingComplete: false,
    createdAt: DateTime.now(),
  );

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    int? age,
    Gender? gender,
    double? heightCm,
    double? weightKg,
    FitnessGoal? goal,
    ActivityLevel? activityLevel,
    List<String>? injuriesOrConstraints,
    List<TimeSlot>? workoutAvailability,
    List<MealSlot>? mealAvailability,
    List<DietaryPreference>? dietaryPreferences,
    List<String>? dislikedFoods,
    EquipmentAccess? equipmentAccess,
    bool? onboardingComplete,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      goal: goal ?? this.goal,
      activityLevel: activityLevel ?? this.activityLevel,
      injuriesOrConstraints:
          injuriesOrConstraints ?? this.injuriesOrConstraints,
      workoutAvailability: workoutAvailability ?? this.workoutAvailability,
      mealAvailability: mealAvailability ?? this.mealAvailability,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      dislikedFoods: dislikedFoods ?? this.dislikedFoods,
      equipmentAccess: equipmentAccess ?? this.equipmentAccess,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'age': age,
    'gender': gender.name,
    'heightCm': heightCm,
    'weightKg': weightKg,
    'goal': goal.name,
    'activityLevel': activityLevel.name,
    'injuriesOrConstraints': injuriesOrConstraints,
    'workoutAvailability': workoutAvailability.map((e) => e.toJson()).toList(),
    'mealAvailability': mealAvailability.map((e) => e.toJson()).toList(),
    'dietaryPreferences': dietaryPreferences.map((e) => e.name).toList(),
    'dislikedFoods': dislikedFoods,
    'equipmentAccess': equipmentAccess.name,
    'onboardingComplete': onboardingComplete,
    'createdAt': createdAt.toIso8601String(),
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    age: json['age'] as int,
    gender: Gender.values.byName(json['gender'] as String),
    heightCm: (json['heightCm'] as num).toDouble(),
    weightKg: (json['weightKg'] as num).toDouble(),
    goal: FitnessGoal.values.byName(json['goal'] as String),
    activityLevel: ActivityLevel.values.byName(json['activityLevel'] as String),
    injuriesOrConstraints: List<String>.from(
      json['injuriesOrConstraints'] as List,
    ),
    workoutAvailability: (json['workoutAvailability'] as List)
        .map((e) => TimeSlot.fromJson(e as Map<String, dynamic>))
        .toList(),
    mealAvailability: (json['mealAvailability'] as List)
        .map((e) => MealSlot.fromJson(e as Map<String, dynamic>))
        .toList(),
    dietaryPreferences: (json['dietaryPreferences'] as List)
        .map((e) => DietaryPreference.values.byName(e as String))
        .toList(),
    dislikedFoods: List<String>.from(json['dislikedFoods'] as List),
    equipmentAccess: EquipmentAccess.values.byName(
      json['equipmentAccess'] as String,
    ),
    onboardingComplete: json['onboardingComplete'] as bool,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  double get bmi => weightKg / ((heightCm / 100) * (heightCm / 100));
}
