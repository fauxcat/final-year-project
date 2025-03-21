class FoodItem {
  final String name;
  final double mass;
  final double carbs;
  final double protein;
  final double fats;
  final double calories;

  FoodItem({
    required this.name,
    required this.mass,
    required this.carbs,
    required this.protein,
    required this.fats,
    required this.calories,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    final nutriments = json['nutriments'] ?? {};
    return FoodItem(
      name: json['product_name'] ?? 'Unknown Food',
      mass: 100.0, // Default to 100g base
      carbs: _parseDouble(nutriments['carbohydrates_100g']),
      protein: _parseDouble(nutriments['proteins_100g']),
      fats: _parseDouble(nutriments['fat_100g']),
      calories: _parseDouble(nutriments['energy-kcal_100g']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  FoodItem copyWithMass(double newMass) {
    final ratio = newMass / mass;
    return FoodItem(
      name: name,
      mass: newMass,
      carbs: carbs * ratio,
      protein: protein * ratio,
      fats: fats * ratio,
      calories: calories * ratio,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'mass': mass,
      'carbs': carbs,
      'protein': protein,
      'fats': fats,
      'calories': calories,
    };
  }
}
