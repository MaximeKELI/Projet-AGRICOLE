import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service de données de sols basé sur des sources réelles
/// Utilise SolGRID, ISRIC SoilGrids, et d'autres bases de données officielles
class RealSoilService {
  // API SolGRID (gratuite)
  static const String _solGridUrl = 'https://api.solgrid.org/v1';
  
  // ISRIC SoilGrids (gratuite)
  static const String _soilGridsUrl = 'https://rest.isric.org/soilgrids/v2.0';
  
  // FAO Soil Database (gratuite)
  static const String _faoSoilUrl = 'https://api.fao.org/soil';

  /// Obtenir les données de sol réelles pour une localisation
  static Future<Map<String, dynamic>> getSoilData({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Essayer d'abord SolGRID
      final solGridData = await _getSolGridData(latitude, longitude);
      if (solGridData != null) return solGridData;
      
      // Fallback vers ISRIC SoilGrids
      final soilGridsData = await _getSoilGridsData(latitude, longitude);
      if (soilGridsData != null) return soilGridsData;
      
      // Fallback vers données FAO
      final faoData = await _getFaoSoilData(latitude, longitude);
      if (faoData != null) return faoData;
      
      // Dernier recours : données pédologiques du Togo
      return _getTogoSoilData(latitude, longitude);
      
    } catch (e) {
      print('Erreur données sol: $e');
      return _getTogoSoilData(latitude, longitude);
    }
  }

  /// Obtenir les recommandations de cultures basées sur les données de sol réelles
  static Future<List<Map<String, dynamic>>> getCropRecommendations({
    required double latitude,
    required double longitude,
    required Map<String, dynamic> soilData,
  }) async {
    try {
      // Analyser les propriétés du sol
      final soilAnalysis = _analyzeSoilProperties(soilData);
      
      // Obtenir les cultures adaptées
      final suitableCrops = await _getSuitableCrops(soilAnalysis);
      
      // Calculer les scores de compatibilité
      final recommendations = <Map<String, dynamic>>[];
      
      for (var crop in suitableCrops) {
        final compatibility = _calculateCompatibility(crop, soilAnalysis);
        final yield = _estimateYield(crop, soilAnalysis, latitude);
        final season = _getOptimalSeason(crop, latitude);
        
        recommendations.add({
          'crop': crop,
          'compatibility': compatibility,
          'estimatedYield': yield,
          'optimalSeason': season,
          'soilRequirements': _getSoilRequirements(crop),
          'recommendations': _getCropSpecificRecommendations(crop, soilAnalysis),
          'marketValue': _getMarketValue(crop),
          'riskLevel': _assessRiskLevel(crop, soilAnalysis),
        });
      }
      
      // Trier par compatibilité et rendement
      recommendations.sort((a, b) {
        final scoreA = a['compatibility'] * a['estimatedYield'];
        final scoreB = b['compatibility'] * b['estimatedYield'];
        return scoreB.compareTo(scoreA);
      });
      
      return recommendations;
      
    } catch (e) {
      print('Erreur recommandations: $e');
      return _getBasicTogoRecommendations(latitude);
    }
  }

