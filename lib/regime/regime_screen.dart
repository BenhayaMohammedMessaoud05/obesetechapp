import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class RegimeScreen extends StatefulWidget {
  const RegimeScreen({Key? key}) : super(key: key);

  @override
  State<RegimeScreen> createState() => _RegimeScreenState();
}

class _RegimeScreenState extends State<RegimeScreen> {
  final List<String> jours = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
  int selectedDayIndex = DateTime.now().weekday - 1;
  final Map<String, bool> checkedItems = {};
  final Map<int, bool> validatedDays = {};

  final Map<int, List<Map<String, dynamic>>> regimeParJour = {
    0: [
      {
        "titre": "Petit-déjeuner",
        "aliments": [
          {"nom": "Œufs", "kcal": 150},
          {"nom": "Pain complet", "kcal": 120},
          {"nom": "Orange", "kcal": 80},
        ]
      },
      {
        "titre": "Déjeuner",
        "aliments": [
          {"nom": "Poulet", "kcal": 250},
          {"nom": "Riz", "kcal": 200},
          {"nom": "Légumes", "kcal": 100},
        ]
      },
      {
        "titre": "Dîner",
        "aliments": [
          {"nom": "Soupe", "kcal": 120},
          {"nom": "Yaourt", "kcal": 90},
          {"nom": "Pomme", "kcal": 60},
        ]
      },
    ],
    1: [
      {
        "titre": "Petit-déjeuner",
        "aliments": [
          {"nom": "Smoothie", "kcal": 180},
          {"nom": "Muesli", "kcal": 140},
          {"nom": "Kiwi", "kcal": 60},
        ]
      },
      {
        "titre": "Déjeuner",
        "aliments": [
          {"nom": "Steak", "kcal": 300},
          {"nom": "Patates douces", "kcal": 180},
          {"nom": "Salade verte", "kcal": 70},
        ]
      },
      {
        "titre": "Dîner",
        "aliments": [
          {"nom": "Soupe de légumes", "kcal": 100},
          {"nom": "Pain complet", "kcal": 120},
          {"nom": "Pomme", "kcal": 60},
        ]
      },
    ],
    2: [
      {
        "titre": "Petit-déjeuner",
        "aliments": [
          {"nom": "Yaourt nature", "kcal": 100},
          {"nom": "Fruits rouges", "kcal": 80},
          {"nom": "Granola", "kcal": 120},
        ]
      },
      {
        "titre": "Déjeuner",
        "aliments": [
          {"nom": "Poisson", "kcal": 220},
          {"nom": "Légumes vapeur", "kcal": 120},
          {"nom": "Quinoa", "kcal": 160},
        ]
      },
      {
        "titre": "Dîner",
        "aliments": [
          {"nom": "Soupe de tomates", "kcal": 110},
          {"nom": "Biscottes", "kcal": 90},
          {"nom": "Compote", "kcal": 70},
        ]
      },
    ],
  };

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
    final repasDuJour = regimeParJour[selectedDayIndex] ?? [];
    final prescrit = calculerPrescritKcal(repasDuJour);
    final mange = calculerMangeKcal(repasDuJour);
    final validated = validatedDays[selectedDayIndex] ?? false;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Régime personnalisé", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
                        setState(() => selectedDayIndex = index);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedDayIndex == index ? Colors.teal : Colors.grey[300],
                        foregroundColor: selectedDayIndex == index ? Colors.white : Colors.black,
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
                              const Icon(LucideIcons.utensils, color: Colors.teal),
                              const SizedBox(width: 8),
                              Text(titre, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 17)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ...aliments.map((a) {
                            final key = '$titre-${a['nom']}';
                            final isChecked = checkedItems[key] ?? false;
                            return ListTile(
                              leading: GestureDetector(
                                onTap: validated
                                    ? null
                                    : () => setState(() => checkedItems[key] = !isChecked),
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
                onPressed: () => setState(() => validatedDays[selectedDayIndex] = true),
                icon: const Icon(LucideIcons.badgeCheck),
                label: const Text("Valider la journée"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.shieldCheck, color: Colors.teal),
                  const SizedBox(width: 8),
                  Text("Journée validée ✅", style: GoogleFonts.poppins(color: Colors.teal, fontWeight: FontWeight.bold)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
