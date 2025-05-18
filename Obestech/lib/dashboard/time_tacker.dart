import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:obesetechapp/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';

class AppColors {
  static const primary = Color(0xFF1A3C5A);
  static const cardBackground = Color(0xFFF9FAFB);
}

class AppTextStyles {
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

class TimeTracker extends StatefulWidget {
  final String token;
  final String userName;

  const TimeTracker({Key? key, required this.token, required this.userName}) : super(key: key);

  @override
  _TimeTrackerState createState() => _TimeTrackerState();
}

class _TimeTrackerState extends State<TimeTracker> {
  List<Map<String, dynamic>> _timeLogs = [];
  bool _isTracking = false;
  DateTime? _startTime;
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;
  String _errorMessage = '';
  TextEditingController _activityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTimeLogs();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _activityController.dispose();
    super.dispose();
  }

  Future<void> _loadTimeLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = prefs.getString('time_logs_${widget.userName}') ?? '[]';
      setState(() {
        _timeLogs = List<Map<String, dynamic>>.from(jsonDecode(logsJson));
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des journaux: $e';
      });
    }
  }

  void _startTracking() {
    if (_activityController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez entrer un nom d\'activité';
      });
      return;
    }
    setState(() {
      _isTracking = true;
      _startTime = DateTime.now();
      _elapsedTime = Duration.zero;
      _errorMessage = '';
    });
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedTime = DateTime.now().difference(_startTime!);
      });
    });
  }

  Future<void> _stopTracking() async {
    try {
      _timer?.cancel();
      final log = {
        'activity': _activityController.text,
        'duration': _elapsedTime.inSeconds,
        'startTime': _startTime!.toIso8601String(),
        'endTime': DateTime.now().toIso8601String(),
      };
      setState(() {
        _timeLogs.add(log);
        _isTracking = false;
        _startTime = null;
        _elapsedTime = Duration.zero;
        _activityController.clear();
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('time_logs_${widget.userName}', jsonEncode(_timeLogs));
      await ApiService.logQuickAction(
        widget.token,
        'time_tracker',
        'Activité: ${log['activity']}, Durée: ${_elapsedTime.inMinutes} min',
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de l\'enregistrement: $e';
      });
    }
  }

  String _formatDuration(Duration duration) {
    return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m ${duration.inSeconds.remainder(60)}s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text('Suivi du Temps', style: AppTextStyles.subhead),
          const SizedBox(height: 16),
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(_errorMessage, style: GoogleFonts.poppins(color: Colors.red)),
            ),
          TextField(
            controller: _activityController,
            decoration: InputDecoration(
              labelText: 'Activité',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            enabled: !_isTracking,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Temps: ${_formatDuration(_elapsedTime)}',
                style: GoogleFonts.poppins(fontSize: 14, color: AppColors.primary),
              ),
              ElevatedButton(
                onPressed: _isTracking ? _stopTracking : _startTracking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isTracking ? Colors.red : AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(
                  _isTracking ? 'Arrêter' : 'Démarrer',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Historique', style: AppTextStyles.subhead),
          if (_timeLogs.isEmpty)
            Text('Aucun journal disponible', style: AppTextStyles.label),
          ..._timeLogs.map((log) => ListTile(
                title: Text(log['activity'], style: GoogleFonts.poppins(fontSize: 14)),
                subtitle: Text(
                  'Durée: ${_formatDuration(Duration(seconds: log['duration']))}',
                  style: AppTextStyles.label,
                ),
              )),
        ],
      ),
    );
  }
}