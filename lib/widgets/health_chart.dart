// 📁 lib/widgets/health_chart.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HealthChart extends StatelessWidget {
  const HealthChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 40,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const labels = ['Pas', 'IMC', 'Calories', '%MG'];
                  return Text(labels[value.toInt() % labels.length]);
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, interval: 10),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 7.5, color: Colors.green)]),
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 27.3, color: Colors.blue)]),
            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 18, color: Colors.orange)]),
            BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 24, color: Colors.teal)]),
          ],
        ),
      ),
    );
  }
}
