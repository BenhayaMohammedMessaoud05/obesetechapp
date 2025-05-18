import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:obesetechapp/community/chat_room_screen.dart';
import 'package:obesetechapp/dashboard/alarm_box.dart';
import 'package:obesetechapp/dashboard/sleep_screen.dart';
import 'package:obesetechapp/dashboard/workout_screen.dart';
import 'package:obesetechapp/notifications/notifications_screen.dart';
import 'package:obesetechapp/profile/componennts/achievements_list.dart' show AchievementsList;
import 'package:obesetechapp/profile/componennts/quick_log_buttons.dart';
import 'package:obesetechapp/profile/componennts/step_summary_card.dart';
import 'package:obesetechapp/profile/componennts/weekly_activity_chart.dart';
import 'package:obesetechapp/profile/componennts/workout_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../regime/regime_dashboard_screen.dart';
import '../marketplace/marketplace_screen.dart';
import '../services/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show File, Platform;
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';

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

// Achievement model
class Achievement {
  final String title;
  final String description;

  Achievement({required this.title, required this.description});
}

// Custom widget for highlighted text with ink-stain effect
class _HighlightedText extends StatelessWidget {
  final String text;
  final TextStyle style;

  const _HighlightedText({required this.text, required this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFD81B60).withOpacity(0.8),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(15),
          bottomLeft: Radius.circular(5),
          bottomRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD81B60).withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: style,
      ),
    );
  }
}

// Widget for auto-scrolling psychological quotes
class _QuoteCarousel extends StatefulWidget {
  final List<String> quotes;

  const _QuoteCarousel({required this.quotes});

  @override
  _QuoteCarouselState createState() => _QuoteCarouselState();
}

class _QuoteCarouselState extends State<_QuoteCarousel> {
  int _currentQuoteIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentQuoteIndex = (_currentQuoteIndex + 1) % widget.quotes.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Text(
        '“${widget.quotes[_currentQuoteIndex]}”',
        key: ValueKey<int>(_currentQuoteIndex),
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontStyle: FontStyle.italic,
          color: const Color(0xFF6B7280),
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class PatientDashboardScreen extends StatefulWidget {
  final String token;
  const PatientDashboardScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  int _selectedIndex = 0;
  String? _token;
  String? _userName;
  Map<String, dynamic>? userData;
  Map<String, dynamic>? activityData;
  Map<String, dynamic>? workoutData;
  Map<String, dynamic>? sleepData;
  List<dynamic>? notifications;
  List<Map<String, dynamic>>? marketplaceRecommendations;
  bool isLoading = true;
  bool isLoadingRecommendations = true;
  String errorMessage = '';
  String recommendationsError = '';

  final List<String> psychologicalQuotes = [
    "Le premier pas vers le changement est la prise de conscience.",
    "Votre esprit est un jardin, vos pensées sont les graines.",
    "Chaque jour est une nouvelle opportunité pour grandir.",
    "La résilience est la clé pour surmonter les défis.",
    "Prenez soin de votre esprit comme vous prenez soin de votre corps."
  ];

  @override
  void initState() {
    super.initState();
    _token = widget.token.isNotEmpty ? widget.token : null;
    print('PatientDashboardScreen: Token initialized: ${_token?.isNotEmpty ?? false ? "[present]" : "[empty]"}');
    if (_token == null || _token!.isEmpty) {
      setState(() {
        errorMessage = 'Aucun token d\'authentification trouvé';
        isLoading = false;
      });
      _redirectToLogin();
    } else {
      _initializeUser();
    }
  }

  Future<void> _initializeUser() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      _userName = prefs.getString('userName');
      print('PatientDashboardScreen: Retrieved userName from SharedPreferences: $_userName');
      if (_userName == null || _userName!.isEmpty) {
        print('PatientDashboardScreen: No userName in SharedPreferences, fetching profile');
        final userProfile = await ApiService.getUserProfile(_token!);
        _userName = userProfile['name']?.toString() ?? '';
        if (_userName!.isEmpty) {
          throw Exception('No valid name in profile response: $userProfile');
        }
        await prefs.setString('userName', _userName!);
        print('PatientDashboardScreen: Stored userName: $_userName');
      }
      await fetchAllData();
      await _fetchMarketplaceRecommendations();
    } catch (e) {
      print('PatientDashboardScreen: Initialization error: $e');
      setState(() {
        errorMessage = 'Erreur lors de l\'initialisation: ${e.toString().replaceFirst('Exception: ', '')}';
        isLoading = false;
      });
      if (e.toString().contains('Invalid token') || e.toString().contains('No valid name')) {
        await _redirectToLogin();
      }
    }
  }

