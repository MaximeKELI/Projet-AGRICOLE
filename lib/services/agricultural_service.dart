import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/agricultural_metrics.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AgriculturalService {
  static const String _baseUrl = 'http://localhost:5000/api';
  static const String _metricsKey = 'agricultural_metrics';

  // Sauvegarder les métriques localement
  Future<void> _saveMetricsLocally(List<AgriculturalMetrics> metrics) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metricsJson = metrics.map((m) => m.toJson()).toList();
      await prefs.setString(_metricsKey, jsonEncode(metricsJson));
    } catch (e) {
      print('Erreur lors de la sauvegarde locale: $e');
    }
  }

  // Charger les métriques depuis le stockage local
  Future<List<AgriculturalMetrics>> _loadMetricsLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metricsString = prefs.getString(_metricsKey);
      if (metricsString != null) {
        final List<dynamic> metricsJson = jsonDecode(metricsString);
        return metricsJson.map((json) => AgriculturalMetrics.fromJson(json)).toList();
      }
    } catch (e) {
      print('Erreur lors du chargement local: $e');
    }
    return [];
  }

  // Obtenir toutes les métriques agricoles
  Future<List<AgriculturalMetrics>> getAgriculturalMetrics(String userId) async {
    try {
      // Essayer d'abord l'API
      final response = await http.get(
        Uri.parse('$_baseUrl/agricultural-metrics/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final metrics = data.map((json) => AgriculturalMetrics.fromJson(json)).toList();
        await _saveMetricsLocally(metrics);
        return metrics;
      }
    } catch (e) {
      print('Erreur API, utilisation des données locales: $e');
    }

    // Fallback vers les données locales
    return await _loadMetricsLocally();
  }

  // Créer une nouvelle métrique agricole
  Future<AgriculturalMetrics> createAgriculturalMetric(AgriculturalMetrics metric) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/agricultural-metrics'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(metric.toJson()),
      );

      if (response.statusCode == 201) {
        final createdMetric = AgriculturalMetrics.fromJson(jsonDecode(response.body));
        
        // Mettre à jour le cache local
        final localMetrics = await _loadMetricsLocally();
        localMetrics.add(createdMetric);
        await _saveMetricsLocally(localMetrics);
        
        return createdMetric;
      }
    } catch (e) {
      print('Erreur lors de la création: $e');
    }

    // Fallback: créer localement
    final localMetrics = await _loadMetricsLocally();
    localMetrics.add(metric);
    await _saveMetricsLocally(localMetrics);
    return metric;
  }

  // Mettre à jour une métrique existante
  Future<AgriculturalMetrics> updateAgriculturalMetric(AgriculturalMetrics metric) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/agricultural-metrics/${metric.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(metric.toJson()),
      );

      if (response.statusCode == 200) {
        final updatedMetric = AgriculturalMetrics.fromJson(jsonDecode(response.body));
        
        // Mettre à jour le cache local
        final localMetrics = await _loadMetricsLocally();
        final index = localMetrics.indexWhere((m) => m.id == metric.id);
        if (index != -1) {
          localMetrics[index] = updatedMetric;
          await _saveMetricsLocally(localMetrics);
        }
        
        return updatedMetric;
      }
    } catch (e) {
      print('Erreur lors de la mise à jour: $e');
    }

    // Fallback: mettre à jour localement
    final localMetrics = await _loadMetricsLocally();
    final index = localMetrics.indexWhere((m) => m.id == metric.id);
    if (index != -1) {
      localMetrics[index] = metric;
      await _saveMetricsLocally(localMetrics);
    }
    return metric;
  }

  // Supprimer une métrique
  Future<void> deleteAgriculturalMetric(String metricId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/agricultural-metrics/$metricId'),
      );

      if (response.statusCode == 200) {
        // Mettre à jour le cache local
        final localMetrics = await _loadMetricsLocally();
        localMetrics.removeWhere((m) => m.id == metricId);
        await _saveMetricsLocally(localMetrics);
      }
    } catch (e) {
      print('Erreur lors de la suppression: $e');
    }
  }

  // Obtenir le résumé du tableau de bord
  Future<DashboardSummary> getDashboardSummary(String userId) async {
    final metrics = await getAgriculturalMetrics(userId);
    return DashboardSummary.fromMetrics(metrics);
  }

  // Obtenir les prédictions de rendement
  Future<Map<String, dynamic>> getYieldPredictions(String cropType, String region) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/agricultural-metrics/predictions?cropType=$cropType&region=$region'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Erreur lors de la prédiction: $e');
    }

    // Fallback: prédiction basique
    return _getBasicYieldPrediction(cropType, region);
  }

  Map<String, dynamic> _getBasicYieldPrediction(String cropType, String region) {
    // Prédictions basiques basées sur les données moyennes du Togo
    final baseYields = {
      'maïs': 2.5, // tonnes/hectare
      'riz': 3.0,
      'arachide': 1.5,
      'manioc': 15.0,
      'igname': 8.0,
      'tomate': 25.0,
      'piment': 20.0,
      'gombo': 15.0,
    };

    final baseYield = baseYields[cropType.toLowerCase()] ?? 2.0;
    final seasonalFactor = _getSeasonalFactor();
    final regionFactor = _getRegionFactor(region);

    final predictedYield = baseYield * seasonalFactor * regionFactor;
    final confidence = 0.75; // 75% de confiance

    return {
      'predictedYield': predictedYield,
      'confidence': confidence,
      'factors': {
        'baseYield': baseYield,
        'seasonalFactor': seasonalFactor,
        'regionFactor': regionFactor,
      },
      'recommendations': _getYieldRecommendations(cropType, predictedYield),
    };
  }

  double _getSeasonalFactor() {
    final month = DateTime.now().month;
    // Facteurs saisonniers pour le Togo
    if (month >= 3 && month <= 6) return 1.2; // Grande saison des pluies
    if (month >= 9 && month <= 11) return 1.1; // Petite saison des pluies
    return 0.8; // Saison sèche
  }

  double _getRegionFactor(String region) {
    // Facteurs régionaux basés sur la fertilité des sols
    final regionFactors = {
      'Maritime': 1.0,
      'Plateaux': 1.1,
      'Centrale': 1.2,
      'Kara': 0.9,
      'Savanes': 0.8,
    };
    return regionFactors[region] ?? 1.0;
  }

  List<String> _getYieldRecommendations(String cropType, double predictedYield) {
    final recommendations = <String>[];

    if (predictedYield < 2.0) {
      recommendations.add('Fertilisation NPK recommandée');
      recommendations.add('Vérifier la qualité des semences');
      recommendations.add('Améliorer la préparation du sol');
    }

    if (cropType.toLowerCase() == 'maïs') {
      recommendations.add('Espacement recommandé: 80cm x 40cm');
      recommendations.add('Irrigation nécessaire pendant la floraison');
    }

    if (cropType.toLowerCase() == 'riz') {
      recommendations.add('Niveau d\'eau: 5-10cm pendant la croissance');
      recommendations.add('Drainage 2 semaines avant récolte');
    }

    return recommendations;
  }

  // Obtenir les alertes agricoles
  Future<List<Map<String, dynamic>>> getAgriculturalAlerts(String userId) async {
    final metrics = await getAgriculturalMetrics(userId);
    final alerts = <Map<String, dynamic>>[];

    for (final metric in metrics) {
      // Alerte si le rendement est faible
      if (metric.yieldEfficiency < 70) {
        alerts.add({
          'type': 'low_yield',
          'severity': 'warning',
          'title': 'Rendement faible détecté',
          'message': 'Le rendement de ${metric.cropType} est ${metric.yieldEfficiency.toStringAsFixed(1)}% des attentes',
          'cropId': metric.id,
          'action': 'Vérifier la fertilisation et l\'irrigation',
        });
      }

      // Alerte si la récolte est proche
      if (metric.daysToHarvest <= 7 && metric.daysToHarvest > 0) {
        alerts.add({
          'type': 'harvest_ready',
          'severity': 'info',
          'title': 'Récolte prête',
          'message': '${metric.cropType} sera prêt à récolter dans ${metric.daysToHarvest} jours',
          'cropId': metric.id,
          'action': 'Préparer la récolte',
        });
      }

      // Alerte si les coûts sont élevés
      if (metric.costPerHectare > 500000) { // 500,000 FCFA/hectare
        alerts.add({
          'type': 'high_cost',
          'severity': 'warning',
          'title': 'Coûts élevés',
          'message': 'Les coûts de ${metric.cropType} sont élevés: ${metric.costPerHectare.toStringAsFixed(0)} FCFA/ha',
          'cropId': metric.id,
          'action': 'Optimiser les intrants',
        });
      }
    }

    return alerts;
  }
}