import 'package:flutter/material.dart';
import '../../../models/achievement.dart';
import '../../../theme/theme.dart';

class AchievementsList extends StatelessWidget {
  final List<Achievement> achievements;

  const AchievementsList({super.key, required this.achievements});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: achievements.map((ach) {
        return ListTile(
          leading: const Icon(Icons.emoji_events, color: Colors.orange),
          title: Text(ach.title, style: AppTextStyles.subhead),
          subtitle: Text(ach.description),
        );
      }).toList(),
    );
  }
}
