import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:obesetechapp/dashboard/patient_dashboard.dart';
import 'package:obesetechapp/services/api_service.dart';


class HomeScreen extends StatefulWidget {
  final String token; // Token JWT pour authentification
  const HomeScreen({Key? key, required this.token}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? userData;
  List<dynamic>? notifications;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    print('Token dans HomeScreen: ${widget.token}');
    fetchUserData();
    fetchNotifications();
  }

  Future<void> fetchUserData() async {
    try {
      final data = await ApiService.getUserProfile(widget.token);
      setState(() {
        userData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  Future<void> fetchNotifications() async {
    try {
      final userName = userData?['name'] ?? 'User';
      final data = await ApiService.getUserNotifications(userName);
      setState(() {
        notifications = data;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur lors du chargement des notifications: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Dashboard Santé",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.teal),
            onPressed: fetchNotifications,
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.person_outline, color: Colors.teal),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PatientDashboardScreen(token: widget.token),
              ),
            );
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage, style: GoogleFonts.poppins(color: Colors.red)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.teal.shade700, Colors.teal.shade400],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.teal.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Évaluation IA",
                                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Risque modéré", // Peut être dynamisé via API
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Basé sur vos dernières données",
                                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  height: 60,
                                  width: 60,
                                  child: CircularProgressIndicator(
                                    value: 0.68, // Peut être dynamisé via API
                                    strokeWidth: 8,
                                    backgroundColor: Colors.white30,
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                Text(
                                  "68%",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Statistiques Santé",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _StatCard(
                            title: "IMC",
                            value: userData != null && userData!['bmi'] != null
                                ? userData!['bmi'].toStringAsFixed(1)
                                : 'N/A',
                            color: Colors.blue,
                          ),
                          _StatCard(
                            title: "Poids",
                            value: userData != null && userData!['weight'] != null
                                ? "${userData!['weight']} kg"
                                : 'N/A',
                            color: Colors.orange,
                          ),
                          _StatCard(
                            title: "Taille",
                            value: userData != null && userData!['height'] != null
                                ? "${userData!['height']} cm"
                                : 'N/A',
                            color: Colors.green,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Évolution Globale",
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                              value: 0.75, // Peut être dynamisé via API
                              minHeight: 10,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.teal.shade400),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Début: 01/01/2023",
                                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
                                ),
                                Text(
                                  "Objectif: 31/12/2023",
                                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Dernières Notifications",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      const SizedBox(height: 12),
                      notifications == null || notifications!.isEmpty
                          ? const Text("Aucune notification disponible")
                          : Column(
                              children: notifications!
                                  .take(3)
                                  .map((notification) => _StatCard(
                                        title: notification['title'] ?? 'Notification',
                                        value: notification['message'] ?? 'Détails indisponibles',
                                        color: Colors.teal,
                                      ))
                                  .toList(),
                            ),
                    ],
                  ),
                ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 110,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}