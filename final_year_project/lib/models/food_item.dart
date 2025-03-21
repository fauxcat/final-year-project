import 'package:hive/hive.dart';

part 'food_item.g.dart';

// Used for storing food items in Hive

@HiveType(typeId: 0) // this id identifies the FoodItem class in Hive
class FoodItem {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final double mass;

  @HiveField(2)
  final double caloriesPer100g; // Stored as per 100g values

  @HiveField(3)
  final double proteinPer100g;

  @HiveField(4)
  final double carbsPer100g;

  @HiveField(5)
  final double fatsPer100g;

  @HiveField(6)
  final DateTime date;

  @HiveField(7)
  final int? key; // Unique key for each food item

  FoodItem({
    required this.name,
    required this.mass,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatsPer100g,
    required this.date,
    this.key,
  });

  double get calories => (caloriesPer100g * mass) / 100;
  double get protein => (proteinPer100g * mass) / 100;
  double get carbs => (carbsPer100g * mass) / 100;
  double get fats => (fatsPer100g * mass) / 100;

  FoodItem copyWith({
    String? name,
    double? mass,
    double? caloriesPer100g,
    double? proteinPer100g,
    double? carbsPer100g,
    double? fatsPer100g,
    DateTime? date,
    int? key,
  }) {
    return FoodItem(
      name: name ?? this.name,
      mass: mass ?? this.mass,
      caloriesPer100g: caloriesPer100g ?? this.caloriesPer100g,
      proteinPer100g: proteinPer100g ?? this.proteinPer100g,
      carbsPer100g: carbsPer100g ?? this.carbsPer100g,
      fatsPer100g: fatsPer100g ?? this.fatsPer100g,
      date: date ?? this.date,
      key: key ?? this.key,
    );
  }
}
