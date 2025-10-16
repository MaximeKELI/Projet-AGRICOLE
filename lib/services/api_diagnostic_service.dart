import 'dart:convert';
import 'real_soil_service.dart';
import 'satellite_service.dart';
import '../config/api_keys.dart';
import 'real_weather_service.dart';
import 'package:http/http.dart' as http;
import 'togo_agricultural_data_service.dart';

/// Service de diagnostic des APIs
/// Vérifie la connectivité et la validité des APIs configurées
class ApiDiagnosticService {
  
  /// Effectuer un diagnostic complet de toutes les APIs
  static Future<Map<String, dynamic>> performFullDiagnostic() async {
    print('🔍 Début du diagnostic complet des APIs...');
    
    final results = <String, Map<String, dynamic>>{};
    
    // Diagnostic des APIs météo
    results['weather'] = await _diagnoseWeatherApis();
    
    // Diagnostic des APIs de sol
    results['soil'] = await _diagnoseSoilApis();
    
    // Diagnostic des APIs agricoles
    results['agricultural'] = await _diagnoseAgriculturalApis();
    
    // Diagnostic des APIs satellites
    results['satellite'] = await _diagnoseSatelliteApis();
    
    // Diagnostic des APIs gouvernementales
    results['government'] = await _diagnoseGovernmentApis();
    
    // Calculer le score global
    final overallScore = _calculateOverallScore(results);
    
    print('✅ Diagnostic complet terminé - Score: $overallScore%');
    
    return {
      'overallScore': overallScore,
      'status': _getOverallStatus(overallScore),
      'results': results,
      'recommendations': _generateRecommendations(results),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Diagnostic des APIs météo
  static Future<Map<String, dynamic>> _diagnoseWeatherApis() async {
    final results = <String, Map<String, dynamic>>{};
    
    // Test OpenWeatherMap
    if (ApiKeys.isApiKeyConfigured(ApiKeys.openWeatherMapApiKey)) {
      results['openweathermap'] = await _testOpenWeatherMap();
    } else {
      results['openweathermap'] = {
        'status': 'NOT_CONFIGURED',
        'message': 'Clé API non configurée',
        'score': 0,
      };
    }
    
    // Test WeatherAPI
    if (ApiKeys.isApiKeyConfigured(ApiKeys.weatherApiApiKey)) {
      results['weatherapi'] = await _testWeatherApi();
    } else {
      results['weatherapi'] = {
        'status': 'NOT_CONFIGURED',
        'message': 'Clé API non configurée',
        'score': 0,
      };
    }
    
    // Test WeatherBit
    if (ApiKeys.isApiKeyConfigured(ApiKeys.weatherBitApiKey)) {
      results['weatherbit'] = await _testWeatherBit();
    } else {
      results['weatherbit'] = {
        'status': 'NOT_CONFIGURED',
        'message': 'Clé API non configurée',
        'score': 0,
      };
    }
    
    return {
      'apis': results,
      'score': _calculateCategoryScore(results),
      'status': _getCategoryStatus(results),
    };
  }

  /// Diagnostic des APIs de sol
  static Future<Map<String, dynamic>> _diagnoseSoilApis() async {
    final results = <String, Map<String, dynamic>>{};
    
    // Test iSDAsoil
    if (ApiKeys.isApiKeyConfigured(ApiKeys.isdaSoilEmail) && 
        ApiKeys.isApiKeyConfigured(ApiKeys.isdaSoilPassword)) {
      results['isdasoil'] = await _testISDASoil();
    } else {
      results['isdasoil'] = {
        'status': 'NOT_CONFIGURED',
        'message': 'Identifiants non configurés',
        'score': 0,
      };
    }
    
    // Test ISRIC SoilGrids
    results['soilgrids'] = await _testSoilGrids();
    
    // Test SolGRID
    if (ApiKeys.isApiKeyConfigured(ApiKeys.solGridApiKey)) {
      results['solgrid'] = await _testSolGrid();
    } else {
      results['solgrid'] = {
        'status': 'NOT_CONFIGURED',
        'message': 'Clé API non configurée',
        'score': 0,
      };
    }
    
    return {
      'apis': results,
      'score': _calculateCategoryScore(results),
      'status': _getCategoryStatus(results),
    };
  }

  /// Diagnostic des APIs agricoles
  static Future<Map<String, dynamic>> _diagnoseAgriculturalApis() async {
    final results = <String, Map<String, dynamic>>{};
    
    // Test FAO
    if (ApiKeys.isApiKeyConfigured(ApiKeys.faoApiKey)) {
      results['fao'] = await _testFAO();
    } else {
      results['fao'] = {
        'status': 'NOT_CONFIGURED',
        'message': 'Clé API non configurée',
        'score': 0,
      };
    }
    
    // Test World Bank
    if (ApiKeys.isApiKeyConfigured(ApiKeys.worldBankApiKey)) {
      results['worldbank'] = await _testWorldBank();
    } else {
      results['worldbank'] = {
        'status': 'NOT_CONFIGURED',
        'message': 'Clé API non configurée',
        'score': 0,
      };
    }
    
    // Test UN Statistics
    if (ApiKeys.isApiKeyConfigured(ApiKeys.unStatsApiKey)) {
      results['unstats'] = await _testUNStats();
    } else {
      results['unstats'] = {
        'status': 'NOT_CONFIGURED',
        'message': 'Clé API non configurée',
        'score': 0,
      };
    }
    
    return {
      'apis': results,
      'score': _calculateCategoryScore(results),
      'status': _getCategoryStatus(results),
    };
  }

  /// Diagnostic des APIs satellites
  static Future<Map<String, dynamic>> _diagnoseSatelliteApis() async {
    final results = <String, Map<String, dynamic>>{};
    
    // Test Sentinel Hub
    if (ApiKeys.isApiKeyConfigured(ApiKeys.sentinelHubApiKey)) {
      results['sentinelhub'] = await _testSentinelHub();
    } else {
      results['sentinelhub'] = {
        'status': 'NOT_CONFIGURED',
        'message': 'Clé API non configurée',
        'score': 0,
      };
    }
    
    // Test NASA Earthdata
    if (ApiKeys.isApiKeyConfigured(ApiKeys.nasaEarthdataApiKey)) {
      results['nasaearthdata'] = await _testNASAEarthdata();
    } else {
      results['nasaearthdata'] = {
        'status': 'NOT_CONFIGURED',
        'message': 'Clé API non configurée',
        'score': 0,
      };
    }
    
    return {
      'apis': results,
      'score': _calculateCategoryScore(results),
      'status': _getCategoryStatus(results),
    };
  }

  /// Diagnostic des APIs gouvernementales
  static Future<Map<String, dynamic>> _diagnoseGovernmentApis() async {
    final results = <String, Map<String, dynamic>>{};
    
    // Test Ministère de l'Agriculture
    if (ApiKeys.isApiKeyConfigured(ApiKeys.governmentApiKey)) {
      results['agriculture'] = await _testGovernmentApi('Agriculture');
    } else {
      results['agriculture'] = {
        'status': 'NOT_CONFIGURED',
        'message': 'Clé API non configurée',
        'score': 0,
      };
    }
    
    // Test Météo Officielle
    if (ApiKeys.isApiKeyConfigured(ApiKeys.meteoApiKey)) {
      results['meteo'] = await _testGovernmentApi('Meteo');
    } else {
      results['meteo'] = {
        'status': 'NOT_CONFIGURED',
        'message': 'Clé API non configurée',
        'score': 0,
      };
    }
    
    return {
      'apis': results,
      'score': _calculateCategoryScore(results),
      'status': _getCategoryStatus(results),
    };
  }

  // Tests individuels des APIs

  static Future<Map<String, dynamic>> _testOpenWeatherMap() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=6.1378&lon=1.2123&appid=${ApiKeys.openWeatherMapApiKey}&units=metric'),
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'status': 'WORKING',
          'message': 'API fonctionnelle',
          'score': 100,
          'responseTime': response.headers['date'],
          'data': data,
        };
      } else {
        return {
          'status': 'ERROR',
          'message': 'Erreur HTTP ${response.statusCode}',
          'score': 0,
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'status': 'ERROR',
        'message': 'Erreur de connexion: $e',
        'score': 0,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> _testWeatherApi() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.weatherapi.com/v1/current.json?key=${ApiKeys.weatherApiApiKey}&q=6.1378,1.2123&aqi=no'),
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'status': 'WORKING',
          'message': 'API fonctionnelle',
          'score': 100,
          'responseTime': response.headers['date'],
          'data': data,
        };
      } else {
        return {
          'status': 'ERROR',
          'message': 'Erreur HTTP ${response.statusCode}',
          'score': 0,
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'status': 'ERROR',
        'message': 'Erreur de connexion: $e',
        'score': 0,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> _testWeatherBit() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.weatherbit.io/v2.0/current?lat=6.1378&lon=1.2123&key=${ApiKeys.weatherBitApiKey}&units=M'),
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'status': 'WORKING',
          'message': 'API fonctionnelle',
          'score': 100,
          'responseTime': response.headers['date'],
          'data': data,
        };
      } else {
        return {
          'status': 'ERROR',
          'message': 'Erreur HTTP ${response.statusCode}',
          'score': 0,
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'status': 'ERROR',
        'message': 'Erreur de connexion: $e',
        'score': 0,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> _testISDASoil() async {
    try {
      // Note: iSDAsoil nécessite une authentification JWT
      // En production, implémenter l'authentification complète
      return {
        'status': 'NOT_IMPLEMENTED',
        'message': 'Authentification JWT requise',
        'score': 0,
        'note': 'Nécessite une implémentation complète de l\'authentification',
      };
    } catch (e) {
      return {
        'status': 'ERROR',
        'message': 'Erreur de connexion: $e',
        'score': 0,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> _testSoilGrids() async {
    try {
      final response = await http.get(
        Uri.parse('https://rest.isric.org/soilgrids/v2.0/properties?lon=1.2123&lat=6.1378&property=phh2o&property=clay&property=sand&property=silt&property=oc&depth=0-5cm&value=mean'),
      ).timeout(Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'status': 'WORKING',
          'message': 'API fonctionnelle',
          'score': 100,
          'responseTime': response.headers['date'],
          'data': data,
        };
      } else {
        return {
          'status': 'ERROR',
          'message': 'Erreur HTTP ${response.statusCode}',
          'score': 0,
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'status': 'ERROR',
        'message': 'Erreur de connexion: $e',
        'score': 0,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> _testSolGrid() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.solgrid.org/v1/soil?lat=6.1378&lon=1.2123&key=${ApiKeys.solGridApiKey}'),
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'status': 'WORKING',
          'message': 'API fonctionnelle',
          'score': 100,
          'responseTime': response.headers['date'],
          'data': data,
        };
      } else {
        return {
          'status': 'ERROR',
          'message': 'Erreur HTTP ${response.statusCode}',
          'score': 0,
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'status': 'ERROR',
        'message': 'Erreur de connexion: $e',
        'score': 0,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> _testFAO() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.fao.org/production?country=TG&year=2023'),
        headers: {'Authorization': 'Bearer ${ApiKeys.faoApiKey}'},
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'status': 'WORKING',
          'message': 'API fonctionnelle',
          'score': 100,
          'responseTime': response.headers['date'],
          'data': data,
        };
      } else {
        return {
          'status': 'ERROR',
          'message': 'Erreur HTTP ${response.statusCode}',
          'score': 0,
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'status': 'ERROR',
        'message': 'Erreur de connexion: $e',
        'score': 0,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> _testWorldBank() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.worldbank.org/v2/country/TG/indicator/AG.PRD.CROP.XD?format=json&date=2023'),
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'status': 'WORKING',
          'message': 'API fonctionnelle',
          'score': 100,
          'responseTime': response.headers['date'],
          'data': data,
        };
      } else {
        return {
          'status': 'ERROR',
          'message': 'Erreur HTTP ${response.statusCode}',
          'score': 0,
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'status': 'ERROR',
        'message': 'Erreur de connexion: $e',
        'score': 0,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> _testUNStats() async {
    try {
      final response = await http.get(
        Uri.parse('https://unstats.un.org/api/v1/data/UNSD/agriculture?country=TG&year=2023'),
        headers: {'Authorization': 'Bearer ${ApiKeys.unStatsApiKey}'},
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'status': 'WORKING',
          'message': 'API fonctionnelle',
          'score': 100,
          'responseTime': response.headers['date'],
          'data': data,
        };
      } else {
        return {
          'status': 'ERROR',
          'message': 'Erreur HTTP ${response.statusCode}',
          'score': 0,
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'status': 'ERROR',
        'message': 'Erreur de connexion: $e',
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> _testSentinelHub() async {
    try {
      final response = await http.get(
        Uri.parse('https://services.sentinel-hub.com/api/v1/process'),
        headers: {
          'Authorization': 'Bearer ${ApiKeys.sentinelHubApiKey}',
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return {
          'status': 'WORKING',
          'message': 'API fonctionnelle',
          'score': 100,
          'responseTime': response.headers['date'],
        };
      } else {
        return {
          'status': 'ERROR',
          'message': 'Erreur HTTP ${response.statusCode}',
          'score': 0,
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'status': 'ERROR',
        'message': 'Erreur de connexion: $e',
        'score': 0,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> _testNASAEarthdata() async {
    try {
      final response = await http.get(
        Uri.parse('https://earthengine.google.com/api/v1/projects'),
        headers: {'Authorization': 'Bearer ${ApiKeys.nasaEarthdataApiKey}'},
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return {
          'status': 'WORKING',
          'message': 'API fonctionnelle',
          'score': 100,
          'responseTime': response.headers['date'],
        };
      } else {
        return {
          'status': 'ERROR',
          'message': 'Erreur HTTP ${response.statusCode}',
          'score': 0,
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'status': 'ERROR',
        'message': 'Erreur de connexion: $e',
        'score': 0,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> _testGovernmentApi(String apiName) async {
    try {
      // Test basique de connectivité
      final response = await http.get(
        Uri.parse('https://api.agriculture.gouv.tg/health'),
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return {
          'status': 'WORKING',
          'message': 'API $apiName fonctionnelle',
          'score': 100,
          'responseTime': response.headers['date'],
        };
      } else {
        return {
          'status': 'ERROR',
          'message': 'Erreur HTTP ${response.statusCode}',
          'score': 0,
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'status': 'ERROR',
        'message': 'Erreur de connexion: $e',
        'score': 0,
        'error': e.toString(),
      };
    }
  }

  // Méthodes utilitaires

  static double _calculateOverallScore(Map<String, Map<String, dynamic>> results) {
    double totalScore = 0;
    int categoryCount = 0;
    
    results.forEach((category, data) {
      if (data['score'] != null) {
        totalScore += data['score'];
        categoryCount++;
      }
    });
    
    return categoryCount > 0 ? totalScore / categoryCount : 0;
  }

  static double _calculateCategoryScore(Map<String, Map<String, dynamic>> apis) {
    double totalScore = 0;
    int apiCount = 0;
    
    apis.forEach((api, data) {
      if (data['score'] != null) {
        totalScore += data['score'];
        apiCount++;
      }
    });
    
    return apiCount > 0 ? totalScore / apiCount : 0;
  }

  static String _getOverallStatus(double score) {
    if (score >= 80) return 'EXCELLENT';
    if (score >= 60) return 'GOOD';
    if (score >= 40) return 'FAIR';
    return 'POOR';
  }

  static String _getCategoryStatus(Map<String, Map<String, dynamic>> apis) {
    final scores = apis.values.where((data) => data['score'] != null).map((data) => data['score']).toList();
    if (scores.isEmpty) return 'NO_APIS';
    
    final avgScore = scores.reduce((a, b) => a + b) / scores.length;
    return _getOverallStatus(avgScore);
  }

  static List<Map<String, dynamic>> _generateRecommendations(Map<String, Map<String, dynamic>> results) {
    final recommendations = <Map<String, dynamic>>[];
    
    results.forEach((category, data) {
      final apis = data['apis'] as Map<String, Map<String, dynamic>>? ?? {};
      
      apis.forEach((api, apiData) {
        if (apiData['status'] == 'NOT_CONFIGURED') {
          recommendations.add({
            'type': 'CONFIGURATION',
            'category': category,
            'api': api,
            'title': 'Configurer ${api.toUpperCase()}',
            'description': 'Configurez la clé API pour ${api.toUpperCase()}',
            'priority': 'HIGH',
            'action': 'Ajoutez votre clé API dans le fichier de configuration',
          });
        } else if (apiData['status'] == 'ERROR') {
          recommendations.add({
            'type': 'ERROR',
            'category': category,
            'api': api,
            'title': 'Corriger ${api.toUpperCase()}',
            'description': 'Erreur détectée: ${apiData['message']}',
            'priority': 'MEDIUM',
            'action': 'Vérifiez votre clé API et votre connexion internet',
          });
        }
      });
    });
    
    return recommendations;
  }

  /// Obtenir un résumé du diagnostic
  static Future<Map<String, dynamic>> getDiagnosticSummary() async {
    final diagnostic = await performFullDiagnostic();
    
    return {
      'overallScore': diagnostic['overallScore'],
      'status': diagnostic['status'],
      'configuredApis': _countConfiguredApis(diagnostic['results']),
      'workingApis': _countWorkingApis(diagnostic['results']),
      'totalApis': _countTotalApis(diagnostic['results']),
      'recommendations': diagnostic['recommendations'],
      'lastChecked': diagnostic['timestamp'],
    };
  }

  static int _countConfiguredApis(Map<String, dynamic> results) {
    int count = 0;
    results.forEach((category, data) {
      final apis = data['apis'] as Map<String, dynamic>? ?? {};
      apis.forEach((api, apiData) {
        if (apiData['status'] != 'NOT_CONFIGURED') count++;
      });
    });
    return count;
  }

  static int _countWorkingApis(Map<String, dynamic> results) {
    int count = 0;
    results.forEach((category, data) {
      final apis = data['apis'] as Map<String, dynamic>? ?? {};
      apis.forEach((api, apiData) {
        if (apiData['status'] == 'WORKING') count++;
      });
    });
    return count;
  }

  static int _countTotalApis(Map<String, dynamic> results) {
    int count = 0;
    results.forEach((category, data) {
      final apis = data['apis'] as Map<String, dynamic>? ?? {};
      count += apis.length;
    });
    return count;
  }
}