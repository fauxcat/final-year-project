import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/food_screen.dart';
import 'screens/exercise_screen.dart';

void main() {
  runApp(const FitnessTrackerApp());
}

class FitnessTrackerApp extends StatelessWidget {
  const FitnessTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      routes: {
        '/food': (context) => const FoodLogScreen(),
        '/exercise': (context) => const ExerciseLogScreen(),
      },
    );
  }
}
