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
  late DateTime _currentDate; // Current date for tracking

  // Date selector button methods
  void _previousDay() {
    setState(() {
      _currentDate = _currentDate.subtract(const Duration(days: 1));
      HiveService.setCurrentDate(_currentDate); // Persist date change
    });
  }

  // Increment date by 1, but not beyond present
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

  @override
  void initState() {
    super.initState();
    _currentDate = HiveService.currentDate; // Initialise with stored data
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

            // Overview section (calories / goal)
            Center(child: _OverviewBar(date: _currentDate)),
            const SizedBox(height: 16),

            // Exercise status text
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: Text(
                  _getExerciseStatus(),
                  style: const TextStyle(fontSize: 16),
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

  // Food navigation handler
  void _navigateToFoodLog(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodScreen(selectedDate: _currentDate),
      ),
    );
    setState(() {}); // Force refresh after returning
  }

  // Exercise navigation handler
  void _navigateToExerciseLog(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseScreen(selectedDate: _currentDate),
      ),
    );
    setState(() {}); // Force refresh after returning
  }

  // Exercise status text
  String _getExerciseStatus() {
    final exercises = HiveService.getDailyExercises(_currentDate);
    if (exercises.isEmpty) return 'You haven\'t worked out today!';

    final totalSets =
        exercises.fold(0, (sum, exercise) => sum + exercise.sets.length);
    return 'You have completed ${exercises.length} exercises and $totalSets sets today';
  }
}

// Progress bar and text for daily overview (food section)
class _OverviewBar extends StatelessWidget {
  final DateTime date;

  const _OverviewBar({required this.date});

  @override
  Widget build(BuildContext context) {
    final calories = HiveService.getDailyFoodItems(date)
        .fold(0, (sum, item) => sum + item.calories.round());
    final goal = HiveService.currentGoals.calories.round();
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
