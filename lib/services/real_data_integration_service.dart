import 'dart:convert';
import 'real_soil_service.dart';
import 'satellite_service.dart';
import '../config/api_keys.dart';
import 'real_weather_service.dart';
import 'package:http/http.dart' as http;
import 'togo_agricultural_data_service.dart';

/// Service d'intégration des données réelles
/// Combine toutes les sources de données pour une analyse complète
class RealDataIntegrationService {
  
  /// Obtenir une analyse complète pour une localisation
  static Future<Map<String, dynamic>> getCompleteAnalysis({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
  }) async {
    try {
      print('🌍 Début de l\'analyse complète pour: $latitude, $longitude');
      
      // Récupérer toutes les données en parallèle
      final results = await Future.wait([
        _getWeatherData(latitude, longitude),
        _getSoilData(latitude, longitude),
        _getAgriculturalData(latitude, longitude),
        _getSatelliteData(latitude, longitude, radiusKm),
        _getMarketData(latitude, longitude),
        _getHistoricalData(latitude, longitude),
      ]);
      
      final weatherData = results[0] as Map<String, dynamic>;
      final soilData = results[1] as Map<String, dynamic>;
      final agriculturalData = results[2] as Map<String, dynamic>;
      final satelliteData = results[3] as Map<String, dynamic>;
      final marketData = results[4] as Map<String, dynamic>;
      final historicalData = results[5] as Map<String, dynamic>;
      
      // Analyser et combiner les données
      final analysis = _analyzeAndCombineData(
        weatherData,
        soilData,
        agriculturalData,
        satelliteData,
        marketData,
        historicalData,
        latitude,
        longitude,
      );
      
      print('✅ Analyse complète terminée');
      return analysis;
      
    } catch (e) {
      print('❌ Erreur lors de l\'analyse complète: $e');
      return _getFallbackAnalysis(latitude, longitude);
    }
  }

  /// Obtenir les recommandations personnalisées
  static Future<List<Map<String, dynamic>>> getPersonalizedRecommendations({
    required double latitude,
    required double longitude,
    required String userType, // 'FARMER', 'COOPERATIVE', 'INVESTOR', 'RESEARCHER'
    required List<String> interests, // ['CROPS', 'LIVESTOCK', 'MARKETING', 'TECHNOLOGY']
  }) async {
    try {
      final analysis = await getCompleteAnalysis(
        latitude: latitude,
        longitude: longitude,
      );
      
      final recommendations = <Map<String, dynamic>>[];
      
      // Recommandations basées sur le type d'utilisateur
      recommendations.addAll(_getUserTypeRecommendations(userType, analysis));
      
      // Recommandations basées sur les intérêts
      recommendations.addAll(_getInterestBasedRecommendations(interests, analysis));
      
      // Recommandations basées sur l'analyse des données
      recommendations.addAll(_getDataBasedRecommendations(analysis));
      
      // Trier par priorité et pertinence
      recommendations.sort((a, b) {
        final priorityA = _getPriorityValue(a['priority']);
        final priorityB = _getPriorityValue(b['priority']);
        return priorityB.compareTo(priorityA);
      });
      
      return recommendations;
      
    } catch (e) {
      print('❌ Erreur recommandations personnalisées: $e');
      return [];
    }
  }

