import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../services/open_food_facts_service.dart';

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  // Dummy data - replace with real data later
  final List<Map<String, dynamic>> _foodItems = [
    {
      'name': 'Sandwich',
      'mass': 365.0,
      'calories': 658.0,
      'protein': 30.0,
      'carbs': 50.0,
      'fats': 20.0
    },
    {
      'name': 'Milkshake',
      'mass': 500.0,
      'calories': 398.0,
      'protein': 8.0,
      'carbs': 62.0,
      'fats': 12.0
    },
  ];

  final Map<String, dynamic> _macros = {
    'protein': {'current': 59, 'goal': 130},
    'carbs': {'current': 220, 'goal': 195},
    'fats': {'current': 38, 'goal': 60},
  };

  Map<String, double> _calculateTotals() {
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFats = 0;

    for (var item in _foodItems) {
      totalCalories += item['calories'];
      totalProtein += item['protein'];
      totalCarbs += item['carbs'];
      totalFats += item['fats'];
    }

    return {
      'calories': totalCalories,
      'protein': totalProtein,
      'carbs': totalCarbs,
      'fats': totalFats,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Log'),
        actions: [
          // Help button in the top-right corner
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFoodItem,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCalorieHeader(),
            const SizedBox(height: 20),
            _buildFoodList(),
            const SizedBox(height: 20),
            _buildMacroNutrients(),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieHeader() {
    final totals = _calculateTotals();
    return Center(
      child: Text(
        '${totals['calories']!.round()}/${_macros['calorieGoal']} Calories',
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildFoodList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "What you've eaten today",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        const Divider(),
        ..._foodItems.map((item) => _foodItemRow(item)),
      ],
    );
  }

  Widget _foodItemRow(Map<String, dynamic> item) {
    return InkWell(
      onTap: () => _showItemOptions(item),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(item['name'], style: const TextStyle(fontSize: 12)),
            Text('${item['mass'].round()}g',
                style: const TextStyle(fontSize: 12)),
            Text('${item['calories'].round()}kCal',
                style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroNutrients() {
    return Column(
      children: [
        const Text(
          'Macronutrient Breakdown',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        ..._macros.entries.map((entry) => _buildMacroRow(
            entry.key, entry.value['current'], entry.value['goal']))
      ],
    );
  }

  Widget _buildMacroRow(String type, int current, int goal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child:
                Text(type.capitalise(), style: const TextStyle(fontSize: 16)),
          ),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: current / goal,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                  current > goal ? Colors.green : Colors.blue),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text('$current/${goal}g',
                textAlign: TextAlign.right,
                style: TextStyle(
                    color: current > goal ? Colors.green : Colors.white)),
          ),
        ],
      ),
    );
  }

  void _addFoodItem() async {
    final newFood = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddFoodSheet(),
    );

    if (newFood != null) {
      setState(() {
        _foodItems.add(newFood);
      });

      // Force UI refresh for macros
      _calculateTotals();
    }
  }

  void _showItemOptions(Map<String, dynamic> item) {
    // Store original values as doubles
    final originalMass = item['mass'].toDouble();
    final originalCalories = item['calories'].toDouble();
    final originalProtein = item['protein'].toDouble();
    final originalCarbs = item['carbs'].toDouble();
    final originalFats = item['fats'].toDouble();

    final TextEditingController massController = TextEditingController(
      text: item['mass'].toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, dialogSetState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            item['name'],
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Calories: ${item['calories'].round()} kCal',
                  style: const TextStyle(color: Colors.white)),
              Text('Protein: ${item['protein'].round()} g',
                  style: const TextStyle(color: Colors.white)),
              Text('Carbs: ${item['carbs'].round()} g',
                  style: const TextStyle(color: Colors.white)),
              Text('Fats: ${item['fats'].round()} g',
                  style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 16),
              TextField(
                controller: massController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Mass (g)',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  if (value.isEmpty) return;
                  try {
                    final newMass = double.parse(value);
                    final scaleFactor = newMass / originalMass;

                    // Update dialog UI
                    dialogSetState(() {
                      item['mass'] = newMass;
                      item['calories'] =
                          (originalCalories * scaleFactor).round();
                      item['protein'] = (originalProtein * scaleFactor).round();
                      item['carbs'] = (originalCarbs * scaleFactor).round();
                      item['fats'] = (originalFats * scaleFactor).round();
                    });

                    // Update parent UI
                    setState(() {}); // This triggers FoodScreen rebuild
                  } catch (e) {
                    // Handle invalid input
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Update parent state
                setState(() {
                  _foodItems.remove(item);
                });
                Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900], // Dark grey background
        title: const Text(
          'Help',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '• Tap food item for details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            Text(
              '• Details include macronutrients and calories',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            Text(
              '• Edit mass or delete food items within details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class AddFoodSheet extends StatefulWidget {
  const AddFoodSheet({super.key});

  @override
  State<AddFoodSheet> createState() => _AddFoodSheetState();
}

class _AddFoodSheetState extends State<AddFoodSheet> {
  final OpenFoodFactsService _apiService = OpenFoodFactsService();
  final TextEditingController _searchController = TextEditingController();
  List<FoodItem> _searchResults = [];
  bool _isSearching = false;
  String? _errorMessage;

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _errorMessage = null;
      _searchResults = [];
    });

    try {
      final results = await _apiService.searchFoods(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
        _errorMessage = 'Failed to search foods: ${e.toString()}';
      });
    }
  }

  void _handleFoodSelection(FoodItem food, BuildContext context) {
    final TextEditingController massController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          "Add ${food.name}",
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNutritionInfoRow('Calories', '${food.calories.round()} kcal'),
            _buildNutritionInfoRow('Carbs', '${food.carbs.round()}g'),
            _buildNutritionInfoRow('Protein', '${food.protein.round()}g'),
            _buildNutritionInfoRow('Fats', '${food.fats.round()}g'),
            const SizedBox(height: 16),
            TextField(
              controller: massController,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Mass (grams)',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              final mass = double.tryParse(massController.text) ?? 0;
              if (mass > 0) {
                final adjustedFood = food.copyWithMass(mass);

                // Close both dialog and bottom sheet
                Navigator.pop(context);
                Navigator.pop(context, adjustedFood.toMap());
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white70, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_errorMessage != null) {
      return Center(
          child: Text(_errorMessage!,
              style: const TextStyle(color: Colors.white)));
    }

    if (_searchResults.isEmpty && !_isSearching) {
      return const Center(
          child: Text(
        'No results found',
        style: TextStyle(color: Colors.white),
      ));
    }

    return ListView.separated(
      itemCount: _searchResults.length,
      separatorBuilder: (_, __) => const Divider(
        color: Colors.grey,
        height: 1,
      ),
      itemBuilder: (context, index) {
        final food = _searchResults[index];
        return ListTile(
          tileColor: Colors.grey[800],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: Text(
            food.name,
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            '${food.mass.round()}g • ${food.calories.round()} kcal',
            style: const TextStyle(color: Colors.white),
          ),
          trailing: const Icon(Icons.add_circle_outline),
          onTap: () => _handleFoodSelection(food, context),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[900], // BG colour for search sheet
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: Colors.white), // Input text color
              cursorColor: Colors.white,
              decoration: InputDecoration(
                labelText: 'Search food database',
                labelStyle: const TextStyle(color: Colors.white),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _performSearch(_searchController.text),
                ),
              ),
              onSubmitted: _performSearch,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isSearching
                  ? const Center(
                      child: CircularProgressIndicator(
                      color: Colors.white,
                    ))
                  : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }
}

// String capitalisation
extension StringExtension on String {
  String capitalise() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
