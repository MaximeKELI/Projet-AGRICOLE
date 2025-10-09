import 'dart:convert';
import 'real_soil_service.dart';
import 'satellite_service.dart';
import 'isda_soil_service.dart';
import 'real_weather_service.dart';
import 'package:http/http.dart' as http;
import 'togo_agricultural_data_service.dart';

/// Service d'intégration de toutes les données réelles
/// Combine météo, sols, satellites et données agricoles du Togo
class RealDataIntegrationService {
  
  /// Obtenir une analyse complète pour une localisation
  static Future<Map<String, dynamic>> getCompleteAnalysis({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
  }) async {
    try {
      // Obtenir toutes les données en parallèle
      final results = await Future.wait([
        RealWeatherService.getCurrentWeather(
          latitude: latitude,
          longitude: longitude,
        ),
        RealWeatherService.getWeatherForecast(
          latitude: latitude,
          longitude: longitude,
          days: 7,
        ),
        RealWeatherService.getWeatherAlerts(
          latitude: latitude,
          longitude: longitude,
        ),
        _getBestSoilData(
          latitude: latitude,
          longitude: longitude,
        ),
        SatelliteService.getNDVIData(
          latitude: latitude,
          longitude: longitude,
          radiusKm: radiusKm,
        ),
        SatelliteService.getLandSurfaceTemperature(
          latitude: latitude,
          longitude: longitude,
          radiusKm: radiusKm,
        ),
        SatelliteService.getSoilMoisture(
          latitude: latitude,
          longitude: longitude,
          radiusKm: radiusKm,
        ),
        TogoAgriculturalDataService.getProductionData(),
        TogoAgriculturalDataService.getMarketPrices(),
        TogoAgriculturalDataService.getHistoricalWeatherData(
          latitude: latitude,
          longitude: longitude,
          year: DateTime.now().year,
        ),
      ]);

      final weatherData = results[0] as Map<String, dynamic>;
      final forecastData = results[1] as List<Map<String, dynamic>>;
      final alertsData = results[2] as List<Map<String, dynamic>>;
      final soilData = results[3] as Map<String, dynamic>;
      final ndviData = results[4] as Map<String, dynamic>;
      final lstData = results[5] as Map<String, dynamic>;
      final moistureData = results[6] as Map<String, dynamic>;
      final productionData = results[7] as Map<String, dynamic>;
      final marketData = results[8] as Map<String, dynamic>;
      final historicalWeather = results[9] as Map<String, dynamic>;

      // Obtenir les recommandations de cultures
      final cropRecommendations = await RealSoilService.getCropRecommendations(
        latitude: latitude,
        longitude: longitude,
        soilData: soilData,
      );

      // Analyser la santé des cultures
      final cropHealth = await SatelliteService.analyzeCropHealth(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      );

      // Obtenir les recommandations agricoles
      final agriculturalRecommendations = await TogoAgriculturalDataService.getAgriculturalRecommendations(
        latitude: latitude,
        longitude: longitude,
        season: _getCurrentSeason(),
      );

      // Compiler l'analyse complète
      return {
        'location': {
          'latitude': latitude,
          'longitude': longitude,
          'region': _getTogoRegion(latitude),
          'radiusKm': radiusKm,
        },
        'weather': {
          'current': weatherData,
          'forecast': forecastData,
          'alerts': alertsData,
          'historical': historicalWeather,
        },
        'soil': soilData,
        'satellite': {
          'ndvi': ndviData,
          'landSurfaceTemperature': lstData,
          'soilMoisture': moistureData,
          'cropHealth': cropHealth,
        },
        'agriculture': {
          'production': productionData,
          'market': marketData,
          'cropRecommendations': cropRecommendations,
          'recommendations': agriculturalRecommendations,
        },
        'analysis': _generateComprehensiveAnalysis(
          weatherData, soilData, ndviData, lstData, moistureData,
          cropHealth, cropRecommendations, agriculturalRecommendations,
        ),
        'timestamp': DateTime.now().toIso8601String(),
        'dataSources': _getDataSources(),
      };

    } catch (e) {
      print('Erreur analyse complète: $e');
      return _getFallbackAnalysis(latitude, longitude);
    }
  }

