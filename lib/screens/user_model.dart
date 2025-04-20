import 'package:flutter/material.dart';

class UserModel extends ChangeNotifier {
  String? _name;
  String? _email;
  String? _phone;
  String? _role;
  String? _farmName;
  String? _location;
  String? _token; // Préparation pour l'authentification Django

  // Getters
  String? get name => _name;
  String? get email => _email;
  String? get phone => _phone;
  String? get role => _role;
  String? get farmName => _farmName;
  String? get location => _location;
  String? get token => _token;
  bool get isLoggedIn => _token != null; // Modifié pour vérifier le token
  bool get isFarmer => _role == 'farmer';

  /// Initialise l'utilisateur avec les données de l'API Django
  void setUser({
    required String name,
    required String email,
    required String phone,
    required String role,
    required String token, // Token JWT pour Django
    String? farmName,
    String? location,
  }) {
    _name = name;
    _email = email;
    _phone = phone;
    _role = role;
    _token = token;
    _farmName = farmName;
    _location = location;
    notifyListeners();
  }

  /// Charge les données utilisateur depuis le stockage local
  Future<void> loadUser() async {
    try {
      // Simulation de chargement
      await Future.delayed(Duration(milliseconds: 500));

      // Pour tests, vous pouvez décommenter cette partie :
      /* 
      _name = "Test User";
      _email = "test@example.com";
      _phone = "0123456789";
      _role = "farmer";
      _token = "simulated_token";
      _farmName = "Ma Ferme Test";
      _location = "Paris";
      */

      notifyListeners();
    } catch (e) {
      print("Erreur de chargement: $e");
      await logout(); // Réinitialise si erreur
    }
  }

  /// Déconnexion et nettoyage
  Future<void> logout() async {
    _name = null;
    _email = null;
    _phone = null;
    _role = null;
    _farmName = null;
    _location = null;
    _token = null;
    notifyListeners();
  }

  /// Met à jour le profil utilisateur
  void updateProfile({
    String? name,
    String? phone,
    String? farmName,
    String? location,
  }) {
    _name = name ?? _name;
    _phone = phone ?? _phone;
    _farmName = farmName ?? _farmName;
    _location = location ?? _location;
    notifyListeners();
  }

  /// Vérifie si l'utilisateur a un rôle spécifique
  bool hasRole(String role) => _role == role;

  /// Données minimales pour l'inscription
  Map<String, dynamic> toRegistrationMap() {
    return {
      'name': _name,
      'email': _email,
      'phone': _phone,
      'password': 'hidden', // À remplacer par le vrai mot de passe
      'role': _role,
      if (isFarmer) ...{
        'farm_name': _farmName,
        'location': _location,
      },
    };
  }
}
