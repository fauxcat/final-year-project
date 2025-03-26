import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/food_item.dart';
import '../models/nutrition_goals.dart';
import '../services/hive_service.dart';
import '../services/open_food_facts_service.dart';

// Food logging screen
// Handles food item CRUD operations with Hive db and Food DB API integration

class FoodScreen extends StatefulWidget {
  final DateTime selectedDate;

  const FoodScreen({super.key, required this.selectedDate});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  late List<FoodItem> _foodItems; // Local cache of food entries
  late NutritionGoals _goals; // User set nutrition goals
  final OpenFoodFactsService _apiService =
      OpenFoodFactsService(); // Food DB API

  @override
  void initState() {
    super.initState();
    _loadDailyData(); // Initialise data from Hive db
  }

  // Loads current date's data from Hive
  void _loadDailyData() {
    setState(() {
      _foodItems = HiveService.getDailyFoodItems(widget.selectedDate);
      _goals = HiveService.currentGoals;
    });
  }

  // Calculate total calories and macronutrients from food items
  Map<String, double> _calculateTotals() {
    return {
      'calories': _foodItems.fold(0, (sum, item) => sum + item.calories),
      'protein': _foodItems.fold(0, (sum, item) => sum + item.protein),
      'carbs': _foodItems.fold(0, (sum, item) => sum + item.carbs),
      'fats': _foodItems.fold(0, (sum, item) => sum + item.fats),
    };
  }

