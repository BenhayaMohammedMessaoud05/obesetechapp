import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key, List? notifications});

  final List<Map<String, String>> notifications = const [
    {
      'title': 'Nouveau message dans le groupe Motivation',
      'body': 'Rejoignez la discussion pour rester motivé !',
    },
    {
      'title': 'Rappel : Activité physique',
      'body': 'Vous n\'avez pas bougé depuis 2 heures.',
    },
    {
      'title': 'Nouveau régime disponible',
      'body': 'Consultez votre profil pour voir les suggestions.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final notif = notifications[index];
          return ListTile(
            leading: const Icon(Icons.notifications_active, color: Colors.teal),
            title: Text(notif['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(notif['body']!),
          );
        },
      ),
    );
  }
}
