import 'package:flutter/material.dart';

import 'package:obesetechapp/regime/regime_dashboard_screen.dart'; // ✅


import '../community/community_screen.dart';
import '../marketplace/marketplace_screen.dart';
import 'package:obesetechapp/dashboard/home_screen.dart';


class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  int _selectedIndex = 0;

 final List<Widget> _pages = [
  const HomeScreen(),
  const CommunityScreen(),
  const MarketplaceScreen(),
  RegimeDashboardScreen(), // ✅ no `const` here
];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.groups), label: 'Communauté'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Marketplace'),
          BottomNavigationBarItem(icon: Icon(Icons.local_dining), label: 'Régime'),
        ],
      ),
    );
  }
}


