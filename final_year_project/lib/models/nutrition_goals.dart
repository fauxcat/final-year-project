class NutritionGoals {
  final double carbs;
  final double protein;
  final double fats;
  final double? calories; // Optional override

  NutritionGoals({
    required this.carbs,
    required this.protein,
    required this.fats,
    this.calories,
  });

  // Auto-calculate calories if not provided
  double get calculatedCalories =>
      calories ?? (carbs * 4) + (protein * 4) + (fats * 9);
}
