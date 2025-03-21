import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/food_item.dart';

class OpenFoodFactsService {
  static const String _baseUrl =
      'https://world.openfoodfacts.org/cgi/search.pl';
  static const int _pageSize = 10;

  Future<List<FoodItem>> searchFoods(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?'
            'search_terms=${Uri.encodeQueryComponent(query)}&'
            'page_size=$_pageSize&'
            'json=1&'
            'fields=product_name,nutriments'),
      );

      if (response.statusCode == 200) {
        return _parseResults(response.body);
      }
      return [];
    } catch (e) {
      print('Search error: $e');
      return [];
    }
  }

  List<FoodItem> _parseResults(String responseBody) {
    final jsonData = jsonDecode(responseBody);
    final products = jsonData['products'] as List<dynamic>? ?? [];

    return products
        .where((p) => p['product_name'] != null)
        .map((product) => FoodItem.fromJson(product))
        .toList();
  }
}
