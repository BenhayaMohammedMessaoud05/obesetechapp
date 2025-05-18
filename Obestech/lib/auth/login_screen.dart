import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:obesetechapp/dashboard/patient_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:obesetechapp/services/api_service.dart';

import 'dart:math';
import 'dart:ui';

// Theme classes
class AppColors {
  static const primary = Color(0xFF1A3C5A);
  static const accent = Color(0xFF2A5C8A);
  static const cardBackground = Color(0xFFF9FAFB);
}

class AppTextStyles {
  static final headline = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );
  static final subhead = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );
  static final label = GoogleFonts.poppins(
    fontSize: 12,
    color: Color(0xFF6B7280),
  );
}

// Animated background with moving colored dots
class AnimatedBackground extends StatefulWidget {
  final Widget child;

  const AnimatedBackground({Key? key, required this.child}) : super(key: key);

  @override
  _AnimatedBackgroundState createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<_Dot> _dots = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    _initializeDots();
  }

  void _initializeDots() {
    final random = Random();
    _dots = List.generate(25, (index) {
      return _Dot(
        x: random.nextDouble(),
        y: random.nextDouble(),
        radius: 4 + random.nextDouble() * 8,
        color: [
          AppColors.primary.withOpacity(0.4),
          AppColors.accent.withOpacity(0.4),
          Colors.teal.withOpacity(0.4),
        ][random.nextInt(3)],
        dx: (random.nextDouble() - 0.5) * 0.0015,
        dy: (random.nextDouble() - 0.5) * 0.0015,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.05),
                Colors.teal.withOpacity(0.05),
              ],
            ),
          ),
        ),
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              for (var dot in _dots) {
                dot.x += dot.dx;
                dot.y += dot.dy;
                if (dot.x < 0 || dot.x > 1) dot.dx = -dot.dx;
                if (dot.y < 0 || dot.y > 1) dot.dy = -dot.dy;
              }
              return CustomPaint(
                painter: _DotPainter(_dots),
                size: Size.infinite,
              );
            },
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _Dot {
  double x;
  double y;
  double radius;
  Color color;
  double dx;
  double dy;

  _Dot({required this.x, required this.y, required this.radius, required this.color, required this.dx, required this.dy});
}

class _DotPainter extends CustomPainter {
  final List<_Dot> dots;

  _DotPainter(this.dots);

  @override
  void paint(Canvas canvas, Size size) {
    for (var dot in dots) {
      final paint = Paint()
        ..color = dot.color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(dot.x * size.width, dot.y * size.height),
        dot.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    print('LoginScreen: _login called');
    if (!_formKey.currentState!.validate()) {
      print('LoginScreen: Form validation failed');
      setState(() {
        _errorMessage = 'Veuillez remplir tous les champs';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      print('LoginScreen: Sending login request for identifier: ${_identifierController.text}');
      final response = await ApiService.login(
        _identifierController.text,
        _passwordController.text,
      );
      print('LoginScreen: Received response: $response');

      final token = response['token'] as String?;
      final name = response['name'] as String?;

      if (token == null || token.isEmpty) {
        print('LoginScreen: Token is null or empty');
        throw Exception('Token manquant dans la réponse');
      }
      if (name == null || name.isEmpty) {
        print('LoginScreen: Name is null or empty');
        throw Exception('Nom manquant dans la réponse');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('userName', name);
      print('LoginScreen: Stored token: $token, userName: $name');

      if (mounted) {
        print('LoginScreen: Navigating to PatientDashboardScreen');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PatientDashboardScreen(token: token),
          ),
        );
      } else {
        print('LoginScreen: Widget not mounted, navigation skipped');
      }
    } catch (e) {
      print('LoginScreen: Login error: $e');
      setState(() {
        _errorMessage = 'Échec de la connexion: ${e.toString().replaceFirst('Exception: ', '')}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Blurred background
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Obese',
                                  style: GoogleFonts.dmSerifDisplay(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Text(
                                  'Tech',
                                  style: GoogleFonts.dmSerifDisplay(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Votre partenaire pour une vie plus saine',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: const Color(0xFF6B7280),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Box for logo, title, and inputs
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.15),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary.withOpacity(0.2),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: Image.asset(
                                        'lib/logo.png',
                                        width: 60,
                                        height: 60,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Connexion',
                                      style: GoogleFonts.dmSerifDisplay(
                                        fontSize: 28,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    if (_errorMessage.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 16),
                                        child: Text(
                                          _errorMessage,
                                          style: GoogleFonts.poppins(
                                            color: Colors.red,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    Text('Identifiant', style: AppTextStyles.subhead),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _identifierController,
                                      keyboardType: TextInputType.text,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                        filled: true,
                                        fillColor: AppColors.cardBackground,
                                        hintText: 'Entrez votre identifiant',
                                        hintStyle: AppTextStyles.label,
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Identifiant requis';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    Text('Mot de passe', style: AppTextStyles.subhead),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                        filled: true,
                                        fillColor: AppColors.cardBackground,
                                        hintText: 'Entrez votre mot de passe',
                                        hintStyle: AppTextStyles.label,
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Mot de passe requis';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _isLoading
                                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                                : ElevatedButton(
                                    onPressed: () {
                                      print('LoginScreen: Se connecter button pressed');
                                      _login();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      padding: EdgeInsets.zero,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.primary,
                                            AppColors.accent,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary.withOpacity(0.3),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      child: Text(
                                        'Se connecter',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                            const SizedBox(height: 16),
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  print('LoginScreen: Navigating to /register');
                                  Navigator.pushNamed(context, '/register');
                                },
                                child: Text(
                                  'Pas de compte ? Inscrivez-vous',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.primary,
                                    fontSize: 14,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}