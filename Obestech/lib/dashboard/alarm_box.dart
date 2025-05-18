import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:obesetechapp/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

class AlarmBox extends StatefulWidget {
  final String token;
  final String userName;

  const AlarmBox({Key? key, required this.token, required this.userName}) : super(key: key);

  @override
  _AlarmBoxState createState() => _AlarmBoxState();
}

class _AlarmBoxState extends State<AlarmBox> {
  List<Map<String, dynamic>> _alarms = [];
  String _errorMessage = '';
  bool _recurring = false;

  @override
  void initState() {
    super.initState();
    _loadAlarms();
  }

  Future<void> _loadAlarms() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alarmsJson = prefs.getString('alarms_${widget.userName}') ?? '[]';
      setState(() {
        _alarms = List<Map<String, dynamic>>.from(jsonDecode(alarmsJson));
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des alarmes: $e';
      });
    }
  }

  Future<void> _addAlarm(TimeOfDay time, String title, bool recurring) async {
    try {
      final newAlarm = {
        'title': title,
        'time': '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
        'createdAt': DateTime.now().toIso8601String(),
        'recurring': recurring,
      };
      setState(() {
        _alarms.add(newAlarm);
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('alarms_${widget.userName}', jsonEncode(_alarms));
      await ApiService.logQuickAction(widget.token, 'alarm', 'Ajout alarme: $title à ${newAlarm['time']}, Récurrent: $recurring');
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de l\'ajout de l\'alarme: $e';
      });
    }
  }

  Future<void> _deleteAlarm(int index) async {
    try {
      final alarm = _alarms[index];
      setState(() {
        _alarms.removeAt(index);
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('alarms_${widget.userName}', jsonEncode(_alarms));
      await ApiService.logQuickAction(widget.token, 'alarm', 'Suppression alarme: ${alarm['title']}');
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la suppression de l\'alarme: $e';
      });
    }
  }

  void _showAddAlarmDialog() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    final titleController = TextEditingController();
    bool recurring = false;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nouvelle Alarme', style: AppTextStyles.subhead),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Titre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            StatefulBuilder(
              builder: (context, setDialogState) {
                return CheckboxListTile(
                  title: Text('Récurrente', style: GoogleFonts.poppins(fontSize: 14)),
                  value: recurring,
                  onChanged: (value) {
                    setDialogState(() {
                      recurring = value ?? false;
                    });
                  },
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: GoogleFonts.poppins(color: AppColors.primary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                _addAlarm(time, titleController.text, recurring);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text('Ajouter', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Alarmes', style: AppTextStyles.subhead),
              IconButton(
                icon: Icon(Icons.add, color: AppColors.primary),
                onPressed: _showAddAlarmDialog,
              ),
            ],
          ),
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(_errorMessage, style: GoogleFonts.poppins(color: Colors.red)),
            ),
          if (_alarms.isEmpty)
            Text('Aucune alarme configurée', style: AppTextStyles.label),
          ..._alarms.asMap().entries.map((entry) {
            final index = entry.key;
            final alarm = entry.value;
            return ListTile(
              title: Text(alarm['title'], style: GoogleFonts.poppins(fontSize: 14)),
              subtitle: Text(
                '${alarm['time']} ${alarm['recurring'] ? '(Récurrente)' : ''}',
                style: AppTextStyles.label,
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteAlarm(index),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}