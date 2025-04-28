import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'regime_screen.dart';

class RegimeDashboardScreen extends StatelessWidget {
  RegimeDashboardScreen({super.key});

  final List<int> kcalPrescrit = [1450, 1300, 1550, 1600, 1500, 1700, 1400];
  final List<int> kcalMange = [1200, 1100, 1400, 1300, 1350, 1600, 1200];

  @override
  Widget build(BuildContext context) {
    final maxY = (([...kcalPrescrit, ...kcalMange].reduce((a, b) => a > b ? a : b)) + 200).toDouble();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // **Amélioration de la section "Voir mon régime du jour"**
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.local_fire_department, color: Colors.orange, size: 30),
                  ),
                  title: const Text(
                    "Voir mon régime du jour",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegimeScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 0, 85, 150),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                    ),
                    child: const Text(
                      "Accéder",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Texte en blanc
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "Progression Hebdomadaire",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 20),
              // **Amélioration du graphique**
              AspectRatio(
                aspectRatio: 1.7,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: BarChart(
                    BarChartData(
                      maxY: maxY,
                      barGroups: List.generate(7, (index) {
                        return BarChartGroupData(
                          x: index,
                          barsSpace: 8,
                          barRods: [
                            BarChartRodData(
                              toY: kcalPrescrit[index].toDouble(),
                              color: Colors.green.shade400,
                              width: 8,
                              borderRadius: BorderRadius.circular(12),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: maxY,
                                color: Colors.green.shade100,
                              ),
                            ),
                            BarChartRodData(
                              toY: kcalMange[index].toDouble(),
                              color: Colors.redAccent.shade200,
                              width: 8,
                              borderRadius: BorderRadius.circular(12),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: maxY,
                                color: Colors.redAccent.shade100,
                              ),
                            ),
                          ],
                        );
                      }),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
                              if (value.toInt() >= 0 && value.toInt() < days.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    days[value.toInt()],
                                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                                  ),
                                );
                              } else {
                                return const SizedBox.shrink();
                              }
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 200,
                            reservedSize: 38,
                            getTitlesWidget: (value, meta) => Text(
                              '${value.toInt()}',
                              style: const TextStyle(fontSize: 12, color: Colors.black54),
                            ),
                          ),
                        ),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(show: true, drawVerticalLine: false),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