  /// Obtenir les alertes et notifications
  static Future<List<Map<String, dynamic>>> getAlertsAndNotifications({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final alerts = <Map<String, dynamic>>[];
      
      // Alertes météorologiques
      final weatherAlerts = await RealWeatherService.getWeatherAlerts(
        latitude: latitude,
        longitude: longitude,
      );
      alerts.addAll(weatherAlerts.map((alert) => {
        ...alert,
        'type': 'WEATHER',
        'severity': _mapWeatherSeverity(alert['severity']),
      }));
      
      // Alertes de marché
      final marketAlerts = await _getMarketAlerts(latitude, longitude);
      alerts.addAll(marketAlerts);
      
      // Alertes agricoles
      final agriculturalAlerts = await _getAgriculturalAlerts(latitude, longitude);
      alerts.addAll(agriculturalAlerts);
      
      // Alertes de sol
      final soilAlerts = await _getSoilAlerts(latitude, longitude);
      alerts.addAll(soilAlerts);
      
      // Trier par sévérité et date
      alerts.sort((a, b) {
        final severityA = _getSeverityValue(a['severity']);
        final severityB = _getSeverityValue(b['severity']);
        if (severityA != severityB) return severityB.compareTo(severityA);
        return b['timestamp'].compareTo(a['timestamp']);
      });
      
      return alerts;
      
    } catch (e) {
      print('❌ Erreur alertes: $e');
      return [];
    }
  }

  /// Obtenir le tableau de bord professionnel
  static Future<Map<String, dynamic>> getProfessionalDashboard({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final analysis = await getCompleteAnalysis(
        latitude: latitude,
        longitude: longitude,
      );
      
      return {
        'location': {
          'latitude': latitude,
          'longitude': longitude,
          'region': analysis['region'],
          'country': 'Togo',
        },
        'weather': {
          'current': analysis['weather'],
          'forecast': analysis['weatherForecast'],
          'alerts': analysis['weatherAlerts'],
        },
        'soil': {
          'analysis': analysis['soil'],
          'recommendations': analysis['soilRecommendations'],
        },
        'agriculture': {
          'crops': analysis['cropRecommendations'],
          'market': analysis['marketData'],
          'statistics': analysis['agriculturalStatistics'],
        },
        'satellite': {
          'vegetation': analysis['vegetationIndex'],
          'moisture': analysis['soilMoisture'],
          'temperature': analysis['landSurfaceTemperature'],
        },
        'recommendations': analysis['recommendations'],
        'alerts': analysis['alerts'],
        'lastUpdated': DateTime.now().toIso8601String(),
        'dataQuality': _assessDataQuality(analysis),
        'confidence': _calculateConfidence(analysis),
      };
      
    } catch (e) {
      print('❌ Erreur tableau de bord: $e');
      return _getFallbackDashboard(latitude, longitude);
    }
  }

  // Méthodes privées pour récupérer les données

  static Future<Map<String, dynamic>> _getWeatherData(double lat, double lon) async {
    try {
      final current = await RealWeatherService.getCurrentWeather(
        latitude: lat,
        longitude: lon,
      );
      final forecast = await RealWeatherService.getWeatherForecast(
        latitude: lat,
        longitude: lon,
        days: 7,
      );
      final alerts = await RealWeatherService.getWeatherAlerts(
        latitude: lat,
        longitude: lon,
      );
      
      return {
        'current': current,
        'forecast': forecast,
        'alerts': alerts,
        'source': 'Real Weather Service',
      };
    } catch (e) {
      print('❌ Erreur données météo: $e');
      return {};
    }
  }

  static Future<Map<String, dynamic>> _getSoilData(double lat, double lon) async {
    try {
      final soil = await RealSoilService.getSoilData(
        latitude: lat,
        longitude: lon,
      );
      final recommendations = await RealSoilService.getCropRecommendations(
        latitude: lat,
        longitude: lon,
        soilData: soil,
      );
      
      return {
        'analysis': soil,
        'recommendations': recommendations,
        'source': 'Real Soil Service',
      };
    } catch (e) {
      print('❌ Erreur données sol: $e');
      return {};
    }
  }

  static Future<Map<String, dynamic>> _getAgriculturalData(double lat, double lon) async {
    try {
      final production = await TogoAgriculturalDataService.getProductionData();
      final prices = await TogoAgriculturalDataService.getMarketPrices();
      final statistics = await TogoAgriculturalDataService.getAgriculturalStatistics();
      final recommendations = await TogoAgriculturalDataService.getAgriculturalRecommendations(
        latitude: lat,
        longitude: lon,
        season: _getCurrentSeason(),
      );
      
      return {
        'production': production,
        'prices': prices,
        'statistics': statistics,
        'recommendations': recommendations,
        'source': 'Togo Agricultural Data Service',
      };
    } catch (e) {
      print('❌ Erreur données agricoles: $e');
      return {};
    }
  }

