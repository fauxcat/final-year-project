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
              // Safety guidelines card
              _buildSafetyGuidelines(),
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
      padding: const EdgeInsets.symmetric(vertical: 20.0),
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

  Widget _buildSafetyGuidelines() {
    return Card(
      color: Colors.black, //
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Nutrition Safety Guidelines',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Recommended Daily Intake:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text('• Women: 1,600 - 2,400 kCal'),
            const Text('• Men: 2,000 - 3,000 kCal'),
            const SizedBox(height: 12),
            Text(
              'Important:',
              style: TextStyle(
                color: Colors.red[800],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Calorie intake below 1,200 kCal for women or 1,500 kCal for men '
              'should only be undertaken with medical supervision. '
              '\n\nExtreme goals can lead to serious health consequences.',
              style: TextStyle(color: Colors.red[800]),
            ),
          ],
        ),
      ),
    );
  }

  // Show warning dialog if goals are outside recommended range
  void _saveGoals() async {
    if (_formKey.currentState!.validate()) {
      final calories = double.parse(_caloriesController.text);

      if (calories < 1500) {
        await _showWarningDialog(
          'Extremely Low Calorie Goal',
          'Goals below 1,200 kCal/day are generally not recommended without medical supervision. '
              '\n\nThis can lead to nutrient deficiencies and other health risks.',
        );
      } else if (calories > 3000) {
        await _showWarningDialog(
          'High Calorie Goal',
          'Goals above 3,000 kCal/day should be set with caution. '
              '\n\nEnsure this aligns with your activity level and health goals.',
        );
      }

      _saveConfirmed();
    }
  }

  // Saving goals to database after validation and warnings
  void _saveConfirmed() {
    NutritionGoals newGoals = NutritionGoals(
      calories: double.parse(_caloriesController.text),
      protein: double.parse(_proteinController.text),
      carbs: double.parse(_carbsController.text),
      fats: double.parse(_fatsController.text),
    );
    HiveService.saveGoals(newGoals);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Goals updated!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Show warning dialog for extreme goals
  Future<void> _showWarningDialog(String title, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          title: Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'I Understand',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
