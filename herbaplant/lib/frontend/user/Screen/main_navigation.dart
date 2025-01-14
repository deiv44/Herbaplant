import 'package:flutter/material.dart';
import 'Homeuser.dart';
import 'Diagnose.dart';
import 'MyPlant.dart';
import 'Profileuser.dart';

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // List of screens
  final List<Widget> _screens = [
    HomeUser(),
    Diagnose(),
    MyPlant(),
    ProfileUserScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex], 
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, 
        onTap: _onItemTapped, 
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety),
            label: 'Diagnose',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_florist),
            label: 'My Plant',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
