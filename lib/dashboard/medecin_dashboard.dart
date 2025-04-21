// 📁 lib/dashboard/medecin_dashboard.dart

import 'package:flutter/material.dart';
import '../community/community_screen.dart';

import '../profile/user_profile_screen.dart';

import '../widgets/bottom_nav_bar.dart';

class MedecinDashboard extends StatefulWidget {
  const MedecinDashboard({super.key});

  @override
  State<MedecinDashboard> createState() => _MedecinDashboardState();
}

class _MedecinDashboardState extends State<MedecinDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
   
    CommunityScreen(),
    
    UserProfileScreen(),
  ];

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Médecin')),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onTap,
      ),
    );
  }
}