  /// Obtenir les recommandations personnalisées
  static Future<List<Map<String, dynamic>>> getPersonalizedRecommendations({
    required double latitude,
    required double longitude,
    required String userProfile,
    required List<String> userCrops,
  }) async {
    try {
      // Obtenir l'analyse complète
      final analysis = await getCompleteAnalysis(
        latitude: latitude,
        longitude: longitude,
      );

      // Générer des recommandations personnalisées
      final recommendations = <Map<String, dynamic>>[];

      // Recommandations basées sur le profil utilisateur
      if (userProfile == 'débutant') {
        recommendations.addAll(_getBeginnerRecommendations(analysis));
      } else if (userProfile == 'expérimenté') {
        recommendations.addAll(_getExperiencedRecommendations(analysis));
      } else {
        recommendations.addAll(_getProfessionalRecommendations(analysis));
      }

      // Recommandations basées sur les cultures de l'utilisateur
      for (String crop in userCrops) {
        recommendations.addAll(_getCropSpecificRecommendations(crop, analysis));
      }

      // Recommandations basées sur les conditions actuelles
      recommendations.addAll(_getConditionBasedRecommendations(analysis));

      // Trier par priorité et impact
      recommendations.sort((a, b) {
        final priorityA = _getPriorityValue(a['priority']);
        final priorityB = _getPriorityValue(b['priority']);
        if (priorityA != priorityB) return priorityB.compareTo(priorityA);
        
        final impactA = _getImpactValue(a['impact']);
        final impactB = _getImpactValue(b['impact']);
        return impactB.compareTo(impactA);
      });

      return recommendations.take(10).toList();

    } catch (e) {
      print('Erreur recommandations personnalisées: $e');
      return _getBasicRecommendations();
    }
  }

  /// Obtenir les alertes agricoles
  static Future<List<Map<String, dynamic>>> getAgriculturalAlerts({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final alerts = <Map<String, dynamic>>[];

      // Alertes météo
      final weatherAlerts = await RealWeatherService.getWeatherAlerts(
        latitude: latitude,
        longitude: longitude,
      );
      alerts.addAll(weatherAlerts.map((alert) => {
        'type': 'weather',
        'severity': alert['severity'],
        'title': alert['title'] ?? 'Alerte météo',
        'message': alert['message'] ?? alert['description'],
        'startTime': alert['startTime'],
        'endTime': alert['endTime'],
        'recommendations': alert['recommendations'] ?? [],
      }));

      // Alertes de santé des cultures
      final cropHealth = await SatelliteService.analyzeCropHealth(
        latitude: latitude,
        longitude: longitude,
        radiusKm: 5.0,
      );
      
      if (cropHealth['healthScore'] < 0.5) {
        alerts.add({
          'type': 'crop_health',
          'severity': 'high',
          'title': 'Santé des cultures dégradée',
          'message': 'Les cultures montrent des signes de stress. Action recommandée.',
          'recommendations': cropHealth['recommendations'] ?? [],
        });
      }

      // Alertes de sécheresse
      final soilMoisture = await SatelliteService.getSoilMoisture(
        latitude: latitude,
        longitude: longitude,
        radiusKm: 5.0,
      );
      
      if (soilMoisture['droughtRisk'] == 'Élevé') {
        alerts.add({
          'type': 'drought',
          'severity': 'high',
          'title': 'Risque de sécheresse',
          'message': 'L\'humidité du sol est faible. Irrigation recommandée.',
          'recommendations': [
            'Augmenter la fréquence d\'irrigation',
            'Utiliser du paillage pour conserver l\'humidité',
            'Surveiller les signes de stress hydrique',
          ],
        });
      }

      // Alertes de température
      final lst = await SatelliteService.getLandSurfaceTemperature(
        latitude: latitude,
        longitude: longitude,
        radiusKm: 5.0,
      );
      
      if (lst['heatStress'] == 'Élevé') {
        alerts.add({
          'type': 'heat_stress',
          'severity': 'medium',
          'title': 'Stress thermique',
          'message': 'Les températures élevées peuvent affecter les cultures.',
          'recommendations': [
            'Augmenter l\'irrigation',
            'Utiliser de l\'ombrage si possible',
            'Surveiller les signes de stress thermique',
          ],
        });
      }

      return alerts;

    } catch (e) {
      print('Erreur alertes agricoles: $e');
      return [];
    }
  }

