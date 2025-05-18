import 'package:flutter/material.dart';
import 'package:obesetechapp/auth/SplashScreen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth/onboarding_screen.dart';
import 'auth/login_screen.dart';
import 'dashboard/patient_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => CartModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// Determines the initial route based on stored token.
  Future<Map<String, String>> _getInitialRouteData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    print('MyApp: Checking stored token - token: ${token.isNotEmpty ? "[present]" : "[empty]"}');

    if (token.isNotEmpty) {
      print('MyApp: Valid token found, routing to /dashboard');
      return {
        'route': '/dashboard',
        'token': token,
      };
    }

    print('MyApp: No valid token, defaulting to /splash');
    return {
      'route': '/splash',
      'token': '',
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ObeseTech',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Poppins',
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<Map<String, String>>(
        future: _getInitialRouteData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            print('MyApp: Waiting for initial route data');
            return const Center(child: CircularProgressIndicator(color: Colors.teal));
          }
          if (snapshot.hasError) {
            print('MyApp: Initial route error: ${snapshot.error}');
            return const Scaffold(
              body: Center(child: Text('Erreur de chargement', style: TextStyle(color: Colors.red))),
            );
          }

          final data = snapshot.data ?? {'route': '/splash', 'token': ''};
          final initialRoute = data['route']!;
          final token = data['token']!;
          print('MyApp: Navigating to $initialRoute with token: ${token.isNotEmpty ? "[present]" : "[empty]"}');

          return initialRoute == '/dashboard'
              ? PatientDashboardScreen(token: token)
              : const SplashScreen();
        },
      ),
      routes: {
        '/splash': (context) {
          print('MyApp: Navigating to /splash');
          return const SplashScreen();
        },
        '/login': (context) {
          print('MyApp: Navigating to /login');
          return const LoginScreen();
        },
        '/signup': (context) {
          print('MyApp: Navigating to /signup');
          return const OnboardingScreen();
        },
        '/dashboard': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          print('MyApp: /dashboard args: $args');
          if (args == null || args['token'] is! String) {
            print('MyApp: Invalid /dashboard args, redirecting to /login');
            return const LoginScreen();
          }
          final token = args['token'] as String;
          if (token.isEmpty) {
            print('MyApp: Empty token for /dashboard, redirecting to /login');
            return const LoginScreen();
          }
          print('MyApp: Loading /dashboard with token: ${token.isNotEmpty ? "[present]" : "[empty]"}');
          return PatientDashboardScreen(token: token);
        },
      },
    );
  }
}

class CartModel extends ChangeNotifier {
  final List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items => _items;

  void addItem(Map<String, dynamic> product) {
    if (product['id'] == null || product['name'] == null || product['price'] == null) {
      print('CartModel: Cannot add item, missing required fields: $product');
      return;
    }
    _items.add(product);
    print('CartModel: Added item: ${product['name']} (ID: ${product['id']}), total items: ${_items.length}');
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item['id'] == productId);
    print('CartModel: Removed item with ID: $productId, total items: ${_items.length}');
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    print('CartModel: Cart cleared, total items: ${_items.length}');
    notifyListeners();
  }

  double get totalPrice {
    final total = _items.fold<double>(0.0, (sum, item) => sum + (item['price'] ?? 0.0));
    print('CartModel: Total price calculated: $total');
    return total;
  }
}