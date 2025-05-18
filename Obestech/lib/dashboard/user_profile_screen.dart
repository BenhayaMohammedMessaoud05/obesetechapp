import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:obesetechapp/services/api_service.dart';
import 'package:obesetechapp/profile/componennts/quick_log_buttons.dart';
import 'package:obesetechapp/profile/componennts/workout_card.dart';
import 'package:obesetechapp/profile/componennts/achievements_list.dart';
import 'package:obesetechapp/profile/componennts/step_summary_card.dart';
import 'package:obesetechapp/profile/componennts/weekly_activity_chart.dart';
import 'package:obesetechapp/dashboard/alarm_box.dart';

// Mock theme classes
class AppColors {
  static const primary = Color(0xFF1A3C5A);
  static const accent = Color(0xFF2A5C8A);
  static const cardBackground = Color(0xFFF9FAFB);
}

class AppTextStyles {
  static final headline = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );
  static final subhead = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );
  static final label = GoogleFonts.poppins(
    fontSize: 12,
    color: Color(0xFF6B7280),
  );
  static final value = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );
}

class UserProfileScreen extends StatefulWidget {
  final String token;

  const UserProfileScreen({super.key, required this.token});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  int _selectedIndex = 0;
  Map<String, dynamic>? userData;
  Map<String, dynamic>? sleepData;
  Map<String, dynamic>? workoutData;
  Map<String, dynamic>? activityData;
  List<Map<String, String>> searchedUsers = [];
  bool isLoadingUser = true;
  bool isLoadingSleep = true;
  bool isLoadingWorkout = true;
  bool isLoadingActivity = true;
  bool isLoadingSearch = false;
  String errorMessage = '';
  String searchError = '';
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _bmiController = TextEditingController();
  bool isEditingProfile = false;
  bool isSavingProfile = false;
  String searchQuery = '';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchAllData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _bmiController.dispose();
    super.dispose();
  }

  Future<void> fetchAllData() async {
    if (widget.token.isEmpty) {
      setState(() {
        errorMessage = 'Token invalide';
        isLoadingUser = false;
        isLoadingSleep = false;
        isLoadingWorkout = false;
        isLoadingActivity = false;
      });
      return;
    }

    try {
      final data = await ApiService.getUserProfile(widget.token);
      setState(() {
        userData = data;
        _nameController.text = data['name'] ?? '';
        _emailController.text = data['email'] ?? '';
        _weightController.text = formatNumber(data['weight']);
        _heightController.text = formatNumber(data['height']);
        _bmiController.text = formatNumber(data['bmi']);
        isLoadingUser = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoadingUser = false;
      });
    }

    try {
      final data = await ApiService.getSleepData(widget.token);
      setState(() {
        sleepData = data;
        isLoadingSleep = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoadingSleep = false;
      });
    }

    try {
      final data = await ApiService.getWorkouts(widget.token);
      setState(() {
        workoutData = data;
        isLoadingWorkout = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoadingWorkout = false;
      });
    }

    try {
      final data = await ApiService.getActivity(widget.token);
      setState(() {
        activityData = data;
        isLoadingActivity = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoadingActivity = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      isSavingProfile = true;
    });

    try {
      final updates = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'weight': double.tryParse(_weightController.text.trim()),
        'height': double.tryParse(_heightController.text.trim()),
        'bmi': double.tryParse(_bmiController.text.trim()),
      };
      await ApiService.updateUserProfile(widget.token, updates);

      setState(() {
        userData = {...?userData, ...updates};
        isEditingProfile = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Modifications enregistrées")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: ${e.toString().replaceFirst('Exception: ', '')}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSavingProfile = false;
        });
      }
    }
  }

  Future<void> _updateSleepSession(String action) async {
    try {
      await ApiService.updateSleepSession(widget.token, action);
      final data = await ApiService.getSleepData(widget.token);
      setState(() {
        sleepData = data;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sleep $action successful")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: ${e.toString().replaceFirst('Exception: ', '')}")),
        );
      }
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchedUsers = [];
        isLoadingSearch = false;
        searchError = '';
      });
      return;
    }
    setState(() {
      isLoadingSearch = true;
      searchError = '';
    });

    try {
      final users = await ApiService.searchUsers(widget.token, query);
      setState(() {
        searchedUsers = users;
        isLoadingSearch = false;
      });
    } catch (e) {
      setState(() {
        searchError = e.toString().replaceFirst('Exception: ', '');
        isLoadingSearch = false;
      });
    }
  }

  String formatNumber(dynamic value) {
    if (value is num && value.isFinite) {
      return value.toStringAsFixed(1);
    }
    return '';
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formatter = DateFormat.jm();
    final time = formatter.format(now);

    final List<Widget> pages = [
      _buildProfileContent(),
      _buildSearchDoctorsContent(),
      AlarmBox(token: widget.token, userName: userData?['name'] ?? ''),
      _buildSleepTrackerContent(time),
      _buildWorkoutFormContent(),
      _buildActivityTrackerContent(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    Colors.teal.withOpacity(0.1),
                  ],
                ),
              ),
            ),
            RefreshIndicator(
              onRefresh: fetchAllData,
              child: pages[_selectedIndex],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: const Color(0xFF6B7280),
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Médecins'),
          BottomNavigationBarItem(icon: Icon(Icons.alarm), label: 'Alarmes'),
          BottomNavigationBarItem(icon: Icon(Icons.nights_stay), label: 'Sommeil'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Entraînement'),
          BottomNavigationBarItem(icon: Icon(Icons.directions_walk), label: 'Activité'),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profil', style: AppTextStyles.headline),
          const SizedBox(height: 16),
          isLoadingUser
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : errorMessage.isNotEmpty && userData == null
                  ? Center(
                      child: Text(
                        errorMessage,
                        style: GoogleFonts.poppins(color: Colors.red, fontSize: 14),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 40,
                            backgroundColor: AppColors.primary,
                            child: Icon(Icons.person, size: 50, color: Colors.white),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userData?['name'] ?? 'Utilisateur',
                                  style: AppTextStyles.headline,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  userData?['email'] ?? 'email@exemple.com',
                                  style: AppTextStyles.label,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Poids: ${formatNumber(userData?['weight'])} kg',
                                  style: AppTextStyles.label,
                                ),
                                Text(
                                  'Taille: ${formatNumber(userData?['height'])} cm',
                                  style: AppTextStyles.label,
                                ),
                                Text(
                                  'IMC: ${formatNumber(userData?['bmi'])}',
                                  style: AppTextStyles.label,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isEditingProfile) ...[
                  Text('Nom', style: AppTextStyles.subhead),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: AppColors.cardBackground,
                    ),
                    validator: (value) => value!.isEmpty ? 'Nom requis' : null,
                  ),
                  const SizedBox(height: 12),
                  Text('Email', style: AppTextStyles.subhead),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: AppColors.cardBackground,
                    ),
                    validator: (value) => value!.contains('@') ? null : 'Email invalide',
                  ),
                  const SizedBox(height: 12),
                  Text('Poids (kg)', style: AppTextStyles.subhead),
                  TextFormField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: AppColors.cardBackground,
                    ),
                    validator: (value) =>
                        double.tryParse(value ?? '') != null ? null : 'Poids invalide',
                  ),
                  const SizedBox(height: 12),
                  Text('Taille (cm)', style: AppTextStyles.subhead),
                  TextFormField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: AppColors.cardBackground,
                    ),
                    validator: (value) =>
                        double.tryParse(value ?? '') != null ? null : 'Taille invalide',
                  ),
                  const SizedBox(height: 12),
                  Text('IMC', style: AppTextStyles.subhead),
                  TextFormField(
                    controller: _bmiController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: AppColors.cardBackground,
                    ),
                    validator: (value) =>
                        double.tryParse(value ?? '') != null ? null : 'IMC invalide',
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: isEditingProfile
                          ? _saveProfile
                          : () => setState(() => isEditingProfile = true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        isEditingProfile
                            ? isSavingProfile
                                ? 'Enregistrement...'
                                : 'Enregistrer'
                            : 'Modifier',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    ),
                    if (isEditingProfile)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isEditingProfile = false;
                            _nameController.text = userData?['name'] ?? '';
                            _emailController.text = userData?['email'] ?? '';
                            _weightController.text = formatNumber(userData?['weight']);
                            _heightController.text = formatNumber(userData?['height']);
                            _bmiController.text = formatNumber(userData?['bmi']);
                          });
                        },
                        child: Text('Annuler', style: GoogleFonts.poppins(color: AppColors.primary)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchDoctorsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rechercher un professionnel', style: AppTextStyles.headline),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              hintText: "Rechercher par nom...",
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: AppColors.cardBackground,
            ),
            onChanged: (value) {
              setState(() => searchQuery = value);
              _searchUsers(value);
            },
          ),
          const SizedBox(height: 12),
          isLoadingSearch
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : searchError.isNotEmpty
                  ? Center(
                      child: Text(
                        searchError,
                        style: GoogleFonts.poppins(color: Colors.red, fontSize: 14),
                      ),
                    )
                  : searchedUsers.isEmpty && searchQuery.isNotEmpty
                      ? Center(
                          child: Text(
                            "Aucun utilisateur trouvé",
                            style: GoogleFonts.poppins(color: Color(0xFF6B7280)),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: searchedUsers.length,
                          itemBuilder: (context, index) {
                            final user = searchedUsers[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: AppColors.primary,
                                  child: Icon(Icons.person, color: Colors.white),
                                ),
                                title: Text(user["name"] ?? 'Inconnu', style: AppTextStyles.subhead),
                                subtitle: Text(
                                  "${user["role"] ?? 'N/A'} • ${user["email"] ?? 'N/A'}",
                                  style: AppTextStyles.label,
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.email, color: AppColors.primary),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Email de ${user["name"] ?? 'utilisateur'} copié !",
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
        ],
      ),
    );
  }

  Widget _buildSleepTrackerContent(String time) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Suivi du Sommeil', style: AppTextStyles.headline),
          const SizedBox(height: 12),
          isLoadingSleep
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : errorMessage.isNotEmpty && sleepData == null
                  ? Center(
                      child: Text(
                        errorMessage,
                        style: GoogleFonts.poppins(color: Colors.red, fontSize: 14),
                      ),
                    )
                  : Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                time,
                                style: AppTextStyles.value.copyWith(fontSize: 24),
                              ),
                              const SizedBox(height: 10),
                              CircularPercentIndicator(
                                radius: 90,
                                lineWidth: 18,
                                percent: (sleepData?['percent'] ?? 0.78).toDouble(),
                                circularStrokeCap: CircularStrokeCap.round,
                                center: Text(
                                  "Cycle de sommeil\nAppuyez pour voir\nles détails",
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.label,
                                ),
                                backgroundColor: Colors.grey[300]!,
                                progressColor: AppColors.accent,
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _SleepPhase(
                                    label: "Sommeil profond",
                                    value: sleepData?['deep'] ?? "2h 15m",
                                    color: AppColors.primary,
                                  ),
                                  _SleepPhase(
                                    label: "REM",
                                    value: sleepData?['rem'] ?? "1h 45m",
                                    color: AppColors.accent,
                                  ),
                                  _SleepPhase(
                                    label: "Sommeil léger",
                                    value: sleepData?['light'] ?? "3h 30m",
                                    color: AppColors.primary.withOpacity(0.7),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Session de sommeil', style: AppTextStyles.subhead),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _TimeInfo(
                                    icon: Icons.nights_stay,
                                    label: "Coucher",
                                    time: sleepData?['bedtime'] ?? "10:30 PM",
                                  ),
                                  _TimeInfo(
                                    icon: Icons.wb_sunny,
                                    label: "Réveil",
                                    time: sleepData?['wakeup'] ?? "7:00 AM",
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    ),
                                    icon: const Icon(Icons.play_arrow, color: Colors.white),
                                    label: Text(
                                      "Démarrer sommeil",
                                      style: GoogleFonts.poppins(color: Colors.white),
                                    ),
                                    onPressed: () => _updateSleepSession('start'),
                                  ),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.accent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    ),
                                    icon: const Icon(Icons.stop, color: Colors.white),
                                    label: Text(
                                      "Terminer sommeil",
                                      style: GoogleFonts.poppins(color: Colors.white),
                                    ),
                                    onPressed: () => _updateSleepSession('end'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Informations sur la qualité du sommeil",
                                style: AppTextStyles.subhead,
                              ),
                              const SizedBox(height: 12),
                              ...["Lun", "Mar", "Mer", "Jeu", "Ven", "Sam", "Dim"].map((day) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 3),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 40,
                                        child: Text(
                                          day,
                                          style: AppTextStyles.label,
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: AppColors.accent.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              const SizedBox(height: 10),
                              Text(
                                "Votre qualité de sommeil était meilleure le samedi. Envisagez un coucher plus tôt pour améliorer le sommeil profond.",
                                style: AppTextStyles.label,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Alarmes intelligentes",
                                style: AppTextStyles.subhead,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _AlarmBox(
                                    title: "Alarme de réveil",
                                    time: "7:00 AM",
                                    icon: Icons.alarm,
                                  ),
                                  _AlarmBox(
                                    title: "Rappel de sommeil",
                                    time: "10:00 PM",
                                    icon: Icons.notifications,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(Icons.add_alarm, color: Colors.white),
                                label: Text(
                                  "Définir nouvelle alarme",
                                  style: GoogleFonts.poppins(color: Colors.white),
                                ),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Alarmes non implémentées"),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            "Conseils de sommeil",
                            style: AppTextStyles.subhead,
                          ),
                        ),
                      ],
                    ),
        ],
      ),
    );
  }

  Widget _buildWorkoutFormContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Formulaire d\'entraînement', style: AppTextStyles.headline),
          const SizedBox(height: 12),
          isLoadingWorkout
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : errorMessage.isNotEmpty && workoutData == null
                  ? Center(
                      child: Text(
                        errorMessage,
                        style: GoogleFonts.poppins(color: Colors.red, fontSize: 14),
                      ),
                    )
                  : Column(
                      children: [
                        WorkoutCard(
                          title: workoutData?['workouts']?.isNotEmpty == true
                              ? workoutData!['workouts'][0]['title']
                              : 'HIIT Cardio Challenge',
                          description: workoutData?['workouts']?.isNotEmpty == true
                              ? workoutData!['workouts'][0]['description']
                              : 'Boostez votre métabolisme avec des intervalles de haute intensité.',
                          duration: workoutData?['workouts']?.isNotEmpty == true
                              ? workoutData!['workouts'][0]['duration']
                              : '25 min',
                          intensity: workoutData?['workouts']?.isNotEmpty == true
                              ? workoutData!['workouts'][0]['intensity']
                              : 'Haute intensité',
                          onStart: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Démarrage de l'entraînement non implémenté"),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        Text('Réalisations', style: AppTextStyles.headline),
                        const SizedBox(height: 12),
                        AchievementsList(token: '', achievements: [],),
                      ],
                    ),
        ],
      ),
    );
  }

  Widget _buildActivityTrackerContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Suivi d\'activité', style: AppTextStyles.headline),
          const SizedBox(height: 12),
          isLoadingActivity
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : errorMessage.isNotEmpty && activityData == null
                  ? Center(
                      child: Text(
                        errorMessage,
                        style: GoogleFonts.poppins(color: Colors.red, fontSize: 14),
                      ),
                    )
                  : Column(
                      children: [
                        StepSummaryCard(
                          steps: activityData?['steps']?.toInt() ?? 0,
                          calories: (activityData?['calories'] ?? 0).toDouble(),
                          kilometers: (activityData?['kilometers'] ?? 0).toDouble(),
                          activeMinutes: activityData?['activeMinutes']?.toInt() ?? 0,
                          goalPercent: activityData?['goalPercent']?.toDouble() ?? 0,
                        ),
                        const SizedBox(height: 24),
                        WeeklyActivityChart(
                          weeklySteps: (activityData?['weeklySteps'] as List<dynamic>?)?.cast<int>() ??
                              [0, 0, 0, 0, 0, 0, 0],
                        ),
                      ],
                    ),
        ],
      ),
    );
  }
}

class _SleepPhase extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SleepPhase({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(color: color),
        ),
        Text(
          value,
          style: AppTextStyles.value,
        ),
      ],
    );
  }
}

class _TimeInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String time;

  const _TimeInfo({
    required this.icon,
    required this.label,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 30,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.label,
        ),
        Text(
          time,
          style: AppTextStyles.value,
        ),
      ],
    );
  }
}

class _AlarmBox extends StatelessWidget {
  final String title;
  final String time;
  final IconData icon;

  const _AlarmBox({
    required this.title,
    required this.time,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 30,
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: AppTextStyles.label,
        ),
        Text(
          time,
          style: AppTextStyles.value,
        ),
      ],
    );
  }
}