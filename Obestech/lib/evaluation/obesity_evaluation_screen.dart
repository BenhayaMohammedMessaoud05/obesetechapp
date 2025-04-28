// 📁 lib/evaluation/obesity_evaluation_screen.dart

import 'package:flutter/material.dart';

class ObesityEvaluationScreen extends StatelessWidget {
  const ObesityEvaluationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double imc = 28.4;
    final String result = imc < 18.5
        ? 'Insuffisance pondérale'
        : imc < 25
            ? 'Poids normal'
            : imc < 30
                ? 'Surpoids'
                : 'Obésité';

    return Scaffold(
      appBar: AppBar(title: const Text("Évaluation IMC")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Ton IMC est de $imc", style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: imc / 40,
              minHeight: 12,
              color: Colors.orange,
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(height: 20),
            Text("Interprétation : $result", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.info_outline),
              label: const Text("En savoir plus"),
              onPressed: () {},
            )
          ],
        ),
      ),
    );
  }
}