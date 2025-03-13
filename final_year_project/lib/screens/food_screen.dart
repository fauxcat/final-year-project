import 'package:flutter/material.dart';

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  // Dummy data - replace with real data later
  final List<Map<String, dynamic>> _foodItems = [
    {'name': 'Sandwich', 'mass': '365g', 'calories': '658kCal'},
    {'name': 'Milkshake', 'mass': '500g', 'calories': '398kCal'},
  ];

  final Map<String, dynamic> _macros = {
    'protein': {'current': 59, 'goal': 130},
    'carbs': {'current': 220, 'goal': 195},
    'fats': {'current': 38, 'goal': 60},
  };

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
    return const Center(
      child: Text(
        '1800/2000 Calories',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
            Text(item['name'], style: const TextStyle(fontSize: 20)),
            Text(item['mass'], style: const TextStyle(fontSize: 20)),
            Text(item['calories'], style: const TextStyle(fontSize: 20)),
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
                  current > goal ? Colors.red : Colors.blue),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text('$current/${goal}g',
                textAlign: TextAlign.right,
                style: TextStyle(
                    color: current > goal ? Colors.red : Colors.white)),
          ),
        ],
      ),
    );
  }

  void _addFoodItem() {
    // TODO: Implement add food
    showModalBottomSheet(
      context: context,
      builder: (context) => const AddFoodSheet(),
    );
  }

  void _showItemOptions(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item['name']),
        actions: [
          TextButton(onPressed: () {}, child: const Text('Edit Mass')),
          TextButton(onPressed: () {}, child: const Text('Macronutrients')),
          TextButton(onPressed: () {}, child: const Text('Delete')),
        ],
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

class AddFoodSheet extends StatelessWidget {
  const AddFoodSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Add Food Item',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Search for food',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Placeholder for adding food
              Navigator.pop(context); // Close the sheet
            },
            child: const Text('Add Food'),
          ),
        ],
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
