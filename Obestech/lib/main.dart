import 'package:flutter/material.dart';
import 'package:obesetechapp/auth/login_screen.dart';
import 'package:obesetechapp/auth/onboarding_screen.dart';
import 'package:obesetechapp/auth/signup_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Obesetech',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const OnboardingScreen(),
      },
    );
  }
}