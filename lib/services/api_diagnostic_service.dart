import 'dart:convert';
import 'isda_soil_service.dart';
import '../config/api_keys.dart';
import 'package:http/http.dart' as http;

/// Service de diagnostic pour vérifier la configuration des clés API
class ApiDiagnosticService {
  
  /// Vérifie toutes les clés API configurées
  static Future<Map<String, dynamic>> diagnoseAllApis() async {
    final results = <String, dynamic>{};
    
    // Vérifier les services météo
    results['weather'] = await _diagnoseWeatherApis();
    
    // Vérifier les services de sol
    results['soil'] = await _diagnoseSoilApis();
    
    // Vérifier les services satellitaires
    results['satellite'] = await _diagnoseSatelliteApis();
    
    // Vérifier les services agricoles
    results['agricultural'] = await _diagnoseAgriculturalApis();
    
    // Résumé global
    results['summary'] = _generateSummary(results);
    
    return results;
  }
  
  /// Diagnostique les services météo
  static Future<Map<String, dynamic>> _diagnoseWeatherApis() async {
    final results = <String, dynamic>{};
    
    // OpenWeatherMap
    if (ApiKeys.isApiKeyConfigured(ApiKeys.openWeatherMapApiKey)) {
      results['openweathermap'] = await _testOpenWeatherMap();
    } else {
      results['openweathermap'] = {'status': 'not_configured', 'message': 'Clé API non configurée'};
    }
    
    // WeatherAPI
    if (ApiKeys.isApiKeyConfigured(ApiKeys.weatherApiApiKey)) {
      results['weatherapi'] = await _testWeatherApi();
    } else {
      results['weatherapi'] = {'status': 'not_configured', 'message': 'Clé API non configurée'};
    }
    
    // WeatherBit
    if (ApiKeys.isApiKeyConfigured(ApiKeys.weatherBitApiKey)) {
      results['weatherbit'] = await _testWeatherBit();
    } else {
      results['weatherbit'] = {'status': 'not_configured', 'message': 'Clé API non configurée'};
    }
    
    return results;
  }
  
  /// Diagnostique les services de sol
  static Future<Map<String, dynamic>> _diagnoseSoilApis() async {
    final results = <String, dynamic>{};
    
    // iSDAsoil (Recommandé pour l'Afrique)
    if (ApiKeys.isApiKeyConfigured(ApiKeys.isdaSoilEmail) && 
        ApiKeys.isApiKeyConfigured(ApiKeys.isdaSoilPassword)) {
      results['isdasoil'] = await _testIsdaSoil();
    } else {
      results['isdasoil'] = {'status': 'not_configured', 'message': 'Email ou mot de passe non configuré'};
    }
    
    // SoilGrids
    if (ApiKeys.isApiKeyConfigured(ApiKeys.soilGridsApiKey)) {
      results['soilgrids'] = await _testSoilGrids();
    } else {
      results['soilgrids'] = {'status': 'not_configured', 'message': 'Clé API non configurée'};
    }
    
    // SolGRID
    if (ApiKeys.isApiKeyConfigured(ApiKeys.solGridApiKey)) {
      results['solgrid'] = await _testSolGrid();
    } else {
      results['solgrid'] = {'status': 'not_configured', 'message': 'Clé API non configurée'};
    }
    
    return results;
  }
  
  /// Diagnostique les services satellitaires
  static Future<Map<String, dynamic>> _diagnoseSatelliteApis() async {
    final results = <String, dynamic>{};
    
    // Sentinel Hub
    if (ApiKeys.isApiKeyConfigured(ApiKeys.sentinelHubApiKey)) {
      results['sentinelhub'] = await _testSentinelHub();
    } else {
      results['sentinelhub'] = {'status': 'not_configured', 'message': 'Clé API non configurée'};
    }
    
    // NASA Earthdata
    if (ApiKeys.isApiKeyConfigured(ApiKeys.nasaEarthdataApiKey)) {
      results['nasa'] = await _testNasaEarthdata();
    } else {
      results['nasa'] = {'status': 'not_configured', 'message': 'Clé API non configurée'};
    }
    
    return results;
  }
  
  /// Diagnostique les services agricoles
  static Future<Map<String, dynamic>> _diagnoseAgriculturalApis() async {
    final results = <String, dynamic>{};
    
    // FAO
    if (ApiKeys.isApiKeyConfigured(ApiKeys.faoApiKey)) {
      results['fao'] = await _testFao();
    } else {
      results['fao'] = {'status': 'not_configured', 'message': 'Clé API non configurée'};
    }
    
    // Togo Agricultural
    if (ApiKeys.isApiKeyConfigured(ApiKeys.togoAgriculturalApiKey)) {
      results['togo'] = await _testTogoAgricultural();
    } else {
      results['togo'] = {'status': 'not_configured', 'message': 'Clé API non configurée'};
    }
    
    return results;
  }
  
