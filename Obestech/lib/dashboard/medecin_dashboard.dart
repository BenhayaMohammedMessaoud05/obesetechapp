// 📁 lib/dashboard/medecin_dashboard.dart
import 'user_profile_screen.dart';
import 'package:flutter/material.dart';
import '../community/community_screen.dart';

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
    UserProfileScreen(token: '',),
  ];

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ✅ Seulement cercle jaune en bas à droite
          Positioned(
            bottom: -90,
            right: -90,
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.yellow.withOpacity(0.5), Colors.yellow.withOpacity(0.3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellow.withOpacity(0.3),
                    spreadRadius: 5,
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 40),
              Center(
                child: Image.asset(
                  'lib/logo.png', // Chemin de ton logo
                  width: 100,
                  height: 100,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _screens[_selectedIndex],
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onTap,
      ),
      backgroundColor: const Color(0xFFF3F4F6),
    );
  }
}
