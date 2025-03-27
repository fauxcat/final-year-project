import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import '../models/nutrition_goals.dart';

// Goal setting screen
class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final _formKey = GlobalKey<FormState>(); // Form validation key
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatsController;

  @override
  void initState() {
    super.initState();
    // Initialise controllers with current goals
    NutritionGoals current = HiveService.currentGoals;
    _caloriesController =
        TextEditingController(text: current.calories.toStringAsFixed(0));
    _proteinController =
        TextEditingController(text: current.protein.toStringAsFixed(0));
    _carbsController =
        TextEditingController(text: current.carbs.toStringAsFixed(0));
    _fatsController =
        TextEditingController(text: current.fats.toStringAsFixed(0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Goals')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Input fields for each goal
              _buildGoalField('Calories (kCal)', _caloriesController),
              _buildGoalField('Protein (g)', _proteinController),
              _buildGoalField('Carbohydrates (g)', _carbsController),
              _buildGoalField('Fats (g)', _fatsController),
              const SizedBox(height: 20),
              // Save button with validation
              ElevatedButton(
                onPressed: _saveGoals,
                child: const Text('Save Goals'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to standardise goal input fields
  Widget _buildGoalField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white, fontSize: 20),
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Please enter $label';
          final parsedValue = double.tryParse(value);
          if (parsedValue == null) return 'Invalid number';
          if (parsedValue <= 0) return 'Must be greater than 0';
          return null;
        },
      ),
    );
  }

  // Save goals to Hive after validation
  void _saveGoals() {
    if (_formKey.currentState!.validate()) {
      NutritionGoals newGoals = NutritionGoals(
        calories: double.parse(_caloriesController.text),
        protein: double.parse(_proteinController.text),
        carbs: double.parse(_carbsController.text),
        fats: double.parse(_fatsController.text),
      );
      HiveService.saveGoals(newGoals);
      // Show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Goals updated!')),
      );
    }
  }
}
