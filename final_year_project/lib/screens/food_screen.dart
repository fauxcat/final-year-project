// food_log_screen.dart
import 'package:flutter/material.dart';

class FoodLogScreen extends StatelessWidget {
  const FoodLogScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Food Log')),
      body: const Center(child: Text('Food logging screen')),
    );
  }
}
