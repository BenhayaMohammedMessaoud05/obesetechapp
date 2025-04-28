import 'package:flutter/material.dart';
import 'package:obesetechapp/regime/regime_dashboard_screen.dart';
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
    RegimeDashboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 200, // 📏 hauteur de la bannière
                    width: double.infinity,
                    child: Image.asset(
                      '../lib/zf.jpg', // 🖼️ ton image en haut
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 60, // 📍 position verticale du logo
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Image.asset(
                        'lib/logo.png', // 🖼️ ton logo par-dessus
                        width: 80, // 📏 taille du logo
                        height: 80,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _pages[_selectedIndex],
              ),
            ],
          ),
        ],
      ),
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
      backgroundColor: const Color(0xFFF3F4F6),
    );
  }
}
