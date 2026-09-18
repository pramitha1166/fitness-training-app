import 'enums.dart';
import 'food_item.dart';
import 'time_slot.dart';

/// A single scheduled meal (FR-3.1, FR-3.5).
class Meal {
  final String id;
  final MealType type;
  final TimeSlot slot;
  FoodItem food;
  LogStatus status;

  Meal({
    required this.id,
    required this.type,
    required this.slot,
    required this.food,
    this.status = LogStatus.pending,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'slot': slot.toJson(),
    'foodId': food.id,
    'status': status.name,
  };

  factory Meal.fromJson(
    Map<String, dynamic> json,
    FoodItem Function(String id) foodLookup,
  ) => Meal(
    id: json['id'] as String,
    type: MealType.values.byName(json['type'] as String),
    slot: TimeSlot.fromJson(json['slot'] as Map<String, dynamic>),
    food: foodLookup(json['foodId'] as String),
    status: LogStatus.values.byName(json['status'] as String? ?? 'pending'),
  );
}

/// The full weekly meal plan (FR-3.1).
class MealPlan {
  final String id;
  final DateTime generatedAt;
  final List<Meal> meals;

  const MealPlan({
    required this.id,
    required this.generatedAt,
    required this.meals,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'generatedAt': generatedAt.toIso8601String(),
    'meals': meals.map((m) => m.toJson()).toList(),
  };

  factory MealPlan.fromJson(
    Map<String, dynamic> json,
    FoodItem Function(String id) foodLookup,
  ) => MealPlan(
    id: json['id'] as String,
    generatedAt: DateTime.parse(json['generatedAt'] as String),
    meals: (json['meals'] as List)
        .map((m) => Meal.fromJson(m as Map<String, dynamic>, foodLookup))
        .toList(),
  );
}
