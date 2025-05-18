import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:io' show File, Platform;
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String get baseUrl {
    String url;
    if (kIsWeb) {
      url = 'http://localhost:2000';
    } else if (Platform.isAndroid && !Platform.environment.containsKey('FLUTTER_TEST')) {
      url = 'http://10.0.2.2:2000';
    } else {
      url = 'http://localhost:2000';
    }
    print('ApiService: Using baseUrl: $url');
    return url;
  }

  // ---------------- Auth ----------------

  static Future<Map<String, dynamic>> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email et mot de passe requis');
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      print('ApiService: Login response: ${response.statusCode}, ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final name = data['user']?['name'] ?? 'User';
        if (token == null || token.isEmpty) {
          throw Exception('Invalid response: Missing or empty token. Response: $data');
        }
        if (name.isEmpty) {
          throw Exception('Invalid response: Missing or empty name. Response: $data');
        }
        print('ApiService: Extracted token: $token, name: $name');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('userName', name);
        return {'token': token, 'name': name};
      } else if (response.statusCode == 401) {
        throw Exception('Email ou mot de passe incorrect');
      }
      throw Exception('Erreur lors de la connexion: ${response.statusCode}, ${response.body}');
    } catch (e) {
      print('ApiService: Login request failed: $e');
      throw Exception('Erreur réseau ou serveur: $e');
    }
  }

  static Future<void> signup({
    required String name,
    required String email,
    required String password,
    required double? weight,
    required double? bmi,
    required double? height,
    String role = 'Patient',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
        'weight': weight,
        'bmi': bmi,
        'height': height,
        'role': role,
      }),
    );
    if (response.statusCode == 201) return;
    throw Exception(json.decode(response.body)['msg'] ?? 'Échec de l\'inscription');
  }

  // ---------------- User ----------------

  static Future<Map<String, dynamic>> getUserProfile(String token) async {
    if (token.isEmpty) {
      throw Exception('Token requis');
    }
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );
      print('ApiService: getUserProfile response: ${response.statusCode}, ${response.body}');
      if (response.statusCode == 200) {
        final profile = json.decode(response.body);
        final name = profile['name']?.toString();
        if (name == null || name.isEmpty) {
          print('ApiService: No valid name found in profile response: $profile');
          throw Exception('No valid name in profile response: $profile');
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', name);
        return profile;
      } else if (response.statusCode == 401) {
        throw Exception('Invalid token');
      } else if (response.statusCode == 404) {
        throw Exception('Profil utilisateur non trouvé');
      }
      throw Exception('Erreur lors de la récupération du profil: ${response.statusCode}, ${response.body}');
    } catch (e) {
      print('ApiService: getUserProfile request failed: $e');
      throw Exception('Erreur réseau ou serveur: $e');
    }
  }

  static Future<void> updateUserProfile(String token, Map<String, dynamic> updates) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/users/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(updates),
    );
    if (response.statusCode == 200) return;
    throw Exception(json.decode(response.body)['msg'] ?? 'Échec de la mise à jour du profil');
  }

  static Future<List<Map<String, String>>> searchUsers(String token, String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/users/search?query=$query'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return List<Map<String, String>>.from(json.decode(response.body));
    }
    throw Exception(json.decode(response.body)['msg'] ?? 'Échec de la recherche d\'utilisateurs');
  }

  // ---------------- Sleep ----------------

  static Future<Map<String, dynamic>> getSleepData(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/sleep'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception(json.decode(response.body)['msg'] ?? 'Échec de la récupération des données de sommeil');
  }

  static Future<void> updateSleepSession(String token, String action) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/sleep'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'action': action}),
    );
    if (response.statusCode == 200) return;
    throw Exception(json.decode(response.body)['msg'] ?? 'Échec de la mise à jour de la session de sommeil');
  }

  // ---------------- Activity ----------------

  static Future<Map<String, dynamic>> getActivity(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/activity'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception(json.decode(response.body)['msg'] ?? 'Échec de la récupération de l\'activité');
  }

  static Future<void> updateActivity(String token, Map<String, dynamic> activity) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/activity'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(activity),
    );
    if (response.statusCode == 200) return;
    throw Exception(json.decode(response.body)['msg'] ?? 'Échec de la mise à jour de l\'activité');
  }

  // ---------------- Workouts ----------------

  static Future<Map<String, dynamic>> getWorkouts(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/workouts'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception(json.decode(response.body)['msg'] ?? 'Échec de la récupération des entraînements');
  }

  static Future<void> logWorkout(String token, Map<String, dynamic> workout) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/workouts'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(workout),
    );
    if (response.statusCode == 200) return;
    throw Exception(json.decode(response.body)['msg'] ?? 'Échec de l\'enregistrement de l\'entraînement');
  }

  // ---------------- Logs ----------------

  static Future<void> logQuickAction(String token, String type, String details) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/logs'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'type': type, 'details': details}),
    );
    if (response.statusCode == 200) return;
    throw Exception(json.decode(response.body)['msg'] ?? 'Échec de l\'enregistrement de l\'action');
  }

  // ---------------- Notifications ----------------

  static Future<List<dynamic>> getUserNotifications(String name) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/notifications/$name'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception('Erreur lors du chargement des notifications');
  }

  // ---------------- Marketplace ----------------

  static Future<List<Map<String, dynamic>>> getProducts(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/products'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    }
    throw Exception(json.decode(response.body)['msg'] ?? 'Échec de la récupération des produits');
  }

  static Future<Map<String, dynamic>> getProductById(String token, String productId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/products/$productId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception(json.decode(response.body)['msg'] ?? 'Échec de la récupération du produit');
  }

  static Future<Map<String, dynamic>> addProduct(String token, Map<String, dynamic> product) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/products'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(product),
    );
    if (response.statusCode == 201) return json.decode(response.body);
    throw Exception(json.decode(response.body)['msg'] ?? 'Échec de l\'ajout du produit');
  }

  static Future<Map<String, dynamic>> updateProduct(String token, String productId, Map<String, dynamic> updates) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/products/$productId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(updates),
    );
    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception(json.decode(response.body)['msg'] ?? 'Échec de la mise à jour du produit');
  }

  static Future<void> deleteProduct(String token, String productId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/products/$productId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) return;
    throw Exception(json.decode(response.body)['msg'] ?? 'Échec de la suppression du produit');
  }

  // ---------------- Regime ----------------

  static Future<Map<String, dynamic>> getKcalTracking(String token, String name) async {
    if (token.isEmpty || name.isEmpty) {
      throw Exception('Invalid token or name');
    }
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/kcal/$name'),
        headers: {'Authorization': 'Bearer $token'},
      );
      print('ApiService: getKcalTracking response for name $name: ${response.statusCode}, ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> kcalPrescritRaw = data['kcalPrescrit'] ?? List.filled(7, 0);
        List<dynamic> kcalMangeRaw = data['kcalMange'] ?? List.filled(7, 0);
        List<int> kcalPrescrit = List.filled(7, 0);
        List<int> kcalMange = List.filled(7, 0);
        for (int i = 0; i < 7 && i < kcalPrescritRaw.length; i++) {
          kcalPrescrit[i] = (kcalPrescritRaw[i] as num?)?.toInt() ?? 0;
        }
        for (int i = 0; i < 7 && i < kcalMangeRaw.length; i++) {
          kcalMange[i] = (kcalMangeRaw[i] as num?)?.toInt() ?? 0;
        }
        return {
          'kcalPrescrit': kcalPrescrit,
          'kcalMange': kcalMange,
        };
      } else if (response.statusCode == 401) {
        throw Exception('Invalid token');
      } else if (response.statusCode == 404) {
        print('ApiService: No kcal data found for name $name');
        return {
          'kcalPrescrit': List.filled(7, 0),
          'kcalMange': List.filled(7, 0),
        };
      }
      throw Exception('Erreur lors de la récupération des données kcal: ${response.statusCode}, ${response.body}');
    } catch (e) {
      print('ApiService: getKcalTracking request failed: $e');
      throw Exception('Erreur réseau ou serveur: $e');
    }
  }

  static Future<Map<String, dynamic>> getRegime(String token, String name, int dayIndex) async {
    if (token.isEmpty || name.isEmpty) {
      throw Exception('Invalid token or name');
    }
    if (dayIndex < 0 || dayIndex > 6) {
      throw Exception('Invalid dayIndex: $dayIndex');
    }
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/regime/$name/$dayIndex'),
        headers: {'Authorization': 'Bearer $token'},
      );
      print('ApiService: getRegime response for name $name, dayIndex $dayIndex: ${response.statusCode}, ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'meals': data['meals'] ?? []};
      } else if (response.statusCode == 401) {
        throw Exception('Invalid token');
      } else if (response.statusCode == 404) {
        print('ApiService: No regime data found for name $name, dayIndex $dayIndex');
        return {'meals': []};
      }
      throw Exception('Erreur lors de la récupération du régime: ${response.statusCode}, ${response.body}');
    } catch (e) {
      print('ApiService: getRegime request failed: $e');
      throw Exception('Erreur réseau ou serveur: $e');
    }
  }

  static Future<Map<String, dynamic>> getRegimeData(String name, int dayIndex, String token) async {
    try {
      final kcalData = await getKcalTracking(token, name);
      final regimeData = await getRegime(token, name, dayIndex);
      return {
        'weeklyKcal': {
          'monday': kcalData['kcalMange'][0],
          'tuesday': kcalData['kcalMange'][1],
          'wednesday': kcalData['kcalMange'][2],
          'thursday': kcalData['kcalMange'][3],
          'friday': kcalData['kcalMange'][4],
          'saturday': kcalData['kcalMange'][5],
          'sunday': kcalData['kcalMange'][6],
        },
        'kcalPrescrit': kcalData['kcalPrescrit'],
        'kcalMange': kcalData['kcalMange'],
        'meals': regimeData['meals'],
      };
    } catch (e) {
      print('ApiService: getRegimeData failed: $e');
      throw Exception('Erreur lors de la récupération des données du régime: $e');
    }
  }

  static Future<void> updateRegime(String token, String name, int dayIndex, List<Map<String, dynamic>> meals) async {
    if (token.isEmpty || name.isEmpty) {
      throw Exception('Invalid token or name');
    }
    if (dayIndex < 0 || dayIndex > 6) {
      throw Exception('Invalid dayIndex: $dayIndex');
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/regime/$name'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'dayIndex': dayIndex, 'meals': meals}),
      );
      print('ApiService: updateRegime response for name $name, dayIndex $dayIndex: ${response.statusCode}, ${response.body}');
      if (response.statusCode == 200) return;
      if (response.statusCode == 401) throw Exception('Invalid token');
      throw Exception('Erreur lors de la mise à jour du régime: ${response.statusCode}, ${response.body}');
    } catch (e) {
      print('ApiService: updateRegime request failed: $e');
      throw Exception('Erreur réseau ou serveur: $e');
    }
  }

  static Future<void> updateKcalTracking(String token, String name, List<int> kcalPrescrit, List<int> kcalMange) async {
    if (token.isEmpty || name.isEmpty) {
      throw Exception('Invalid token or name');
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/kcal/$name'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'kcalPrescrit': kcalPrescrit,
          'kcalMange': kcalMange,
        }),
      );
      print('ApiService: updateKcalTracking response for name $name: ${response.statusCode}, ${response.body}');
      if (response.statusCode == 200) return;
      if (response.statusCode == 401) throw Exception('Invalid token');
      throw Exception('Erreur lors de la mise à jour des données kcal: ${response.statusCode}, ${response.body}');
    } catch (e) {
      print('ApiService: updateKcalTracking request failed: $e');
      throw Exception('Erreur réseau ou serveur: $e');
    }
  }

  static Future<Map<String, dynamic>> getValidation(String token, String name, int dayIndex) async {
    if (token.isEmpty || name.isEmpty) {
      throw Exception('Invalid token or name');
    }
    if (dayIndex < 0 || dayIndex > 6) {
      throw Exception('Invalid dayIndex: $dayIndex');
    }
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/validate/$name/$dayIndex'),
        headers: {'Authorization': 'Bearer $token'},
      );
      print('ApiService: getValidation response for name $name, dayIndex $dayIndex: ${response.statusCode}, ${response.body}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Invalid token');
      } else if (response.statusCode == 404) {
        print('ApiService: No validation data found for name $name, dayIndex $dayIndex');
        return {'validated': false};
      }
      throw Exception('Erreur lors de la validation du jour: ${response.statusCode}, ${response.body}');
    } catch (e) {
      print('ApiService: getValidation request failed: $e');
      throw Exception('Erreur réseau ou serveur: $e');
    }
  }

  static Future<void> validateDay(String token, String name, int dayIndex) async {
    if (token.isEmpty || name.isEmpty) {
      throw Exception('Invalid token or name');
    }
    if (dayIndex < 0 || dayIndex > 6) {
      throw Exception('Invalid dayIndex: $dayIndex');
    }
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/validate/$name/$dayIndex'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'validated': true}),
      );
      print('ApiService: validateDay response for name $name, dayIndex $dayIndex: ${response.statusCode}, ${response.body}');
      if (response.statusCode == 200) return;
      if (response.statusCode == 401) throw Exception('Invalid token');
      throw Exception('Erreur lors de la validation du jour: ${response.statusCode}, ${response.body}');
    } catch (e) {
      print('ApiService: validateDay request failed: $e');
      throw Exception('Erreur réseau ou serveur: $e');
    }
  }

  // ---------------- Upload Image ----------------

  static Future<String> uploadImage({
    File? imageFile,
    Uint8List? webImageBytes,
    String? webImageName,
    required Uint8List imageBytes,
    required String fileName,
    required String mimeType,
  }) async {
    final uri = Uri.parse('$baseUrl/api/upload');
    final request = http.MultipartRequest('POST', uri);
    if (kIsWeb) {
      if (webImageBytes == null || webImageName == null) {
        throw Exception('Aucune image sélectionnée pour le Web.');
      }
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        webImageBytes,
        filename: webImageName,
        contentType: MediaType('image', mimeType.split('/').last),
      ));
    } else {
      if (imageFile == null) {
        throw Exception('Aucun fichier image trouvé sur l\'appareil.');
      }
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType('image', mimeType.split('/').last),
      ));
    }
    final response = await request.send();
    final responseData = await http.Response.fromStream(response);
    if (responseData.statusCode == 200) {
      final data = json.decode(responseData.body);
      return data['imageUrl'];
    }
    throw Exception('Échec de l\'upload (${responseData.statusCode}): ${responseData.body}');
  }

  static Future<List<dynamic>> getAchievements(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/achievements'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception(json.decode(response.body)['msg'] ?? 'Échec de la récupération des réalisations');
  }

 static Future<List<Map<String, dynamic>>> getMarketplaceRecommendations(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/marketplace/recommendations'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.map((item) => Map<String, dynamic>.from(item)).toList();
        }
        throw Exception('Invalid response format');
      }
      throw Exception('Failed to load marketplace recommendations: ${response.statusCode}');
    } catch (e) {
      print('ApiService: Error fetching marketplace recommendations: $e');
      // Fallback to mock data
      return [
        {
          'id': '1',
          'title': 'Shake Protéiné Vanille',
          'description': 'Boisson riche en protéines pour la récupération musculaire.',
          'price': 29.99,
          'imageUrl': 'https://via.placeholder.com/150',
        },
        {
          'id': '2',
          'title': 'Tapis de Yoga Antidérapant',
          'description': 'Idéal pour vos séances de yoga et de fitness.',
          'price': 39.99,
          'imageUrl': 'https://via.placeholder.com/150',
        },
        {
          'id': '3',
          'title': 'Vitamines Multinutrition',
          'description': 'Complément pour soutenir votre santé globale.',
          'price': 19.99,
          'imageUrl': 'https://via.placeholder.com/150',
        },
      ];
    }
  }

  static Future<List<Map<String, dynamic>>> getChannels(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/channels'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    throw Exception('Failed to load channels');
  }

  static Future<Map<String, dynamic>> createChannel(String token, String name, String description) async {
    final response = await http.post(
      Uri.parse('$baseUrl/channels'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'name': name, 'description': description}),
    );
    if (response.statusCode == 201) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    }
    throw Exception('Failed to create channel');
  }
    }