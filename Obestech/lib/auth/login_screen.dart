import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:obesetechapp/auth/signup_screen.dart' as signup;
import 'package:obesetechapp/dashboard/patient_dashboard.dart' as dashboard;
import '../dashboard/medecin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isPasswordVisible = false;
  String selectedRole = 'Patient';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    }

    // Redirection selon le rôle choisi
    if (selectedRole == 'Patient') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const dashboard.PatientDashboard()), // Use alias here
      );
    } else if (selectedRole == 'Médecin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MedecinDashboard()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),

      body: Stack(
        children: [
          // Ajouter l'image en haut de l'interface
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 200, // Ajustez la hauteur de l'image
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('../lib/splash.jpg'), // Remplacez par votre image
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Ajouter l'image du logo en haut
          Positioned(
            top: 20, // Ajustez cette valeur pour positionner le logo sous l'image de fond
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                '../lib/logo.png', // Remplacez par votre image de logo
                height: 100, // Ajustez la taille du logo
                width: 100, // Ajustez la largeur du logo si nécessaire
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 220), // Augmenté pour déplacer le texte plus bas
                Text(
                  'Bienvenue sur Obesetech',
                  style: GoogleFonts.roboto(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003366),
                  ),
                ),
                const SizedBox(height: 30),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: InputDecoration(
                    labelText: "Rôle",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Patient', child: Text('Patient')),
                    DropdownMenuItem(value: 'Médecin', child: Text('Médecin')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value!;
                    });
                  },
                ),
                const SizedBox(height: 20),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue),
                    color: Colors.white,
                  ),
                  child: TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue),
                    color: Colors.white,
                  ),
                  child: TextField(
                    controller: passwordController,
                    obscureText: !isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: "Mot de passe",
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      suffixIcon: IconButton(
                        icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Se connecter",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/signup'),
                    child: const Text(
                      "Pas encore de compte ? Créer un compte",
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
