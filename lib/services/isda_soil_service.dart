import 'dart:convert';
import '../config/api_keys.dart';
import 'package:http/http.dart' as http;

/// Service pour l'API iSDAsoil - Données de sol spécialisées pour l'Afrique
class IsdaSoilService {
  static const String _baseUrl = 'https://api.isda-africa.com/isdasoil/v2';
  static String? _jwtToken;
  static DateTime? _tokenExpiry;

  /// Authentification avec l'API iSDAsoil
  static Future<bool> authenticate() async {
    try {
      if (!ApiKeys.isApiKeyConfigured(ApiKeys.isdaSoilEmail) || 
          !ApiKeys.isApiKeyConfigured(ApiKeys.isdaSoilPassword)) {
        print('iSDAsoil: Email ou mot de passe non configuré');
        return false;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'username=${ApiKeys.isdaSoilEmail}&password=${ApiKeys.isdaSoilPassword}',
      ).timeout(Duration(seconds: ApiKeys.apiTimeoutSeconds));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _jwtToken = data['access_token'];
        _tokenExpiry = DateTime.now().add(Duration(hours: 1)); // Token expire après 1 heure
        print('iSDAsoil: Authentification réussie');
        return true;
      } else {
        print('iSDAsoil: Erreur d\'authentification - ${response.statusCode}');
        print('iSDAsoil: ${response.body}');
        return false;
      }
    } catch (e) {
      print('iSDAsoil: Erreur de connexion - $e');
      return false;
    }
  }

  /// Vérifie si le token est valide et le renouvelle si nécessaire
  static Future<bool> _ensureValidToken() async {
    if (_jwtToken == null || _tokenExpiry == null || DateTime.now().isAfter(_tokenExpiry!)) {
      return await authenticate();
    }
    return true;
  }

  /// Obtient les données de sol pour une localisation donnée
  static Future<Map<String, dynamic>?> getSoilData({
    required double latitude,
    required double longitude,
    List<String>? properties,
  }) async {
    try {
      if (!await _ensureValidToken()) {
        return null;
      }

      // Propriétés par défaut si non spécifiées
      final soilProperties = properties ?? [
        'clay', 'sand', 'silt', 'ph', 'organic_carbon', 'bulk_density',
        'nitrogen', 'phosphorus', 'potassium', 'calcium', 'magnesium'
      ];

      final response = await http.get(
        Uri.parse('$_baseUrl/soilproperty?lat=$latitude&lon=$longitude&properties=${soilProperties.join(',')}'),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $_jwtToken',
        },
      ).timeout(Duration(seconds: ApiKeys.apiTimeoutSeconds));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseSoilData(data);
      } else {
        print('iSDAsoil: Erreur récupération données - ${response.statusCode}');
        print('iSDAsoil: ${response.body}');
        return null;
      }
    } catch (e) {
      print('iSDAsoil: Erreur getSoilData - $e');
      return null;
    }
  }

  /// Obtient les données de couches de sol
  static Future<Map<String, dynamic>?> getLayersData({
    required double latitude,
    required double longitude,
  }) async {
    try {
      if (!await _ensureValidToken()) {
        return null;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/layers?lat=$latitude&lon=$longitude'),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $_jwtToken',
        },
      ).timeout(Duration(seconds: ApiKeys.apiTimeoutSeconds));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseLayersData(data);
      } else {
        print('iSDAsoil: Erreur récupération couches - ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('iSDAsoil: Erreur getLayersData - $e');
      return null;
    }
  }

  /// Obtient des recommandations agricoles basées sur les données de sol
  static Future<Map<String, dynamic>?> getAgriculturalRecommendations({
    required double latitude,
    required double longitude,
    String? cropType,
  }) async {
    try {
      final soilData = await getSoilData(latitude: latitude, longitude: longitude);
      if (soilData == null) return null;

      return _generateRecommendations(soilData, cropType);
    } catch (e) {
      print('iSDAsoil: Erreur getAgriculturalRecommendations - $e');
      return null;
    }
  }

  /// Parse les données de sol de l'API iSDAsoil
  static Map<String, dynamic> _parseSoilData(Map<String, dynamic> data) {
    final result = <String, dynamic>{
      'location': {
        'latitude': data['lat'],
        'longitude': data['lon'],
      },
      'properties': <String, dynamic>{},
      'metadata': <String, dynamic>{},
    };

    if (data['properties'] != null) {
      for (var property in data['properties']) {
        final propName = property['property'];
        final values = property['values'] as List;
        
        if (values.isNotEmpty) {
          final value = values.first;
          result['properties'][propName] = {
            'value': value['value'],
            'unit': value['unit'] ?? '',
            'depth': value['depth'] ?? '0-30cm',
            'uncertainty': value['uncertainty'] ?? 0.0,
          };
        }
      }
    }

    return result;
  }

  /// Parse les données de couches de sol
  static Map<String, dynamic> _parseLayersData(Map<String, dynamic> data) {
    return {
      'location': {
        'latitude': data['lat'],
        'longitude': data['lon'],
      },
      'layers': data['layers'] ?? [],
    };
  }

  /// Génère des recommandations agricoles basées sur les données de sol
  static Map<String, dynamic> _generateRecommendations(
    Map<String, dynamic> soilData, 
    String? cropType,
  ) {
    final properties = soilData['properties'] as Map<String, dynamic>;
    final recommendations = <String, dynamic>{
      'crop_suitability': <String, dynamic>{},
      'fertilizer_recommendations': <String, dynamic>{},
      'soil_improvements': <String, dynamic>{},
      'irrigation_advice': <String, dynamic>{},
    };

    // Analyse du pH
    final ph = _getPropertyValue(properties, 'ph');
    if (ph != null) {
      if (ph < 5.5) {
        recommendations['soil_improvements']['ph'] = {
          'status': 'acide',
          'recommendation': 'Ajouter de la chaux pour augmenter le pH',
          'priority': 'high',
        };
      } else if (ph > 7.5) {
        recommendations['soil_improvements']['ph'] = {
          'status': 'alcalin',
          'recommendation': 'Ajouter du soufre ou de la matière organique',
          'priority': 'medium',
        };
      } else {
        recommendations['soil_improvements']['ph'] = {
          'status': 'optimal',
          'recommendation': 'pH optimal pour la plupart des cultures',
          'priority': 'low',
        };
      }
    }

    // Analyse de la matière organique
    final organicCarbon = _getPropertyValue(properties, 'organic_carbon');
    if (organicCarbon != null) {
      if (organicCarbon < 1.0) {
        recommendations['soil_improvements']['organic_matter'] = {
          'status': 'faible',
          'recommendation': 'Ajouter du compost ou du fumier pour améliorer la structure',
          'priority': 'high',
        };
      } else if (organicCarbon > 3.0) {
        recommendations['soil_improvements']['organic_matter'] = {
          'status': 'élevée',
          'recommendation': 'Niveau de matière organique excellent',
          'priority': 'low',
        };
      }
    }

    // Analyse de la texture du sol
    final clay = _getPropertyValue(properties, 'clay');
    final sand = _getPropertyValue(properties, 'sand');
    final silt = _getPropertyValue(properties, 'silt');

    if (clay != null && sand != null && silt != null) {
      final texture = _determineSoilTexture(clay, sand, silt);
      recommendations['soil_improvements']['texture'] = {
        'type': texture,
        'recommendation': _getTextureRecommendation(texture),
        'priority': 'medium',
      };
    }

    // Recommandations spécifiques aux cultures
    if (cropType != null) {
      recommendations['crop_suitability'] = _getCropSuitability(properties, cropType);
    }

    // Recommandations d'engrais
    recommendations['fertilizer_recommendations'] = _getFertilizerRecommendations(properties);

    return recommendations;
  }

  /// Obtient la valeur d'une propriété de sol
  static double? _getPropertyValue(Map<String, dynamic> properties, String propertyName) {
    final property = properties[propertyName];
    if (property is Map<String, dynamic> && property['value'] != null) {
      return (property['value'] as num).toDouble();
    }
    return null;
  }

  /// Détermine la texture du sol
  static String _determineSoilTexture(double clay, double sand, double silt) {
    if (clay > 40) return 'argileux';
    if (sand > 70) return 'sableux';
    if (silt > 40) return 'limoneux';
    if (clay > 20 && sand > 45) return 'argilo-sableux';
    if (clay > 20 && silt > 40) return 'argilo-limoneux';
    if (sand > 40 && silt > 40) return 'sablo-limoneux';
    return 'équilibré';
  }

  /// Obtient les recommandations basées sur la texture
  static String _getTextureRecommendation(String texture) {
    switch (texture) {
      case 'argileux':
        return 'Sol lourd, bon drainage nécessaire, bon pour la rétention d\'eau';
      case 'sableux':
        return 'Sol léger, ajouter de la matière organique, irrigation fréquente';
      case 'limoneux':
        return 'Texture équilibrée, bon pour la plupart des cultures';
      case 'argilo-sableux':
        return 'Bon équilibre, adapté à de nombreuses cultures';
      case 'argilo-limoneux':
        return 'Très fertile, excellent pour l\'agriculture';
      case 'sablo-limoneux':
        return 'Bon drainage, nécessite des apports organiques';
      default:
        return 'Texture équilibrée, adaptée à la plupart des cultures';
    }
  }

  /// Obtient l'aptitude aux cultures
  static Map<String, dynamic> _getCropSuitability(Map<String, dynamic> properties, String cropType) {
    final ph = _getPropertyValue(properties, 'ph');
    final clay = _getPropertyValue(properties, 'clay');
    
    // Recommandations basiques pour le Togo
    final togoCrops = {
      'maïs': {'ph_min': 5.5, 'ph_max': 7.5, 'clay_min': 10, 'clay_max': 40},
      'riz': {'ph_min': 5.0, 'ph_max': 7.0, 'clay_min': 20, 'clay_max': 60},
      'manioc': {'ph_min': 4.5, 'ph_max': 8.0, 'clay_min': 5, 'clay_max': 50},
      'igname': {'ph_min': 5.0, 'ph_max': 7.5, 'clay_min': 10, 'clay_max': 40},
      'coton': {'ph_min': 5.5, 'ph_max': 8.0, 'clay_min': 15, 'clay_max': 50},
    };

    final crop = togoCrops[cropType.toLowerCase()];
    if (crop == null) {
      return {'suitability': 'unknown', 'reason': 'Culture non reconnue'};
    }

    bool phSuitable = ph == null || (ph >= crop['ph_min']! && ph <= crop['ph_max']!);
    bool claySuitable = clay == null || (clay >= crop['clay_min']! && clay <= crop['clay_max']!);

    if (phSuitable && claySuitable) {
      return {'suitability': 'excellent', 'reason': 'Conditions optimales'};
    } else if (phSuitable || claySuitable) {
      return {'suitability': 'moderate', 'reason': 'Conditions acceptables avec améliorations'};
    } else {
      return {'suitability': 'poor', 'reason': 'Conditions non optimales, améliorations nécessaires'};
    }
  }

  /// Obtient les recommandations d'engrais
  static Map<String, dynamic> _getFertilizerRecommendations(Map<String, dynamic> properties) {
    final nitrogen = _getPropertyValue(properties, 'nitrogen');
    final phosphorus = _getPropertyValue(properties, 'phosphorus');
    final potassium = _getPropertyValue(properties, 'potassium');

    final recommendations = <String, dynamic>{};

    if (nitrogen != null && nitrogen < 0.1) {
      recommendations['nitrogen'] = {
        'status': 'deficient',
        'recommendation': 'Apport d\'azote nécessaire (NPK 20-10-10)',
        'amount': '50-100 kg/ha',
      };
    }

    if (phosphorus != null && phosphorus < 0.05) {
      recommendations['phosphorus'] = {
        'status': 'deficient',
        'recommendation': 'Apport de phosphore nécessaire (superphosphate)',
        'amount': '30-50 kg/ha',
      };
    }

    if (potassium != null && potassium < 0.1) {
      recommendations['potassium'] = {
        'status': 'deficient',
        'recommendation': 'Apport de potassium nécessaire (KCl)',
        'amount': '40-80 kg/ha',
      };
    }

    return recommendations;
  }

  /// Teste la connexion à l'API iSDAsoil
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      final success = await authenticate();
      if (success) {
        return {
          'status': 'working',
          'message': 'API iSDAsoil fonctionnelle',
          'note': 'Authentification réussie',
        };
      } else {
        return {
          'status': 'error',
          'message': 'Erreur d\'authentification iSDAsoil',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Erreur de connexion iSDAsoil: $e',
      };
    }
  }
}