  /// Générer une analyse complète
  static Map<String, dynamic> _generateComprehensiveAnalysis(
    Map<String, dynamic> weatherData,
    Map<String, dynamic> soilData,
    Map<String, dynamic> ndviData,
    Map<String, dynamic> lstData,
    Map<String, dynamic> moistureData,
    Map<String, dynamic> cropHealth,
    List<Map<String, dynamic>> cropRecommendations,
    List<Map<String, dynamic>> agriculturalRecommendations,
  ) {
    // Calculer un score de santé global
    double healthScore = 0.0;
    int factors = 0;

    // Facteur météo (25%)
    final weatherScore = _calculateWeatherScore(weatherData);
    healthScore += weatherScore * 0.25;
    factors++;

    // Facteur sol (25%)
    final soilScore = _calculateSoilScore(soilData);
    healthScore += soilScore * 0.25;
    factors++;

    // Facteur végétation (25%)
    final vegetationScore = _calculateVegetationScore(ndviData, cropHealth);
    healthScore += vegetationScore * 0.25;
    factors++;

    // Facteur humidité (25%)
    final moistureScore = _calculateMoistureScore(moistureData);
    healthScore += moistureScore * 0.25;
    factors++;

    final overallHealthScore = factors > 0 ? healthScore / factors : 0.0;

    return {
      'overallHealthScore': overallHealthScore,
      'healthStatus': _getHealthStatus(overallHealthScore),
      'weatherScore': weatherScore,
      'soilScore': soilScore,
      'vegetationScore': vegetationScore,
      'moistureScore': moistureScore,
      'topCrops': cropRecommendations.take(5).toList(),
      'keyRecommendations': agriculturalRecommendations.take(3).toList(),
      'riskFactors': _identifyRiskFactors(weatherData, soilData, moistureData, lstData),
      'opportunities': _identifyOpportunities(cropRecommendations, weatherData),
    };
  }

  // Méthodes de calcul des scores
  static double _calculateWeatherScore(Map<String, dynamic> weatherData) {
    double score = 0.5; // Score de base
    
    final temp = weatherData['temperature'] ?? 25.0;
    final humidity = weatherData['humidity'] ?? 60.0;
    final rainfall = weatherData['rainfall'] ?? 0.0;
    
    // Score basé sur la température (optimal: 20-30°C)
    if (temp >= 20.0 && temp <= 30.0) {
      score += 0.3;
    } else if (temp >= 15.0 && temp <= 35.0) {
      score += 0.2;
    }
    
    // Score basé sur l'humidité (optimal: 60-80%)
    if (humidity >= 60.0 && humidity <= 80.0) {
      score += 0.2;
    } else if (humidity >= 40.0 && humidity <= 90.0) {
      score += 0.1;
    }
    
    return score.clamp(0.0, 1.0);
  }

  static double _calculateSoilScore(Map<String, dynamic> soilData) {
    double score = 0.5; // Score de base
    
    final ph = soilData['ph'] ?? 6.5;
    final organicMatter = soilData['organicMatter'] ?? 2.0;
    final fertility = soilData['fertility'] ?? 'medium';
    
    // Score basé sur le pH (optimal: 6.0-7.5)
    if (ph >= 6.0 && ph <= 7.5) {
      score += 0.3;
    } else if (ph >= 5.5 && ph <= 8.0) {
      score += 0.2;
    }
    
    // Score basé sur la matière organique
    if (organicMatter >= 3.0) {
      score += 0.2;
    } else if (organicMatter >= 2.0) {
      score += 0.1;
    }
    
    // Score basé sur la fertilité
    if (fertility == 'élevée') {
      score += 0.2;
    } else if (fertility == 'moyenne') {
      score += 0.1;
    }
    
    return score.clamp(0.0, 1.0);
  }

