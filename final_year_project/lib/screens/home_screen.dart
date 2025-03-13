import 'package:flutter/material.dart';
import 'exercise_screen.dart';
import 'food_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness Tracker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Placeholder date selector (static text)
            const Text(
              'Monday 10th February 2025',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Core feature: Food/Exercise navigation buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavigationButton(
                  context: context,
                  label: 'Food',
                  onPressed: () => _navigateToFoodLog(context),
                ),
                _buildNavigationButton(
                  context: context,
                  label: 'Exercise',
                  onPressed: () => _navigateToExerciseLog(context),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Placeholder overview bar (static data)
            const _OverviewBar(calories: 1800, goal: 2000),
            const Spacer(),

            // Placeholder end log button (non-functional)
            const Center(
              child: ElevatedButton(
                onPressed: null, // Disabled for now
                child: Text('End Today\'s Log'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable navigation button widget
  Widget _buildNavigationButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }

  // Navigation methods (core functionality)
  void _navigateToFoodLog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FoodScreen()),
    );
  }

  void _navigateToExerciseLog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ExerciseScreen()),
    );
  }
}

// Placeholder overview widget
class _OverviewBar extends StatelessWidget {
  final int calories;
  final int goal;

  const _OverviewBar({
    required this.calories,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daily Overview',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          '$calories/$goal Calories',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
