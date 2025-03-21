import 'package:hive/hive.dart';

part 'nutrition_goals.g.dart';

// Used for user nutrition goals (UNIMPLEMENTED)
@HiveType(typeId: 1) // this id identifies the NutritionGoals class in Hive
class NutritionGoals {
  @HiveField(0)
  final double calories;

  @HiveField(1)
  final double carbs;

  @HiveField(2)
  final double protein;

  @HiveField(3)
  final double fats;

  NutritionGoals({
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fats,
  });
}
