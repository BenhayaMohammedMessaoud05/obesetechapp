import 'package:flutter/material.dart';
import 'package:obesetechapp/widgets/group_tile.dart';
import 'chat_room_screen.dart';


class GroupListScreen extends StatelessWidget {
  const GroupListScreen({super.key});

  final List<Map<String, dynamic>> groups = const [
    {'title': 'Général', 'icon': Icons.chat_bubble_outline, 'color': Colors.blue},
    {'title': 'Diabète et obésité', 'icon': Icons.monitor_heart, 'color': Colors.teal},
    {'title': 'Grossesse et obésité', 'icon': Icons.pregnant_woman, 'color': Colors.pinkAccent},
    {'title': 'Enfants et adolescents', 'icon': Icons.child_care, 'color': Colors.orange},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return GroupTile(
          title: group['title'],
          icon: group['icon'],
          color: group['color'],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatRoomScreen(title: group['title']),
              ),
            );
          },
        );
      },
    );
  }
}
