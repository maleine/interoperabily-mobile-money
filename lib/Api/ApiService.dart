import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static final ApiService _instance = ApiService._internal();
  final String baseUrl = 'http://192.168.1.6:8000/api'; // Remplacer par l'URL de votre API
  String? _token; // Token en mémoire

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  // Getter pour accéder au token
  String? get token => _token;

  /// Inscription d'un nouvel utilisateur
  Future<Map<String, dynamic>> register(String name, String numero, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'numero': numero,
        'password': password,
        'password_confirmation': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // OTP envoyé
    } else {
      final errorMessage = jsonDecode(response.body)['message'] ?? 'Erreur lors de l\'inscription';
      throw Exception(errorMessage);
    }
  }

  /// Vérification de l'OTP pour l'inscription ou la connexion
  Future<Map<String, dynamic>> verifyOtp(String numero, String otp, {String? name, String? password}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'numero': numero,
        'otp': otp,
        if (name != null) 'name': name,
        if (password != null) 'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      _token = responseData['token']; // Stocker le token en mémoire
      print('Token stocké: $_token');
      return responseData;
    } else {
      final errorMessage = jsonDecode(response.body)['message'] ?? 'Erreur lors de la vérification de l\'OTP';
      throw Exception(errorMessage);
    }
  }

  /// Connexion d'un utilisateur existant
  Future<Map<String, dynamic>> login(String numero, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'numero': numero,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      _token = responseData['token']; // Stocker le token en mémoire
      print('Token stocké: $_token');
      return responseData;
    } else {
      final errorMessage = jsonDecode(response.body)['message'] ?? 'Erreur lors de la connexion';
      throw Exception(errorMessage);
    }
  }

  /// Demande de réinitialisation du mot de passe (envoi de l'OTP)
  Future<void> requestPasswordReset(String numero) async {
    final response = await http.post(
      Uri.parse('$baseUrl/requestPasswordReset'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'numero': numero,
      }),
    );

    if (response.statusCode == 200) {
      print('OTP envoyé avec succès.');
    } else {
      final errorMessage = jsonDecode(response.body)['message'] ?? 'Erreur lors de l\'envoi de l\'OTP';
      throw Exception(errorMessage);
    }
  }


  Future<void> resetPassword(String numero, String newPassword, String confirmPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/resetPassword'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'numero': numero,
        'password': newPassword,
        'password_confirmation': confirmPassword,
      }),
    );

    if (response.statusCode == 200) {
      print('Mot de passe réinitialisé avec succès.');
    } else {
      final errorMessage = jsonDecode(response.body)['message'] ?? 'Erreur lors de la réinitialisation du mot de passe';
      throw Exception(errorMessage);
    }
  }


  /// Vérification de l'OTP pour la réinitialisation du mot de passe
  Future<void> verifyOtpPassword(String numero, String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verifyotp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'numero': numero,
        'otp': otp,
      }),
    );

    if (response.statusCode == 200) {
      print('OTP vérifié avec succès.');
    } else {
      final errorMessage = jsonDecode(response.body)['message'] ?? 'Erreur lors de la vérification de l\'OTP';
      throw Exception(errorMessage);
    }
  }

  /// Fonction de déconnexion
  Future<void> logout() async {
    try {
      // Invalider le token
      _token = null;
      print('Utilisateur déconnecté. Token réinitialisé.');

      // Si l'API gère la déconnexion, vous pouvez l'appeler ici :
      await http.post(Uri.parse('$baseUrl/logout'), headers: {
        'Authorization': 'Bearer $_token',
      });
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
      throw Exception('Erreur lors de la déconnexion');
    }
  }

  /// Récupérer les informations de l'utilisateur
  Future<Map<String, dynamic>> getUserInfo() async {
    print('Token utilisé pour getUserInfo: $_token');
    if (_token == null) {
      throw Exception('Utilisateur non authentifié. Veuillez vous connecter.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/getUserInfo'),
      headers: {
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorMessage = jsonDecode(response.body)['message'] ?? 'Erreur lors de la récupération des informations utilisateur';
      throw Exception(errorMessage);
    }
  }

  /// Mise à jour des informations de l'utilisateur
  Future<Map<String, dynamic>> updateUser({String? name, String? numero, String? password}) async {
    if (_token == null) {
      throw Exception('Utilisateur non authentifié.');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/updateUser'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: jsonEncode({
        if (name != null) 'name': name,
        if (numero != null) 'numero': numero,
        if (password != null) 'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Réponse après mise à jour
    } else {
      final errorMessage = jsonDecode(response.body)['message'] ?? 'Erreur lors de la mise à jour des informations';
      throw Exception(errorMessage);
    }
  }

  /// Archiver l'utilisateur
  Future<void> archiveUser() async {
    if (_token == null) {
      throw Exception('Utilisateur non authentifié.'); // Gérer l'erreur si l'utilisateur n'est pas connecté
    }

    final response = await http.post(
      Uri.parse('$baseUrl/archiveUser'), // Assurez-vous que cette URL correspond à votre API
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      print('Utilisateur archivé avec succès.'); // Confirmation de l'archivage
    } else {
      final errorMessage = jsonDecode(response.body)['message'] ?? 'Erreur lors de l\'archivage de l\'utilisateur';
      throw Exception(errorMessage);
    }
  }

  /// Effectuer une transaction
  Future<Map<String, dynamic>> transaction({
    required String fromOperator,
    required String toOperator,
    required double amount,
    required String fromPhone,
    required String toPhone,
  }) async {
    // Vérifier si le token est valide
    if (_token == null) {
      throw Exception('Utilisateur non authentifié. Veuillez vous connecter.');
    }

    // Préparer les données de la transaction
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/exchangeFunds'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',  // Inclure le token d'authentification
        },
        body: jsonEncode({
          'from_operator': fromOperator,  // L'opérateur du côté de l'utilisateur
          'to_operator': toOperator,  // L'opérateur du destinataire
          'amount': amount,  // Le montant de la transaction
          'from_phone': fromPhone,  // Le numéro de téléphone de l'utilisateur
          'to_phone': toPhone,  // Le numéro de téléphone du destinataire
        }),
      );

      // Afficher le statut et le corps de la réponse dans la console
      print("Statut de la réponse : ${response.statusCode}");
      print("Corps de la réponse : ${response.body}");


      // Vérifier la réponse de l'API
      if (response.statusCode == 200) {
        // Retourner les détails de la transaction
        return jsonDecode(response.body);
      } else {
        // Gérer l'erreur en cas d'échec de la transaction
        final errorMessage = jsonDecode(response.body)['message'] ?? 'Erreur lors de la transaction';
        throw Exception(errorMessage);
      }
    } catch (e) {
      // En cas d'erreur avec la requête (problème réseau, JSON invalide, etc.)
      throw Exception('Une erreur est survenue lors de la transaction: $e');
    }
  }

  }



