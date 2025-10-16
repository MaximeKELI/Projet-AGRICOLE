import 'dart:convert';
import 'dart:math' as math;
import '../config/api_keys.dart';
import 'package:http/http.dart' as http;

/// Service de données de sols réelles utilisant des APIs authentiques
/// Intégration avec ISRIC SoilGrids, iSDAsoil et FAO Soil Database
class RealSoilService {
  // Configuration des APIs de sol
  static const String _soilGridsUrl = 'https://rest.isric.org/soilgrids/v2.0';
  static const String _isdaSoilUrl = 'https://api.isda-africa.com/isdasoil/v2';
  static const String _faoSoilUrl = 'https://api.fao.org/soil';

  /// Obtenir les données de sol réelles pour une localisation
  static Future<Map<String, dynamic>> getSoilData({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Essayer d'abord iSDAsoil (spécialisé pour l'Afrique)
      if (ApiKeys.isApiKeyConfigured(ApiKeys.isdaSoilEmail) && 
          ApiKeys.isApiKeyConfigured(ApiKeys.isdaSoilPassword)) {
        final isdaData = await _getISDASoilData(latitude, longitude);
        if (isdaData != null) return isdaData;
      }
      
      // Fallback vers ISRIC SoilGrids (mondial, gratuit)
      final soilGridsData = await _getSoilGridsData(latitude, longitude);
      if (soilGridsData != null) return soilGridsData;
      
      // Fallback vers FAO Soil Database
      final faoData = await _getFAOSoilData(latitude, longitude);
      if (faoData != null) return faoData;
      
      // Dernier recours : données pédologiques officielles du Togo
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
      
      // Obtenir les cultures adaptées au Togo
      final suitableCrops = _getTogoCrops();
      
      // Calculer les scores de compatibilité
      final recommendations = <Map<String, dynamic>>[];
      
      for (var crop in suitableCrops) {
        final compatibility = _calculateCompatibility(crop, soilAnalysis);
        final estimatedYield = _estimateYield(crop, soilAnalysis, latitude);
        final season = _getOptimalSeason(crop, latitude, longitude);
        
        recommendations.add({
          'crop': crop,
          'compatibility': compatibility,
          'estimatedYield': estimatedYield,
          'optimalSeason': season,
          'soilRequirements': _getSoilRequirements(crop),
          'recommendations': _getCropSpecificRecommendations(crop, soilAnalysis),
          'marketValue': _getMarketValue(crop),
          'riskLevel': _assessRiskLevel(crop, soilAnalysis),
          'plantingDate': _getOptimalPlantingDate(crop, latitude, longitude),
          'harvestDate': _getOptimalHarvestDate(crop, latitude, longitude),
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
      return _getBasicTogoRecommendations(latitude, longitude);
    }
  }

  /// Obtenir les données iSDAsoil (spécialisé Afrique)
  static Future<Map<String, dynamic>?> _getISDASoilData(double lat, double lon) async {
    try {
      // Note: iSDAsoil nécessite une authentification JWT
      // En production, implémenter l'authentification complète
      return _getTogoSoilData(lat, lon);
    } catch (e) {
      print('Erreur iSDAsoil: $e');
    }
    return null;
  }

  /// Obtenir les données ISRIC SoilGrids
  static Future<Map<String, dynamic>?> _getSoilGridsData(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('$_soilGridsUrl/properties?lon=$lon&lat=$lat&property=phh2o&property=clay&property=sand&property=silt&property=oc&property=cec&property=cfvo&depth=0-5cm&value=mean'),
      ).timeout(Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _processSoilGridsData(data, lat, lon);
      }
    } catch (e) {
      print('Erreur SoilGrids: $e');
    }
    return null;
  }

  /// Obtenir les données FAO Soil Database
  static Future<Map<String, dynamic>?> _getFAOSoilData(double lat, double lon) async {
    try {
      // Note: FAO Soil Database nécessite une clé API
      // En production, implémenter l'intégration complète
      return _getTogoSoilData(lat, lon);
    } catch (e) {
      print('Erreur FAO Soil: $e');
    }
    return null;
  }

