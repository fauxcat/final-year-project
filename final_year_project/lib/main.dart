import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // To set window size
import 'services/hive_service.dart'; // To initialise Hive
import 'screens/home_screen.dart'; // To load to home screen on startup

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await HiveService.init(); // Initialize Hive

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
        // Lots of styling, not important
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
        // Customize button themes
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
            foregroundColor: Colors.grey[300],
            side: BorderSide(color: Colors.grey[700]!),
          ),
        ),
      ),
      home: const MainNavigationWrapper(),
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
    const PlaceholderScreen(title: 'Progress'), // Placeholder for progress
    const PlaceholderScreen(title: 'Goals'), // Placeholder for goals
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

// Placeholder screen for progress and goals
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