  /// Teste OpenWeatherMap
  static Future<Map<String, dynamic>> _testOpenWeatherMap() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=6.1725&lon=1.2314&appid=${ApiKeys.openWeatherMapApiKey}&units=metric'),
      ).timeout(Duration(seconds: ApiKeys.apiTimeoutSeconds));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'status': 'working',
          'message': 'API fonctionnelle',
          'location': data['name'],
          'temperature': data['main']['temp'],
        };
      } else {
        return {
          'status': 'error',
          'message': 'Erreur HTTP ${response.statusCode}',
          'details': response.body,
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Erreur de connexion: $e',
      };
    }
  }
  
  /// Teste WeatherAPI
  static Future<Map<String, dynamic>> _testWeatherApi() async {
    try {
      final response = await http.get(
        Uri.parse('http://api.weatherapi.com/v1/current.json?key=${ApiKeys.weatherApiApiKey}&q=6.1725,1.2314'),
      ).timeout(Duration(seconds: ApiKeys.apiTimeoutSeconds));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'status': 'working',
          'message': 'API fonctionnelle',
          'location': data['location']['name'],
          'temperature': data['current']['temp_c'],
        };
      } else {
        return {
          'status': 'error',
          'message': 'Erreur HTTP ${response.statusCode}',
          'details': response.body,
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Erreur de connexion: $e',
      };
    }
  }
  
  /// Teste WeatherBit
  static Future<Map<String, dynamic>> _testWeatherBit() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.weatherbit.io/v2.0/current?lat=6.1725&lon=1.2314&key=${ApiKeys.weatherBitApiKey}'),
      ).timeout(Duration(seconds: ApiKeys.apiTimeoutSeconds));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'status': 'working',
          'message': 'API fonctionnelle',
          'location': data['data'][0]['city_name'],
          'temperature': data['data'][0]['temp'],
        };
      } else {
        return {
          'status': 'error',
          'message': 'Erreur HTTP ${response.statusCode}',
          'details': response.body,
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Erreur de connexion: $e',
      };
    }
  }
  
  /// Teste SoilGrids
  static Future<Map<String, dynamic>> _testSoilGrids() async {
    try {
      // Test simple de l'API SoilGrids
      final response = await http.get(
        Uri.parse('https://rest.isric.org/soilgrids/v2.0/properties/query?lon=1.2314&lat=6.1725&property=clay&depth=0-5cm&value=mean'),
      ).timeout(Duration(seconds: ApiKeys.apiTimeoutSeconds));
      
      if (response.statusCode == 200) {
        return {
          'status': 'working',
          'message': 'API fonctionnelle',
          'note': 'Données de sol récupérées',
        };
      } else {
        return {
          'status': 'error',
          'message': 'Erreur HTTP ${response.statusCode}',
          'details': response.body,
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Erreur de connexion: $e',
      };
    }
  }
  
  /// Teste iSDAsoil
  static Future<Map<String, dynamic>> _testIsdaSoil() async {
    return await IsdaSoilService.testConnection();
  }

  /// Teste SolGRID
  static Future<Map<String, dynamic>> _testSolGrid() async {
    // SolGRID nécessite une clé API spécifique
    return {
      'status': 'not_implemented',
      'message': 'Test SolGRID non implémenté (nécessite clé API spécifique)',
    };
  }
  
  /// Teste Sentinel Hub
  static Future<Map<String, dynamic>> _testSentinelHub() async {
    try {
      // Test d'authentification Sentinel Hub
      final response = await http.post(
        Uri.parse('https://services.sentinel-hub.com/oauth/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'grant_type=client_credentials&client_id=${ApiKeys.sentinelHubClientId}&client_secret=${ApiKeys.sentinelHubClientSecret}',
      ).timeout(Duration(seconds: ApiKeys.apiTimeoutSeconds));
      
      if (response.statusCode == 200) {
        return {
          'status': 'working',
          'message': 'API fonctionnelle',
          'note': 'Authentification réussie',
        };
      } else {
        return {
          'status': 'error',
          'message': 'Erreur d\'authentification ${response.statusCode}',
          'details': response.body,
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Erreur de connexion: $e',
      };
    }
  }
  
  /// Teste NASA Earthdata
  static Future<Map<String, dynamic>> _testNasaEarthdata() async {
    try {
      // Test simple de l'API NASA
      final response = await http.get(
        Uri.parse('https://earthengine.googleapis.com/v1alpha/projects/earthengine-legacy/assets'),
        headers: {'Authorization': 'Bearer ${ApiKeys.nasaEarthdataApiKey}'},
      ).timeout(Duration(seconds: ApiKeys.apiTimeoutSeconds));
      
      if (response.statusCode == 200) {
        return {
          'status': 'working',
          'message': 'API fonctionnelle',
          'note': 'Accès aux données satellitaires réussi',
        };
      } else {
        return {
          'status': 'error',
          'message': 'Erreur HTTP ${response.statusCode}',
          'details': response.body,
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Erreur de connexion: $e',
      };
    }
  }
  
  /// Teste FAO
  static Future<Map<String, dynamic>> _testFao() async {
    return {
      'status': 'not_implemented',
      'message': 'Test FAO non implémenté (nécessite clé API spécifique)',
    };
  }
  
  /// Teste Togo Agricultural
  static Future<Map<String, dynamic>> _testTogoAgricultural() async {
    return {
      'status': 'not_implemented',
      'message': 'Test Togo Agricultural non implémenté (API personnalisée)',
    };
  }
  
  /// Génère un résumé des résultats
  static Map<String, dynamic> _generateSummary(Map<String, dynamic> results) {
    int totalApis = 0;
    int workingApis = 0;
    int configuredApis = 0;
    int errorApis = 0;
    
    results.forEach((category, categoryResults) {
      if (category != 'summary' && categoryResults is Map<String, dynamic>) {
        categoryResults.forEach((api, apiResult) {
          if (apiResult is Map<String, dynamic>) {
            totalApis++;
            if (apiResult['status'] == 'working') {
              workingApis++;
            } else if (apiResult['status'] == 'not_configured') {
              configuredApis++;
            } else if (apiResult['status'] == 'error') {
              errorApis++;
            }
          }
        });
      }
    });
    
    return {
      'total_apis': totalApis,
      'working_apis': workingApis,
      'configured_apis': configuredApis,
      'error_apis': errorApis,
      'success_rate': totalApis > 0 ? (workingApis / totalApis * 100).round() : 0,
      'recommendation': _getRecommendation(workingApis, totalApis),
    };
  }
  
  /// Génère une recommandation basée sur les résultats
  static String _getRecommendation(int workingApis, int totalApis) {
    if (workingApis == 0) {
      return 'Aucune API configurée. Configurez au moins une API météo pour commencer.';
    } else if (workingApis < 3) {
      return 'Peu d\'APIs configurées. Ajoutez plus de clés pour une meilleure fiabilité.';
    } else if (workingApis < totalApis * 0.5) {
      return 'Configuration partielle. Considérez ajouter plus de clés API.';
    } else {
      return 'Configuration excellente ! Toutes les APIs principales sont fonctionnelles.';
    }
  }
  
  /// Affiche un rapport de diagnostic dans la console
  static Future<void> printDiagnosticReport() async {
    print('\n🔍 === DIAGNOSTIC DES CLÉS API ===');
    
    final results = await diagnoseAllApis();
    
    // Afficher le résumé
    final summary = results['summary'] as Map<String, dynamic>;
    print('\n📊 RÉSUMÉ:');
    print('   Total APIs: ${summary['total_apis']}');
    print('   Fonctionnelles: ${summary['working_apis']}');
    print('   Configurées: ${summary['configured_apis']}');
    print('   Erreurs: ${summary['error_apis']}');
    print('   Taux de succès: ${summary['success_rate']}%');
    print('   Recommandation: ${summary['recommendation']}');
    
    // Afficher les détails par catégorie
    results.forEach((category, categoryResults) {
      if (category != 'summary' && categoryResults is Map<String, dynamic>) {
        print('\n🌐 ${category.toUpperCase()}:');
        categoryResults.forEach((api, apiResult) {
          if (apiResult is Map<String, dynamic>) {
            final status = apiResult['status'];
            final message = apiResult['message'];
            final icon = status == 'working' ? '✅' : 
                        status == 'not_configured' ? '❌' : 
                        status == 'error' ? '⚠️' : '❓';
            print('   $icon $api: $message');
          }
        });
      }
    });
    
    print('\n🔧 Pour configurer les clés API, consultez: API_KEYS_SETUP_GUIDE.md');
    print('=====================================\n');
  }
}
