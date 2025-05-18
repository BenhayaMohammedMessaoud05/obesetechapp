import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class RegimeSummaryGraph extends StatelessWidget {
  final List<int> kcalPrescrit;
  final List<int> kcalMange;

  const RegimeSummaryGraph({
    super.key,
    required this.kcalPrescrit,
    required this.kcalMange,
  });

  @override
  Widget build(BuildContext context) {
    final maxY = (kcalPrescrit + kcalMange).reduce((a, b) => a > b ? a : b) + 200;

    return AspectRatio(
      aspectRatio: 1.5,
      child: BarChart(
        BarChartData(
          maxY: maxY.toDouble(),
          barGroups: List.generate(7, (i) {
            return BarChartGroupData(x: i, barRods: [
              BarChartRodData(toY: kcalPrescrit[i].toDouble(), width: 8, color: Colors.green),
              BarChartRodData(toY: kcalMange[i].toDouble(), width: 8, color: Colors.deepOrange),
            ]);
          }),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 200,
                reservedSize: 40,
                getTitlesWidget: (value, _) => Text("${value.toInt()}", style: GoogleFonts.poppins(fontSize: 12)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  const days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(days[value.toInt() % 7], style: GoogleFonts.poppins(fontSize: 12)),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          groupsSpace: 16,
          barTouchData: BarTouchData(enabled: true),
        ),
      ),
    );
  }
}

class RegimeScreen extends StatefulWidget {
  final String token;
  final String userId;
  final int selectedDayIndex;
  final List<Map<String, dynamic>> meals;
  final bool isValidated;
  final Function(int) onValidate;

  const RegimeScreen({
    super.key,
    required this.token,
    required this.userId,
    required this.selectedDayIndex,
    required this.meals,
    required this.isValidated,
    required this.onValidate,
  });

  @override
  State<RegimeScreen> createState() => _RegimeScreenState();
}

class _RegimeScreenState extends State<RegimeScreen> {
  final List<String> jours = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
  final Map<String, bool> checkedItems = {};

  int calculerPrescritKcal(List<Map<String, dynamic>> repas) {
    return repas.fold(0, (total, r) {
      final aliments = r['aliments'] as List<dynamic>;
      return total + aliments.fold(0, (sum, a) => sum + ((a['kcal'] is int) ? a['kcal'] as int : 0));
    });
  }

  int calculerMangeKcal(List<Map<String, dynamic>> repas) {
    return repas.fold(0, (total, r) {
      final aliments = r['aliments'] as List<dynamic>;
      final keyBase = r['titre'];
      return total + aliments.fold(0, (sum, a) {
        final key = '$keyBase-${a['nom']}';
        return sum + (((checkedItems[key] ?? false) && a['kcal'] is int) ? a['kcal'] as int : 0);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final repasDuJour = widget.meals;
    final prescrit = calculerPrescritKcal(repasDuJour);
    final mange = calculerMangeKcal(repasDuJour);
    final validated = widget.isValidated;

    return Column(
      children: [
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: jours.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                child: ElevatedButton(
                  onPressed: () {
                    widget.onValidate(index);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.selectedDayIndex == index ? Colors.blue : Colors.grey[300],
                    foregroundColor: widget.selectedDayIndex == index ? Colors.white : Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(jours[index], style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              const Icon(LucideIcons.flame, color: Colors.green),
              const SizedBox(width: 6),
              Text("Prescrit: $prescrit kcal", style: GoogleFonts.poppins(fontSize: 16)),
            ]),
            Row(children: [
              const Icon(LucideIcons.apple, color: Colors.deepOrange),
              const SizedBox(width: 6),
              Text("Mangé: $mange kcal", style: GoogleFonts.poppins(fontSize: 16)),
            ]),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: repasDuJour.length,
            itemBuilder: (context, index) {
              final repas = repasDuJour[index];
              final aliments = repas['aliments'] as List<dynamic>;
              final titre = repas['titre'];

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(LucideIcons.utensils, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(titre, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 17)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...aliments.map((a) {
                        final key = '$titre-${a['nom']}';
                        final isChecked = checkedItems[key] ?? a['checked'] ?? false;
                        return ListTile(
                          leading: GestureDetector(
                            onTap: validated
                                ? null
                                : () async {
                                    setState(() => checkedItems[key] = !isChecked);
                                    try {
                                      a['checked'] = !isChecked;
                                      await ApiService.updateRegime(
                                        widget.token,
                                        widget.userId,
                                        widget.selectedDayIndex,
                                        widget.meals,
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Erreur lors de la mise à jour: $e')),
                                      );
                                    }
                                  },
                            child: Icon(
                              isChecked ? LucideIcons.checkCircle : LucideIcons.circle,
                              color: isChecked ? Colors.green : Colors.grey,
                            ),
                          ),
                          title: Text(a['nom'], style: GoogleFonts.poppins()),
                          trailing: Text('${a['kcal']} kcal', style: GoogleFonts.poppins()),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        if (!validated)
          ElevatedButton.icon(
            onPressed: () async {
              try {
                await ApiService.validateDay(widget.token, widget.userId, widget.selectedDayIndex);
                widget.onValidate(widget.selectedDayIndex);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur lors de la validation: $e')),
                );
              }
            },
            icon: const Icon(LucideIcons.badgeCheck),
            label: const Text("Valider la journée", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.shieldCheck, color: Colors.blue),
              const SizedBox(width: 8),
              Text("Journée validée ✅", style: GoogleFonts.poppins(color: Colors.blue, fontWeight: FontWeight.bold)),
            ],
          ),
      ],
    );
  }
}

class RegimeDashboardScreen extends StatefulWidget {
  final String token;
  const RegimeDashboardScreen({super.key, required this.token, required String userId, required String userName});

  @override
  State<RegimeDashboardScreen> createState() => _RegimeDashboardScreenState();
}

class _RegimeDashboardScreenState extends State<RegimeDashboardScreen> {
  int selectedDayIndex = DateTime.now().weekday - 1;
  List<int> kcalPrescrit = List.filled(7, 0);
  List<int> kcalMange = List.filled(7, 0);
  List<Map<String, dynamic>> meals = [];
  bool isValidated = false;
  bool isLoading = true;
  String? errorMessage;
  String? userId;

  @override
  void initState() {
    super.initState();
    print('RegimeDashboardScreen: Initializing with token: ${widget.token.isNotEmpty ? "[present]" : "[empty]"}');
    _fetchData();
  }

  Future<void> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    print('RegimeDashboardScreen: Checking SharedPreferences for userId: $userId');
    if (userId != null && userId!.isNotEmpty) {
      print('RegimeDashboardScreen: Using userId from SharedPreferences: $userId');
      return;
    }
    print('RegimeDashboardScreen: No userId in SharedPreferences, fetching from API');
    try {
      final userData = await ApiService.getUserProfile(widget.token);
      print('RegimeDashboardScreen: User profile response: $userData');
      userId = userData['id']?.toString() ??
               userData['_id']?.toString() ??
               userData['userId']?.toString() ??
               '';
      print('RegimeDashboardScreen: Extracted userId from API: $userId');
      if (userId!.isNotEmpty) {
        await prefs.setString('userId', userId!);
        print('RegimeDashboardScreen: Stored userId in SharedPreferences: $userId');
      } else {
        print('RegimeDashboardScreen: No valid userId found in user profile: $userData');
        setState(() {
          errorMessage = 'Profil utilisateur ne contient pas d\'identifiant. Veuillez réessayer.';
          isLoading = false;
        });
      }
    } catch (e) {
      print('RegimeDashboardScreen: Error fetching user profile: $e');
      setState(() {
        errorMessage = 'Erreur lors de la récupération du profil : $e';
        isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    print('RegimeDashboardScreen: Cleared token and userId, redirecting to /login');
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      print('RegimeDashboardScreen: Fetching data with token: ${widget.token}');
      if (widget.token.isEmpty) {
        setState(() {
          errorMessage = 'Aucun token d\'authentification trouvé';
          isLoading = false;
        });
        await _logout();
        return;
      }
      await _getUserId();
      if (userId == null || userId!.isEmpty) {
        setState(() {
          errorMessage = 'Utilisateur non identifié. Veuillez vérifier votre connexion ou réessayer.';
          isLoading = false;
        });
        return;
      }
      final data = await ApiService.getRegimeData(userId!, selectedDayIndex, widget.token);
      final validationData = await ApiService.getValidation(widget.token, userId!, selectedDayIndex);
      print('RegimeDashboardScreen: Fetched data: $data');
      print('RegimeDashboardScreen: Validation data: $validationData');
      setState(() {
        kcalPrescrit = List<int>.from(data['kcalPrescrit'] ?? List.filled(7, 0));
        kcalMange = List<int>.from(data['kcalMange'] ?? List.filled(7, 0));
        meals = List<Map<String, dynamic>>.from(data['meals'] ?? []);
        isValidated = validationData['validated'] ?? false;
        isLoading = false;
      });
    } catch (e) {
      print('RegimeDashboardScreen: Fetch error: $e');
      setState(() {
        errorMessage = 'Erreur lors du chargement des données : ${e.toString().replaceFirst('Exception: ', '')}';
        isLoading = false;
      });
      if (e.toString().contains('Invalid token')) {
        await _logout();
      }
    }
  }

  void _onDaySelected(int index) {
    setState(() {
      selectedDayIndex = index;
    });
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A3C5A)))
            : errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          errorMessage!,
                          style: GoogleFonts.poppins(color: const Color(0xFFB91C1C), fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _fetchData,
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
                          onPressed: _logout,
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
                      Text(
                        'Régime',
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 36,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF1A3C5A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Suivez votre plan alimentaire !',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: const Color(0xFF6B7280),
                        ),
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
                              'Résumé Calorique Hebdomadaire',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: const Color(0xFF1A3C5A),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 200,
                              child: RegimeSummaryGraph(
                                kcalPrescrit: kcalPrescrit,
                                kcalMange: kcalMange,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Plan Alimentaire',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: const Color(0xFF1A3C5A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      RegimeScreen(
                        token: widget.token,
                        userId: userId!,
                        selectedDayIndex: selectedDayIndex,
                        meals: meals,
                        isValidated: isValidated,
                        onValidate: (index) {
                          setState(() {
                            selectedDayIndex = index;
                            isValidated = true;
                          });
                          _fetchData();
                        },
                      ),
                    ],
                  ),
      ),
    );
  }
}