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
      appBar: AppBar(
        title: const Text("Mon régime personnalisé"),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: const Icon(Icons.local_fire_department, color: Colors.orange),
                title: const Text(
                  "Voir mon régime du jour",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegimeScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  child: const Text("Accéder"),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Progression hebdomadaire",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 1.8,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: BarChart(
                  BarChartData(
                    maxY: maxY,
                    barGroups: List.generate(7, (index) {
                      return BarChartGroupData(
                        x: index,
                        barsSpace: 4, // 🟢 ESPACEMENT entre les deux barres
                        barRods: [
                          BarChartRodData(
                            toY: kcalPrescrit[index].toDouble(),
                            color: Colors.green,
                            width: 6,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          BarChartRodData(
                            toY: kcalMange[index].toDouble(),
                            color: Colors.redAccent,
                            width: 6,
                            borderRadius: BorderRadius.circular(4),
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
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  days[value.toInt()],
                                  style: const TextStyle(fontSize: 12),
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
                          reservedSize: 36,
                          getTitlesWidget: (value, meta) => Padding(
                            padding: const EdgeInsets.only(right: 4.0),
                            child: Text('${value.toInt()}', style: const TextStyle(fontSize: 10)),
                          ),
                        ),
                      ),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(show: true),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
