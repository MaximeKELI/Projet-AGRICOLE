import 'dart:math';
import 'dart:async';

class AnalyticsData {
  final String id;
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final String source;

  AnalyticsData({
    required this.id,
    required this.type,
    required this.data,
    required this.timestamp,
    required this.source,
  });
}

class PredictionResult {
  final String type;
  final double confidence;
  final Map<String, dynamic> prediction;
  final DateTime timestamp;
  final String description;

  PredictionResult({
    required this.type,
    required this.confidence,
    required this.prediction,
    required this.timestamp,
    required this.description,
  });
}

class AnalyticsService {
  static final List<AnalyticsData> _data = [];
  static final StreamController<AnalyticsData> _dataController = StreamController<AnalyticsData>.broadcast();
  static final StreamController<PredictionResult> _predictionController = StreamController<PredictionResult>.broadcast();

  // Streams publics
  static Stream<AnalyticsData> get dataStream => _dataController.stream;
  static Stream<PredictionResult> get predictionStream => _predictionController.stream;

  // Enregistrer des données d'analytics
  static void trackEvent({
    required String type,
    required Map<String, dynamic> data,
    String source = 'app',
  }) {
    final analyticsData = AnalyticsData(
      id: 'analytics_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      data: data,
      timestamp: DateTime.now(),
      source: source,
    );

    _data.add(analyticsData);
    _dataController.add(analyticsData);
  }

