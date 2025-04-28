import 'package:flutter/material.dart';

class SearchUsersScreen extends StatefulWidget {
  const SearchUsersScreen({super.key});

  @override
  State<SearchUsersScreen> createState() => _SearchUsersScreenState();
}

class _SearchUsersScreenState extends State<SearchUsersScreen> {
  String query = '';
  final List<Map<String, String>> users = [
    {"name": "Dr. Saïd Lamine", "role": "Médecin", "email": "said.lamine@obe.com"},
    {"name": "Coach Inès", "role": "Coach sportif", "email": "ines.fit@obe.com"},
    {"name": "Dr. Khaled", "role": "Nutritionniste", "email": "khaled.nutri@obe.com"},
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = users
        .where((user) => user["name"]!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Rechercher un professionnel")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: "Rechercher par nom...",
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => query = value),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final user = filtered[index];
                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(user["name"]!),
                      subtitle: Text("${user["role"]} • ${user["email"]}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.email),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Email de ${user["name"]} copié !")),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
