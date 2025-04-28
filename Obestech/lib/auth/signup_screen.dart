import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String selectedRole = 'patient';
  Color buttonColor = Colors.deepPurple;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void signUp() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Les mots de passe ne correspondent pas")),
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
      body: Stack(
        children: [
          // Gradient avec couleur bleu ciel
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.lightBlue.withOpacity(0.1), // Bleu ciel avec faible opacité
                    Colors.transparent, // Transparent en bas
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: ListView(
                shrinkWrap: true,
                children: [
                  // Affichage du logo avec le bon chemin
                  Center(
                    child: Image.asset(
                      'lib/logo.png', // Chemin corrigé
                      width: 150, // Ajustez la taille du logo
                      height: 150, // Ajustez la taille du logo
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    "Créer un compte sur Obestech",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF001F54),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Champ email sans border radius avec hover effect
                  MouseRegion(
                    onEnter: (_) {
                      setState(() {
                        // Change background color on hover
                      });
                    },
                    onExit: (_) {
                      setState(() {
                        // Reset background color on exit
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.deepPurple),
                        color: Colors.white,
                      ),
                      child: TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: "Email",
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Champ mot de passe sans border radius avec hover effect
                  MouseRegion(
                    onEnter: (_) {
                      setState(() {
                        // Change background color on hover
                      });
                    },
                    onExit: (_) {
                      setState(() {
                        // Reset background color on exit
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.deepPurple),
                        color: Colors.white,
                      ),
                      child: TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Mot de passe",
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Champ confirmation mot de passe sans border radius avec hover effect
                  MouseRegion(
                    onEnter: (_) {
                      setState(() {
                        // Change background color on hover
                      });
                    },
                    onExit: (_) {
                      setState(() {
                        // Reset background color on exit
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.deepPurple),
                        color: Colors.white,
                      ),
                      child: TextField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Confirmer le mot de passe",
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Je suis :",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF001F54),
                    ),
                  ),
                  Row(
                    children: [
                      Radio<String>(
                        value: 'patient',
                        groupValue: selectedRole,
                        onChanged: (val) => setState(() => selectedRole = val!),
                      ),
                      const Text("Patient"),
                      Radio<String>(
                        value: 'medecin',
                        groupValue: selectedRole,
                        onChanged: (val) => setState(() => selectedRole = val!),
                      ),
                      const Text("Médecin"),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Effet hover sur le bouton
                  MouseRegion(
                    onEnter: (_) {
                      setState(() {
                        buttonColor = Colors.deepPurpleAccent;
                      });
                    },
                    onExit: (_) {
                      setState(() {
                        buttonColor = Colors.deepPurple;
                      });
                    },
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // Radius sur le bouton
                          ),
                          elevation: 8,
                          shadowColor: Colors.deepPurpleAccent.withOpacity(0.4),
                        ),
                        child: const Text(
                          "Créer un compte",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Déjà un compte ? Se connecter",
                        style: TextStyle(fontSize: 16, color: Colors.deepPurple),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Cercles ajoutés aux coins de l'écran avec flou et gradient
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 250, // Taille du cercle bleu
              height: 250, // Taille du cercle bleu
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.withOpacity(0.5), Colors.transparent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.5),
                    blurRadius: 30, // Flou pour l'effet de halo
                    spreadRadius: 10, // Pour étendre l'effet du flou
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -80,  // Positionné juste en dessous du bouton
            right: -80,
            child: Container(
              width: 200, // Taille réduite du cercle jaune
              height: 200, // Taille réduite du cercle jaune
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.yellow.withOpacity(0.5), Colors.transparent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellow.withOpacity(0.5),
                    blurRadius: 30, // Flou pour l'effet de halo
                    spreadRadius: 10, // Pour étendre l'effet du flou
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF3F4F6),
    );
  }
}

// Dummy Screens for navigation purposes
class PatientDashboard extends StatelessWidget {
  const PatientDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Patient Dashboard")),
      body: const Center(child: Text("Welcome to the Patient Dashboard")),
    );
  }
}

class MedecinDashboard extends StatelessWidget {
  const MedecinDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Médecin Dashboard")),
      body: const Center(child: Text("Welcome to the Médecin Dashboard")),
    );
  }
}
