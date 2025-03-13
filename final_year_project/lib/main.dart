import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For setting window size
import 'screens/home_screen.dart';
import 'screens/food_screen.dart';
import 'screens/exercise_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
        primarySwatch: Colors.grey, // Primary color for buttons, app bar, etc.
        scaffoldBackgroundColor: const Color.fromARGB(
            255, 26, 26, 26), // Set background to dark grey
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black, // Set app bar background to black
          foregroundColor: Colors.white, // Set app bar text/icons to white
        ),
        textTheme: const TextTheme(
          bodyLarge:
              TextStyle(color: Colors.white), // Set default text color to white
          bodyMedium: TextStyle(color: Colors.white),
        ),
        useMaterial3: true,
        // Customize button themes
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                Colors.grey[800], // Grey background for ElevatedButton
            foregroundColor: Colors.white, // White text for ElevatedButton
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[300], // Light grey text for TextButton
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor:
                Colors.grey[300], // Light grey text for OutlinedButton
            side: BorderSide(
                color: Colors.grey[700]!), // Grey border for OutlinedButton
          ),
        ),
      ),
      home: const MainNavigationWrapper(), // Use a wrapper for navigation
    );
  }
}

// Wrapper to manage navigation state
class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _selectedIndex = 0; // Start with Home selected

  // List of screens
  final List<Widget> _screens = [
    const HomeScreen(),
    const PlaceholderScreen(title: 'Progress'), // Placeholder for Progress
    const PlaceholderScreen(title: 'Goals'), // Placeholder for Goals
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex], // Display the selected screen
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
        selectedItemColor: Colors.white, // Selected item color
        unselectedItemColor: Colors.grey, // Unselected item color
      ),
    );
  }
}

// Placeholder screen for unimplemented pages
class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$title Screen',
        style: const TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }
}
