// 📁 lib/main.dart

import 'package:flutter/material.dart';
import 'auth/login_screen.dart';
import 'theme/theme.dart';

void main() {
  runApp(const ObeseTechApp());
}

class ObeseTechApp extends StatelessWidget {
  const ObeseTechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ObeseTech',
      debugShowCheckedModeBanner: false,
      theme: obeseTechTheme,
      home: const LoginScreen(),
    );
  }
}