  static Future<Map<String, dynamic>> _getSatelliteData(double lat, double lon, double radius) async {
    try {
      final vegetation = await SatelliteService.getVegetationData(
        latitude: lat,
        longitude: lon,
        radiusKm: radius,
      );
      final moisture = await SatelliteService.getSoilMoisture(
        latitude: lat,
        longitude: lon,
        radiusKm: radius,
      );
      final temperature = await SatelliteService.getLandSurfaceTemperature(
        latitude: lat,
        longitude: lon,
        radiusKm: radius,
      );
      
      return {
        'vegetation': vegetation,
        'moisture': moisture,
        'temperature': temperature,
        'source': 'Satellite Service',
      };
    } catch (e) {
      print('❌ Erreur données satellite: $e');
      return {};
    }
  }

  static Future<Map<String, dynamic>> _getMarketData(double lat, double lon) async {
    try {
      final prices = await TogoAgriculturalDataService.getMarketPrices();
      final production = await TogoAgriculturalDataService.getProductionData();
      
      return {
        'prices': prices,
        'production': production,
        'trends': _analyzeMarketTrends(prices, production),
        'source': 'Market Data Service',
      };
    } catch (e) {
      print('❌ Erreur données marché: $e');
      return {};
    }
  }

  static Future<Map<String, dynamic>> _getHistoricalData(double lat, double lon) async {
    try {
      final weather = await TogoAgriculturalDataService.getHistoricalWeatherData(
        latitude: lat,
        longitude: lon,
        year: DateTime.now().year - 1,
      );
      final production = await TogoAgriculturalDataService.getProductionData(
        year: DateTime.now().year - 1,
      );
      
      return {
        'weather': weather,
        'production': production,
        'trends': _analyzeHistoricalTrends(weather, production),
        'source': 'Historical Data Service',
      };
    } catch (e) {
      print('❌ Erreur données historiques: $e');
      return {};
    }
  }

  // Méthodes d'analyse et de combinaison

  static Map<String, dynamic> _analyzeAndCombineData(
    Map<String, dynamic> weatherData,
    Map<String, dynamic> soilData,
    Map<String, dynamic> agriculturalData,
    Map<String, dynamic> satelliteData,
    Map<String, dynamic> marketData,
    Map<String, dynamic> historicalData,
    double latitude,
    double longitude,
  ) {
    final region = _determineTogoRegion(latitude, longitude);
    final season = _getCurrentSeason();
    
    return {
      'location': {
        'latitude': latitude,
        'longitude': longitude,
        'region': region,
        'country': 'Togo',
        'season': season,
      },
      'weather': weatherData['current'] ?? {},
      'weatherForecast': weatherData['forecast'] ?? [],
      'weatherAlerts': weatherData['alerts'] ?? [],
      'soil': soilData['analysis'] ?? {},
      'soilRecommendations': soilData['recommendations'] ?? [],
      'cropRecommendations': _getCropRecommendations(soilData, weatherData, agriculturalData),
      'marketData': marketData,
      'agriculturalStatistics': agriculturalData['statistics'] ?? {},
      'vegetationIndex': satelliteData['vegetation'] ?? {},
      'soilMoisture': satelliteData['moisture'] ?? {},
      'landSurfaceTemperature': satelliteData['temperature'] ?? {},
      'recommendations': _generateRecommendations(
        weatherData,
        soilData,
        agriculturalData,
        satelliteData,
        marketData,
        region,
        season,
      ),
      'alerts': _generateAlerts(weatherData, soilData, agriculturalData),
      'dataQuality': _assessDataQuality({
        'weather': weatherData,
        'soil': soilData,
        'agricultural': agriculturalData,
        'satellite': satelliteData,
      }),
      'confidence': _calculateConfidence({
        'weather': weatherData,
        'soil': soilData,
        'agricultural': agriculturalData,
        'satellite': satelliteData,
      }),
      'lastUpdated': DateTime.now().toIso8601String(),
      'sources': _getDataSources(weatherData, soilData, agriculturalData, satelliteData),
    };
  }