  // Analyser les performances agricoles
  static Future<Map<String, dynamic>> analyzeAgriculturalPerformance({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Simulation d'analyse des performances
    await Future.delayed(const Duration(seconds: 2));

    final random = Random();
    
    return {
      'yieldEfficiency': 0.85 + random.nextDouble() * 0.15,
      'costEfficiency': 0.78 + random.nextDouble() * 0.22,
      'profitMargin': 0.65 + random.nextDouble() * 0.35,
      'cropRotationScore': 0.72 + random.nextDouble() * 0.28,
      'waterUsageEfficiency': 0.68 + random.nextDouble() * 0.32,
      'fertilizerEfficiency': 0.75 + random.nextDouble() * 0.25,
      'pestControlScore': 0.80 + random.nextDouble() * 0.20,
      'overallScore': 0.76 + random.nextDouble() * 0.24,
      'recommendations': [
        'Augmenter la rotation des cultures pour améliorer la fertilité du sol',
        'Optimiser l\'utilisation de l\'eau avec un système d\'irrigation goutte à goutte',
        'Réduire l\'utilisation de pesticides en favorisant les méthodes biologiques',
        'Diversifier les cultures pour réduire les risques',
      ],
      'trends': {
        'yield': 'increasing',
        'costs': 'decreasing',
        'profit': 'increasing',
        'efficiency': 'stable',
      },
    };
  }

  // Prédire les rendements futurs
  static Future<PredictionResult> predictYield({
    required String cropType,
    required double area,
    required String region,
    required Map<String, dynamic> conditions,
  }) async {
    // Simulation de prédiction IA
    await Future.delayed(const Duration(seconds: 3));

    final random = Random();
    final baseYield = _getBaseYield(cropType);
    final weatherFactor = _calculateWeatherFactor(conditions);
    final soilFactor = _calculateSoilFactor(region);
    final managementFactor = 0.8 + random.nextDouble() * 0.2;

    final predictedYield = baseYield * area * weatherFactor * soilFactor * managementFactor;
    final confidence = 0.75 + random.nextDouble() * 0.2;

    final prediction = PredictionResult(
      type: 'yield_prediction',
      confidence: confidence,
      prediction: {
        'predictedYield': predictedYield,
        'confidence': confidence,
        'factors': {
          'weather': weatherFactor,
          'soil': soilFactor,
          'management': managementFactor,
        },
        'recommendations': _getYieldRecommendations(cropType, conditions),
        'riskFactors': _getRiskFactors(conditions),
      },
      timestamp: DateTime.now(),
      description: 'Prédiction de rendement pour $cropType sur ${area}ha en $region',
    );

    _predictionController.add(prediction);
    return prediction;
  }

  // Prédire les prix du marché
  static Future<PredictionResult> predictMarketPrice({
    required String productId,
    required String region,
    required int daysAhead,
  }) async {
    // Simulation de prédiction de prix
    await Future.delayed(const Duration(seconds: 2));

    final random = Random();
    final basePrice = 200000.0 + random.nextDouble() * 100000.0;
    final trendFactor = 0.95 + random.nextDouble() * 0.1;
    final seasonalFactor = _calculateSeasonalFactor(DateTime.now(), productId);
    final demandFactor = 0.9 + random.nextDouble() * 0.2;

    final predictedPrice = basePrice * trendFactor * seasonalFactor * demandFactor;
    final confidence = 0.70 + random.nextDouble() * 0.25;

    final prediction = PredictionResult(
      type: 'price_prediction',
      confidence: confidence,
      prediction: {
        'predictedPrice': predictedPrice,
        'currentPrice': basePrice,
        'priceChange': ((predictedPrice - basePrice) / basePrice) * 100,
        'confidence': confidence,
        'factors': {
          'trend': trendFactor,
          'seasonal': seasonalFactor,
          'demand': demandFactor,
        },
        'recommendations': _getPriceRecommendations(predictedPrice, basePrice),
      },
      timestamp: DateTime.now(),
      description: 'Prédiction de prix pour $productId en $region dans $daysAhead jours',
    );

    _predictionController.add(prediction);
    return prediction;
  }

  // Analyser les tendances de vente
  static Future<Map<String, dynamic>> analyzeSalesTrends({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Simulation d'analyse des tendances
    await Future.delayed(const Duration(seconds: 2));

    final random = Random();
    
    return {
      'totalSales': 2500000.0 + random.nextDouble() * 1000000.0,
      'growthRate': 0.15 + random.nextDouble() * 0.1,
      'topProducts': [
        {'name': 'Riz de Casamance', 'sales': 850000.0, 'growth': 0.22},
        {'name': 'Tomates de Niayes', 'sales': 650000.0, 'growth': 0.18},
        {'name': 'Mangues de Kédougou', 'sales': 450000.0, 'growth': 0.25},
        {'name': 'Arachides', 'sales': 350000.0, 'growth': 0.12},
        {'name': 'Maïs', 'sales': 200000.0, 'growth': 0.08},
      ],
      'topRegions': [
        {'name': 'Dakar', 'sales': 1200000.0, 'percentage': 0.45},
        {'name': 'Thiès', 'sales': 600000.0, 'percentage': 0.22},
        {'name': 'Kaolack', 'sales': 400000.0, 'percentage': 0.15},
        {'name': 'Saint-Louis', 'sales': 300000.0, 'percentage': 0.11},
        {'name': 'Ziguinchor', 'sales': 200000.0, 'percentage': 0.07},
      ],
      'seasonalPatterns': {
        'Q1': 0.22, // Jan-Mar
        'Q2': 0.18, // Avr-Jun
        'Q3': 0.25, // Jul-Sep
        'Q4': 0.35, // Oct-Déc
      },
      'customerSegments': {
        'individuals': 0.40,
        'restaurants': 0.25,
        'exporters': 0.20,
        'processors': 0.15,
      },
      'recommendations': [
        'Augmenter la production de riz en Q4 pour profiter de la demande élevée',
        'Développer le marché des restaurants pour les tomates',
        'Explorer de nouveaux marchés d\'exportation pour les mangues',
        'Optimiser la logistique pour réduire les coûts de livraison',
      ],
    };
  }

  // Analyser la satisfaction client
  static Future<Map<String, dynamic>> analyzeCustomerSatisfaction({
    required String userId,
  }) async {
    // Simulation d'analyse de satisfaction
    await Future.delayed(const Duration(seconds: 1));

    final random = Random();
    
    return {
      'overallSatisfaction': 4.2 + random.nextDouble() * 0.6,
      'deliverySatisfaction': 4.0 + random.nextDouble() * 0.8,
      'productQuality': 4.5 + random.nextDouble() * 0.4,
      'customerService': 4.1 + random.nextDouble() * 0.6,
      'priceSatisfaction': 3.8 + random.nextDouble() * 0.8,
      'npsScore': 65 + random.nextInt(20), // Net Promoter Score
      'feedback': [
        'Produits de très bonne qualité',
        'Livraison rapide et fiable',
        'Prix compétitifs',
        'Service client réactif',
        'Interface utilisateur intuitive',
      ],
      'improvementAreas': [
        'Réduire les délais de livraison',
        'Améliorer la communication sur les retards',
        'Diversifier les méthodes de paiement',
        'Optimiser l\'emballage des produits',
      ],
    };
  }

  // Obtenir des recommandations personnalisées
  static Future<List<Map<String, dynamic>>> getPersonalizedRecommendations({
    required String userId,
  }) async {
    // Simulation de recommandations personnalisées
    await Future.delayed(const Duration(seconds: 2));

    final random = Random();
    
    return [
      {
        'type': 'crop_optimization',
        'title': 'Optimiser la rotation des cultures',
        'description': 'Basé sur vos données, nous recommandons de planter du maïs après le riz pour améliorer la fertilité du sol.',
        'priority': 'high',
        'impact': 'Augmentation de 15% du rendement',
        'effort': 'medium',
        'timeline': '2-3 semaines',
      },
      {
        'type': 'market_opportunity',
        'title': 'Nouveau marché pour les tomates',
        'description': 'Les prix des tomates sont en hausse de 20% cette semaine. C\'est le moment idéal pour vendre.',
        'priority': 'high',
        'impact': 'Revenus supplémentaires de 150,000 FCFA',
        'effort': 'low',
        'timeline': '1 semaine',
      },
      {
        'type': 'cost_reduction',
        'title': 'Optimiser l\'utilisation des engrais',
        'description': 'Réduire l\'utilisation d\'engrais de 20% sans impact sur le rendement grâce à une application ciblée.',
        'priority': 'medium',
        'impact': 'Économies de 50,000 FCFA par hectare',
        'effort': 'medium',
        'timeline': '1-2 semaines',
      },
      {
        'type': 'certification',
        'title': 'Obtenir la certification bio',
        'description': 'Vos pratiques agricoles sont déjà conformes aux standards bio. Obtenez la certification pour augmenter vos prix de vente.',
        'priority': 'medium',
        'impact': 'Augmentation des prix de 30%',
        'effort': 'high',
        'timeline': '2-3 mois',
      },
    ];
  }

  // Obtenir le rendement de base par type de culture
  static double _getBaseYield(String cropType) {
    switch (cropType.toLowerCase()) {
      case 'riz':
        return 3.5; // tonnes/hectare
      case 'maïs':
        return 4.0;
      case 'tomates':
        return 25.0;
      case 'mangues':
        return 8.0;
      case 'arachides':
        return 1.5;
      default:
        return 2.0;
    }
  }

  // Calculer le facteur météo
  static double _calculateWeatherFactor(Map<String, dynamic> conditions) {
    final temperature = conditions['temperature'] ?? 25.0;
    final humidity = conditions['humidity'] ?? 60.0;
    final rainfall = conditions['rainfall'] ?? 100.0;

    double factor = 1.0;
    
    // Facteur température (optimal: 20-30°C)
    if (temperature >= 20 && temperature <= 30) {
      factor *= 1.0;
    } else if (temperature < 20 || temperature > 35) {
      factor *= 0.7;
    } else {
      factor *= 0.9;
    }

    // Facteur humidité (optimal: 60-80%)
    if (humidity >= 60 && humidity <= 80) {
      factor *= 1.0;
    } else if (humidity < 40 || humidity > 90) {
      factor *= 0.8;
    } else {
      factor *= 0.95;
    }

    // Facteur pluviométrie (optimal: 100-200mm/mois)
    if (rainfall >= 100 && rainfall <= 200) {
      factor *= 1.0;
    } else if (rainfall < 50 || rainfall > 300) {
      factor *= 0.6;
    } else {
      factor *= 0.9;
    }

    return factor;
  }

  // Calculer le facteur sol
  static double _calculateSoilFactor(String region) {
    switch (region.toLowerCase()) {
      case 'casamance':
        return 1.2; // Sols fertiles
      case 'niayes':
        return 1.1; // Sols sablo-limoneux
      case 'thies':
        return 1.0; // Sols moyens
      case 'kaolack':
        return 0.9; // Sols plus pauvres
      default:
        return 1.0;
    }
  }

  // Calculer le facteur saisonnier
  static double _calculateSeasonalFactor(DateTime date, String productId) {
    final month = date.month;
    
    switch (productId.toLowerCase()) {
      case 'riz':
        return month >= 10 && month <= 12 ? 1.2 : 1.0; // Meilleur en fin d'année
      case 'tomates':
        return month >= 3 && month <= 6 ? 1.3 : 0.8; // Meilleur au printemps
      case 'mangues':
        return month >= 4 && month <= 7 ? 1.4 : 0.6; // Meilleur en été
      case 'arachides':
        return month >= 9 && month <= 11 ? 1.1 : 1.0; // Meilleur en automne
      default:
        return 1.0;
    }
  }

  // Obtenir les recommandations de rendement
  static List<String> _getYieldRecommendations(String cropType, Map<String, dynamic> conditions) {
    final recommendations = <String>[];
    
    if (conditions['temperature'] < 20) {
      recommendations.add('Utiliser des serres pour maintenir la température optimale');
    }
    
    if (conditions['humidity'] < 50) {
      recommendations.add('Augmenter l\'irrigation pour maintenir l\'humidité du sol');
    }
    
    if (conditions['rainfall'] < 100) {
      recommendations.add('Planifier l\'irrigation supplémentaire pendant la saison sèche');
    }

    recommendations.add('Utiliser des engrais organiques pour améliorer la fertilité du sol');
    recommendations.add('Pratiquer la rotation des cultures pour éviter l\'épuisement du sol');

    return recommendations;
  }

  // Obtenir les facteurs de risque
  static List<String> _getRiskFactors(Map<String, dynamic> conditions) {
    final risks = <String>[];
    
    if (conditions['temperature'] > 35) {
      risks.add('Risque de stress thermique élevé');
    }
    
    if (conditions['humidity'] > 85) {
      risks.add('Risque de maladies fongiques élevé');
    }
    
    if (conditions['rainfall'] > 250) {
      risks.add('Risque d\'inondation et de pourriture des racines');
    }

    return risks;
  }

  // Obtenir les recommandations de prix
  static List<String> _getPriceRecommendations(double predictedPrice, double currentPrice) {
    final recommendations = <String>[];
    final priceChange = ((predictedPrice - currentPrice) / currentPrice) * 100;
    
    if (priceChange > 10) {
      recommendations.add('Prix en forte hausse - Vendre maintenant pour maximiser les profits');
    } else if (priceChange > 5) {
      recommendations.add('Prix en hausse modérée - Considérer la vente dans les 2-3 semaines');
    } else if (priceChange < -10) {
      recommendations.add('Prix en forte baisse - Attendre une reprise ou stocker');
    } else if (priceChange < -5) {
      recommendations.add('Prix en baisse modérée - Surveiller les tendances du marché');
    } else {
      recommendations.add('Prix stable - Maintenir la stratégie actuelle');
    }

    return recommendations;
  }

  // Obtenir les statistiques globales
  static Map<String, dynamic> getGlobalStatistics() {
    return {
      'totalEvents': _data.length,
      'eventTypes': _data.map((e) => e.type).toSet().length,
      'dataPoints': _data.length,
      'lastUpdate': _data.isNotEmpty ? _data.last.timestamp : null,
      'topEventTypes': _getTopEventTypes(),
    };
  }

  // Obtenir les types d'événements les plus fréquents
  static List<Map<String, dynamic>> _getTopEventTypes() {
    final typeCounts = <String, int>{};
    for (var data in _data) {
      typeCounts[data.type] = (typeCounts[data.type] ?? 0) + 1;
    }

    final sortedTypes = typeCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedTypes.take(5).map((entry) => {
      'type': entry.key,
      'count': entry.value,
      'percentage': (entry.value / _data.length * 100).toStringAsFixed(1),
    }).toList();
  }

  // Nettoyer les données anciennes
  static void cleanupOldData({Duration maxAge = const Duration(days: 30)}) {
    final cutoffDate = DateTime.now().subtract(maxAge);
    _data.removeWhere((data) => data.timestamp.isBefore(cutoffDate));
  }
}
