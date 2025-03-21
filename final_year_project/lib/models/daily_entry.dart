import 'food_item.dart';
import 'nutrition_goals.dart';

// Will be used later to separate storage of food and exercises into different days

class DailyEntry {
  final DateTime date;
  final NutritionGoals goals;
  final List<FoodItem> foods;

  DailyEntry({
    required this.date,
    required this.goals,
    required this.foods,
  });
}
