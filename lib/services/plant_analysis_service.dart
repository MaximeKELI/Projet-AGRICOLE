import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class PlantAnalysisService {
  static const String _apiKey = 'EpimKwqmcMtb8FBBBCIiqu8Jd7rfHvlTOWC8DMqJHcf8OmM5nV';
  static const String _healthApiUrl = 'https://plant.id/api/v3/health_assessment';
  static const String _identifyApiUrl = 'https://plant.id/api/v3/identification';

  // Couleurs pour l'analyse visuelle
  final Map<String, List<int>> _colors = {
    'healthy': [0, 255, 0],     // Vert
    'warning': [0, 165, 255],   // Orange
    'danger': [0, 0, 255],      // Rouge
  };

  Future<Map<String, dynamic>> analyzePlant({
    required String imageBase64,
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Faire la requête d'identification
      print('Sending identification request to Plant.id API...');
      final identifyResponse = await http.post(
        Uri.parse(_identifyApiUrl),
        headers: {
          'Api-Key': _apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'images': [imageBase64],
          'latitude': latitude,
          'longitude': longitude,
          'similar_images': true,
          'classification_level': 'species',
          'language': 'fr',
        }),
      );

      print('Identification response status code: ${identifyResponse.statusCode}');
      print('Identification response body: ${identifyResponse.body}');

      // Faire la requête d'analyse de santé
      print('Sending health assessment request to Plant.id API...');
      final healthResponse = await http.post(
        Uri.parse(_healthApiUrl),
        headers: {
          'Api-Key': _apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'images': [imageBase64],
          'latitude': latitude,
          'longitude': longitude,
          'similar_images': true,
          'health': 'all',
          'symptoms': true,
          'classification_level': 'species',
        }),
      );

      print('Health response status code: ${healthResponse.statusCode}');
      print('Health response body: ${healthResponse.body}');

      // Initialiser les valeurs par défaut
      Map<String, dynamic> result = {
        'isHealthy': 'Non déterminé',
        'healthProbability': 0.0,
        'diseases': [],
        'similarImages': [],
        'accessToken': '',
        'modelVersion': '',
        'classification': {},
      };

      // Traiter la réponse d'identification
      if (identifyResponse.statusCode == 201) {
        try {
          final identifyData = jsonDecode(identifyResponse.body);
          print('Identification data: $identifyData');
          if (identifyData is Map && identifyData['result'] != null) {
            final suggestions = identifyData['result']['suggestions'];
            if (suggestions is List && suggestions.isNotEmpty) {
              result['classification'] = suggestions.first;
              print('Plant classification: ${result['classification']}');
            }
          }
        } catch (e) {
          print('Error parsing identification response: $e');
        }
      }

      // Traiter la réponse d'analyse de santé
      if (healthResponse.statusCode == 201) {
        try {
          final healthData = jsonDecode(healthResponse.body);
          print('Parsed health response: $healthData');

          // Récupérer le token d'accès et la version du modèle
          result['accessToken'] = healthData['access_token'] ?? '';
          result['modelVersion'] = healthData['model_version'] ?? '';

          // Vérifier si nous avons un résultat
          if (healthData['result'] == null) {
            print('No result field in health response. Available keys: ${healthData.keys.toList()}');
            return result;
          }

          final analysisResult = healthData['result'];
          if (analysisResult is! Map) {
            print('Analysis result is not a Map, type: ${analysisResult.runtimeType}');
            return result;
          }

          // Traiter la santé de la plante
          final isHealthyData = analysisResult['is_healthy'];
          if (isHealthyData != null && isHealthyData is Map) {
            result['healthProbability'] = isHealthyData['probability'] ?? 0.0;
            result['isHealthy'] = isHealthyData['binary'] == true ? 'En bonne santé' : 
                                isHealthyData['binary'] == false ? 'Malade' : 'Non déterminé';
          }

          // Traiter les maladies
          final diseaseData = analysisResult['disease'];
          if (diseaseData != null && diseaseData is Map) {
            final suggestions = diseaseData['suggestions'];
            if (suggestions is List) {
              result['diseases'] = suggestions.map((disease) {
                return {
                  'name': disease['name'] ?? 'Inconnu',
                  'probability': disease['probability'] ?? 0.0,
                  'similarImages': (disease['similar_images'] as List?)?.map((image) {
                    return {
                      'url': image['url'] ?? '',
                      'similarity': image['similarity'] ?? 0.0,
                      'license': image['license_name'] ?? '',
                      'citation': image['citation'] ?? '',
                    };
                  }).toList() ?? [],
                };
              }).toList();
            }
          }

          // Traiter les images similaires globales
          final similarImages = healthData['similar_images'];
          if (similarImages is List) {
            result['similarImages'] = similarImages.map((image) {
              return {
                'url': image['url'] ?? '',
                'similarity': image['similarity'] ?? 0.0,
                'license': image['license_name'] ?? '',
                'citation': image['citation'] ?? '',
              };
            }).toList();
          }

        } catch (e) {
          print('Error parsing health response: $e');
        }
      }

      print('Final result: $result');
      return result;

    } catch (e) {
      print('Error in analyzePlant: $e');
      throw Exception('Erreur lors de l\'analyse: $e');
    }
  }

  Future<void> sendFeedback(
    String accessToken,
    int rating,
    String comment,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('https://plant.id/api/v3/feedback'),
        headers: {
          'Api-Key': _apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'access_token': accessToken,
          'rating': rating,
          'comment': comment,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur ${response.statusCode} lors de l\'envoi du feedback: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi du feedback: $e');
    }
  }

  Future<Map<String, dynamic>> askQuestion({
    required String accessToken,
    required String question,
    String? prompt,
    double temperature = 0.5,
    String? appName,
    Map<String, dynamic>? plantData,
  }) async {
    try {
      // Construire le prompt initial avec les informations de la plante
      String initialPrompt = '';
      if (plantData != null) {
        final classification = plantData['classification'] ?? {};
        final plantName = classification['name'] ?? 'Non identifié';
        final plantProbability = classification['probability'] ?? 0.0;
        final isHealthy = plantData['isHealthy'] ?? 'Non déterminé';
        final healthProbability = plantData['healthProbability'] ?? 0.0;
        final diseases = plantData['diseases'] ?? [];

        initialPrompt = '''
Je suis une IA spécialisée dans l'identification et l'analyse des plantes. Voici les informations exactes sur la plante analysée que vous devez utiliser pour répondre aux questions :

INFORMATIONS DE LA PLANTE :
- Espèce identifiée : $plantName (confiance : ${(plantProbability * 100).toStringAsFixed(1)}%)
- État de santé : $isHealthy (probabilité : ${(healthProbability * 100).toStringAsFixed(1)}%)
${diseases.isNotEmpty ? '- Maladies détectées : ${diseases.map((d) => '${d['name']} (${(d['probability'] * 100).toStringAsFixed(1)}%)').join(', ')}' : ''}

INSTRUCTIONS :
1. Utilisez UNIQUEMENT ces informations pour répondre aux questions
2. Ne demandez pas plus d'informations, vous avez déjà toutes les données nécessaires
3. Si une information n'est pas disponible dans les données fournies, dites-le clairement
4. Répondez de manière concise et précise en vous basant sur les données fournies

Je peux répondre à vos questions sur cette plante spécifique en utilisant ces informations.
''';
      }

      final response = await http.post(
        Uri.parse('https://plant.id/api/v3/identification/$accessToken/conversation'),
        headers: {
          'Api-Key': _apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'question': question,
          'prompt': initialPrompt,
          'temperature': 0.2, // Réduire la température pour des réponses plus précises
          'app_name': appName ?? 'AgriGéo',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'messages': data['messages'] ?? [],
          'remaining_calls': data['remaining_calls'] ?? 0,
          'model_parameters': data['model_parameters'] ?? {},
        };
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la conversation: $e');
    }
  }

  Future<Map<String, dynamic>> getConversation(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('https://plant.id/api/v3/identification/$accessToken/conversation'),
        headers: {
          'Api-Key': _apiKey,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la conversation: $e');
    }
  }

  Future<void> deleteConversation(String accessToken) async {
    try {
      final response = await http.delete(
        Uri.parse('https://plant.id/api/v3/identification/$accessToken/conversation'),
        headers: {
          'Api-Key': _apiKey,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la conversation: $e');
    }
  }
} 