  static double _calculateVegetationScore(Map<String, dynamic> ndviData, Map<String, dynamic> cropHealth) {
    double score = 0.5; // Score de base
    
    final ndvi = ndviData['ndvi'] ?? 0.6;
    final healthScore = cropHealth['healthScore'] ?? 0.7;
    
    // Score basé sur NDVI
    if (ndvi >= 0.7) {
      score += 0.3;
    } else if (ndvi >= 0.5) {
      score += 0.2;
    } else if (ndvi >= 0.3) {
      score += 0.1;
    }
    
    // Score basé sur la santé des cultures
    score += healthScore * 0.2;
    
    return score.clamp(0.0, 1.0);
  }

  static double _calculateMoistureScore(Map<String, dynamic> moistureData) {
    double score = 0.5; // Score de base
    
    final moisture = moistureData['soilMoisture'] ?? 0.3;
    final droughtRisk = moistureData['droughtRisk'] ?? 'Faible';
    
    // Score basé sur l'humidité du sol
    if (moisture >= 0.4) {
      score += 0.3;
    } else if (moisture >= 0.3) {
      score += 0.2;
    } else if (moisture >= 0.2) {
      score += 0.1;
    }
    
    // Score basé sur le risque de sécheresse
    if (droughtRisk == 'Très faible') {
      score += 0.2;
    } else if (droughtRisk == 'Faible') {
      score += 0.1;
    }
    
    return score.clamp(0.0, 1.0);
  }

  // Méthodes utilitaires
  static String _getHealthStatus(double score) {
    if (score >= 0.8) return 'Excellente';
    if (score >= 0.6) return 'Bonne';
    if (score >= 0.4) return 'Moyenne';
    return 'Faible';
  }

  static List<String> _identifyRiskFactors(
    Map<String, dynamic> weatherData,
    Map<String, dynamic> soilData,
    Map<String, dynamic> moistureData,
    Map<String, dynamic> lstData,
  ) {
    final risks = <String>[];
    
    final temp = weatherData['temperature'] ?? 25.0;
    final humidity = weatherData['humidity'] ?? 60.0;
    final moisture = moistureData['soilMoisture'] ?? 0.3;
    final lst = lstData['landSurfaceTemperature'] ?? 30.0;
    
    if (temp > 35.0) risks.add('Températures élevées');
    if (temp < 15.0) risks.add('Températures basses');
    if (humidity < 40.0) risks.add('Humidité faible');
    if (moisture < 0.2) risks.add('Sécheresse');
    if (lst > 40.0) risks.add('Stress thermique');
    
    return risks;
  }

  static List<String> _identifyOpportunities(
    List<Map<String, dynamic>> cropRecommendations,
    Map<String, dynamic> weatherData,
  ) {
    final opportunities = <String>[];
    
    if (cropRecommendations.isNotEmpty) {
      final topCrop = cropRecommendations.first;
      opportunities.add('Culture recommandée: ${topCrop['crop']}');
      opportunities.add('Rendement estimé: ${topCrop['estimatedYield']} tonnes/ha');
    }
    
    final temp = weatherData['temperature'] ?? 25.0;
    if (temp >= 20.0 && temp <= 30.0) {
      opportunities.add('Conditions météo optimales');
    }
    
    return opportunities;
  }

