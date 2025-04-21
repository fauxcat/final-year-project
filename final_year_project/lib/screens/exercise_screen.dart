import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../services/hive_service.dart';
import '../data/exercise_data.dart';

// Exercise logging and management screen

class ExerciseScreen extends StatefulWidget {
  final DateTime selectedDate;

  const ExerciseScreen({super.key, required this.selectedDate});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  late List<Exercise> _exercises;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  // Loads exercises from hive db for selected date
  void _loadExercises() {
    setState(() {
      _exercises = HiveService.getDailyExercises(widget.selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Log'),
        actions: [
          // Help button for user info
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: Stack(
        children: [
          // List of recorded exercises
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _exercises.length,
            itemBuilder: (context, index) => _exerciseTile(_exercises[index]),
          ),
          // Button to add new exercises
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: _addExercise,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Add Exercise'),
            ),
          ),
        ],
      ),
    );
  }

  // Builds individual exercise tiles in list
  Widget _exerciseTile(Exercise exercise) {
    return Card(
      color: Colors.grey[900],
      child: ListTile(
        title: Text(exercise.name, style: const TextStyle(color: Colors.white)),
        subtitle: Text('${exercise.sets.length} sets',
            style: const TextStyle(color: Colors.white70)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white70),
        onTap: () => _showExerciseDetails(exercise),
      ),
    );
  }

  // Handles adding new exercises through bottom sheet selection
  void _addExercise() async {
    final selectedExercise = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => AddExerciseSheet(),
    );

    if (selectedExercise != null) {
      // Create and save new exercise entry
      final newExercise = Exercise(
        name: selectedExercise,
        date: widget.selectedDate,
        sets: [],
      );
      await HiveService.addExercise(newExercise);
      setState(() {
        _exercises = HiveService.getDailyExercises(widget.selectedDate);
      });
    }
  }

  // Shows detailed view for an exercise, allowing update and deletion
  void _showExerciseDetails(Exercise exercise) async {
    if (exercise.key == null) return;

    final result = await showDialog<Exercise?>(
      context: context,
      builder: (context) => ExerciseDetailsDialog(exercise: exercise),
      barrierDismissible: false, // Prevent closing by clicking outside
    );

    // Handle different button press results
    if (result != null) {
      if (result == exercise) {
        // Delete case
        await HiveService.exerciseBox.delete(exercise.key!);
        setState(() => _exercises.removeWhere((e) => e.key == exercise.key));
      } else {
        // Update case
        await HiveService.exerciseBox.put(exercise.key!, result);
        setState(() {
          final index = _exercises.indexWhere((e) => e.key == exercise.key);
          _exercises[index] = result;
        });
      }
    }
  }

  // Displays help dialog for exercise screen
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
              '• Tap exercise for details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            Text(
              '• Add/edit sets in details view',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            Text(
              '• Delete exercises or individual sets',
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

// Dialog for managing exercises sets and details
class ExerciseDetailsDialog extends StatefulWidget {
  final Exercise exercise;

  const ExerciseDetailsDialog({super.key, required this.exercise});

  @override
  State<ExerciseDetailsDialog> createState() => _ExerciseDetailsDialogState();
}

class _ExerciseDetailsDialogState extends State<ExerciseDetailsDialog> {
  late List<ExerciseSet> _tempSets;

  @override
  void initState() {
    super.initState();
    // Create a temp copy of the sets
    _tempSets = List.from(widget.exercise.sets);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: Text(widget.exercise.name,
          style: const TextStyle(color: Colors.white)),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Display existing sets
            ..._tempSets
                .asMap()
                .entries
                .map((entry) => _buildSetRow(entry.key, entry.value)),
            const SizedBox(height: 16),
            // Add new set button
            ElevatedButton(
              onPressed: _addSet,
              child: const Text('Add Set'),
            ),
          ],
        ),
      ),
      actions: [
        // Details control buttons
        TextButton(
          onPressed: () => Navigator.pop(context), // Close without saving
          child: const Text('Close', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () => _confirmDeleteExercise(context),
          child: const Text('Delete Exercise',
              style: TextStyle(color: Colors.red)),
        ),
        TextButton(
          onPressed: () {
            final updatedExercise = widget.exercise.copyWith(sets: _tempSets);
            Navigator.pop(context, updatedExercise);
          },
          child: const Text('Save', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  // Builds individual set rows in the exercise details dialog
  Widget _buildSetRow(int index, ExerciseSet set) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title:
          Text('Set ${index + 1}', style: const TextStyle(color: Colors.white)),
      subtitle: Text('${set.weight}kg × ${set.reps} reps',
          style: const TextStyle(color: Colors.white70)),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () => _deleteSet(index),
      ),
    );
  }

  // Handles adding new sets
  void _addSet() async {
    final newSet = await showDialog<ExerciseSet>(
      context: context,
      builder: (context) => const AddSetDialog(),
    );

    if (newSet != null) {
      setState(() {
        _tempSets.add(newSet);
      });
    }
  }

  // Handles deleting sets from an exercise
  void _deleteSet(int index) {
    setState(() {
      _tempSets.removeAt(index);
    });
  }

  // Confirms deletion of an exercise
  void _confirmDeleteExercise(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Delete Exercise',
            style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure? This cannot be undone.',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Return the original exercise to signal deletion
      Navigator.pop(context, widget.exercise);
    }
  }
}

// Dialog for adding new sets to an exercise
class AddSetDialog extends StatelessWidget {
  const AddSetDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController weightController = TextEditingController();
    final TextEditingController repsController = TextEditingController();

    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: const Text('Add Set', style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Input fields for weight and reps
          TextField(
            style: const TextStyle(color: Colors.white),
            controller: weightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                )),
          ),
          TextField(
            controller: repsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                labelText: 'Reps',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                )),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white)),
        ),
        ElevatedButton(
          onPressed: () {
            // Validate input and create new set
            final weight = double.tryParse(weightController.text);
            final reps = int.tryParse(repsController.text);

            if (weight == null || weight <= 0 || reps == null || reps <= 0) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Invalid Input'),
                  content: const Text(
                      'Please enter valid weight (>0) and reps (>0)'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
              return;
            }
            Navigator.pop(context, ExerciseSet(weight: weight, reps: reps));
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class AddExerciseSheet extends StatelessWidget {
  final List<String> filteredExercises =
      predefinedExercises; // Uses exercise_data.dart - should be improved

  AddExerciseSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[900],
      child: Column(
        children: [
          // Exercise list
          Expanded(
            child: ListView.builder(
              itemCount: filteredExercises.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(filteredExercises[index],
                    style: const TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context, filteredExercises[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
