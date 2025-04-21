import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegimeSummaryGraph extends StatelessWidget {
  final List<int> kcalPrescrit;
  final List<int> kcalMange;

  const RegimeSummaryGraph({
    super.key,
    required this.kcalPrescrit,
    required this.kcalMange,
  });

  @override
  Widget build(BuildContext context) {
    final maxY = (kcalPrescrit + kcalMange).reduce((a, b) => a > b ? a : b) + 200;

    return AspectRatio(
      aspectRatio: 1.5,
      child: BarChart(
        BarChartData(
          maxY: maxY.toDouble(),
          barGroups: List.generate(7, (i) {
            return BarChartGroupData(x: i, barRods: [
              BarChartRodData(toY: kcalPrescrit[i].toDouble(), width: 8, color: Colors.green),
              BarChartRodData(toY: kcalMange[i].toDouble(), width: 8, color: Colors.deepOrange),
            ]);
          }),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 200,
                reservedSize: 40,
                getTitlesWidget: (value, _) => Text("${value.toInt()}", style: GoogleFonts.poppins(fontSize: 12)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  const days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(days[value.toInt() % 7], style: GoogleFonts.poppins(fontSize: 12)),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          groupsSpace: 16,
          barTouchData: BarTouchData(enabled: true),
        ),
      ),
    );
  }
}