  Future<void> _fetchMarketplaceRecommendations() async {
    setState(() {
      isLoadingRecommendations = true;
      recommendationsError = '';
    });
    try {
      final recommendations = await ApiService.getMarketplaceRecommendations(_token!);
      setState(() {
        marketplaceRecommendations = recommendations;
        isLoadingRecommendations = false;
      });
    } catch (e) {
      print('PatientDashboardScreen: Marketplace recommendations error: $e');
      setState(() {
        recommendationsError = 'Erreur lors du chargement des recommandations: ${e.toString().replaceFirst('Exception: ', '')}';
        isLoadingRecommendations = false;
        // Fallback to mock data
        marketplaceRecommendations = [
          {
            'id': '1',
            'title': 'Shake Protéiné Vanille',
            'description': 'Boisson riche en protéines pour la récupération musculaire.',
            'price': 29.99,
          },
          {
            'id': '2',
            'title': 'Tapis de Yoga Antidérapant',
            'description': 'Idéal pour vos séances de yoga et de fitness.',
            'price': 39.99,
          },
          {
            'id': '3',
            'title': 'Vitamines Multinutrition',
            'description': 'Complément pour soutenir votre santé globale.',
            'price': 19.99,
          },
        ];
      });
    }
  }

  Future<void> _redirectToLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userName');
    print('PatientDashboardScreen: Cleared token and userName, redirecting to /login');
    if (mounted) {
      await Future.delayed(Duration.zero);
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> fetchAllData() async {
    if (_token == null || _token!.isEmpty) {
      setState(() {
        errorMessage = 'Aucun token d\'authentification trouvé';
        isLoading = false;
      });
      await _redirectToLogin();
      return;
    }
    try {
      final userProfile = await ApiService.getUserProfile(_token!);
      final activity = await ApiService.getActivity(_token!);
      final workouts = await ApiService.getWorkouts(_token!);
      final sleep = await ApiService.getSleepData(_token!);
      final userName = userProfile['name'] ?? 'User';
      final notificationsData = await ApiService.getUserNotifications(userName);

      setState(() {
        userData = userProfile;
        activityData = activity;
        workoutData = workouts;
        sleepData = sleep;
        notifications = notificationsData;
        _userName = userName;
        isLoading = false;
      });
    } catch (e) {
      print('PatientDashboardScreen: Fetch error: $e');
      setState(() {
        errorMessage = 'Erreur lors du chargement des données: ${e.toString().replaceFirst('Exception: ', '')}';
        isLoading = false;
      });
      if (e.toString().contains('Invalid token')) {
        await _redirectToLogin();
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      print('PatientDashboardScreen: Navigated to index $index (${['Accueil', 'Régime', 'Marketplace', 'Chat'][index]})');
      if (index == 0 && (userData == null || notifications == null) && _token != null && _token!.isEmpty) {
        isLoading = true;
        fetchAllData();
      }
    });
  }

  void _updateUserData(Map<String, dynamic> updatedData) {
    setState(() {
      userData = {...?userData, ...updatedData};
      _userName = updatedData['name'] ?? _userName;
    });
  }

  void _updateSleepData(Map<String, dynamic> updatedSleepData) {
    setState(() {
      sleepData = {...?sleepData, ...updatedSleepData};
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeContent(),
      _userName == null
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A3C5A)))
          : RegimeDashboardScreen(token: _token ?? '', userName: _userName!, userId: '',),
      MarketplaceScreen(token: _token ?? ''),
      ChatRoomScreen(token: _token ?? '', title: ''),
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
                    const Color(0xFF1A3C5A).withOpacity(0.1),
                    Colors.teal.withOpacity(0.1),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -50,
                    left: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.teal.withOpacity(0.2),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                        child: Container(color: Colors.transparent),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -100,
                    right: -100,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF1A3C5A).withOpacity(0.2),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                        child: Container(color: Colors.transparent),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  height: 100,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1A3C5A).withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'lib/logo.png',
                            width: 40,
                            height: 40,
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 100,
                            child: _QuoteCarousel(quotes: psychologicalQuotes),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'ObeseTech',
                            style: GoogleFonts.dmSerifDisplay(
                              fontSize: 24,
                              color: const Color(0xFF1A3C5A),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.person, color: Color(0xFF1A3C5A)),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfileScreen(
                                    token: _token ?? '',
                                    userData: userData,
                                    activityData: activityData,
                                    workoutData: workoutData,
                                    sleepData: sleepData,
                                    onUserDataUpdate: _updateUserData,
                                    onSleepDataUpdate: _updateSleepData,
                                  ),
                                ),
                              );
                            },
                          ),
                          Stack(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.notifications, color: Color(0xFF1A3C5A)),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NotificationsScreen(notifications: notifications),
                                    ),
                                  );
                                },
                              ),
                              if (notifications != null && notifications!.isNotEmpty)
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      '${notifications!.length}',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(child: pages[_selectedIndex]),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF1A3C5A),
        unselectedItemColor: const Color(0xFF6B7280),
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.local_dining), label: 'Régime'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Marketplace'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
      child: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A3C5A)))
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        errorMessage,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFB91C1C),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _initializeUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A3C5A),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          'Réessayer',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _redirectToLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          'Se déconnecter',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        _HighlightedText(
                          text: 'Obese',
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 36,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF1A3C5A),
                          ),
                        ),
                        Text(
                          'Tech',
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 36,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF1A3C5A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vers une vie plus saine !',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [const Color(0xFF1A3C5A), const Color(0xFF2A5C8A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1A3C5A).withOpacity(0.2),
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
                                  " BP  Évaluation IA",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Risque modéré",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Basé sur vos dernières données",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
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
                                  value: 0.68,
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
                      "Recommandations du Marketplace",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: const Color(0xFF1A3C5A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    isLoadingRecommendations
                        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                        : recommendationsError.isNotEmpty
                            ? Center(
                                child: Text(
                                  recommendationsError,
                                  style: GoogleFonts.poppins(color: Colors.red, fontSize: 14),
                                ),
                              )
                            : marketplaceRecommendations == null || marketplaceRecommendations!.isEmpty
                                ? Center(
                                    child: Text(
                                      "Aucune recommandation disponible",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: const Color(0xFF6B7280),
                                      ),
                                    ),
                                  )
                                : SizedBox(
                                    height: 200,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: marketplaceRecommendations!.length,
                                      itemBuilder: (context, index) {
                                        final product = marketplaceRecommendations![index];
                                        return Container(
                                          width: 180,
                                          margin: const EdgeInsets.only(right: 16),
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
                                                product['title'] ?? 'Produit',
                                                style: AppTextStyles.subhead,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                product['description'] ?? 'Description indisponible',
                                                style: AppTextStyles.label,
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                '${product['price']?.toStringAsFixed(2) ?? 'N/A'} €',
                                                style: AppTextStyles.value,
                                              ),
                                              const Spacer(),
                                              Align(
                                                alignment: Alignment.bottomRight,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => MarketplaceScreen(token: _token ?? ''),
                                                      ),
                                                    );
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: AppColors.primary,
                                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    'Voir',
                                                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                    const SizedBox(height: 24),
                    Text(
                      "Statistiques Santé",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF1A3C5A),
                      ),
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
                          color: const Color(0xFF1A3C5A),
                        ),
                        _StatCard(
                          title: "Poids",
                          value: userData != null && userData!['weight'] != null
                              ? "${userData!['weight']} kg"
                              : 'N/A',
                          color: const Color(0xFF2A5C8A),
                        ),
                        _StatCard(
                          title: "Taille",
                          value: userData != null && userData!['height'] != null
                              ? "${userData!['height']} cm"
                              : 'N/A',
                          color: const Color(0xFF3A7CBA),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1A3C5A).withOpacity(0.1),
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
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: const Color(0xFF1A3C5A),
                            ),
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: 0.75,
                            minHeight: 10,
                            backgroundColor: const Color(0xFFE5E7EB),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1A3C5A)),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Début: 01/01/2023",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                              Text(
                                "Objectif: 31/12/2023",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Dernières Notifications",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: const Color(0xFF1A3C5A),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Color(0xFF1A3C5A)),
                          onPressed: fetchAllData,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    notifications == null || notifications!.isEmpty
                        ? Text(
                            "Aucune notification disponible",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: const Color(0xFF6B7280),
                            ),
                          )
                        : Column(
                            children: notifications!
                                .take(3)
                                .map((notification) => _StatCard(
                                      title: notification['title'] ?? 'Notification',
                                      value: notification['message'] ?? 'Détails indisponibles',
                                      color: const Color(0xFF1A3C5A),
                                    ))
                                .toList(),
                          ),
                  ],
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
    return Container(
      width: 100,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
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
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF6B7280),
            ),
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
class ProfileScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic>? userData;
  final Map<String, dynamic>? activityData;
  final Map<String, dynamic>? workoutData;
  final Map<String, dynamic>? sleepData;
  final Function(Map<String, dynamic>) onUserDataUpdate;
  final Function(Map<String, dynamic>) onSleepDataUpdate;

  const ProfileScreen({
    Key? key,
    required this.token,
    this.userData,
    this.activityData,
    this.workoutData,
    this.sleepData,
    required this.onUserDataUpdate,
    required this.onSleepDataUpdate,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 0;
  Map<String, dynamic>? _userData;
  bool _isEditing = false;
  bool _isSaving = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _bmiController;
  String _errorMessage = '';
  List<Map<String, String>> _searchedUsers = [];
  bool _isLoadingSearch = false;
  String _searchError = '';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _userData = widget.userData;
    _nameController = TextEditingController(text: _userData?['name'] ?? '');
    _emailController = TextEditingController(text: _userData?['email'] ?? '');
    _weightController = TextEditingController(text: _userData?['weight']?.toString() ?? '');
    _heightController = TextEditingController(text: _userData?['height']?.toString() ?? '');
    _bmiController = TextEditingController(text: _userData?['bmi']?.toString() ?? '');
    if (_userData == null) {
      _fetchUserData();
    }
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

  Future<void> _fetchUserData() async {
    try {
      final userProfile = await ApiService.getUserProfile(widget.token);
      setState(() {
        _userData = userProfile;
        _nameController.text = userProfile['name'] ?? '';
        _emailController.text = userProfile['email'] ?? '';
        _weightController.text = userProfile['weight']?.toString() ?? '';
        _heightController.text = userProfile['height']?.toString() ?? '';
        _bmiController.text = userProfile['bmi']?.toString() ?? '';
      });
      widget.onUserDataUpdate(userProfile);
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement du profil: $e';
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _errorMessage = '';
      _isSaving = true;
    });
    try {
      final updates = {
        'name': _nameController.text,
        'email': _emailController.text,
        'weight': double.tryParse(_weightController.text) ?? 0.0,
        'height': double.tryParse(_heightController.text) ?? 0.0,
        'bmi': double.tryParse(_bmiController.text) ?? 0.0,
      };
      await ApiService.updateUserProfile(widget.token, updates);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', _nameController.text);
      setState(() {
        _userData = {...?_userData, ...updates};
        _isEditing = false;
      });
      widget.onUserDataUpdate(updates);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour avec succès')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la mise à jour: $e';
      });
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchedUsers = [];
        _isLoadingSearch = false;
        _searchError = '';
      });
      return;
    }
    setState(() {
      _isLoadingSearch = true;
      _searchError = '';
    });

    try {
      final users = await ApiService.searchUsers(widget.token, query);
      setState(() {
        _searchedUsers = users;
        _isLoadingSearch = false;
      });
    } catch (e) {
      setState(() {
        _searchError = e.toString().replaceFirst('Exception: ', '');
        _isLoadingSearch = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildProfileContent(),
      _buildSearchDoctorsContent(),
      AlarmBox(token: widget.token, userName: _userData?['name'] ?? ''),
      _buildSleepContent(),
      _buildWorkoutContent(),
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
              onRefresh: _fetchUserData,
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
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Entraînements'),
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
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                _errorMessage,
                style: GoogleFonts.poppins(color: Colors.red, fontSize: 14),
              ),
            ),
          _userData == null
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
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
                              _userData?['name'] ?? 'Utilisateur',
                              style: AppTextStyles.headline,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _userData?['email'] ?? 'email@exemple.com',
                              style: AppTextStyles.label,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Poids: ${_userData?['weight']?.toString() ?? 'N/A'} kg',
                              style: AppTextStyles.label,
                            ),
                            Text(
                              'Taille: ${_userData?['height']?.toString() ?? 'N/A'} cm',
                              style: AppTextStyles.label,
                            ),
                            Text(
                              'IMC: ${_userData?['bmi']?.toString() ?? 'N/A'}',
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
                if (_isEditing) ...[
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
                      onPressed: _isEditing
                          ? _updateProfile
                          : () => setState(() => _isEditing = true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        _isEditing
                            ? _isSaving
                                ? 'Enregistrement...'
                                : 'Sauvegarder'
                            : 'Modifier',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    ),
                    if (_isEditing)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                            _nameController.text = _userData?['name'] ?? '';
                            _emailController.text = _userData?['email'] ?? '';
                            _weightController.text = _userData?['weight']?.toString() ?? '';
                            _heightController.text = _userData?['height']?.toString() ?? '';
                            _bmiController.text = _userData?['bmi']?.toString() ?? '';
                          });
                        },
                        child: Text(
                          'Annuler',
                          style: GoogleFonts.poppins(color: AppColors.primary),
                        ),
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
              setState(() => _searchQuery = value);
              _searchUsers(value);
            },
          ),
          const SizedBox(height: 12),
          if (_isLoadingSearch)
            const Center(child: CircularProgressIndicator(color: AppColors.primary))
          else if (_searchError.isNotEmpty)
            Center(
              child: Text(
                _searchError,
                style: GoogleFonts.poppins(color: Colors.red, fontSize: 14),
              ),
            )
          else if (_searchedUsers.isEmpty && _searchQuery.isNotEmpty)
            Center(
              child: Text(
                "Aucun utilisateur trouvé",
                style: GoogleFonts.poppins(color: Color(0xFF6B7280)),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _searchedUsers.length,
              itemBuilder: (context, index) {
                final user = _searchedUsers[index];
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

  Widget _buildSleepContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sommeil', style: AppTextStyles.headline),
          const SizedBox(height: 16),
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
            child: ListTile(
              leading: Icon(Icons.nights_stay, color: AppColors.primary),
              title: Text('Accéder au suivi du sommeil', style: AppTextStyles.subhead),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SleepScreen(
                      token: widget.token,
                      sleepData: widget.sleepData,
                      onSleepDataUpdate: widget.onSleepDataUpdate,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Entraînements', style: AppTextStyles.headline),
          const SizedBox(height: 16),
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
            child: ListTile(
              leading: Icon(Icons.fitness_center, color: AppColors.primary),
              title: Text('Accéder aux entraînements', style: AppTextStyles.subhead),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkoutScreen(
                      token: widget.token,
                      workoutData: widget.workoutData,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}