  static String _getCurrentSeason() {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 6) return 'grande_saison';
    if (month >= 9 && month <= 11) return 'petite_saison';
    return 'saison_seche';
  }

  static String _getTogoRegion(double latitude) {
    if (latitude > 8.5) return 'Kara';
    if (latitude > 7.5) return 'Centrale';
    if (latitude > 6.5) return 'Plateaux';
    return 'Maritime';
  }

  static List<String> _getDataSources() {
    return [
      'OpenWeatherMap',
      'WeatherAPI',
      'WeatherBit',
      'ISRIC SoilGrids',
      'SolGRID',
      'FAO',
      'Sentinel Hub',
      'Landsat',
      'GPM',
      'Ministère de l\'Agriculture du Togo',
    ];
  }

  // Méthodes de recommandations
  static List<Map<String, dynamic>> _getBeginnerRecommendations(Map<String, dynamic> analysis) {
    return [
      {
        'type': 'general',
        'title': 'Commencez par des cultures faciles',
        'description': 'Choisissez des cultures résistantes comme le manioc ou l\'igname.',
        'priority': 'high',
        'impact': 'Élevé',
        'effort': 'Faible',
      },
      {
        'type': 'soil',
        'title': 'Améliorez votre sol',
        'description': 'Ajoutez du compost pour enrichir votre sol.',
        'priority': 'high',
        'impact': 'Élevé',
        'effort': 'Moyen',
      },
    ];
  }

  static List<Map<String, dynamic>> _getExperiencedRecommendations(Map<String, dynamic> analysis) {
    return [
      {
        'type': 'optimization',
        'title': 'Optimisez vos rendements',
        'description': 'Utilisez des techniques avancées pour maximiser vos rendements.',
        'priority': 'high',
        'impact': 'Élevé',
        'effort': 'Élevé',
      },
    ];
  }

  static List<Map<String, dynamic>> _getProfessionalRecommendations(Map<String, dynamic> analysis) {
    return [
      {
        'type': 'technology',
        'title': 'Intégrez la technologie',
        'description': 'Utilisez des capteurs IoT et l\'IA pour optimiser vos cultures.',
        'priority': 'high',
        'impact': 'Très élevé',
        'effort': 'Très élevé',
      },
    ];
  }

  static List<Map<String, dynamic>> _getCropSpecificRecommendations(String crop, Map<String, dynamic> analysis) {
    return [
      {
        'type': 'crop_specific',
        'title': 'Optimisation pour $crop',
        'description': 'Recommandations spécifiques pour la culture du $crop.',
        'priority': 'medium',
        'impact': 'Moyen',
        'effort': 'Moyen',
      },
    ];
  }

  static List<Map<String, dynamic>> _getConditionBasedRecommendations(Map<String, dynamic> analysis) {
    return [
      {
        'type': 'conditions',
        'title': 'Adaptation aux conditions',
        'description': 'Adaptez vos pratiques aux conditions actuelles.',
        'priority': 'medium',
        'impact': 'Moyen',
        'effort': 'Faible',
      },
    ];
  }

  static List<Map<String, dynamic>> _getBasicRecommendations() {
    return [
      {
        'type': 'general',
        'title': 'Recommandation générale',
        'description': 'Surveillez régulièrement vos cultures.',
        'priority': 'medium',
        'impact': 'Moyen',
        'effort': 'Faible',
      },
    ];
  }

  static int _getPriorityValue(String priority) {
    switch (priority.toLowerCase()) {
      case 'high': return 3;
      case 'medium': return 2;
      case 'low': return 1;
      default: return 2;
    }
  }

  static int _getImpactValue(String impact) {
    switch (impact.toLowerCase()) {
      case 'très élevé': return 4;
      case 'élevé': return 3;
      case 'moyen': return 2;
      case 'faible': return 1;
      default: return 2;
    }
  }

  static Map<String, dynamic> _getFallbackAnalysis(double latitude, double longitude) {
    return {
      'location': {
        'latitude': latitude,
        'longitude': longitude,
        'region': _getTogoRegion(latitude),
      },
      'analysis': {
        'overallHealthScore': 0.7,
        'healthStatus': 'Bonne',
        'riskFactors': ['Données limitées'],
        'opportunities': ['Surveillance recommandée'],
      },
      'timestamp': DateTime.now().toIso8601String(),
      'dataSources': ['Fallback Data'],
    };
  }

  /// Obtient les meilleures données de sol disponibles
  static Future<Map<String, dynamic>?> _getBestSoilData({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Priorité à iSDAsoil pour l'Afrique
      final isdaData = await IsdaSoilService.getSoilData(
        latitude: latitude,
        longitude: longitude,
      );
      
      if (isdaData != null) {
        print('Données de sol iSDAsoil récupérées');
        return isdaData;
      }
      
      // Fallback vers le service de sol générique
      return await RealSoilService.getSoilData(
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      print('Erreur données de sol: $e');
      return null;
    }
  }
}