  @override
  Widget build(BuildContext context) {
    final totals = _calculateTotals();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog, // Help alert pop-up
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFoodItem, // Add food button (should be updated)
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Calorie progress header
            _buildCalorieHeader(totals),
            const SizedBox(height: 20),

            // Food items list
            _buildFoodList(),
            const SizedBox(height: 20),

            // Macronutrient progress bars
            _buildMacroNutrients(totals),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  // Building above widgets

  Widget _buildCalorieHeader(Map<String, double> totals) {
    return Center(
      child: Text(
        '${totals['calories']!.round()}/${_goals.calories.round()} Calories',
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Scrollable food list
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

  // Indivudal rows for each food item
  Widget _foodItemRow(FoodItem item) {
    return InkWell(
      onTap: () => _showItemOptions(item),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(item.name, style: const TextStyle(fontSize: 12)),
            Text('${item.mass.round()}g', style: const TextStyle(fontSize: 12)),
            Text('${item.calories.round()}kCal',
                style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // Macronutrient progress bars
  Widget _buildMacroNutrients(Map<String, double> totals) {
    return Column(
      children: [
        const Text(
          'Macronutrient Breakdown',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        _buildMacroRow('Protein', totals['protein']!, _goals.protein),
        _buildMacroRow('Carbs', totals['carbs']!, _goals.carbs),
        _buildMacroRow('Fats', totals['fats']!, _goals.fats),
      ],
    );
  }

  // Individual row for macronutrient progress visualisation
  Widget _buildMacroRow(String type, double current, double goal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(type, style: const TextStyle(fontSize: 16)),
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
            child: Text('${current.round()}/${goal.round()}g',
                textAlign: TextAlign.right,
                style: TextStyle(
                    color: current > goal ? Colors.green : Colors.white)),
          ),
        ],
      ),
    );
  }

  // Food item management

  // Adds new food via modal bottom sheet search interface
  void _addFoodItem() async {
    final newFood = await showModalBottomSheet<FoodItem>(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddFoodSheet(apiService: _apiService),
    );

    if (newFood != null) {
      // Add food item to Hive db with current date
      final foodWithDate = newFood.copyWith(
        date: widget.selectedDate,
        key: null,
      );
      await HiveService.addFoodItem(foodWithDate);
      _loadDailyData(); // Reload UI after adding new food
      if (mounted) {
        Navigator.pop(context, true); // Pass true to say updated data
      }
    }
  }

  // Edits existing food item entry
  void _showItemOptions(FoodItem item) async {
    // Controller for mass text field
    final TextEditingController massController = TextEditingController(
      text: item.mass.toStringAsFixed(0),
    );

    // Track any changes locally
    FoodItem currentItem = item;

    // Show dialog for editing item
    final updatedItem = await showDialog<FoodItem>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, dialogSetState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(item.name,
              style: const TextStyle(color: Colors.white, fontSize: 20)),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food details
                  _buildNutritionRow(
                      'Calories', '${item.calories.round()} kCal'),
                  _buildNutritionRow('Protein', '${item.protein.round()} g'),
                  _buildNutritionRow('Carbs', '${item.carbs.round()} g'),
                  _buildNutritionRow('Fats', '${item.fats.round()} g'),
                  const SizedBox(height: 20),
                  // Edit mass
                  TextField(
                    controller: massController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Mass (grams)',
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(12),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      if (value.isEmpty) return;
                      try {
                        final newMass = double.parse(value);
                        dialogSetState(() {
                          currentItem = currentItem.copyWith(mass: newMass);
                        });
                      } catch (_) {}
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Delete item
                TextButton(
                  onPressed: () async {
                    if (currentItem.key != null) {
                      await HiveService.deleteFoodItem(currentItem.key!);
                    }
                    Navigator.pop(context);
                    _loadDailyData();
                  },
                  child: const Text('Delete',
                      style: TextStyle(color: Colors.red, fontSize: 16)),
                ),
                // Save updated item
                TextButton(
                  onPressed: () => Navigator.pop(context, currentItem),
                  child: const Text('Save',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    // Persist changes if saved
    if (updatedItem != null && updatedItem.key != null) {
      await HiveService.updateFoodItem(updatedItem);
      _loadDailyData();
      if (mounted) {
        Navigator.pop(context, true); // Pass true to say updated data
      }
    }
  }

  Widget _buildNutritionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 16)),
          Text(value,
              style: const TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }

  // Shows usage instructions for the food screen
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
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

// Food search modal bottom sheet

class AddFoodSheet extends StatefulWidget {
  final OpenFoodFactsService apiService;

  const AddFoodSheet({super.key, required this.apiService});

  @override
  State<AddFoodSheet> createState() => _AddFoodSheetState();
}

class _AddFoodSheetState extends State<AddFoodSheet> {
  // Manages food search state
  final TextEditingController _searchController = TextEditingController();
  List<FoodItem> _searchResults = [];
  bool _isSearching = false;
  String? _errorMessage;

  // Executes API search
  Future<void> _performSearch(String query) async {
    setState(() {
      _isSearching = true;
      _errorMessage = null;
      _searchResults = [];
    });

    try {
      final results = await widget.apiService.searchFoods(query);
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

  // Handle food selection after search and mass input
  Future<FoodItem?> _handleFoodSelection(
      FoodItem food, BuildContext context) async {
    final TextEditingController massController =
        TextEditingController(text: '100');

    return await showDialog<FoodItem>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text("Add ${food.name}",
            style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Displays food nutrition info after selection
            _buildNutritionInfoRow(
                'Calories / 100g', '${food.caloriesPer100g.round()} kcal'),
            _buildNutritionInfoRow(
                'Protein / 100g', '${food.proteinPer100g.round()}g'),
            _buildNutritionInfoRow(
                'Carbs / 100g', '${food.carbsPer100g.round()}g'),
            _buildNutritionInfoRow(
                'Fats / 100g', '${food.fatsPer100g.round()}g'),
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
              final mass = double.tryParse(massController.text) ?? 100;
              Navigator.pop(context, food.copyWith(mass: mass));
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // Builds nutrition info row for food search results
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

  // Builds search results list
  Widget _buildSearchResults() {
    if (_errorMessage != null) {
      return Center(
          child: Text(_errorMessage!,
              style: const TextStyle(color: Colors.white)));
    }

    if (_searchResults.isEmpty && !_isSearching) {
      return const Center(
          child:
              Text('No results found', style: TextStyle(color: Colors.white)));
    }

    return ListView.separated(
      itemCount: _searchResults.length,
      separatorBuilder: (_, __) => const Divider(color: Colors.grey, height: 1),
      itemBuilder: (context, index) {
        final food = _searchResults[index];
        return ListTile(
          tileColor: Colors.grey[800],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: Text(food.name, style: const TextStyle(color: Colors.white)),
          subtitle: Text(
              '${food.mass.round()}g • ${food.calories.round()} kcal',
              style: const TextStyle(color: Colors.white)),
          trailing: const Icon(Icons.add_circle_outline),
          onTap: () async {
            final result = await _handleFoodSelection(food, context);
            if (result != null) {
              Navigator.of(context).pop(result);
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search bar input
            TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
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
            // Loading/Search results list/Error state
            Expanded(
              child: _isSearching
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white))
                  : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }
}
