// 📁 lib/auth/signup_screen.dart

import 'package:flutter/material.dart';
import '../dashboard/patient_dashboard.dart';
import '../dashboard/medecin_dashboard.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String selectedRole = 'patient';

  void register() {
    final username = nameController.text.trim();
    if (username.isEmpty || emailController.text.trim().isEmpty || passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs.")),
      );
      return;
    }
    if (selectedRole == 'patient') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PatientDashboard()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MedecinDashboard()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Créer un compte")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            const Text("Informations", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Nom")),
            const SizedBox(height: 12),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email")),
            const SizedBox(height: 12),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: "Mot de passe"), obscureText: true),
            const SizedBox(height: 20),
            const Text("Rôle :", style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Radio<String>(value: 'patient', groupValue: selectedRole, onChanged: (val) => setState(() => selectedRole = val!)),
                const Text("Patient"),
                Radio<String>(value: 'medecin', groupValue: selectedRole, onChanged: (val) => setState(() => selectedRole = val!)),
                const Text("Médecin"),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: register,
              icon: const Icon(Icons.check),
              label: const Text("Créer le compte"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Déjà inscrit ? Se connecter"),
            )
          ],
        ),
      ),
    );
  }
}
