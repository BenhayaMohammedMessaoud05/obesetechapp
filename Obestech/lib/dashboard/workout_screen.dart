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

class WorkoutScreen extends StatefulWidget {
  final String token;
  final Map<String, dynamic>? workoutData;

  const WorkoutScreen({Key? key, required this.token, this.workoutData}) : super(key: key);

  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  Map<String, dynamic>? _workoutData;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _typeController = TextEditingController();
  TextEditingController _durationController = TextEditingController();
  TextEditingController _caloriesController = TextEditingController();
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _workoutData = widget.workoutData;
    _fetchWorkouts();
  }

  @override
  void dispose() {
    _typeController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  Future<void> _fetchWorkouts() async {
    try {
      final workouts = await ApiService.getWorkouts(widget.token);
      setState(() {
        _workoutData = workouts;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des entraînements: $e';
      });
    }
  }

  Future<void> _logWorkout() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final workout = {
        'type': _typeController.text,
        'duration': int.tryParse(_durationController.text) ?? 0,
        'calories': int.tryParse(_caloriesController.text) ?? 0,
        'date': DateTime.now().toIso8601String(),
      };
      await ApiService.logWorkout(widget.token, workout);
      final workouts = await ApiService.getWorkouts(widget.token);
      setState(() {
        _workoutData = workouts;
        _typeController.clear();
        _durationController.clear();
        _caloriesController.clear();
        _errorMessage = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Entraînement enregistré')),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de l\'enregistrement: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Entraînements', style: AppTextStyles.headline),
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
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Type d\'entraînement', style: AppTextStyles.subhead),
                  TextFormField(
                    controller: _typeController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: AppColors.cardBackground,
                    ),
                    validator: (value) => value!.isEmpty ? 'Type requis' : null,
                  ),
                  const SizedBox(height: 16),
                  Text('Durée (min)', style: AppTextStyles.subhead),
                  TextFormField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: AppColors.cardBackground,
                    ),
                    validator: (value) => int.tryParse(value ?? '') != null ? null : 'Durée invalide',
                  ),
                  const SizedBox(height: 16),
                  Text('Calories brûlées', style: AppTextStyles.subhead),
                  TextFormField(
                    controller: _caloriesController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: AppColors.cardBackground,
                    ),
                    validator: (value) => int.tryParse(value ?? '') != null ? null : 'Calories invalides',
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _logWorkout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      'Enregistrer Entraînement',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Historique', style: AppTextStyles.headline),
            const SizedBox(height: 16),
            if (_workoutData == null || _workoutData!['workouts'] == null)
              Text('Aucun entraînement disponible', style: AppTextStyles.label)
            else
              ...(_workoutData!['workouts'] as List).map((workout) => ListTile(
                    title: Text(workout['type'], style: GoogleFonts.poppins(fontSize: 14)),
                    subtitle: Text(
                      'Durée: ${workout['duration']} min, Calories: ${workout['calories']}',
                      style: AppTextStyles.label,
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}