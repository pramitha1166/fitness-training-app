import '../models/enums.dart';
import '../models/food_item.dart';

/// In-house nutrition/recipe library (NFR-12). Each item lists which
/// dietary preferences it satisfies so the generator can filter safely
/// (FR-3.2).
class FoodLibrary {
  FoodLibrary._();

  static final List<FoodItem> all = [
    // Breakfast
    FoodItem(
      id: 'fd_oats_berries',
      name: 'Oats with Berries & Whey',
      category: MealType.breakfast,
      calories: 420,
      proteinG: 32,
      carbsG: 55,
      fatsG: 8,
      suitableFor: [DietaryPreference.none, DietaryPreference.vegetarian],
      instructions:
          'Cook 60g oats with water/milk, top with berries and a scoop of whey protein.',
      prepMinutes: 8,
    ),
    FoodItem(
      id: 'fd_egg_whites_toast',
      name: 'Egg White Omelette & Wholegrain Toast',
      category: MealType.breakfast,
      calories: 380,
      proteinG: 34,
      carbsG: 38,
      fatsG: 9,
      suitableFor: [DietaryPreference.none, DietaryPreference.vegetarian],
      instructions:
          '5 egg whites + 1 whole egg omelette with spinach, 2 slices wholegrain toast.',
      prepMinutes: 10,
    ),
    FoodItem(
      id: 'fd_tofu_scramble',
      name: 'Tofu Scramble with Veggies',
      category: MealType.breakfast,
      calories: 360,
      proteinG: 26,
      carbsG: 30,
      fatsG: 14,
      suitableFor: [
        DietaryPreference.vegan,
        DietaryPreference.vegetarian,
        DietaryPreference.dairyFree,
      ],
      instructions:
          'Crumble firm tofu, sauté with turmeric, peppers, and onion.',
      prepMinutes: 12,
    ),
    FoodItem(
      id: 'fd_greek_yogurt_bowl',
      name: 'Greek Yogurt Protein Bowl',
      category: MealType.breakfast,
      calories: 340,
      proteinG: 30,
      carbsG: 32,
      fatsG: 8,
      suitableFor: [DietaryPreference.vegetarian, DietaryPreference.none],
      instructions: 'Greek yogurt, honey, granola, and mixed berries.',
      prepMinutes: 5,
    ),
    FoodItem(
      id: 'fd_keto_avocado_eggs',
      name: 'Avocado & Baked Eggs',
      category: MealType.breakfast,
      calories: 450,
      proteinG: 24,
      carbsG: 10,
      fatsG: 34,
      suitableFor: [
        DietaryPreference.keto,
        DietaryPreference.glutenFree,
        DietaryPreference.none,
      ],
      instructions: 'Bake 2 eggs in half an avocado at 200°C for 12 minutes.',
      prepMinutes: 15,
    ),
    FoodItem(
      id: 'fd_smoothie_pb',
      name: 'Peanut Butter Protein Smoothie',
      category: MealType.breakfast,
      calories: 410,
      proteinG: 35,
      carbsG: 40,
      fatsG: 12,
      suitableFor: [
        DietaryPreference.vegan,
        DietaryPreference.vegetarian,
        DietaryPreference.dairyFree,
        DietaryPreference.none,
      ],
      instructions:
          'Blend plant milk, banana, protein powder, and 1 tbsp peanut butter.',
      prepMinutes: 5,
    ),

    // Lunch
    FoodItem(
      id: 'fd_chicken_rice_bowl',
      name: 'Grilled Chicken & Rice Bowl',
      category: MealType.lunch,
      calories: 620,
      proteinG: 48,
      carbsG: 65,
      fatsG: 14,
      suitableFor: [
        DietaryPreference.none,
        DietaryPreference.glutenFree,
        DietaryPreference.dairyFree,
      ],
      instructions:
          'Grilled chicken breast, jasmine rice, steamed broccoli, light soy glaze.',
      prepMinutes: 20,
    ),
    FoodItem(
      id: 'fd_salmon_quinoa',
      name: 'Baked Salmon & Quinoa Salad',
      category: MealType.lunch,
      calories: 580,
      proteinG: 42,
      carbsG: 45,
      fatsG: 22,
      suitableFor: [
        DietaryPreference.pescatarian,
        DietaryPreference.glutenFree,
        DietaryPreference.dairyFree,
        DietaryPreference.none,
      ],
      instructions:
          'Baked salmon fillet over quinoa, rocket, and lemon dressing.',
      prepMinutes: 25,
    ),
    FoodItem(
      id: 'fd_chickpea_salad',
      name: 'Chickpea & Feta Power Salad',
      category: MealType.lunch,
      calories: 520,
      proteinG: 24,
      carbsG: 55,
      fatsG: 18,
      suitableFor: [DietaryPreference.vegetarian, DietaryPreference.none],
      instructions: 'Chickpeas, cucumber, tomato, feta, olive oil and herbs.',
      prepMinutes: 12,
    ),
    FoodItem(
      id: 'fd_vegan_buddha_bowl',
      name: 'Vegan Buddha Bowl',
      category: MealType.lunch,
      calories: 540,
      proteinG: 22,
      carbsG: 68,
      fatsG: 16,
      suitableFor: [
        DietaryPreference.vegan,
        DietaryPreference.vegetarian,
        DietaryPreference.dairyFree,
      ],
      instructions:
          'Roasted sweet potato, edamame, brown rice, tahini dressing.',
      prepMinutes: 25,
    ),
    FoodItem(
      id: 'fd_turkey_wrap',
      name: 'Lean Turkey Wholewheat Wrap',
      category: MealType.lunch,
      calories: 490,
      proteinG: 38,
      carbsG: 48,
      fatsG: 12,
      suitableFor: [DietaryPreference.none],
      instructions:
          'Sliced turkey breast, wholewheat wrap, lettuce, mustard, light mayo.',
      prepMinutes: 8,
    ),
    FoodItem(
      id: 'fd_keto_steak_salad',
      name: 'Steak & Greens Keto Salad',
      category: MealType.lunch,
      calories: 560,
      proteinG: 45,
      carbsG: 10,
      fatsG: 36,
      suitableFor: [
        DietaryPreference.keto,
        DietaryPreference.glutenFree,
        DietaryPreference.dairyFree,
      ],
      instructions:
          'Pan-seared sirloin strips over mixed greens with olive oil dressing.',
      prepMinutes: 18,
    ),

    // Dinner
    FoodItem(
      id: 'fd_lean_beef_stirfry',
      name: 'Lean Beef & Vegetable Stir-Fry',
      category: MealType.dinner,
      calories: 560,
      proteinG: 44,
      carbsG: 42,
      fatsG: 20,
      suitableFor: [DietaryPreference.none, DietaryPreference.dairyFree],
      instructions:
          'Stir-fry lean beef strips with mixed vegetables and light soy-ginger sauce over rice.',
      prepMinutes: 22,
    ),
    FoodItem(
      id: 'fd_baked_cod_veg',
      name: 'Baked Cod with Roasted Vegetables',
      category: MealType.dinner,
      calories: 460,
      proteinG: 40,
      carbsG: 30,
      fatsG: 16,
      suitableFor: [
        DietaryPreference.pescatarian,
        DietaryPreference.glutenFree,
        DietaryPreference.dairyFree,
        DietaryPreference.none,
      ],
      instructions:
          'Oven-baked cod fillet with roasted zucchini, peppers, and olive oil.',
      prepMinutes: 30,
    ),
    FoodItem(
      id: 'fd_lentil_curry',
      name: 'Red Lentil Dahl',
      category: MealType.dinner,
      calories: 500,
      proteinG: 26,
      carbsG: 70,
      fatsG: 10,
      suitableFor: [
        DietaryPreference.vegan,
        DietaryPreference.vegetarian,
        DietaryPreference.dairyFree,
      ],
      instructions:
          'Simmer red lentils with tomato, turmeric, cumin; serve with brown rice.',
      prepMinutes: 30,
    ),
    FoodItem(
      id: 'fd_chicken_sweet_potato',
      name: 'Herb Chicken with Sweet Potato Mash',
      category: MealType.dinner,
      calories: 610,
      proteinG: 50,
      carbsG: 55,
      fatsG: 16,
      suitableFor: [DietaryPreference.none, DietaryPreference.glutenFree],
      instructions:
          'Roast herb-marinated chicken thigh, mashed sweet potato, green beans.',
      prepMinutes: 35,
    ),
    FoodItem(
      id: 'fd_tofu_stirfry',
      name: 'Crispy Tofu & Broccoli Stir-Fry',
      category: MealType.dinner,
      calories: 480,
      proteinG: 28,
      carbsG: 48,
      fatsG: 18,
      suitableFor: [
        DietaryPreference.vegan,
        DietaryPreference.vegetarian,
        DietaryPreference.dairyFree,
      ],
      instructions:
          'Pan-fry cubed tofu until crispy, toss with broccoli and stir-fry sauce.',
      prepMinutes: 20,
    ),
    FoodItem(
      id: 'fd_keto_salmon_asparagus',
      name: 'Pan-Seared Salmon & Asparagus',
      category: MealType.dinner,
      calories: 540,
      proteinG: 42,
      carbsG: 8,
      fatsG: 36,
      suitableFor: [
        DietaryPreference.keto,
        DietaryPreference.pescatarian,
        DietaryPreference.glutenFree,
        DietaryPreference.dairyFree,
      ],
      instructions:
          'Pan-sear salmon in butter/ghee, serve with grilled asparagus.',
      prepMinutes: 18,
    ),

    // Snacks
    FoodItem(
      id: 'fd_protein_shake',
      name: 'Whey Protein Shake',
      category: MealType.snack,
      calories: 160,
      proteinG: 25,
      carbsG: 6,
      fatsG: 3,
      suitableFor: [
        DietaryPreference.none,
        DietaryPreference.vegetarian,
        DietaryPreference.glutenFree,
      ],
      instructions: 'Shake one scoop whey with water or milk.',
      prepMinutes: 2,
    ),
    FoodItem(
      id: 'fd_almonds_apple',
      name: 'Apple & Almonds',
      category: MealType.snack,
      calories: 220,
      proteinG: 6,
      carbsG: 26,
      fatsG: 12,
      suitableFor: [
        DietaryPreference.vegan,
        DietaryPreference.vegetarian,
        DietaryPreference.dairyFree,
        DietaryPreference.glutenFree,
        DietaryPreference.none,
      ],
      instructions: 'One medium apple with a small handful (20g) of almonds.',
      prepMinutes: 1,
    ),
    FoodItem(
      id: 'fd_cottage_cheese_pineapple',
      name: 'Cottage Cheese & Pineapple',
      category: MealType.snack,
      calories: 200,
      proteinG: 22,
      carbsG: 18,
      fatsG: 4,
      suitableFor: [
        DietaryPreference.vegetarian,
        DietaryPreference.none,
        DietaryPreference.glutenFree,
      ],
      instructions: '150g cottage cheese with fresh pineapple chunks.',
      prepMinutes: 2,
    ),
    FoodItem(
      id: 'fd_hummus_veg_sticks',
      name: 'Hummus & Veggie Sticks',
      category: MealType.snack,
      calories: 180,
      proteinG: 7,
      carbsG: 20,
      fatsG: 9,
      suitableFor: [
        DietaryPreference.vegan,
        DietaryPreference.vegetarian,
        DietaryPreference.dairyFree,
        DietaryPreference.glutenFree,
        DietaryPreference.none,
      ],
      instructions:
          'Carrot, celery, and bell pepper sticks with 3 tbsp hummus.',
      prepMinutes: 5,
    ),
    FoodItem(
      id: 'fd_boiled_eggs',
      name: 'Two Boiled Eggs',
      category: MealType.snack,
      calories: 155,
      proteinG: 13,
      carbsG: 1,
      fatsG: 11,
      suitableFor: [
        DietaryPreference.vegetarian,
        DietaryPreference.keto,
        DietaryPreference.glutenFree,
        DietaryPreference.dairyFree,
        DietaryPreference.none,
      ],
      instructions: 'Boil 2 eggs for 8-10 minutes, season with salt & pepper.',
      prepMinutes: 10,
    ),
    FoodItem(
      id: 'fd_mixed_nuts',
      name: 'Mixed Nuts (Keto Snack)',
      category: MealType.snack,
      calories: 210,
      proteinG: 7,
      carbsG: 6,
      fatsG: 18,
      suitableFor: [
        DietaryPreference.keto,
        DietaryPreference.vegan,
        DietaryPreference.vegetarian,
        DietaryPreference.dairyFree,
        DietaryPreference.glutenFree,
      ],
      instructions: '30g mixed nuts (almonds, walnuts, macadamias).',
      prepMinutes: 1,
    ),
  ];

  static FoodItem byId(String id) =>
      all.firstWhere((f) => f.id == id, orElse: () => all.first);

  static List<FoodItem> forCategory(
    MealType type,
    List<DietaryPreference> preferences,
    List<String> dislikedFoods,
  ) {
    return all.where((f) {
      final matchesCategory = f.category == type;
      final matchesDiet =
          preferences.contains(DietaryPreference.none) ||
          preferences.any((p) => f.suitableFor.contains(p));
      final notDisliked = !dislikedFoods.any(
        (d) =>
            f.name.toLowerCase().contains(d.trim().toLowerCase()) &&
            d.trim().isNotEmpty,
      );
      return matchesCategory && matchesDiet && notDisliked;
    }).toList();
  }
}
