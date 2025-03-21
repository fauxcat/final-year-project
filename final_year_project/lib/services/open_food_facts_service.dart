import 'package:openfoodfacts/openfoodfacts.dart';
import '../models/food_item.dart';

class OpenFoodFactsService {
  Future<List<FoodItem>> searchFoods(String query) async {
    try {
      final parameters = ProductSearchQueryConfiguration(
        parametersList: [
          SearchTerms(terms: [query])
        ],
        language: OpenFoodFactsLanguage.ENGLISH,
        version: ProductQueryVersion.v3,
        fields: [ProductField.ALL],
      );

      OpenFoodAPIConfiguration.userAgent = UserAgent(
        name: 'Tracker App',
      );

      final result = await OpenFoodAPIClient.searchProducts(
        null,
        parameters,
      );

      return result.products?.map((product) {
            final nutriments = product.nutriments;
            return FoodItem(
              name: product.productName?.trim() ?? 'Unnamed Food',
              mass: 100,
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
              date: DateTime.now(),
            );
          }).toList() ??
          [];
    } catch (e, stackTrace) {
      print('Search error: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }
}
