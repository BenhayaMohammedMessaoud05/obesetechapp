import 'package:flutter/material.dart';

class SleepCard extends StatelessWidget {
  final String duration;
  final String quality;

  const SleepCard({
    super.key,
    required this.duration,
    required this.quality,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: ListTile(
        leading: const Icon(Icons.bedtime, size: 40, color: Colors.indigo),
        title: Text("Sommeil : $duration"),
        subtitle: Text("Qualité : $quality"),
      ),
    );
  }
}
