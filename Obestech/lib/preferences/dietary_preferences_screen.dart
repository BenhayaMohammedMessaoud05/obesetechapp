// 📁 lib/preferences/dietary_preferences_screen.dart

import 'package:flutter/material.dart';

class DietaryPreferencesScreen extends StatefulWidget {
  const DietaryPreferencesScreen({super.key});

  @override
  State<DietaryPreferencesScreen> createState() => _DietaryPreferencesScreenState();
}

class _DietaryPreferencesScreenState extends State<DietaryPreferencesScreen> {
  List<String> likes = [];
  List<String> dislikes = [];
  List<String> allergies = [];

  final List<String> foods = ['Poulet', 'Poisson', 'Pain', 'Légumes', 'Lait'];
  final List<String> allergens = ['Gluten', 'Lactose', 'Fruits de mer'];

  String culture = 'Aucune';
  String budget = 'Moyen';
  String schedule = 'Standard';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Préférences alimentaires")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Aliments aimés :", style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: foods.map((item) => FilterChip(
                label: Text(item),
                selected: likes.contains(item),
                onSelected: (val) => setState(() => val ? likes.add(item) : likes.remove(item)),
              )).toList(),
            ),
            const SizedBox(height: 20),
            const Text("Aliments détestés :", style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: foods.map((item) => FilterChip(
                label: Text(item),
                selected: dislikes.contains(item),
                onSelected: (val) => setState(() => val ? dislikes.add(item) : dislikes.remove(item)),
              )).toList(),
            ),
            const SizedBox(height: 20),
            const Text("Allergies :", style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: allergens.map((item) => FilterChip(
                label: Text(item),
                selected: allergies.contains(item),
                onSelected: (val) => setState(() => val ? allergies.add(item) : allergies.remove(item)),
              )).toList(),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField(
              value: culture,
              items: ['Aucune', 'Halal', 'Végétarien', 'Vegan'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => culture = val!),
              decoration: const InputDecoration(labelText: "Culture / Régime"),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField(
              value: budget,
              items: ['Faible', 'Moyen', 'Élevé'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => budget = val!),
              decoration: const InputDecoration(labelText: "Budget"),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField(
              value: schedule,
              items: ['Standard', 'Ramadan', '2 repas/jour', '3 repas/jour'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => schedule = val!),
              decoration: const InputDecoration(labelText: "Horaires"),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Préférences enregistrées")),
                ),
                icon: const Icon(Icons.save),
                label: const Text("Valider"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
