import 'package:flutter/material.dart';
import '../../../theme/theme.dart';

class StepSummaryCard extends StatelessWidget {
  final int steps;
  final int calories;
  final double kilometers;
  final int activeMinutes;
  final int goalPercent;

  const StepSummaryCard({
    super.key,
    required this.steps,
    required this.calories,
    required this.kilometers,
    required this.activeMinutes,
    required this.goalPercent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.cardBackground,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text('$steps', style: AppTextStyles.headline),
                const Spacer(),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: goalPercent / 100,
                      color: AppColors.accent,
                      strokeWidth: 6,
                    ),
                    Text('$goalPercent%', style: AppTextStyles.label),
                  ],
                )
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(Icons.local_fire_department, '$calories', 'Calories'),
                _buildInfoItem(Icons.directions_walk, '$kilometers km', 'Kilometers'),
                _buildInfoItem(Icons.access_time, '$activeMinutes', 'Active Min'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.value),
        Text(label, style: AppTextStyles.label),
      ],
    );
  }
}
