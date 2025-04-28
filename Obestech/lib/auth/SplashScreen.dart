import 'package:flutter/material.dart';
import 'package:obesetechapp/auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(_createRoute());
    });
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Transition de fade-in et zoom-in combinée
        final fadeTween = Tween(begin: 0.0, end: 1.0).animate(animation);
        final scaleTween = Tween(begin: 0.8, end: 1.0).animate(animation);

        return FadeTransition(
          opacity: fadeTween,
          child: ScaleTransition(
            scale: scaleTween,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            '../lib/frz.jpg', // Assure-toi d'avoir l'image à ce chemin
            fit: BoxFit.cover,
          ),
          Column(
            children: [
              const SizedBox(height: 100), // Ajuste la position du logo
              Center(
                child: Image.asset(
                  'lib/logo.png', // chemin de ton logo
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