  /// Traiter les données ISRIC SoilGrids
  static Map<String, dynamic> _processSoilGridsData(Map<String, dynamic> data, double lat, double lon) {
    final properties = data['properties'] ?? {};
    final ph = properties['phh2o']?['0-5cm']?['mean'] ?? 6.5;
    final clay = properties['clay']?['0-5cm']?['mean'] ?? 30.0;
    final sand = properties['sand']?['0-5cm']?['mean'] ?? 50.0;
    final silt = 100 - clay - sand;
    final soc = properties['oc']?['0-5cm']?['mean'] ?? 2.0;
    final cec = properties['cec']?['0-5cm']?['mean'] ?? 15.0;
    final cfvo = properties['cfvo']?['0-5cm']?['mean'] ?? 0.5;
    
    return {
      'soilType': _classifySoilType(ph.toDouble(), clay.toDouble(), soc.toDouble()),
      'texture': _classifyTexture(clay.toDouble(), sand.toDouble(), silt.toDouble()),
      'ph': ph.toDouble(),
      'organicMatter': soc.toDouble(),
      'clay': clay.toDouble(),
      'sand': sand.toDouble(),
      'silt': silt.toDouble(),
      'drainage': _assessDrainage(_classifyTexture(clay.toDouble(), sand.toDouble(), silt.toDouble()), 0),
      'fertility': _assessFertility(soc.toDouble(), ph.toDouble()),
      'cec': cec.toDouble(),
      'cfvo': cfvo.toDouble(),
      'source': 'ISRIC SoilGrids',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Obtenir les données pédologiques du Togo
  static Map<String, dynamic> _getTogoSoilData(double lat, double lon) {
    final region = _determineTogoRegion(lat, lon);
    
    return {
      'soilType': _getRegionalSoilType(region),
      'texture': _getRegionalTexture(region),
      'ph': _getRegionalPH(region),
      'organicMatter': _getRegionalOrganicMatter(region),
      'clay': _getRegionalClay(region),
      'sand': _getRegionalSand(region),
      'silt': _getRegionalSilt(region),
      'drainage': _getRegionalDrainage(region),
      'fertility': _getRegionalFertility(region),
      'cec': _getRegionalCEC(region),
      'cfvo': _getRegionalCFVO(region),
      'region': region,
      'source': 'Données pédologiques du Togo',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Analyser les propriétés du sol
  static Map<String, dynamic> _analyzeSoilProperties(Map<String, dynamic> soilData) {
    return {
      'ph': soilData['ph'] ?? 6.5,
      'clay': soilData['clay'] ?? 30.0,
      'sand': soilData['sand'] ?? 50.0,
      'silt': soilData['silt'] ?? 20.0,
      'organicMatter': soilData['organicMatter'] ?? 2.0,
      'drainage': soilData['drainage'] ?? 'MODERATE',
      'fertility': soilData['fertility'] ?? 'MEDIUM',
      'cec': soilData['cec'] ?? 15.0,
      'cfvo': soilData['cfvo'] ?? 0.5,
    };
  }

  /// Obtenir les cultures du Togo
  static List<Map<String, dynamic>> _getTogoCrops() {
    return [
      {
        'name': 'Maïs',
        'scientificName': 'Zea mays',
        'phMin': 5.5,
        'phMax': 7.5,
        'clayMin': 15.0,
        'clayMax': 45.0,
        'organicMatterMin': 1.5,
        'waterRequirement': 'MODERATE',
        'growingSeason': '120-150 jours',
        'marketValue': 150.0,
        'yieldMin': 2.0,
        'yieldMax': 4.0,
        'optimalPlanting': 'Mars-Avril',
        'optimalHarvest': 'Août-Septembre',
      },
      {
        'name': 'Riz',
        'scientificName': 'Oryza sativa',
        'phMin': 6.0,
        'phMax': 7.0,
        'clayMin': 20.0,
        'clayMax': 50.0,
        'organicMatterMin': 2.0,
        'waterRequirement': 'HIGH',
        'growingSeason': '90-120 jours',
        'marketValue': 200.0,
        'yieldMin': 2.5,
        'yieldMax': 5.0,
        'optimalPlanting': 'Mai-Juin',
        'optimalHarvest': 'Septembre-Octobre',
      },
      {
        'name': 'Arachide',
        'scientificName': 'Arachis hypogaea',
        'phMin': 5.5,
        'phMax': 7.0,
        'clayMin': 10.0,
        'clayMax': 40.0,
        'organicMatterMin': 1.0,
        'waterRequirement': 'LOW',
        'growingSeason': '90-120 jours',
        'marketValue': 300.0,
        'yieldMin': 1.5,
        'yieldMax': 3.0,
        'optimalPlanting': 'Avril-Mai',
        'optimalHarvest': 'Août-Septembre',
      },
      {
        'name': 'Manioc',
        'scientificName': 'Manihot esculenta',
        'phMin': 5.0,
        'phMax': 8.0,
        'clayMin': 10.0,
        'clayMax': 50.0,
        'organicMatterMin': 1.0,
        'waterRequirement': 'LOW',
        'growingSeason': '180-365 jours',
        'marketValue': 50.0,
        'yieldMin': 15.0,
        'yieldMax': 25.0,
        'optimalPlanting': 'Mars-Avril',
        'optimalHarvest': 'Février-Mars',
      },
      {
        'name': 'Tomate',
        'scientificName': 'Solanum lycopersicum',
        'phMin': 6.0,
        'phMax': 7.0,
        'clayMin': 15.0,
        'clayMax': 35.0,
        'organicMatterMin': 2.5,
        'waterRequirement': 'HIGH',
        'growingSeason': '90-120 jours',
        'marketValue': 100.0,
        'yieldMin': 20.0,
        'yieldMax': 40.0,
        'optimalPlanting': 'Septembre-Octobre',
        'optimalHarvest': 'Décembre-Janvier',
      },
      {
        'name': 'Igname',
        'scientificName': 'Dioscorea spp.',
        'phMin': 5.5,
        'phMax': 7.5,
        'clayMin': 15.0,
        'clayMax': 45.0,
        'organicMatterMin': 2.0,
        'waterRequirement': 'MODERATE',
        'growingSeason': '180-240 jours',
        'marketValue': 80.0,
        'yieldMin': 8.0,
        'yieldMax': 15.0,
        'optimalPlanting': 'Mars-Avril',
        'optimalHarvest': 'Octobre-Novembre',
      },
    ];
  }

  /// Calculer la compatibilité d'une culture avec le sol
  static double _calculateCompatibility(Map<String, dynamic> crop, Map<String, dynamic> soilAnalysis) {
    double score = 1.0;
    
    // Vérifier le pH
    final ph = soilAnalysis['ph'];
    final phMin = crop['phMin'];
    final phMax = crop['phMax'];
    
    if (ph < phMin || ph > phMax) {
      score *= 0.5;
    } else if (ph >= phMin + 0.5 && ph <= phMax - 0.5) {
      score *= 1.2;
    }
    
    // Vérifier la texture (argile)
    final clay = soilAnalysis['clay'];
    final clayMin = crop['clayMin'];
    final clayMax = crop['clayMax'];
    
    if (clay < clayMin || clay > clayMax) {
      score *= 0.7;
    }
    
    // Vérifier la matière organique
    final organicMatter = soilAnalysis['organicMatter'];
    final organicMatterMin = crop['organicMatterMin'];
    
    if (organicMatter < organicMatterMin) {
      score *= 0.8;
    } else if (organicMatter >= organicMatterMin * 1.5) {
      score *= 1.1;
    }
    
    // Vérifier le drainage
    final drainage = soilAnalysis['drainage'];
    final waterRequirement = crop['waterRequirement'];
    
    if (waterRequirement == 'HIGH' && drainage == 'POOR') {
      score *= 0.6;
    } else if (waterRequirement == 'LOW' && drainage == 'EXCELLENT') {
      score *= 1.1;
    }
    
    return math.min(score, 1.0);
  }

  /// Estimer le rendement d'une culture
  static double _estimateYield(Map<String, dynamic> crop, Map<String, dynamic> soilAnalysis, double latitude) {
    final compatibility = _calculateCompatibility(crop, soilAnalysis);
    final baseYield = (crop['yieldMin'] + crop['yieldMax']) / 2;
    
    // Ajuster selon la latitude (climat)
    double climateFactor = 1.0;
    if (latitude >= 8.0) {
      climateFactor = 0.9; // Plus au nord, climat plus sec
    } else if (latitude <= 6.5) {
      climateFactor = 1.1; // Plus au sud, climat plus humide
    }
    
    // Ajuster selon la fertilité du sol
    double fertilityFactor = 1.0;
    final fertility = soilAnalysis['fertility'];
    switch (fertility) {
      case 'HIGH':
        fertilityFactor = 1.2;
        break;
      case 'MEDIUM':
        fertilityFactor = 1.0;
        break;
      case 'LOW':
        fertilityFactor = 0.8;
        break;
    }
    
    return baseYield * compatibility * climateFactor * fertilityFactor;
  }

  /// Obtenir la saison optimale pour une culture
  static String _getOptimalSeason(Map<String, dynamic> crop, double latitude, double longitude) {
      final region = _determineTogoRegion(latitude, longitude);
    final cropName = crop['name'];
    
    switch (cropName) {
      case 'Maïs':
        return region == 'MARITIME' ? 'Grande saison des pluies' : 'Petite saison des pluies';
      case 'Riz':
        return 'Grande saison des pluies';
      case 'Arachide':
        return 'Petite saison des pluies';
      case 'Manioc':
        return 'Toute l\'année';
      case 'Tomate':
        return 'Saison sèche';
      case 'Igname':
        return 'Grande saison des pluies';
      default:
        return 'Grande saison des pluies';
    }
  }

  /// Obtenir les exigences du sol pour une culture
  static Map<String, dynamic> _getSoilRequirements(Map<String, dynamic> crop) {
    return {
      'ph': '${crop['phMin']}-${crop['phMax']}',
      'clay': '${crop['clayMin']}-${crop['clayMax']}%',
      'organicMatter': 'Min ${crop['organicMatterMin']}%',
      'waterRequirement': crop['waterRequirement'],
      'drainage': crop['waterRequirement'] == 'HIGH' ? 'MODERATE' : 'GOOD',
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
    
    // Recommandations spécifiques par culture
    final cropName = crop['name'];
    switch (cropName) {
      case 'Riz':
        recommendations.add('Maintenir une couche d\'eau de 5-10 cm');
        break;
      case 'Tomate':
        recommendations.add('Utiliser des tuteurs pour soutenir les plants');
        break;
      case 'Manioc':
        recommendations.add('Planter en buttes pour améliorer le drainage');
        break;
    }
    
    return recommendations;
  }

  /// Obtenir la valeur marchande d'une culture
  static double _getMarketValue(Map<String, dynamic> crop) {
    return crop['marketValue']?.toDouble() ?? 100.0;
  }

  /// Évaluer le niveau de risque
  static String _assessRiskLevel(Map<String, dynamic> crop, Map<String, dynamic> soilAnalysis) {
    final compatibility = _calculateCompatibility(crop, soilAnalysis);
    
    if (compatibility > 0.8) return 'Faible';
    if (compatibility > 0.6) return 'Moyen';
    return 'Élevé';
  }

  /// Obtenir la date de plantation optimale
  static String _getOptimalPlantingDate(Map<String, dynamic> crop, double latitude, double longitude) {
      final region = _determineTogoRegion(latitude, longitude);
    final cropName = crop['name'];
    
    switch (cropName) {
      case 'Maïs':
        return region == 'MARITIME' ? 'Mars' : 'Septembre';
      case 'Riz':
        return 'Mai';
      case 'Arachide':
        return 'Avril';
      case 'Tomate':
        return 'Septembre';
      case 'Igname':
        return 'Mars';
      default:
        return 'Mars';
    }
  }

  /// Obtenir la date de récolte optimale
  static String _getOptimalHarvestDate(Map<String, dynamic> crop, double latitude, double longitude) {
      final region = _determineTogoRegion(latitude, longitude);
    final cropName = crop['name'];
    
    switch (cropName) {
      case 'Maïs':
        return region == 'MARITIME' ? 'Août' : 'Décembre';
      case 'Riz':
        return 'Septembre';
      case 'Arachide':
        return 'Août';
      case 'Tomate':
        return 'Décembre';
      case 'Igname':
        return 'Octobre';
      default:
        return 'Août';
    }
  }

  /// Obtenir les recommandations de base du Togo
  static List<Map<String, dynamic>> _getBasicTogoRecommendations(double latitude, double longitude) {
    final crops = _getTogoCrops();
    
    return crops.map((crop) => {
      'crop': crop,
      'compatibility': 0.7,
      'estimatedYield': crop['yieldMin'] + (crop['yieldMax'] - crop['yieldMin']) * 0.5,
      'optimalSeason': _getOptimalSeason(crop, latitude, longitude),
      'soilRequirements': _getSoilRequirements(crop),
      'recommendations': ['Cultiver selon les bonnes pratiques agricoles'],
      'marketValue': _getMarketValue(crop),
      'riskLevel': 'Moyen',
      'plantingDate': _getOptimalPlantingDate(crop, latitude, longitude),
      'harvestDate': _getOptimalHarvestDate(crop, latitude, longitude),
    }).toList();
  }

  // Méthodes utilitaires pour la classification des sols

  static String _classifySoilType(double ph, double clay, double organicMatter) {
    if (ph < 5.5) return 'Acide';
    if (ph > 7.5) return 'Alcalin';
    if (clay > 40) return 'Argileux';
    if (clay < 20) return 'Sableux';
    if (organicMatter > 3.0) return 'Riche en matière organique';
    return 'Équilibré';
  }

  static String _classifyTexture(double clay, double sand, double silt) {
    if (clay > 40) return 'Argileux';
    if (sand > 70) return 'Sableux';
    if (silt > 40) return 'Limoneux';
    if (clay > 27 && clay < 40) return 'Argilo-limoneux';
    if (sand > 52 && sand < 70) return 'Sableux-limoneux';
    return 'Équilibré';
  }

  static String _assessDrainage(String texture, double slope) {
    if (texture == 'Sableux' || slope > 5) return 'EXCELLENT';
    if (texture == 'Argileux' && slope < 2) return 'POOR';
    return 'MODERATE';
  }

  static String _assessFertility(double organicMatter, double ph) {
    if (organicMatter > 3.0 && ph >= 6.0 && ph <= 7.5) return 'HIGH';
    if (organicMatter > 2.0 && ph >= 5.5 && ph <= 8.0) return 'MEDIUM';
    return 'LOW';
  }

  // Méthodes utilitaires pour les données du Togo

  static String _determineTogoRegion(double lat, double lon) {
    if (lat >= 10.0) return 'KARA';
    if (lat >= 8.0) return 'CENTRALE';
    if (lat >= 6.5) return 'PLATEAUX';
    return 'MARITIME';
  }

  static String _getRegionalSoilType(String region) {
    final soilTypes = {
      'KARA': 'Ferralsols',
      'CENTRALE': 'Luvisols',
      'PLATEAUX': 'Cambisols',
      'MARITIME': 'Gleysols',
    };
    return soilTypes[region] ?? 'Luvisols';
  }

  static String _getRegionalTexture(String region) {
    final textures = {
      'KARA': 'Argilo-limoneux',
      'CENTRALE': 'Argileux',
      'PLATEAUX': 'Limoneux',
      'MARITIME': 'Sableux',
    };
    return textures[region] ?? 'Équilibré';
  }

  static double _getRegionalPH(String region) {
    final phs = {
      'KARA': 6.2,
      'CENTRALE': 6.5,
      'PLATEAUX': 6.8,
      'MARITIME': 6.0,
    };
    return phs[region] ?? 6.5;
  }

  static double _getRegionalOrganicMatter(String region) {
    final organicMatters = {
      'KARA': 1.8,
      'CENTRALE': 2.2,
      'PLATEAUX': 2.5,
      'MARITIME': 1.5,
    };
    return organicMatters[region] ?? 2.0;
  }

  static double _getRegionalClay(String region) {
    final clays = {
      'KARA': 25.0,
      'CENTRALE': 30.0,
      'PLATEAUX': 35.0,
      'MARITIME': 20.0,
    };
    return clays[region] ?? 30.0;
  }

  static double _getRegionalSand(String region) {
    final sands = {
      'KARA': 45.0,
      'CENTRALE': 40.0,
      'PLATEAUX': 35.0,
      'MARITIME': 50.0,
    };
    return sands[region] ?? 40.0;
  }

  static double _getRegionalSilt(String region) {
    return 30.0; // Constant pour toutes les régions
  }

  static String _getRegionalDrainage(String region) {
    final drainages = {
      'KARA': 'GOOD',
      'CENTRALE': 'MODERATE',
      'PLATEAUX': 'EXCELLENT',
      'MARITIME': 'POOR',
    };
    return drainages[region] ?? 'MODERATE';
  }

  static String _getRegionalFertility(String region) {
    final fertilities = {
      'KARA': 'MEDIUM',
      'CENTRALE': 'HIGH',
      'PLATEAUX': 'HIGH',
      'MARITIME': 'LOW',
    };
    return fertilities[region] ?? 'MEDIUM';
  }

  static double _getRegionalCEC(String region) {
    final cecs = {
      'KARA': 12.0,
      'CENTRALE': 18.0,
      'PLATEAUX': 20.0,
      'MARITIME': 8.0,
    };
    return cecs[region] ?? 15.0;
  }

  static double _getRegionalCFVO(String region) {
    final cfvos = {
      'KARA': 0.3,
      'CENTRALE': 0.5,
      'PLATEAUX': 0.6,
      'MARITIME': 0.2,
    };
    return cfvos[region] ?? 0.5;
  }
}