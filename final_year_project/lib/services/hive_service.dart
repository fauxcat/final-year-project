import 'package:hive_flutter/hive_flutter.dart';
import '../models/food_item.dart';
import '../models/nutrition_goals.dart';

class HiveService {
  static const String foodBoxName = 'foodItems';
  static const String goalsBoxName = 'nutritionGoals';
  static const String dateBoxName = 'currentDate';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(FoodItemAdapter());
    Hive.registerAdapter(NutritionGoalsAdapter());
    await Hive.openBox<FoodItem>(foodBoxName);
    await Hive.openBox<NutritionGoals>(goalsBoxName);
    await Hive.openBox<DateTime>(dateBoxName);
  }

  static Box<FoodItem> get foodBox => Hive.box<FoodItem>(foodBoxName);

  static Future<int> addFoodItem(FoodItem item) async {
    final key = await foodBox.add(item);
    await foodBox.put(key, item.copyWith(key: key));
    return key;
  }

  static Future<void> updateFoodItem(FoodItem item) async {
    if (item.key != null) {
      await foodBox.put(item.key, item);
    }
  }

  static Future<void> deleteFoodItem(int key) async {
    await foodBox.delete(key);
  }

  static List<FoodItem> getDailyFoodItems(DateTime date) {
    return foodBox.values
        .where((item) =>
            item.date.year == date.year &&
            item.date.month == date.month &&
            item.date.day == date.day)
        .toList()
        .map((item) => item.copyWith(
            key: foodBox.keyAt(foodBox.values.toList().indexOf(item))))
        .toList();
  }

  static Box<NutritionGoals> get goalsBox =>
      Hive.box<NutritionGoals>(goalsBoxName);
  static Future<void> saveGoals(NutritionGoals goals) =>
      goalsBox.put('current', goals);
  static NutritionGoals get currentGoals =>
      goalsBox.get('current') ??
      NutritionGoals(
        calories: 2000,
        carbs: 195,
        protein: 130,
        fats: 60,
      );

  static Box<DateTime> get dateBox => Hive.box<DateTime>(dateBoxName);
  static DateTime get currentDate => dateBox.get('current') ?? DateTime.now();
  static Future<void> setCurrentDate(DateTime date) =>
      dateBox.put('current', date);
}
