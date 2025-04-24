import 'package:openfoodfacts/openfoodfacts.dart';
import '../models/food_item.dart';

class OpenFoodFactsService {
  // Main method to search food with API
  Future<List<FoodItem>> searchFoods(String query) async {
    assert(query.isNotEmpty, 'Search query cannot be empty');
    try {
      // Configure search parameters
      final parameters = ProductSearchQueryConfiguration(
        parametersList: [
          SearchTerms(terms: [query]) // Search query from user input
        ],
        language: OpenFoodFactsLanguage.ENGLISH,
        version: ProductQueryVersion.v3, // Latest API version
        fields: [ProductField.ALL], // Return all product fields
      );

      // Set required user agent (basic setup)
      OpenFoodAPIConfiguration.userAgent = UserAgent(
        name: 'Tracker App',
      );

      // API request
      final result = await OpenFoodAPIClient.searchProducts(
        null, // No user auth
        parameters,
      );

      // API response -> FoodItem object
      return result.products?.map((product) {
            final nutriments = product.nutriments;
            assert(
                product.productName != null, 'Product name should not be null');
            assert(nutriments != null,
                'Nutritional information should not be null');
            return FoodItem(
              name: product.productName?.trim() ?? 'Unnamed Food',
              mass: 100, // Serving size defaults to 100g
              // Nutritional values per 100g or default to 0
              caloriesPer100g: nutriments?.getValue(
                    Nutrient.energyKCal,
                    PerSize.oneHundredGrams,
                  ) ??
                  0,
              proteinPer100g: nutriments?.getValue(
                    Nutrient.proteins,
                    PerSize.oneHundredGrams,
                  ) ??
                  0,
              carbsPer100g: nutriments?.getValue(
                    Nutrient.carbohydrates,
                    PerSize.oneHundredGrams,
                  ) ??
                  0,
              fatsPer100g: nutriments?.getValue(
                    Nutrient.fat,
                    PerSize.oneHundredGrams,
                  ) ??
                  0,
              date: DateTime.now(), // Current date for tracking
            );
          }).toList() ?? // Null handling
          [];
    } catch (e, stackTrace) {
      // Error handling
      print('Search error: $e');
      print('Stack trace: $stackTrace');
      return []; // Return empty list on error
    }
  }
}
