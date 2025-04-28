// 📁 lib/prediction/risk_prediction_screen.dart

import 'package:flutter/material.dart';

class RiskPredictionScreen extends StatefulWidget {
  const RiskPredictionScreen({super.key});

  @override
  State<RiskPredictionScreen> createState() => _RiskPredictionScreenState();
}

class _RiskPredictionScreenState extends State<RiskPredictionScreen> {
  String sleep = '';
  String activity = '';
  String stress = '';
  String? result;

  void analyze() {
    if (sleep.isEmpty || activity.isEmpty || stress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs.")),
      );
      return;
    }
    setState(() {
      result = "Risque modéré détecté (exemple).";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Prédiction du risque")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text("Analyse de vos habitudes de vie", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: "Heures de sommeil par nuit"),
              onChanged: (val) => sleep = val,
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(labelText: "Activité physique (min/jour)"),
              onChanged: (val) => activity = val,
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(labelText: "Niveau de stress (1-10)"),
              onChanged: (val) => stress = val,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: analyze,
              child: const Text("Analyser"),
            ),
            if (result != null) ...[
              const SizedBox(height: 20),
              Text(result!, style: const TextStyle(fontSize: 16, color: Colors.orange)),
            ]
          ],
        ),
      ),
    );
  }
}
