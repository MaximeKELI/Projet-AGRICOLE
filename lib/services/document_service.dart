import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class DocumentService {
  static const String baseUrl = 'http://localhost:5000/api';
  
  // Récupérer tous les documents
  static Future<List<DocumentRecommendation>> getDocuments() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/documents'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => DocumentRecommendation.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors du chargement des documents');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Récupérer documents par catégorie
  static Future<List<DocumentRecommendation>> getDocumentsByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/documents/category/$category'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => DocumentRecommendation.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors du chargement des documents');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Récupérer documents par région
  static Future<List<DocumentRecommendation>> getDocumentsByRegion(String region) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/documents/region/$region'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => DocumentRecommendation.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors du chargement des documents');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Créer un utilisateur
  static Future<String> createUser(String name, String email, String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'phoneNumber': phoneNumber,
        }),
      );

      if (response.statusCode == 201) {
        final userData = json.decode(response.body);
        return userData['id'];
      } else {
        throw Exception('Erreur lors de la création de l\'utilisateur');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Simuler un paiement mobile money
  static Future<Map<String, dynamic>> simulateMobileMoneyPayment({
    required String userId,
    required String documentId,
    required String phoneNumber,
    required double amount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payments/simulate-mobile-money'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'documentId': documentId,
          'phoneNumber': phoneNumber,
          'amount': amount,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur lors du paiement');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Vérifier l'accès à un document
  static Future<bool> checkDocumentAccess(String userId, String documentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/payments/access/$userId/$documentId'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Télécharger un document
  static Future<String> downloadDocument(String documentId, String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/documents/$documentId/download?userId=$userId'),
      );

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$documentId.pdf');
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      } else {
        throw Exception('Erreur lors du téléchargement');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Vérifier si un document est gratuit
  static bool isDocumentFree(String documentId) {
    return documentId == 'doc_mo'; // Document de la préfecture de Mô gratuit
  }
}

class DocumentRecommendation {
  final String id;
  final String title;
  final String description;
  final String filePath;
  final double price;
  final String category;
  final String prefecture;
  final String region;
  final int fileSizeBytes;
  final String fileExtension;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  DocumentRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.filePath,
    required this.price,
    required this.category,
    required this.prefecture,
    required this.region,
    required this.fileSizeBytes,
    required this.fileExtension,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  factory DocumentRecommendation.fromJson(Map<String, dynamic> json) {
    return DocumentRecommendation(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      filePath: json['filePath'],
      price: json['price'].toDouble(),
      category: json['category'],
      prefecture: json['prefecture'],
      region: json['region'],
      fileSizeBytes: json['fileSizeBytes'],
      fileExtension: json['fileExtension'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isActive: json['isActive'],
    );
  }

  String get formattedPrice => '${price.toInt()} FCFA';
  
  String get formattedSize {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
