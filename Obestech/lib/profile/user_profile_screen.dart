import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:obesetechapp/profile/edit_profile_screen.dart';
import 'package:obesetechapp/profile/search_users_screen.dart';
import '../preferences/dietary_preferences_screen.dart';
import '../profile/sleep_tracker_screen.dart';
import '../profile/workout_form_screen.dart';
import '../profile/activity_tracker_screen.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Header
            Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('../lib/zf.jpg'), // 🖼️ mets ton chemin ici
                  fit: BoxFit.cover,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.blueAccent,
                            child: Icon(Icons.person, size: 50, color: Colors.white),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Housny", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text("housny@gmail.com", style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
                              const SizedBox(height: 8),
                              Text("Health enthusiast & early riser", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Search Bar
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchUsersScreen())),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.search, color: Colors.grey),
                          SizedBox(width: 8),
                          Text("Search medicines or users", style: TextStyle(color: Colors.grey))
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // List-style buttons
                  _ProfileActionButton(
                    icon: Icons.edit,
                    label: "Modifier le profil",
                    color: Colors.blueAccent,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                  ),
                  _ProfileActionButton(
                    icon: Icons.restaurant_menu,
                    label: "Préférences alimentaires",
                    color: Colors.green,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DietaryPreferencesScreen())),
                  ),
                  _ProfileActionButton(
                    icon: Icons.nightlight_round,
                    label: "Suivi du Sommeil",
                    color: Colors.indigo,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SleepTrackerScreen())),
                  ),
                  _ProfileActionButton(
                    icon: Icons.fitness_center,
                    label: "Workout Form",
                    color: Colors.deepOrange,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkoutFormScreen())),
                  ),
                  _ProfileActionButton(
                    icon: Icons.timeline,
                    label: "Activity Tracker",
                    color: Colors.purple,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivityTrackerScreen())),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ProfileActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Icon(icon, size: 28, color: color),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
