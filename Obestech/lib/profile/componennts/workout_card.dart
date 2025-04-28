import 'package:flutter/material.dart';
import '../../../theme/theme.dart';

class WorkoutCard extends StatelessWidget {
  final String title;
  final String description;
  final String duration;
  final String intensity;
  final VoidCallback onStart;

  const WorkoutCard({
    super.key,
    required this.title,
    required this.description,
    required this.duration,
    required this.intensity,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.headline),
            Text('$duration • $intensity', style: AppTextStyles.subhead),
            const SizedBox(height: 8),
            Text(description, style: AppTextStyles.label),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Start Workout'),
            )
          ],
        ),
      ),
    );
  }
}
