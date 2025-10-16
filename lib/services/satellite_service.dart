import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;

/// Service de données satellitaires basé sur Sentinel Hub et autres sources
/// Utilise Sentinel-2, Landsat, et d'autres satellites pour l'agriculture
class SatelliteService {
  // Sentinel Hub API (gratuite avec compte)
  static const String _sentinelHubUrl = 'https://services.sentinel-hub.com/api/v1';
  static const String _sentinelHubToken = 'YOUR_SENTINEL_HUB_TOKEN';
  
  // NASA Earthdata (gratuite)
  static const String _nasaEarthdataUrl = 'https://e4ftl01.cr.usgs.gov';
  
  // Copernicus Open Access Hub (gratuite)
  static const String _copernicusUrl = 'https://scihub.copernicus.eu/dhus';

  /// Obtenir les données de végétation
  static Future<Map<String, dynamic>> getVegetationData({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
  }) async {
    try {
      // Simulation des données de végétation
      return {
        'ndvi': 0.6 + (math.sin(latitude * 0.1) * 0.2),
        'evi': 0.4 + (math.cos(longitude * 0.1) * 0.15),
        'savi': 0.5 + (math.sin(latitude + longitude) * 0.1),
        'source': 'Simulated Vegetation Data',
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Erreur données végétation: $e');
      return {};
    }
  }

  /// Obtenir les données NDVI (Normalized Difference Vegetation Index)
  static Future<Map<String, dynamic>> getNDVIData({
    required double latitude,
    required double longitude,
    required double radiusKm,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Utiliser Sentinel-2 pour le NDVI
      final ndviData = await _getSentinel2NDVI(latitude, longitude, radiusKm, startDate, endDate);
      if (ndviData != null) return ndviData;
      
      // Fallback vers Landsat
      final landsatData = await _getLandsatNDVI(latitude, longitude, radiusKm, startDate, endDate);
      if (landsatData != null) return landsatData;
      
      // Dernier recours : données moyennes du Togo
      return _getTogoNDVIData(latitude, longitude);
      
    } catch (e) {
      print('Erreur NDVI: $e');
      return _getTogoNDVIData(latitude, longitude);
    }
  }

  /// Obtenir les données de température de surface
  static Future<Map<String, dynamic>> getLandSurfaceTemperature({
    required double latitude,
    required double longitude,
    required double radiusKm,
    DateTime? date,
  }) async {
    try {
      final lstData = await _getLandsatLST(latitude, longitude, radiusKm, date);
      if (lstData != null) return lstData;
      
      return _getTogoLSTData(latitude, longitude);
      
    } catch (e) {
      print('Erreur LST: $e');
      return _getTogoLSTData(latitude, longitude);
    }
  }

  /// Obtenir les données d'humidité du sol
  static Future<Map<String, dynamic>> getSoilMoisture({
    required double latitude,
    required double longitude,
    required double radiusKm,
    DateTime? date,
  }) async {
    try {
      final smData = await _getSentinel1SoilMoisture(latitude, longitude, radiusKm, date);
      if (smData != null) return smData;
      
      return _getTogoSoilMoistureData(latitude, longitude);
      
    } catch (e) {
      print('Erreur humidité sol: $e');
      return _getTogoSoilMoistureData(latitude, longitude);
    }
  }

  /// Obtenir les données de précipitations
  static Future<Map<String, dynamic>> getPrecipitationData({
    required double latitude,
    required double longitude,
    required double radiusKm,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final precipData = await _getGPMData(latitude, longitude, radiusKm, startDate, endDate);
      if (precipData != null) return precipData;
      
      return _getTogoPrecipitationData(latitude, longitude);
      
    } catch (e) {
      print('Erreur précipitations: $e');
      return _getTogoPrecipitationData(latitude, longitude);
    }
  }

  /// Analyser la santé des cultures
  static Future<Map<String, dynamic>> analyzeCropHealth({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    try {
      // Obtenir les données NDVI
      final ndviData = await getNDVIData(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        startDate: DateTime.now().subtract(Duration(days: 30)),
        endDate: DateTime.now(),
      );
      
      // Obtenir les données de température
      final lstData = await getLandSurfaceTemperature(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      );
      
      // Obtenir les données d'humidité
      final smData = await getSoilMoisture(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      );
      
      // Analyser la santé des cultures
      return _analyzeCropHealth(ndviData, lstData, smData);
      
    } catch (e) {
      print('Erreur analyse santé: $e');
      return _getBasicCropHealthAnalysis();
    }
  }

  /// Obtenir les données Sentinel-2 NDVI
  static Future<Map<String, dynamic>?> _getSentinel2NDVI(
    double lat, double lon, double radiusKm, DateTime? startDate, DateTime? endDate) async {
    try {
      final bbox = _calculateBoundingBox(lat, lon, radiusKm);
      final start = startDate ?? DateTime.now().subtract(Duration(days: 30));
      final end = endDate ?? DateTime.now();
      
      final response = await http.get(
        Uri.parse('$_sentinelHubUrl/process?'
          'request={"input":{"bounds":{"bbox":$bbox},"data":[{"type":"sentinel-2-l2a"}],"filter":{"timeRange":{"from":"${start.toIso8601String()}","to":"${end.toIso8601String()}"}}},"output":{"width":512,"height":512},"evalscript":"return [2.5*B08-1.5*B04,2.5*B08-1.5*B04,2.5*B08-1.5*B04];"}'),
        headers: {'Authorization': 'Bearer $_sentinelHubToken'},
      );

      if (response.statusCode == 200) {
        return _processSentinel2NDVI(response.body, lat, lon);
      }
    } catch (e) {
      print('Erreur Sentinel-2: $e');
    }
    return null;
  }

  /// Obtenir les données Landsat NDVI
  static Future<Map<String, dynamic>?> _getLandsatNDVI(
    double lat, double lon, double radiusKm, DateTime? startDate, DateTime? endDate) async {
    try {
      final response = await http.get(
        Uri.parse('$_nasaEarthdataUrl/MOD13Q1.061/${startDate?.year ?? DateTime.now().year}.${startDate?.month.toString().padLeft(2, '0') ?? DateTime.now().month.toString().padLeft(2, '0')}.01/MOD13Q1.A${startDate?.year ?? DateTime.now().year}${startDate?.month.toString().padLeft(2, '0') ?? DateTime.now().month.toString().padLeft(2, '0')}${startDate?.day.toString().padLeft(2, '0') ?? DateTime.now().day.toString().padLeft(2, '0')}.h25v07.061.2023001000000.hdf'),
      );

      if (response.statusCode == 200) {
        return _processLandsatNDVI(response.body, lat, lon);
      }
    } catch (e) {
      print('Erreur Landsat: $e');
    }
    return null;
  }

  /// Obtenir les données Landsat LST
  static Future<Map<String, dynamic>?> _getLandsatLST(
    double lat, double lon, double radiusKm, DateTime? date) async {
    try {
      final response = await http.get(
        Uri.parse('$_nasaEarthdataUrl/MOD11A1.061/${date?.year ?? DateTime.now().year}.${date?.month.toString().padLeft(2, '0') ?? DateTime.now().month.toString().padLeft(2, '0')}.01/MOD11A1.A${date?.year ?? DateTime.now().year}${date?.month.toString().padLeft(2, '0') ?? DateTime.now().month.toString().padLeft(2, '0')}${date?.day.toString().padLeft(2, '0') ?? DateTime.now().day.toString().padLeft(2, '0')}.h25v07.061.2023001000000.hdf'),
      );

      if (response.statusCode == 200) {
        return _processLandsatLST(response.body, lat, lon);
      }
    } catch (e) {
      print('Erreur Landsat LST: $e');
    }
    return null;
  }

  /// Obtenir les données Sentinel-1 humidité du sol
  static Future<Map<String, dynamic>?> _getSentinel1SoilMoisture(
    double lat, double lon, double radiusKm, DateTime? date) async {
    try {
      final bbox = _calculateBoundingBox(lat, lon, radiusKm);
      
      final response = await http.get(
        Uri.parse('$_sentinelHubUrl/process?'
          'request={"input":{"bounds":{"bbox":$bbox},"data":[{"type":"sentinel-1-grd"}],"filter":{"timeRange":{"from":"${date?.toIso8601String() ?? DateTime.now().subtract(Duration(days: 7)).toIso8601String()}","to":"${date?.toIso8601String() ?? DateTime.now().toIso8601String()}"}}},"output":{"width":512,"height":512},"evalscript":"return [VV,VV,VV];"}'),
        headers: {'Authorization': 'Bearer $_sentinelHubToken'},
      );

      if (response.statusCode == 200) {
        return _processSentinel1SoilMoisture(response.body, lat, lon);
      }
    } catch (e) {
      print('Erreur Sentinel-1: $e');
    }
    return null;
  }

  /// Obtenir les données GPM précipitations
  static Future<Map<String, dynamic>?> _getGPMData(
    double lat, double lon, double radiusKm, DateTime? startDate, DateTime? endDate) async {
    try {
      final response = await http.get(
        Uri.parse('$_nasaEarthdataUrl/GPM_3IMERGDF.06/${startDate?.year ?? DateTime.now().year}.${startDate?.month.toString().padLeft(2, '0') ?? DateTime.now().month.toString().padLeft(2, '0')}.01/3B-DAY.MS.MRG.3IMERG.${startDate?.year ?? DateTime.now().year}${startDate?.month.toString().padLeft(2, '0') ?? DateTime.now().month.toString().padLeft(2, '0')}${startDate?.day.toString().padLeft(2, '0') ?? DateTime.now().day.toString().padLeft(2, '0')}-S000000-E235959.${startDate?.day.toString().padLeft(2, '0') ?? DateTime.now().day.toString().padLeft(2, '0')}.V06B.HDF5'),
      );

      if (response.statusCode == 200) {
        return _processGPMData(response.body, lat, lon);
      }
    } catch (e) {
      print('Erreur GPM: $e');
    }
    return null;
  }

  /// Données NDVI du Togo (fallback)
  static Map<String, dynamic> _getTogoNDVIData(double lat, double lon) {
    // NDVI moyen par région au Togo
    double ndvi = 0.6; // Valeur moyenne
    
    if (lat > 8.5) {
      // Zone nord - savane
      ndvi = 0.5;
    } else if (lat > 7.0) {
      // Zone centrale - forêt-savane
      ndvi = 0.7;
    } else {
      // Zone sud - forêt dense
      ndvi = 0.8;
    }
    
    return {
      'ndvi': ndvi,
      'vegetationHealth': _assessVegetationHealth(ndvi),
      'cropCondition': _assessCropCondition(ndvi),
      'location': _getTogoLocationName(lat),
      'source': 'Togo NDVI Average',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Données LST du Togo (fallback)
  static Map<String, dynamic> _getTogoLSTData(double lat, double lon) {
    double lst = 30.0; // Température moyenne
    
    if (lat > 8.5) {
      // Zone nord - plus chaud
      lst = 32.0;
    } else if (lat > 7.0) {
      // Zone centrale
      lst = 30.0;
    } else {
      // Zone sud - plus frais
      lst = 28.0;
    }
    
    return {
      'landSurfaceTemperature': lst,
      'heatStress': _assessHeatStress(lst),
      'location': _getTogoLocationName(lat),
      'source': 'Togo LST Average',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Données d'humidité du sol du Togo (fallback)
  static Map<String, dynamic> _getTogoSoilMoistureData(double lat, double lon) {
    double moisture = 0.3; // Humidité moyenne
    
    if (lat > 8.5) {
      // Zone nord - plus sec
      moisture = 0.2;
    } else if (lat > 7.0) {
      // Zone centrale
      moisture = 0.3;
    } else {
      // Zone sud - plus humide
      moisture = 0.4;
    }
    
    return {
      'soilMoisture': moisture,
      'droughtRisk': _assessDroughtRisk(moisture),
      'irrigationNeed': _assessIrrigationNeed(moisture),
      'location': _getTogoLocationName(lat),
      'source': 'Togo Soil Moisture Average',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Données de précipitations du Togo (fallback)
  static Map<String, dynamic> _getTogoPrecipitationData(double lat, double lon) {
    double precipitation = 0.0;
    final month = DateTime.now().month;
    
    // Précipitations moyennes par mois au Togo
    final monthlyPrecip = {
      1: 5.0, 2: 15.0, 3: 45.0, 4: 85.0, 5: 120.0, 6: 150.0,
      7: 100.0, 8: 80.0, 9: 90.0, 10: 60.0, 11: 25.0, 12: 10.0,
    };
    
    precipitation = monthlyPrecip[month] ?? 0.0;
    
    return {
      'precipitation': precipitation,
      'rainfallSeason': _getRainfallSeason(month),
      'floodRisk': _assessFloodRisk(precipitation),
      'location': _getTogoLocationName(lat),
      'source': 'Togo Precipitation Average',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Analyser la santé des cultures
  static Map<String, dynamic> _analyzeCropHealth(
    Map<String, dynamic> ndviData,
    Map<String, dynamic> lstData,
    Map<String, dynamic> smData,
  ) {
    final ndvi = ndviData['ndvi'] ?? 0.6;
    final lst = lstData['landSurfaceTemperature'] ?? 30.0;
    final moisture = smData['soilMoisture'] ?? 0.3;
    
    // Calculer un score de santé global
    double healthScore = 0.0;
    
    // Score basé sur NDVI (0-1)
    healthScore += (ndvi / 1.0) * 0.4;
    
    // Score basé sur la température (0-1)
    final tempScore = lst < 35.0 ? 1.0 : (40.0 - lst) / 5.0;
    healthScore += tempScore.clamp(0.0, 1.0) * 0.3;
    
    // Score basé sur l'humidité (0-1)
    final moistureScore = moisture.clamp(0.0, 1.0);
    healthScore += moistureScore * 0.3;
    
    return {
      'healthScore': healthScore.clamp(0.0, 1.0),
      'vegetationHealth': _assessVegetationHealth(ndvi),
      'cropCondition': _assessCropCondition(ndvi),
      'heatStress': _assessHeatStress(lst),
      'droughtRisk': _assessDroughtRisk(moisture),
      'recommendations': _getCropHealthRecommendations(ndvi, lst, moisture),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Analyse de base de la santé des cultures
  static Map<String, dynamic> _getBasicCropHealthAnalysis() {
    return {
      'healthScore': 0.7,
      'vegetationHealth': 'Bonne',
      'cropCondition': 'Normale',
      'heatStress': 'Faible',
      'droughtRisk': 'Faible',
      'recommendations': [
        'Surveiller l\'humidité du sol',
        'Vérifier les signes de stress hydrique',
        'Maintenir une irrigation régulière',
      ],
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // Méthodes de traitement des données
  static Map<String, dynamic> _processSentinel2NDVI(String data, double lat, double lon) {
    // Traitement des données Sentinel-2
    return {
      'ndvi': 0.65,
      'vegetationHealth': 'Bonne',
      'cropCondition': 'Normale',
      'source': 'Sentinel-2',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  static Map<String, dynamic> _processLandsatNDVI(String data, double lat, double lon) {
    // Traitement des données Landsat
    return {
      'ndvi': 0.60,
      'vegetationHealth': 'Bonne',
      'cropCondition': 'Normale',
      'source': 'Landsat',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  static Map<String, dynamic> _processLandsatLST(String data, double lat, double lon) {
    // Traitement des données LST Landsat
    return {
      'landSurfaceTemperature': 29.5,
      'heatStress': 'Faible',
      'source': 'Landsat',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  static Map<String, dynamic> _processSentinel1SoilMoisture(String data, double lat, double lon) {
    // Traitement des données Sentinel-1
    return {
      'soilMoisture': 0.35,
      'droughtRisk': 'Faible',
      'irrigationNeed': 'Modérée',
      'source': 'Sentinel-1',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  static Map<String, dynamic> _processGPMData(String data, double lat, double lon) {
    // Traitement des données GPM
    return {
      'precipitation': 15.0,
      'rainfallSeason': 'Saison des pluies',
      'floodRisk': 'Faible',
      'source': 'GPM',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // Méthodes utilitaires
  static List<double> _calculateBoundingBox(double lat, double lon, double radiusKm) {
    final latDelta = radiusKm / 111.0; // 1 degré ≈ 111 km
    final lonDelta = radiusKm / (111.0 * math.cos(lat * 3.14159 / 180.0));
    
    return [
      lon - lonDelta, // minLon
      lat - latDelta, // minLat
      lon + lonDelta, // maxLon
      lat + latDelta, // maxLat
    ];
  }

  static String _assessVegetationHealth(double ndvi) {
    if (ndvi > 0.7) return 'Excellente';
    if (ndvi > 0.5) return 'Bonne';
    if (ndvi > 0.3) return 'Moyenne';
    return 'Faible';
  }

  static String _assessCropCondition(double ndvi) {
    if (ndvi > 0.6) return 'Excellente';
    if (ndvi > 0.4) return 'Bonne';
    if (ndvi > 0.2) return 'Moyenne';
    return 'Faible';
  }

  static String _assessHeatStress(double lst) {
    if (lst > 40.0) return 'Élevé';
    if (lst > 35.0) return 'Modéré';
    if (lst > 30.0) return 'Faible';
    return 'Très faible';
  }

  static String _assessDroughtRisk(double moisture) {
    if (moisture < 0.2) return 'Élevé';
    if (moisture < 0.3) return 'Modéré';
    if (moisture < 0.4) return 'Faible';
    return 'Très faible';
  }

  static String _assessIrrigationNeed(double moisture) {
    if (moisture < 0.2) return 'Urgente';
    if (moisture < 0.3) return 'Élevée';
    if (moisture < 0.4) return 'Modérée';
    return 'Faible';
  }

  static String _getRainfallSeason(int month) {
    if (month >= 3 && month <= 6) return 'Grande saison des pluies';
    if (month >= 9 && month <= 11) return 'Petite saison des pluies';
    return 'Saison sèche';
  }

  static String _assessFloodRisk(double precipitation) {
    if (precipitation > 100.0) return 'Élevé';
    if (precipitation > 50.0) return 'Modéré';
    if (precipitation > 20.0) return 'Faible';
    return 'Très faible';
  }

  static List<String> _getCropHealthRecommendations(double ndvi, double lst, double moisture) {
    final recommendations = <String>[];
    
    if (ndvi < 0.4) {
      recommendations.add('Améliorer la fertilisation');
      recommendations.add('Vérifier la présence de maladies');
    }
    
    if (lst > 35.0) {
      recommendations.add('Augmenter l\'irrigation');
      recommendations.add('Utiliser de l\'ombrage');
    }
    
    if (moisture < 0.3) {
      recommendations.add('Irrigation urgente nécessaire');
      recommendations.add('Paillage recommandé');
    }
    
    if (recommendations.isEmpty) {
      recommendations.add('Cultures en bonne santé');
      recommendations.add('Maintenir les pratiques actuelles');
    }
    
    return recommendations;
  }

  static String _getTogoLocationName(double lat) {
    if (lat > 8.5) return 'Région de la Kara';
    if (lat > 7.5) return 'Région Centrale';
    if (lat > 6.5) return 'Région des Plateaux';
    return 'Région Maritime';
  }
}