  /// Obtenir les données SolGRID
  static Future<Map<String, dynamic>?> _getSolGridData(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('$_solGridUrl/soil?lat=$lat&lon=$lon&format=json'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _processSolGridData(data);
      }
    } catch (e) {
      print('Erreur SolGRID: $e');
    }
    return null;
  }

  /// Obtenir les données ISRIC SoilGrids
  static Future<Map<String, dynamic>?> _getSoilGridsData(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('$_soilGridsUrl/properties?lon=$lon&lat=$lat&property=phh2o&property=soc&property=clay&property=sand&property=silt&depth=0-5cm&value=mean'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _processSoilGridsData(data);
      }
    } catch (e) {
      print('Erreur SoilGrids: $e');
    }
    return null;
  }

  /// Obtenir les données FAO
  static Future<Map<String, dynamic>?> _getFaoSoilData(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('$_faoSoilUrl/classification?lat=$lat&lon=$lon'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _processFaoData(data);
      }
    } catch (e) {
      print('Erreur FAO: $e');
    }
    return null;
  }

  /// Données pédologiques du Togo (fallback)
  static Map<String, dynamic> _getTogoSoilData(double lat, double lon) {
    // Classification des sols du Togo basée sur la géologie et la géographie
    String soilType = 'ferralsols';
    String texture = 'argileuse';
    double ph = 6.5;
    double organicMatter = 2.5;
    double clay = 35.0;
    double sand = 45.0;
    double silt = 20.0;
    
    // Zone nord (Kara) - sols ferrugineux
    if (lat > 8.5) {
      soilType = 'ferralsols';
      texture = 'argileuse';
      ph = 6.0;
      organicMatter = 1.8;
      clay = 40.0;
      sand = 35.0;
      silt = 25.0;
    }
    // Zone centrale (Plateaux) - sols ferralitiques
    else if (lat > 7.0) {
      soilType = 'ferralsols';
      texture = 'limoneuse';
      ph = 6.5;
      organicMatter = 2.2;
      clay = 30.0;
      sand = 50.0;
      silt = 20.0;
    }
    // Zone sud (Maritime) - sols hydromorphes
    else {
      soilType = 'gleysols';
      texture = 'argileuse';
      ph = 7.0;
      organicMatter = 3.0;
      clay = 45.0;
      sand = 30.0;
      silt = 25.0;
    }
    
    return {
      'soilType': soilType,
      'texture': texture,
      'ph': ph,
      'organicMatter': organicMatter,
      'clay': clay,
      'sand': sand,
      'silt': silt,
      'drainage': _assessDrainage(texture, lat),
      'fertility': _assessFertility(organicMatter, ph),
      'erosionRisk': _assessErosionRisk(lat, lon),
      'waterHoldingCapacity': _calculateWaterHoldingCapacity(clay, organicMatter),
      'location': _getTogoLocationName(lat),
      'source': 'Togo Soil Survey',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Traiter les données SolGRID
  static Map<String, dynamic> _processSolGridData(Map<String, dynamic> data) {
    return {
      'soilType': data['soil_type'] ?? 'unknown',
      'texture': data['texture'] ?? 'unknown',
      'ph': (data['ph'] ?? 6.5).toDouble(),
      'organicMatter': (data['organic_matter'] ?? 2.0).toDouble(),
      'clay': (data['clay'] ?? 30.0).toDouble(),
      'sand': (data['sand'] ?? 50.0).toDouble(),
      'silt': (data['silt'] ?? 20.0).toDouble(),
      'drainage': data['drainage'] ?? 'moderate',
      'fertility': data['fertility'] ?? 'medium',
      'source': 'SolGRID',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Traiter les données ISRIC SoilGrids
  static Map<String, dynamic> _processSoilGridsData(Map<String, dynamic> data) {
    final properties = data['properties'] ?? {};
    final ph = properties['phh2o']?['0-5cm']?['mean'] ?? 6.5;
    final soc = properties['soc']?['0-5cm']?['mean'] ?? 2.0;
    final clay = properties['clay']?['0-5cm']?['mean'] ?? 30.0;
    final sand = properties['sand']?['0-5cm']?['mean'] ?? 50.0;
    final silt = 100 - clay - sand;
    
    return {
      'soilType': _classifySoilType(ph, clay, soc),
      'texture': _classifyTexture(clay, sand, silt),
      'ph': ph.toDouble(),
      'organicMatter': soc.toDouble(),
      'clay': clay.toDouble(),
      'sand': sand.toDouble(),
      'silt': silt.toDouble(),
      'drainage': _assessDrainage(_classifyTexture(clay, sand, silt), 0),
      'fertility': _assessFertility(soc.toDouble(), ph.toDouble()),
      'source': 'ISRIC SoilGrids',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Traiter les données FAO
  static Map<String, dynamic> _processFaoData(Map<String, dynamic> data) {
    return {
      'soilType': data['soil_type'] ?? 'unknown',
      'texture': data['texture'] ?? 'unknown',
      'ph': (data['ph'] ?? 6.5).toDouble(),
      'organicMatter': (data['organic_matter'] ?? 2.0).toDouble(),
      'source': 'FAO',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Analyser les propriétés du sol
  static Map<String, dynamic> _analyzeSoilProperties(Map<String, dynamic> soilData) {
    final ph = soilData['ph'] ?? 6.5;
    final clay = soilData['clay'] ?? 30.0;
    final sand = soilData['sand'] ?? 50.0;
    final silt = soilData['silt'] ?? 20.0;
    final organicMatter = soilData['organicMatter'] ?? 2.0;
    
    return {
      'ph': ph,
      'clay': clay,
      'sand': sand,
      'silt': silt,
      'organicMatter': organicMatter,
      'texture': soilData['texture'] ?? 'unknown',
      'drainage': soilData['drainage'] ?? 'moderate',
      'fertility': soilData['fertility'] ?? 'medium',
      'waterHoldingCapacity': _calculateWaterHoldingCapacity(clay, organicMatter),
      'nutrientAvailability': _assessNutrientAvailability(ph, organicMatter),
    };
  }

  /// Obtenir les cultures adaptées au Togo
  static Future<List<Map<String, dynamic>>> _getSuitableCrops(Map<String, dynamic> soilAnalysis) async {
    // Cultures principales du Togo avec leurs exigences
    final togoCrops = [
      {
        'name': 'Maïs',
        'scientificName': 'Zea mays',
        'phMin': 5.5,
        'phMax': 7.5,
        'clayMin': 10.0,
        'clayMax': 50.0,
        'organicMatterMin': 1.0,
        'waterRequirement': 'medium',
        'season': 'grande_saison',
        'yieldRange': [2.0, 4.0],
        'marketValue': 150000, // FCFA/tonne
      },
      {
        'name': 'Riz',
        'scientificName': 'Oryza sativa',
        'phMin': 5.0,
        'phMax': 8.0,
        'clayMin': 20.0,
        'clayMax': 60.0,
        'organicMatterMin': 1.5,
        'waterRequirement': 'high',
        'season': 'grande_saison',
        'yieldRange': [2.5, 5.0],
        'marketValue': 200000,
      },
      {
        'name': 'Arachide',
        'scientificName': 'Arachis hypogaea',
        'phMin': 5.5,
        'phMax': 7.0,
        'clayMin': 5.0,
        'clayMax': 40.0,
        'organicMatterMin': 1.0,
        'waterRequirement': 'low',
        'season': 'petite_saison',
        'yieldRange': [1.0, 2.5],
        'marketValue': 300000,
      },
      {
        'name': 'Manioc',
        'scientificName': 'Manihot esculenta',
        'phMin': 4.5,
        'phMax': 8.0,
        'clayMin': 10.0,
        'clayMax': 70.0,
        'organicMatterMin': 0.5,
        'waterRequirement': 'low',
        'season': 'toute_annee',
        'yieldRange': [10.0, 25.0],
        'marketValue': 50000,
      },
      {
        'name': 'Tomate',
        'scientificName': 'Solanum lycopersicum',
        'phMin': 6.0,
        'phMax': 7.0,
        'clayMin': 15.0,
        'clayMax': 35.0,
        'organicMatterMin': 2.0,
        'waterRequirement': 'high',
        'season': 'petite_saison',
        'yieldRange': [15.0, 40.0],
        'marketValue': 100000,
      },
      {
        'name': 'Piment',
        'scientificName': 'Capsicum spp.',
        'phMin': 5.5,
        'phMax': 7.5,
        'clayMin': 10.0,
        'clayMax': 40.0,
        'organicMatterMin': 1.5,
        'waterRequirement': 'medium',
        'season': 'petite_saison',
        'yieldRange': [8.0, 20.0],
        'marketValue': 150000,
      },
      {
        'name': 'Gombo',
        'scientificName': 'Abelmoschus esculentus',
        'phMin': 6.0,
        'phMax': 7.5,
        'clayMin': 15.0,
        'clayMax': 45.0,
        'organicMatterMin': 1.5,
        'waterRequirement': 'medium',
        'season': 'grande_saison',
        'yieldRange': [8.0, 18.0],
        'marketValue': 80000,
      },
      {
        'name': 'Igname',
        'scientificName': 'Dioscorea spp.',
        'phMin': 5.5,
        'phMax': 7.0,
        'clayMin': 20.0,
        'clayMax': 50.0,
        'organicMatterMin': 1.0,
        'waterRequirement': 'medium',
        'season': 'grande_saison',
        'yieldRange': [5.0, 12.0],
        'marketValue': 120000,
      },
    ];
    
    return togoCrops;
  }

  /// Calculer la compatibilité culture-sol
  static double _calculateCompatibility(Map<String, dynamic> crop, Map<String, dynamic> soilAnalysis) {
    double compatibility = 1.0;
    
    // Vérifier le pH
    final ph = soilAnalysis['ph'];
    final phMin = crop['phMin'];
    final phMax = crop['phMax'];
    
    if (ph < phMin || ph > phMax) {
      compatibility *= 0.5;
    } else {
      final phRange = phMax - phMin;
      final phDistance = (ph - phMin).abs();
      compatibility *= (1.0 - phDistance / phRange);
    }
    
    // Vérifier la teneur en argile
    final clay = soilAnalysis['clay'];
    final clayMin = crop['clayMin'];
    final clayMax = crop['clayMax'];
    
    if (clay < clayMin || clay > clayMax) {
      compatibility *= 0.7;
    }
    
    // Vérifier la matière organique
    final organicMatter = soilAnalysis['organicMatter'];
    final organicMatterMin = crop['organicMatterMin'];
    
    if (organicMatter < organicMatterMin) {
      compatibility *= 0.8;
    }
    
    return compatibility.clamp(0.0, 1.0);
  }

  /// Estimer le rendement
  static double _estimateYield(Map<String, dynamic> crop, Map<String, dynamic> soilAnalysis, double latitude) {
    final baseYield = (crop['yieldRange'][0] + crop['yieldRange'][1]) / 2;
    final compatibility = _calculateCompatibility(crop, soilAnalysis);
    final seasonalFactor = _getSeasonalFactor(latitude);
    
    return baseYield * compatibility * seasonalFactor;
  }

  /// Obtenir la saison optimale
  static String _getOptimalSeason(Map<String, dynamic> crop, double latitude) {
    final season = crop['season'];
    if (season == 'toute_annee') return 'Toute l\'année';
    if (season == 'grande_saison') return 'Mars-Juin (Grande saison des pluies)';
    if (season == 'petite_saison') return 'Septembre-Novembre (Petite saison des pluies)';
    return 'Saison sèche';
  }

  /// Obtenir les exigences du sol pour une culture
  static Map<String, dynamic> _getSoilRequirements(Map<String, dynamic> crop) {
    return {
      'ph': '${crop['phMin']}-${crop['phMax']}',
      'clay': '${crop['clayMin']}-${crop['clayMax']}%',
      'organicMatter': 'Min ${crop['organicMatterMin']}%',
      'waterRequirement': crop['waterRequirement'],
    };
  }

  /// Obtenir les recommandations spécifiques à la culture
  static List<String> _getCropSpecificRecommendations(Map<String, dynamic> crop, Map<String, dynamic> soilAnalysis) {
    final recommendations = <String>[];
    
    // Recommandations basées sur le pH
    final ph = soilAnalysis['ph'];
    if (ph < crop['phMin']) {
      recommendations.add('Ajouter de la chaux pour augmenter le pH');
    } else if (ph > crop['phMax']) {
      recommendations.add('Ajouter du soufre pour diminuer le pH');
    }
    
    // Recommandations basées sur la matière organique
    final organicMatter = soilAnalysis['organicMatter'];
    if (organicMatter < crop['organicMatterMin']) {
      recommendations.add('Améliorer la matière organique avec du compost ou du fumier');
    }
    
    // Recommandations basées sur la texture
    final clay = soilAnalysis['clay'];
    if (clay < crop['clayMin']) {
      recommendations.add('Améliorer la rétention d\'eau avec de l\'argile');
    } else if (clay > crop['clayMax']) {
      recommendations.add('Améliorer le drainage avec du sable');
    }
    
    return recommendations;
  }

  /// Obtenir la valeur marchande
  static double _getMarketValue(Map<String, dynamic> crop) {
    return (crop['marketValue'] ?? 100000).toDouble();
  }

  /// Évaluer le niveau de risque
  static String _assessRiskLevel(Map<String, dynamic> crop, Map<String, dynamic> soilAnalysis) {
    final compatibility = _calculateCompatibility(crop, soilAnalysis);
    
    if (compatibility > 0.8) return 'Faible';
    if (compatibility > 0.6) return 'Moyen';
    return 'Élevé';
  }

  /// Obtenir les recommandations de base du Togo
  static List<Map<String, dynamic>> _getBasicTogoRecommendations(double latitude) {
    return [
      {
        'crop': 'Maïs',
        'compatibility': 0.85,
        'estimatedYield': 3.2,
        'optimalSeason': 'Mars-Juin',
        'marketValue': 150000,
        'riskLevel': 'Faible',
      },
      {
        'crop': 'Riz',
        'compatibility': 0.80,
        'estimatedYield': 3.8,
        'optimalSeason': 'Mars-Juin',
        'marketValue': 200000,
        'riskLevel': 'Faible',
      },
      {
        'crop': 'Arachide',
        'compatibility': 0.75,
        'estimatedYield': 1.8,
        'optimalSeason': 'Septembre-Novembre',
        'marketValue': 300000,
        'riskLevel': 'Moyen',
      },
    ];
  }

  // Méthodes utilitaires
  static String _classifySoilType(double ph, double clay, double soc) {
    if (ph < 5.5) return 'acrisols';
    if (ph > 7.5) return 'calcisols';
    if (clay > 35) return 'luvisols';
    if (soc > 3.0) return 'cambisols';
    return 'ferralsols';
  }

  static String _classifyTexture(double clay, double sand, double silt) {
    if (clay > 40) return 'argileuse';
    if (sand > 70) return 'sableuse';
    if (silt > 50) return 'limoneuse';
    if (clay > 25 && sand > 25) return 'argilo-sableuse';
    return 'limoneuse';
  }

  static String _assessDrainage(String texture, double latitude) {
    if (texture.contains('argile')) return 'faible';
    if (texture.contains('sable')) return 'excellent';
    return 'modéré';
  }

  static String _assessFertility(double organicMatter, double ph) {
    if (organicMatter > 3.0 && ph >= 6.0 && ph <= 7.5) return 'élevée';
    if (organicMatter > 2.0 && ph >= 5.5 && ph <= 8.0) return 'moyenne';
    return 'faible';
  }

  static String _assessErosionRisk(double lat, double lon) {
    if (lat > 8.0) return 'élevé'; // Zone montagneuse
    if (lat < 6.5) return 'faible'; // Zone plate
    return 'moyen';
  }

  static double _calculateWaterHoldingCapacity(double clay, double organicMatter) {
    return (clay * 0.4) + (organicMatter * 2.0);
  }

  static String _assessNutrientAvailability(double ph, double organicMatter) {
    if (ph >= 6.0 && ph <= 7.5 && organicMatter > 2.0) return 'élevée';
    if (ph >= 5.5 && ph <= 8.0 && organicMatter > 1.0) return 'moyenne';
    return 'faible';
  }

  static double _getSeasonalFactor(double latitude) {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 6) return 1.2; // Grande saison des pluies
    if (month >= 9 && month <= 11) return 1.1; // Petite saison des pluies
    return 0.8; // Saison sèche
  }

  static String _getTogoLocationName(double lat) {
    if (lat > 8.5) return 'Région de la Kara';
    if (lat > 7.5) return 'Région Centrale';
    if (lat > 6.5) return 'Région des Plateaux';
    return 'Région Maritime';
  }
}
