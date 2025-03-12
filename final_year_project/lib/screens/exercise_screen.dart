// exercise_log_screen.dart
import 'package:flutter/material.dart';

class ExerciseLogScreen extends StatelessWidget {
  const ExerciseLogScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercise Log')),
      body: const Center(child: Text('Exercise logging screen')),
    );
  }
}
