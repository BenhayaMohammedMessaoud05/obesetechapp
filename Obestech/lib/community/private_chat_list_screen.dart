// 📁 lib/community/private_chat_list_screen.dart

import 'package:flutter/material.dart';
import 'chat_room_screen.dart';

class PrivateChatListScreen extends StatelessWidget {
  const PrivateChatListScreen({super.key});

  final List<Map<String, dynamic>> contacts = const [
    {'name': 'Dr. Rania', 'avatar': '🧑‍⚕️', 'lastMessage': 'Rendez-vous confirmé pour demain'},
    {'name': 'Dr. Karim', 'avatar': '👨‍⚕️', 'lastMessage': 'Envoyez-moi vos résultats'},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: contacts.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return ListTile(
          leading: CircleAvatar(child: Text(contact['avatar'])),
          title: Text(contact['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(contact['lastMessage'], maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: const Icon(Icons.chat_bubble_outline),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatRoomScreen(title: contact['name'], token: '',),
              ),
            );
          },
        );
      },
    );
  }
}
