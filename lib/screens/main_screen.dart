import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'decision_details_screen.dart';
import 'profile_screen.dart';
import 'analytics_screen.dart'; // 🔹 Imported the new screen

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // 🔹 Replaced Placeholder() with AnalyticsScreen()
  final List<Widget> _pages = const [
    DashboardScreen(),
    DecisionDetailsScreen(),
    AnalyticsScreen(), 
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black12,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          items: [
            _navItem(Icons.home, "Home", 0),
            _navItem(Icons.assignment, "Decisions", 1),
            _navItem(Icons.bar_chart, "Analytics", 2),
            _navItem(Icons.person, "Profile", 3),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _navItem(
      IconData icon, String label, int index) {
    bool active = _currentIndex == index;

    return BottomNavigationBarItem(
      icon: Icon(
        icon,
        color: active ? Colors.blue : Colors.grey,
        shadows: active
            ? [
                Shadow(
                  blurRadius: 12,
                  color: Colors.blue.withOpacity(0.6),
                )
              ]
            : [],
      ),
      label: label,
    );
  }
}