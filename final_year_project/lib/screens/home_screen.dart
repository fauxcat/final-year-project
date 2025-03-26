import '../services/hive_service.dart';
import 'package:flutter/material.dart';
import 'exercise_screen.dart';
import 'food_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime _currentDate;

  // Date selector button methods
  void _previousDay() {
    setState(() {
      _currentDate = _currentDate.subtract(const Duration(days: 1));
      HiveService.setCurrentDate(_currentDate);
    });
  }

  void _nextDay() {
    final now = DateTime.now();
    if (_currentDate.isBefore(now)) {
      setState(() {
        _currentDate = _currentDate.add(const Duration(days: 1));
        // Dont allow dates beyond today
        if (_currentDate.isAfter(now)) {
          _currentDate = now;
        }
        HiveService.setCurrentDate(_currentDate);
      });
    }
  }

  int _calculateCalories() {
    final items = HiveService.getDailyFoodItems(_currentDate);
    return items.fold(0, (sum, item) => sum + item.calories.round());
  }

  @override
  void initState() {
    super.initState();
    _currentDate = HiveService.currentDate;
  }

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
            // Date display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _previousDay,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    DateFormat('EEEE d MMMM y').format(_currentDate),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextDay,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Food/Exercise buttons
            Center(
              child: Column(
                children: [
                  _buildNavigationButton(
                    context: context,
                    label: 'Food',
                    icon: Icons.fastfood,
                    onPressed: () => _navigateToFoodLog(context),
                  ),
                  const SizedBox(height: 16),
                  _buildNavigationButton(
                    context: context,
                    label: 'Exercise',
                    icon: Icons.directions_run,
                    onPressed: () => _navigateToExerciseLog(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Placeholder overview bar (static data)
            Center(
                child: _OverviewBar(
                    calories: _calculateCalories(),
                    goal: HiveService.currentGoals.calories.round())),
            const SizedBox(height: 16),

            // Workout status
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: const Text(
                  'You haven\'t worked out today!',
                  style: TextStyle(fontSize: 16),
                ),
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
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 120,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Button nav methods
  void _navigateToFoodLog(BuildContext context) async {
    final needsRefresh = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => FoodScreen(selectedDate: _currentDate),
      ),
    );

    if (needsRefresh == true) {
      setState(() {}); // Force refresh with updated data
    }
  }

  void _navigateToExerciseLog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ExerciseScreen(selectedDate: _currentDate)),
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
    final progress = calories / goal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daily Overview',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          '$calories/$goal Calories',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: progress > 1 ? 1 : progress, // Cap at 100% if over goal
          minHeight: 12,
          borderRadius: BorderRadius.circular(6),
          backgroundColor: Colors.grey[800],
          valueColor: AlwaysStoppedAnimation<Color>(
            progress > 1 ? Colors.red : Colors.green,
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${(progress * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              color: progress > 1 ? Colors.red : Colors.green,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
