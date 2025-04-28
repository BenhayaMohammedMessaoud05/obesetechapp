import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:obesetechapp/profile/componennts/step_summary_card.dart';
import 'package:obesetechapp/profile/componennts/weekly_activity_chart.dart';

import '../../models/activity_data.dart';

class ActivityTrackerScreen extends StatelessWidget {
  const ActivityTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final activity = ActivityData(
      steps: 10500,
      calories: 350,
      kilometers: 7.2,
      activeMinutes: 45,
      goalPercent: 84,
      weeklySteps: [5000, 8000, 4000, 10000, 7000, 8500, 6000],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Tracker'),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StepSummaryCard(
              steps: activity.steps,
              calories: activity.calories,
              kilometers: activity.kilometers,
              activeMinutes: activity.activeMinutes,
              goalPercent: activity.goalPercent,
            ),
            const SizedBox(height: 24),
            WeeklyActivityChart(weeklySteps: activity.weeklySteps),
          ],
        ),
      ),
    );
  }
}
