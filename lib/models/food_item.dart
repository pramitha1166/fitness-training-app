import 'enums.dart';

/// A library food/recipe suggestion (content-managed, NFR-12).
class FoodItem {
  final String id;
  final String name;
  final MealType category;
  final int calories;
  final double proteinG;
  final double carbsG;
  final double fatsG;
  final List<DietaryPreference> suitableFor;
  final String instructions;
  final int prepMinutes;

  const FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatsG,
    required this.suitableFor,
    required this.instructions,
    required this.prepMinutes,
  });
}