  static List<Map<String, dynamic>> _getCropRecommendations(
    Map<String, dynamic> soilData,
    Map<String, dynamic> weatherData,
    Map<String, dynamic> agriculturalData,
  ) {
    final recommendations = <Map<String, dynamic>>[];
    
    // Obtenir les recommandations de sol
    final soilRecommendations = soilData['recommendations'] as List? ?? [];
      recommendations.addAll(soilRecommendations.cast<Map<String, dynamic>>());
    
    // Ajouter des recommandations basées sur la météo
    final weather = weatherData['current'] as Map<String, dynamic>? ?? {};
    final season = _getCurrentSeason();
    
    if (season == 'SAISON_DES_PLUIES') {
      recommendations.add({
        'crop': 'Riz',
        'compatibility': 0.9,
        'reason': 'Saison des pluies idéale pour le riz',
        'priority': 'HIGH',
      });
    }
    
    if (weather['temperature'] != null && weather['temperature'] > 25) {
      recommendations.add({
        'crop': 'Tomate',
        'compatibility': 0.8,
        'reason': 'Température favorable pour la tomate',
        'priority': 'MEDIUM',
      });
    }
    
    return recommendations;
  }

  static List<Map<String, dynamic>> _generateRecommendations(
    Map<String, dynamic> weatherData,
    Map<String, dynamic> soilData,
    Map<String, dynamic> agriculturalData,
    Map<String, dynamic> satelliteData,
    Map<String, dynamic> marketData,
    String region,
    String season,
  ) {
    final recommendations = <Map<String, dynamic>>[];
    
    // Recommandations météorologiques
    final weather = weatherData['current'] as Map<String, dynamic>? ?? {};
    if (weather['description']?.toString().toLowerCase().contains('pluie') == true) {
      recommendations.add({
        'type': 'WEATHER',
        'title': 'Préparation aux pluies',
        'description': 'Préparez vos cultures pour les pluies attendues',
        'priority': 'HIGH',
        'action': 'Vérifiez le drainage et protégez les cultures sensibles',
      });
    }
    
    // Recommandations de sol
    final soil = soilData['analysis'] as Map<String, dynamic>? ?? {};
    if (soil['ph'] != null && soil['ph'] < 6.0) {
      recommendations.add({
        'type': 'SOIL',
        'title': 'Amélioration du pH',
        'description': 'Le pH du sol est trop acide',
        'priority': 'MEDIUM',
        'action': 'Ajoutez de la chaux pour augmenter le pH',
      });
    }
    
    // Recommandations de marché
    final prices = marketData['prices'] as Map<String, dynamic>? ?? {};
    if (prices['data'] != null) {
      recommendations.add({
        'type': 'MARKET',
        'title': 'Opportunités de marché',
        'description': 'Analysez les prix actuels pour optimiser vos ventes',
        'priority': 'LOW',
        'action': 'Consultez les prix des marchés locaux',
      });
    }
    
    return recommendations;
  }

