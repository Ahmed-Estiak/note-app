import 'package:flutter/material.dart';
import 'lists_page.dart';
import 'dashboard_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ListsPage(),
    const DashboardPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        height: 48,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined, size: 18),
            selectedIcon: Icon(Icons.shopping_cart, size: 18),
            label: 'Lists',
          ),
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined, size: 18),
            selectedIcon: Icon(Icons.dashboard, size: 18),
            label: 'Dashboard',
          ),
        ],
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      ),
    );
  }
}

