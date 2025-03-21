import 'package:flutter_test/flutter_test.dart';
import '../lib/models/daily_entry.dart';
import '../lib/models/food_item.dart';
import '../lib/models/nutrition_goals.dart';

void main() {
  test('DailyEntry model should properly reference other models', () {
    final goals = NutritionGoals(
      carbs: 150,
      protein: 150,
      fats: 80,
    );

    final foods = [
      FoodItem(
        name: 'Sandwich',
        mass: 200,
        carbs: 30,
        protein: 20,
        fats: 10,
        calories: 200,
      )
    ];

    final entry = DailyEntry(
      date: DateTime.now(),
      goals: goals,
      foods: foods,
    );

    expect(entry.goals.carbs, 150);
    expect(entry.foods.first.name, 'Sandwich');
    expect(entry.goals.calculatedCalories, 150 * 4 + 150 * 4 + 80 * 9);
  });
}
