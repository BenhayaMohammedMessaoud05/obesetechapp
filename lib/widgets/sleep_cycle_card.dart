import 'package:flutter/material.dart';

class SleepCycleCard extends StatelessWidget {
  final String date;
  final String duration;
  final String deepSleep;
  final String remSleep;
  final String lightSleep;

  const SleepCycleCard({
    super.key,
    required this.date,
    required this.duration,
    required this.deepSleep,
    required this.remSleep,
    required this.lightSleep,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1F47),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date and Total Duration
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    const Icon(Icons.timelapse, size: 18, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(
                      duration,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 12),

            // Sleep Stage Breakdown
            _buildStageRow("Deep Sleep", deepSleep, Colors.tealAccent),
            const SizedBox(height: 6),
            _buildStageRow("REM Sleep", remSleep, Colors.orangeAccent),
            const SizedBox(height: 6),
            _buildStageRow("Light Sleep", lightSleep, Colors.blueAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildStageRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
