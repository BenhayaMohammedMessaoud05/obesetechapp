import 'package:flutter/material.dart';
import 'package:obesetechapp/profile/componennts/quick_log_buttons.dart';
import 'package:obesetechapp/profile/componennts/workout_card.dart';
import 'package:obesetechapp/profile/componennts/achievements_list.dart';

import '../../models/achievement.dart';

class WorkoutFormScreen extends StatelessWidget {
  const WorkoutFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final achievements = [
      Achievement(
        title: '10K Steps Champion',
        description: 'Reached 10,000 steps 5 days in a row!',
      ),
      Achievement(
        title: 'Morning Workout Warrior',
        description: 'Completed 3 morning workouts this week.',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Workout Form')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WorkoutCard(
              title: 'HIIT Cardio Challenge',
              description: 'Boost your metabolism with high-intensity intervals.',
              duration: '25 mins',
              intensity: 'High Intensity',
              onStart: () => debugPrint('Workout started!'),
            ),
            const SizedBox(height: 20),
            const QuickLogButtons(),
            const SizedBox(height: 24),
            Text(
              'Achievements',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            AchievementsList(achievements: achievements),
          ],
        ),
      ),
    );
  }
}
