import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/food_library.dart';
import '../../models/enums.dart';
import '../../models/food_item.dart';
import '../../providers/plan_provider.dart';
import '../../providers/user_provider.dart';

/// FR-3.3 (nutrition breakdown), FR-3.4 (swap), FR-3.5 (log eaten/skipped).
class MealDetailScreen extends StatelessWidget {
  final String mealId;
  const MealDetailScreen({super.key, required this.mealId});

  @override
  Widget build(BuildContext context) {
    final plan = context.watch<PlanProvider>();
    final meal = plan.mealPlan?.meals.firstWhere((m) => m.id == mealId);

    if (meal == null) {
      return const Scaffold(body: Center(child: Text('Meal not found')));
    }
    final food = meal.food;

    return Scaffold(
      appBar: AppBar(
        title: Text(meal.type.label),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Swap meal',
            onPressed: () => _showSwapSheet(context, plan),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        children: [
          Text(food.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            '${meal.slot.day.label} · ${meal.slot.startTimeLabel} · ${food.prepMinutes} min prep',
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Macro(label: 'Calories', value: '${food.calories}'),
                  _Macro(
                    label: 'Protein',
                    value: '${food.proteinG.toStringAsFixed(0)}g',
                  ),
                  _Macro(
                    label: 'Carbs',
                    value: '${food.carbsG.toStringAsFixed(0)}g',
                  ),
                  _Macro(
                    label: 'Fats',
                    value: '${food.fatsG.toStringAsFixed(0)}g',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('How to prepare', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(food.instructions),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    await plan.setMealStatus(meal.id, LogStatus.skipped);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Skip'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await plan.setMealStatus(meal.id, LogStatus.completed);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Log as eaten'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSwapSheet(BuildContext context, PlanProvider plan) {
    final meal = plan.mealPlan!.meals.firstWhere((m) => m.id == mealId);
    final profile = context.read<UserProvider>().profile;
    final alternatives = FoodLibrary.forCategory(
      meal.type,
      profile.dietaryPreferences,
      profile.dislikedFoods,
    ).where((f) => f.id != meal.food.id).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        expand: false,
        builder: (ctx, scrollCtrl) => ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Swap ${meal.type.label}',
              style: Theme.of(ctx).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (alternatives.isEmpty)
              const Text('No alternatives available for your preferences.'),
            ...alternatives.map(
              (FoodItem f) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(f.name),
                  subtitle: Text(
                    '${f.calories} kcal · P${f.proteinG.toInt()} C${f.carbsG.toInt()} F${f.fatsG.toInt()}',
                  ),
                  onTap: () async {
                    await plan.swapMeal(meal.id, f);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Macro extends StatelessWidget {
  final String label;
  final String value;
  const _Macro({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleMedium),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
