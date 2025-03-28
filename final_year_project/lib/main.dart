import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // To set window size
import 'services/hive_service.dart'; // To initialise hive db
import 'screens/home_screen.dart'; // To load to home screen on startup
import 'screens/goals_screen.dart'; // To load goals screen

void main() async {
  // Initialise Flutter engine
  WidgetsFlutterBinding.ensureInitialized();

  // Lock device to portrait mode (may not be needed idk)
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Initialise hive db
  await HiveService.init();

  runApp(const FitnessTrackerApp());
}

class FitnessTrackerApp extends StatelessWidget {
  const FitnessTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // App-wide theming config - Dark-mode focused
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: const Color.fromARGB(255, 26, 26, 26),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
        useMaterial3: true,
        // Buttom theming
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[800],
            foregroundColor: Colors.white,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[300],
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.grey,
            side: const BorderSide(color: Colors.grey),
          ),
        ),
      ),
      home: const MainNavigationWrapper(), // Navigation manager
    );
  }
}

// Bottom nav and screen manager
class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _selectedIndex = 0; // Start with Home selected

  // List of screens
  final List<Widget> _screens = const [
    HomeScreen(), // Main/home/dashboard screen
    PlaceholderScreen(title: 'Progress'), // Placeholder for progress
    GoalsScreen(), // Placeholder for goals
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex], // Display selected screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.insights), label: 'Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Goals'),
        ],
        backgroundColor: Colors.black, // Nav bar background
        selectedItemColor: Colors.white, // Selected item colour
        unselectedItemColor: Colors.grey, // Unselected item colour
      ),
    );
  }
}

// Placeholder screen for progress
class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$title Screen (WIP)',
        style: const TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }
}
