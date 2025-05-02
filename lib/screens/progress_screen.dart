import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../services/hive_service.dart';
import '../models/food_item.dart';
import '../models/exercise.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  DateTime? _startDate; // Selected start date
  DateTime? _endDate; // Selected end date
  Map<String, dynamic> _progressData = {}; // Stores calculated data

  // Handle start date selection
  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      // Date picker built into Flutter
      context: context,
      initialDate:
          _startDate ?? DateTime.now().subtract(const Duration(days: 1)),
      firstDate: DateTime(2000), // Earliest selectable date is year 2000
      lastDate: DateTime.now()
          .subtract(const Duration(days: 1)), // Latest date is today - 1 day
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: Colors.grey[800]!,
            onPrimary: Colors.white,
            surface: Colors.grey[900]!,
            onSurface: Colors.white,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        // If end date is before start date, reset end date
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = null;
        }
      });
    }
  }

  // Handle end date selection
  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ??
          (_startDate?.add(const Duration(days: 1)) ?? DateTime.now()),
      firstDate: _startDate?.add(const Duration(days: 1)) ?? DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: Colors.grey[800]!,
            onPrimary: Colors.white,
            surface: Colors.grey[900]!,
            onSurface: Colors.white,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  // Calculate progress data between selected dates
  void _generateProgress() {
    if (_startDate == null || _endDate == null) return;
    if (_endDate!.isBefore(_startDate!)) return;

    double totalCalories = 0;
    int totalExercises = 0;
    int totalSets = 0;

    // Iterate through each day in the range
    DateTime currentDay = _startDate!;
    while (currentDay.isBefore(_endDate!) ||
        currentDay.isAtSameMomentAs(_endDate!)) {
      // Get food data from hive db
      final List<FoodItem> dailyFood =
          HiveService.getDailyFoodItems(currentDay);
      totalCalories += dailyFood.fold(0, (sum, item) => sum + item.calories);

      // Get exercise data from hive db
      final List<Exercise> dailyExercises =
          HiveService.getDailyExercises(currentDay);
      totalExercises += dailyExercises.length;
      totalSets +=
          dailyExercises.fold(0, (sum, exercise) => sum + exercise.sets.length);

      currentDay = currentDay.add(const Duration(days: 1));
    }

    // Calculate days between dates
    final daysBetween = _endDate!.difference(_startDate!).inDays + 1;

    // Update state with progress data to display
    setState(() {
      _progressData = {
        'totalCalories': totalCalories.round(),
        'averageCalories': (totalCalories / daysBetween).round(),
        'totalExercises': totalExercises,
        'totalSets': totalSets,
        'days': daysBetween,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progress Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Date Selection Row with buttons
            Row(
              children: [
                Expanded(
                  child: DatePickerButton(
                    label: 'Start Date',
                    selectedDate: _startDate,
                    onPressed: _selectStartDate,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DatePickerButton(
                    label: 'End Date',
                    selectedDate: _endDate,
                    onPressed: _selectEndDate,
                    enabled:
                        _startDate != null, // End date depeonds on start date
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Generate Button
            ElevatedButton(
              onPressed: _startDate != null && _endDate != null
                  ? _generateProgress
                  : null,
              child: const Text('Generate Results'),
            ),
            const SizedBox(height: 24),

            // Progress Display
            if (_progressData.isNotEmpty) ...[
              _buildProgressCard('Total Days', '${_progressData['days']}'),
              _buildProgressCard(
                  'Total Calories', '${_progressData['totalCalories']}'),
              _buildProgressCard('Daily Average Calories',
                  '${_progressData['averageCalories']}'),
              _buildProgressCard(
                  'Total Exercises', '${_progressData['totalExercises']}'),
              _buildProgressCard('Total Sets', '${_progressData['totalSets']}'),
            ] else if (_startDate != null || _endDate != null)
              const Text('No data found for selected period',
                  style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  // Create cards for each report metric
  Widget _buildProgressCard(String title, String value) {
    return Card(
      color: Colors.grey[900],
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.white70)),
        trailing: Text(value,
            style: const TextStyle(color: Colors.white, fontSize: 18)),
      ),
    );
  }
}

// Custom date picker button widget
class DatePickerButton extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final VoidCallback onPressed;
  final bool enabled;

  const DatePickerButton({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.grey[900],
        side: BorderSide(color: Colors.grey[700]!),
      ),
      onPressed: enabled ? onPressed : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Text(
              selectedDate != null
                  ? DateFormat('MMM dd, yyyy').format(selectedDate!)
                  : 'Select Date',
              style: TextStyle(
                color: enabled ? Colors.white : Colors.white54,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
