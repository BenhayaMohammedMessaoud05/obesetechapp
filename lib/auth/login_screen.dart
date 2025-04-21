// 📁 lib/auth/login_screen.dart

import 'package:flutter/material.dart';
import '../dashboard/patient_dashboard.dart';
import '../dashboard/medecin_dashboard.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String selectedRole = 'patient';

  void login() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs")),
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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              const Text("Connexion", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Mot de passe"),
              ),
              const SizedBox(height: 20),
              const Text("Je suis :", style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Radio<String>(value: 'patient', groupValue: selectedRole, onChanged: (val) => setState(() => selectedRole = val!)),
                  const Text("Patient"),
                  Radio<String>(value: 'medecin', groupValue: selectedRole, onChanged: (val) => setState(() => selectedRole = val!)),
                  const Text("Médecin"),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: login,
                child: const Text("Se connecter"),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                ),
                child: const Text("Créer un compte"),
              )
            ],
          ),
        ),
      ),
    );
  }
}