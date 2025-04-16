import 'package:hive_flutter/hive_flutter.dart';
import '../models/food_item.dart';
import '../models/nutrition_goals.dart';
import '../models/exercise.dart';

class HiveService {
  // Hive box names
  static const String foodBoxName = 'foodItems';
  static const String goalsBoxName = 'nutritionGoals';
  static const String exerciseBoxName = 'exercises';
  static const String dateBoxName = 'currentDate';

  // Initialise hive and register adapters
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(FoodItemAdapter()); // Stores food items
    Hive.registerAdapter(NutritionGoalsAdapter()); // Stores nutrition goals
    Hive.registerAdapter(ExerciseAdapter()); // Stores exercise data
    Hive.registerAdapter(ExerciseSetAdapter()); // Stores exercise sets
// Opens all boxes
    await Hive.openBox<FoodItem>(foodBoxName);
    await Hive.openBox<NutritionGoals>(goalsBoxName);
    await Hive.openBox<DateTime>(dateBoxName);
    await Hive.openBox<Exercise>(exerciseBoxName);
  }

  // Food item operations
  static Box<FoodItem> get foodBox => Hive.box<FoodItem>(foodBoxName);

  // Add food item and return key
  static Future<int> addFoodItem(FoodItem item) async {
    final key = await foodBox.add(item);
    await foodBox.put(key, item.copyWith(key: key)); // Store with key
    return key;
  }

  // Update existing food item using key
  static Future<void> updateFoodItem(FoodItem item) async {
    if (item.key != null) {
      await foodBox.put(item.key, item);
    }
  }

  // Delete food item by key
  static Future<void> deleteFoodItem(int key) async {
    await foodBox.delete(key);
  }

  // Get food items for a specific date (will be used for daily tracking)
  static List<FoodItem> getDailyFoodItems(DateTime date) {
    try {
      return foodBox.values
          .where((item) =>
              item.date.year == date.year &&
              item.date.month == date.month &&
              item.date.day == date.day)
          .toList()
          .map((item) => item.copyWith(
              key: foodBox.keyAt(foodBox.values.toList().indexOf(item))))
          .toList();
    } catch (e) {
      // In case of errors return empty list
      print('Error fetching food items: $e');
      return [];
    }
  }

  // Nutrition goals operations
  static Box<NutritionGoals> get goalsBox =>
      Hive.box<NutritionGoals>(goalsBoxName);
  static Future<void> saveGoals(NutritionGoals goals) =>
      goalsBox.put('current', goals);

  // Get current goals or defaults if none set (always defaults currently)
  static NutritionGoals get currentGoals =>
      goalsBox.get('current') ??
      NutritionGoals(
        calories: 2500,
        carbs: 333,
        protein: 56,
        fats: 80,
      );

  // Date tracking
  static Box<DateTime> get dateBox => Hive.box<DateTime>(dateBoxName);
  static DateTime get currentDate => dateBox.get('current') ?? DateTime.now();
  static Future<void> setCurrentDate(DateTime date) =>
      dateBox.put('current', date);

  // Exercise operations
  static Box<Exercise> get exerciseBox => Hive.box<Exercise>(exerciseBoxName);

  static Future<int> addExercise(Exercise exercise) async {
    final int key = await exerciseBox.add(exercise);
    return key;
  }

  static Future<void> deleteExercise(int key) async {
    await exerciseBox.delete(key);
  }

  static List<Exercise> getDailyExercises(DateTime date) {
    return exerciseBox
        .toMap()
        .entries
        .where((entry) =>
            entry.value.date.year == date.year &&
            entry.value.date.month == date.month &&
            entry.value.date.day == date.day)
        .map((entry) => entry.value.copyWith(key: entry.key))
        .toList();
  }
}
