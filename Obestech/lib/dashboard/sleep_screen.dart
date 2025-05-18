import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:obesetechapp/services/api_service.dart';

class AppColors {
  static const primary = Color(0xFF1A3C5A);
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
}

class SleepScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic>? sleepData;
  final Function(Map<String, dynamic>) onSleepDataUpdate;

  const SleepScreen({
    Key? key,
    required this.token,
    this.sleepData,
    required this.onSleepDataUpdate,
  }) : super(key: key);

  @override
  _SleepScreenState createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  Map<String, dynamic>? _sleepData;
  bool _isSleeping = false;
  String _errorMessage = '';
  DateTime? _sleepStart;

  @override
  void initState() {
    super.initState();
    _sleepData = widget.sleepData;
    _fetchSleepData();
  }

  Future<void> _fetchSleepData() async {
    try {
      final sleepData = await ApiService.getSleepData(widget.token);
      setState(() {
        _sleepData = sleepData;
      });
      widget.onSleepDataUpdate(sleepData);
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des données de sommeil: $e';
      });
    }
  }

  Future<void> _toggleSleepSession() async {
    try {
      setState(() {
        _errorMessage = '';
      });
      if (!_isSleeping) {
        await ApiService.updateSleepSession(widget.token, 'start');
        setState(() {
          _isSleeping = true;
          _sleepStart = DateTime.now();
        });
      } else {
        await ApiService.updateSleepSession(widget.token, 'end');
        final sleepData = await ApiService.getSleepData(widget.token);
        setState(() {
          _isSleeping = false;
          _sleepStart = null;
          _sleepData = sleepData;
        });
        widget.onSleepDataUpdate(sleepData);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la mise à jour de la session: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sommeil', style: AppTextStyles.headline),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(_errorMessage, style: GoogleFonts.poppins(color: Colors.red)),
              ),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Statut Sommeil', style: AppTextStyles.subhead),
                  const SizedBox(height: 8),
                  Text(
                    _isSleeping ? 'En cours...' : 'Aucun sommeil en cours',
                    style: GoogleFonts.poppins(fontSize: 14, color: AppColors.primary),
                  ),
                  if (_isSleeping && _sleepStart != null)
                    Text(
                      'Début: ${_sleepStart!.toString().substring(0, 16)}',
                      style: AppTextStyles.label,
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _toggleSleepSession,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isSleeping ? Colors.red : AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      _isSleeping ? 'Arrêter Sommeil' : 'Démarrer Sommeil',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Données Récentes', style: AppTextStyles.headline),
            const SizedBox(height: 16),
            if (_sleepData == null)
              Text('Aucune donnée disponible', style: AppTextStyles.label)
            else
              Column(
                children: [
                  ListTile(
                    title: Text('Durée Moyenne', style: GoogleFonts.poppins(fontSize: 14)),
                    subtitle: Text(
                      _sleepData!['averageDuration']?.toString() ?? 'N/A',
                      style: AppTextStyles.label,
                    ),
                  ),
                  ListTile(
                    title: Text('Qualité', style: GoogleFonts.poppins(fontSize: 14)),
                    subtitle: Text(
                      _sleepData!['quality']?.toString() ?? 'N/A',
                      style: AppTextStyles.label,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}