  static List<Map<String, dynamic>> _generateAlerts(
    Map<String, dynamic> weatherData,
    Map<String, dynamic> soilData,
    Map<String, dynamic> agriculturalData,
  ) {
    final alerts = <Map<String, dynamic>>[];
    
    // Alertes météorologiques
    final weatherAlerts = weatherData['alerts'] as List? ?? [];
    alerts.addAll(weatherAlerts.map((alert) => {
      ...alert,
      'type': 'WEATHER',
      'severity': _mapWeatherSeverity(alert['severity']),
    }));
    
    // Alertes de sol
    final soil = soilData['analysis'] as Map<String, dynamic>? ?? {};
    if (soil['fertility'] == 'LOW') {
      alerts.add({
        'type': 'SOIL',
        'title': 'Fertilité du sol faible',
        'description': 'La fertilité de votre sol est insuffisante',
        'severity': 'MEDIUM',
        'action': 'Améliorez la fertilité avec des engrais organiques',
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
    
    return alerts;
  }

  // Méthodes utilitaires

  static String _determineTogoRegion(double lat, double lon) {
    if (lat >= 10.0) return 'KARA';
    if (lat >= 8.0) return 'CENTRALE';
    if (lat >= 6.5) return 'PLATEAUX';
    return 'MARITIME';
  }

  static String _getCurrentSeason() {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 6) return 'SAISON_DES_PLUIES';
    if (month >= 9 && month <= 11) return 'PETITE_SAISON_DES_PLUIES';
    return 'SAISON_SECHE';
  }

  static String _mapWeatherSeverity(dynamic severity) {
    if (severity == null) return 'LOW';
    final severityStr = severity.toString().toUpperCase();
    if (severityStr.contains('HIGH') || severityStr.contains('SEVERE')) return 'HIGH';
    if (severityStr.contains('MEDIUM') || severityStr.contains('MODERATE')) return 'MEDIUM';
    return 'LOW';
  }

  static int _getPriorityValue(String? priority) {
    switch (priority?.toUpperCase()) {
      case 'HIGH': return 3;
      case 'MEDIUM': return 2;
      case 'LOW': return 1;
      default: return 0;
    }
  }

  static int _getSeverityValue(String? severity) {
    switch (severity?.toUpperCase()) {
      case 'HIGH': return 3;
      case 'MEDIUM': return 2;
      case 'LOW': return 1;
      default: return 0;
    }
  }

  static Map<String, dynamic> _assessDataQuality(Map<String, dynamic> data) {
    int totalSources = 0;
    int availableSources = 0;
    
    data.forEach((key, value) {
      totalSources++;
      if (value != null && value.isNotEmpty) {
        availableSources++;
      }
    });
    
    final quality = availableSources / totalSources;
    
    return {
      'score': quality,
      'level': quality > 0.8 ? 'EXCELLENT' : quality > 0.6 ? 'GOOD' : quality > 0.4 ? 'FAIR' : 'POOR',
      'availableSources': availableSources,
      'totalSources': totalSources,
    };
  }

  static double _calculateConfidence(Map<String, dynamic> data) {
    double confidence = 0.0;
    int count = 0;
    
    data.forEach((key, value) {
      if (value != null && value.isNotEmpty) {
        confidence += 0.25; // Chaque source ajoute 25%
        count++;
      }
    });
    
    return confidence;
  }

  static List<String> _getDataSources(
    Map<String, dynamic> weatherData,
    Map<String, dynamic> soilData,
    Map<String, dynamic> agriculturalData,
    Map<String, dynamic> satelliteData,
  ) {
    final sources = <String>[];
    
    if (weatherData['source'] != null) sources.add(weatherData['source']);
    if (soilData['source'] != null) sources.add(soilData['source']);
    if (agriculturalData['source'] != null) sources.add(agriculturalData['source']);
    if (satelliteData['source'] != null) sources.add(satelliteData['source']);
    
    return sources;
  }

  static Map<String, dynamic> _analyzeMarketTrends(Map<String, dynamic> prices, Map<String, dynamic> production) {
    return {
      'trend': 'STABLE',
      'analysis': 'Les prix restent stables',
      'recommendation': 'Continuez votre production actuelle',
    };
  }

  static Map<String, dynamic> _analyzeHistoricalTrends(Map<String, dynamic> weather, Map<String, dynamic> production) {
    return {
      'trend': 'POSITIVE',
      'analysis': 'Tendances positives observées',
      'recommendation': 'Maintenez vos pratiques actuelles',
    };
  }

  // Méthodes de fallback

  static Map<String, dynamic> _getFallbackAnalysis(double lat, double lon) {
    return {
      'location': {
        'latitude': lat,
        'longitude': lon,
        'region': _determineTogoRegion(lat, lon),
        'country': 'Togo',
      },
      'weather': _getFallbackWeather(),
      'soil': _getFallbackSoil(),
      'recommendations': _getFallbackRecommendations(),
      'alerts': [],
      'dataQuality': {'score': 0.3, 'level': 'POOR'},
      'confidence': 0.3,
      'lastUpdated': DateTime.now().toIso8601String(),
      'sources': ['Fallback Data'],
    };
  }

  static Map<String, dynamic> _getFallbackDashboard(double lat, double lon) {
    return {
      'location': {
        'latitude': lat,
        'longitude': lon,
        'region': _determineTogoRegion(lat, lon),
        'country': 'Togo',
      },
      'weather': _getFallbackWeather(),
      'soil': _getFallbackSoil(),
      'agriculture': _getFallbackAgriculture(),
      'recommendations': _getFallbackRecommendations(),
      'alerts': [],
      'lastUpdated': DateTime.now().toIso8601String(),
      'dataQuality': {'score': 0.3, 'level': 'POOR'},
      'confidence': 0.3,
    };
  }

  static Map<String, dynamic> _getFallbackWeather() {
    return {
      'temperature': 28.0,
      'description': 'Ciel dégagé',
      'humidity': 70,
      'source': 'Données climatiques du Togo',
    };
  }

  static Map<String, dynamic> _getFallbackSoil() {
    return {
      'ph': 6.5,
      'texture': 'Équilibré',
      'fertility': 'MEDIUM',
      'source': 'Données pédologiques du Togo',
    };
  }

  static Map<String, dynamic> _getFallbackAgriculture() {
    return {
      'crops': _getFallbackCrops(),
      'market': _getFallbackMarket(),
      'statistics': _getFallbackStatistics(),
    };
  }

  static List<Map<String, dynamic>> _getFallbackCrops() {
    return [
      {
        'crop': 'Maïs',
        'compatibility': 0.8,
        'estimatedYield': 3.0,
        'optimalSeason': 'Grande saison des pluies',
      },
      {
        'crop': 'Riz',
        'compatibility': 0.7,
        'estimatedYield': 4.0,
        'optimalSeason': 'Grande saison des pluies',
      },
    ];
  }

  static Map<String, dynamic> _getFallbackMarket() {
    return {
      'mais': {'prix': 150, 'unite': 'FCFA/kg'},
      'riz': {'prix': 200, 'unite': 'FCFA/kg'},
    };
  }

  static Map<String, dynamic> _getFallbackStatistics() {
    return {
      'totalAgriculturalArea': 2400000,
      'totalFarmers': 1200000,
      'agriculturalGDP': 35.0,
    };
  }

  static List<Map<String, dynamic>> _getFallbackRecommendations() {
    return [
      {
        'type': 'GENERAL',
        'title': 'Recommandation générale',
        'description': 'Consultez les données locales pour des recommandations précises',
        'priority': 'LOW',
      },
    ];
  }

  // Méthodes pour les alertes

  static Future<List<Map<String, dynamic>>> _getMarketAlerts(double lat, double lon) async {
    return [];
  }

  static Future<List<Map<String, dynamic>>> _getAgriculturalAlerts(double lat, double lon) async {
    return [];
  }

  static Future<List<Map<String, dynamic>>> _getSoilAlerts(double lat, double lon) async {
    return [];
  }

  // Méthodes pour les recommandations personnalisées

  static List<Map<String, dynamic>> _getUserTypeRecommendations(String userType, Map<String, dynamic> analysis) {
    final recommendations = <Map<String, dynamic>>[];
    
    switch (userType.toUpperCase()) {
      case 'FARMER':
        recommendations.addAll([
          {
            'type': 'CULTURE',
            'title': 'Cultures recommandées',
            'description': 'Consultez les recommandations de cultures pour votre région',
            'priority': 'HIGH',
          },
          {
            'type': 'TECHNIQUE',
            'title': 'Techniques agricoles',
            'description': 'Améliorez vos techniques de culture',
            'priority': 'MEDIUM',
          },
        ]);
        break;
      case 'COOPERATIVE':
        recommendations.addAll([
          {
            'type': 'ORGANISATION',
            'title': 'Gestion de la coopérative',
            'description': 'Optimisez la gestion de votre coopérative',
            'priority': 'HIGH',
          },
          {
            'type': 'MARKETING',
            'title': 'Commercialisation',
            'description': 'Améliorez la commercialisation de vos produits',
            'priority': 'MEDIUM',
          },
        ]);
        break;
      case 'INVESTOR':
        recommendations.addAll([
          {
            'type': 'INVESTMENT',
            'title': 'Opportunités d\'investissement',
            'description': 'Identifiez les opportunités d\'investissement agricole',
            'priority': 'HIGH',
          },
          {
            'type': 'RISK',
            'title': 'Gestion des risques',
            'description': 'Évaluez et gérez les risques d\'investissement',
            'priority': 'MEDIUM',
          },
        ]);
        break;
      case 'RESEARCHER':
        recommendations.addAll([
          {
            'type': 'RESEARCH',
            'title': 'Domaines de recherche',
            'description': 'Identifiez les domaines de recherche prioritaires',
            'priority': 'HIGH',
          },
          {
            'type': 'DATA',
            'title': 'Collecte de données',
            'description': 'Améliorez la collecte et l\'analyse de données',
            'priority': 'MEDIUM',
          },
        ]);
        break;
    }
    
    return recommendations;
  }

  static List<Map<String, dynamic>> _getInterestBasedRecommendations(List<String> interests, Map<String, dynamic> analysis) {
    final recommendations = <Map<String, dynamic>>[];
    
    for (final interest in interests) {
      switch (interest.toUpperCase()) {
        case 'CROPS':
          recommendations.add({
            'type': 'CROPS',
            'title': 'Gestion des cultures',
            'description': 'Optimisez la gestion de vos cultures',
            'priority': 'HIGH',
          });
          break;
        case 'LIVESTOCK':
          recommendations.add({
            'type': 'LIVESTOCK',
            'title': 'Élevage',
            'description': 'Développez votre activité d\'élevage',
            'priority': 'MEDIUM',
          });
          break;
        case 'MARKETING':
          recommendations.add({
            'type': 'MARKETING',
            'title': 'Commercialisation',
            'description': 'Améliorez la commercialisation de vos produits',
            'priority': 'MEDIUM',
          });
          break;
        case 'TECHNOLOGY':
          recommendations.add({
            'type': 'TECHNOLOGY',
            'title': 'Technologie agricole',
            'description': 'Adoptez les nouvelles technologies agricoles',
            'priority': 'LOW',
          });
          break;
      }
    }
    
    return recommendations;
  }

  static List<Map<String, dynamic>> _getDataBasedRecommendations(Map<String, dynamic> analysis) {
    final recommendations = <Map<String, dynamic>>[];
    
    // Recommandations basées sur l'analyse des données
    if (analysis['weather'] != null) {
      recommendations.add({
        'type': 'WEATHER',
        'title': 'Gestion météorologique',
        'description': 'Adaptez vos pratiques aux conditions météorologiques',
        'priority': 'MEDIUM',
      });
    }
    
    if (analysis['soil'] != null) {
      recommendations.add({
        'type': 'SOIL',
        'title': 'Amélioration du sol',
        'description': 'Améliorez la qualité de votre sol',
        'priority': 'HIGH',
      });
    }
    
    return recommendations;
  }
}