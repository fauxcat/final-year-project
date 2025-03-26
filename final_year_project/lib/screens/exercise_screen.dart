import 'package:flutter/material.dart';

// Placeholder for now
class ExerciseScreen extends StatefulWidget {
  final DateTime selectedDate;

  const ExerciseScreen({super.key, required this.selectedDate});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise'),
      ),
      body: const Center(
        child: Text('Exercise logging screen'),
      ),
    );
  }
}
