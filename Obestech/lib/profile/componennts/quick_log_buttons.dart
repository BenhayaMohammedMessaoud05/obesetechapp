import 'package:flutter/material.dart';

class QuickLogButtons extends StatelessWidget {
  const QuickLogButtons({super.key, required String token, required Future<Null> Function() onLog});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildButton(Icons.directions_run, 'Run'),
        _buildButton(Icons.self_improvement, 'Yoga'),
        _buildButton(Icons.fitness_center, 'Weights'),
      ],
    );
  }

  Widget _buildButton(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          child: Icon(icon),
        ),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }
}
