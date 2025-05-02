import 'nutrition_goals.dart';

// Separate storage of food and exercises into different days - accessed by date

class DailyEntry {
  final DateTime date;
  final NutritionGoals goals;

  DailyEntry({
    required this.date,
    required this.goals,
  });
}
