import 'dart:math';
import 'dart:convert';
import '../models/weather_data.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherService {
  static const String _baseUrl = 'http://localhost:5000/api';
  static const String _weatherKey = 'weather_data';
  static const String _forecastKey = 'weather_forecast';
  static const String _alertsKey = 'weather_alerts';

  // Obtenir les données météo actuelles
  Future<WeatherData> getCurrentWeather(double latitude, double longitude) async {
    try {
      // Essayer d'abord l'API
      final response = await http.get(
        Uri.parse('$_baseUrl/weather/current?lat=$latitude&lon=$longitude'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final weather = WeatherData.fromJson(data);
        await _saveWeatherData(weather);
        return weather;
      }
    } catch (e) {
      print('Erreur API météo, utilisation des données simulées: $e');
    }

    // Fallback: données simulées basées sur la localisation
    return _generateSimulatedWeather(latitude, longitude);
  }

  // Obtenir les prévisions météo
  Future<WeatherForecast> getWeatherForecast(double latitude, double longitude) async {
    try {
      // Essayer d'abord l'API
      final response = await http.get(
        Uri.parse('$_baseUrl/weather/forecast?lat=$latitude&lon=$longitude'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final forecast = WeatherForecast.fromJson(data);
        await _saveForecastData(forecast);
        return forecast;
      }
    } catch (e) {
      print('Erreur API prévisions, génération de données simulées: $e');
    }

    // Fallback: prévisions simulées
    return _generateSimulatedForecast(latitude, longitude);
  }

  // Obtenir les alertes météo
  Future<List<WeatherAlert>> getWeatherAlerts(double latitude, double longitude) async {
    try {
      // Essayer d'abord l'API
      final response = await http.get(
        Uri.parse('$_baseUrl/weather/alerts?lat=$latitude&lon=$longitude'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final alerts = data.map((item) => WeatherAlert.fromJson(item)).toList();
        await _saveAlertsData(alerts);
        return alerts;
      }
    } catch (e) {
      print('Erreur API alertes, génération d\'alertes simulées: $e');
    }

    // Fallback: alertes simulées
    return _generateSimulatedAlerts(latitude, longitude);
  }

  // Obtenir les données météo pour l'agriculture
  Future<Map<String, dynamic>> getAgriculturalWeatherData(double latitude, double longitude) async {
    final currentWeather = await getCurrentWeather(latitude, longitude);
    final forecast = await getWeatherForecast(latitude, longitude);
    final alerts = await getWeatherAlerts(latitude, longitude);

    return {
      'current': currentWeather.toJson(),
      'forecast': forecast.toJson(),
      'alerts': alerts.map((alert) => alert.toJson()).toList(),
      'agriculturalAdvice': _generateAgriculturalAdvice(currentWeather, forecast),
      'irrigationAdvice': _generateIrrigationAdvice(currentWeather, forecast),
      'diseaseRisk': _assessDiseaseRisk(currentWeather, forecast),
      'plantingWindow': _findPlantingWindow(forecast),
      'harvestWindow': _findHarvestWindow(forecast),
    };
  }

  // Générer des données météo simulées réalistes pour le Togo
  WeatherData _generateSimulatedWeather(double latitude, double longitude) {
    final now = DateTime.now();
    final random = Random();
    
    // Déterminer la saison basée sur le mois
    final month = now.month;
    final isRainySeason = (month >= 3 && month <= 6) || (month >= 9 && month <= 11);
    final isDrySeason = month >= 12 || month <= 2;
    
    // Température basée sur la saison et la latitude
    double baseTemp = 25.0;
    if (isRainySeason) baseTemp = 28.0;
    if (isDrySeason) baseTemp = 32.0;
    
    // Ajustement basé sur la latitude (plus chaud au sud)
    baseTemp += (6.0 - latitude) * 0.5;
    
    final temperature = baseTemp + (random.nextDouble() - 0.5) * 6.0;
    
    // Humidité basée sur la saison
    double humidity = 60.0;
    if (isRainySeason) humidity = 75.0 + random.nextDouble() * 15.0;
    if (isDrySeason) humidity = 40.0 + random.nextDouble() * 20.0;
    
    // Pluie basée sur la saison
    double rainfall = 0.0;
    if (isRainySeason) {
      rainfall = random.nextDouble() * 15.0; // 0-15mm
    } else if (month == 7 || month == 8) {
      rainfall = random.nextDouble() * 5.0; // Petite saison des pluies
    }
    
    // Vent
    final windSpeed = 5.0 + random.nextDouble() * 15.0;
    final windDirection = random.nextDouble() * 360.0;
    
    // Pression atmosphérique
    final pressure = 1010.0 + (random.nextDouble() - 0.5) * 20.0;
    
    // UV Index
    final uvIndex = 6.0 + random.nextDouble() * 6.0; // 6-12 pour le Togo
    
    // Condition météo
    String condition = 'partiellement_ensoleillé';
    if (rainfall > 5) condition = 'pluvieux';
    else if (rainfall > 1) condition = 'nuageux';
    else if (humidity > 80) condition = 'humide';
    else if (temperature > 35) condition = 'chaud';
    else if (temperature < 20) condition = 'frais';
    
    return WeatherData(
      id: 'sim_${now.millisecondsSinceEpoch}',
      location: _getLocationName(latitude, longitude),
      latitude: latitude,
      longitude: longitude,
      temperature: temperature,
      humidity: humidity,
      pressure: pressure,
      windSpeed: windSpeed,
      windDirection: windDirection,
      rainfall: rainfall,
      uvIndex: uvIndex,
      condition: condition,
      description: _getWeatherDescription(condition, temperature, rainfall),
      timestamp: now,
    );
  }

  // Générer des prévisions simulées
  WeatherForecast _generateSimulatedForecast(double latitude, double longitude) {
    final dailyForecast = <WeatherData>[];
    final hourlyForecast = <WeatherData>[];
    
    for (int i = 0; i < 7; i++) {
      final date = DateTime.now().add(Duration(days: i));
      final dailyWeather = _generateSimulatedWeather(latitude, longitude);
      dailyForecast.add(dailyWeather.copyWith(
        id: 'forecast_daily_$i',
        timestamp: DateTime(date.year, date.month, date.day, 12),
      ));
    }
    
    for (int i = 0; i < 24; i++) {
      final hour = DateTime.now().add(Duration(hours: i));
      final hourlyWeather = _generateSimulatedWeather(latitude, longitude);
      hourlyForecast.add(hourlyWeather.copyWith(
        id: 'forecast_hourly_$i',
        timestamp: hour,
      ));
    }
    
    return WeatherForecast(
      location: _getLocationName(latitude, longitude),
      dailyForecast: dailyForecast,
      hourlyForecast: hourlyForecast,
      agriculturalRecommendations: _generateAgriculturalRecommendations(dailyForecast),
    );
  }

  // Générer des alertes simulées
  List<WeatherAlert> _generateSimulatedAlerts(double latitude, double longitude) {
    final alerts = <WeatherAlert>[];
    final random = Random();
    
    // 30% de chance d'avoir une alerte
    if (random.nextDouble() < 0.3) {
      final alertTypes = ['pluie_intense', 'vent_fort', 'chaleur_excessive', 'secheresse'];
      final severities = ['info', 'warning', 'critical'];
      
      final type = alertTypes[random.nextInt(alertTypes.length)];
      final severity = severities[random.nextInt(severities.length)];
      
      alerts.add(WeatherAlert(
        id: 'alert_${DateTime.now().millisecondsSinceEpoch}',
        type: type,
        severity: severity,
        title: _getAlertTitle(type),
        message: _getAlertMessage(type, severity),
        location: _getLocationName(latitude, longitude),
        startTime: DateTime.now(),
        endTime: DateTime.now().add(Duration(hours: 6 + random.nextInt(18))),
        recommendations: _getAlertRecommendations(type),
      ));
    }
    
    return alerts;
  }

  // Méthodes utilitaires
  String _getLocationName(double latitude, double longitude) {
    // Approximation basée sur les coordonnées du Togo
    if (latitude >= 6.0 && latitude <= 6.3 && longitude >= 1.0 && longitude <= 1.3) {
      return 'Lomé';
    } else if (latitude >= 8.0 && latitude <= 8.3 && longitude >= 1.0 && longitude <= 1.3) {
      return 'Sokodé';
    } else if (latitude >= 9.0 && latitude <= 9.3 && longitude >= 1.0 && longitude <= 1.3) {
      return 'Kara';
    } else if (latitude >= 7.0 && latitude <= 7.3 && longitude >= 1.0 && longitude <= 1.3) {
      return 'Atakpamé';
    } else if (latitude >= 6.5 && latitude <= 6.8 && longitude >= 0.5 && longitude <= 0.8) {
      return 'Kpalimé';
    } else if (latitude >= 10.0 && latitude <= 10.3 && longitude >= 0.5 && longitude <= 0.8) {
      return 'Dapaong';
    }
    return 'Togo';
  }

  String _getWeatherDescription(String condition, double temperature, double rainfall) {
    if (rainfall > 10) return 'Pluie intense avec ${rainfall.toStringAsFixed(1)}mm';
    if (rainfall > 5) return 'Pluie modérée avec ${rainfall.toStringAsFixed(1)}mm';
    if (rainfall > 1) return 'Légère pluie avec ${rainfall.toStringAsFixed(1)}mm';
    if (temperature > 35) return 'Très chaud, ${temperature.toStringAsFixed(1)}°C';
    if (temperature < 20) return 'Frais, ${temperature.toStringAsFixed(1)}°C';
    return 'Conditions agréables, ${temperature.toStringAsFixed(1)}°C';
  }

  String _getAlertTitle(String type) {
    switch (type) {
      case 'pluie_intense': return 'Alerte Pluie Intense';
      case 'vent_fort': return 'Alerte Vent Fort';
      case 'chaleur_excessive': return 'Alerte Chaleur Excessive';
      case 'secheresse': return 'Alerte Sécheresse';
      default: return 'Alerte Météo';
    }
  }

  String _getAlertMessage(String type, String severity) {
    switch (type) {
      case 'pluie_intense':
        return 'Pluies intenses prévues. Éviter les travaux agricoles en plein air.';
      case 'vent_fort':
        return 'Vents forts attendus. Sécuriser les installations agricoles.';
      case 'chaleur_excessive':
        return 'Températures élevées prévues. Protéger les cultures sensibles.';
      case 'secheresse':
        return 'Période de sécheresse prolongée. Irrigation intensive recommandée.';
      default:
        return 'Conditions météorologiques particulières attendues.';
    }
  }

  List<String> _getAlertRecommendations(String type) {
    switch (type) {
      case 'pluie_intense':
        return [
          'Éviter les travaux de plantation',
          'Protéger les cultures sensibles',
          'Vérifier le drainage des parcelles',
        ];
      case 'vent_fort':
        return [
          'Sécuriser les tuteurs et supports',
          'Éviter l\'application de pesticides',
          'Protéger les jeunes plants',
        ];
      case 'chaleur_excessive':
        return [
          'Augmenter l\'irrigation',
          'Utiliser de l\'ombrage',
          'Arroser tôt le matin ou tard le soir',
        ];
      case 'secheresse':
        return [
          'Irrigation intensive nécessaire',
          'Paillage pour conserver l\'humidité',
          'Choisir des cultures résistantes à la sécheresse',
        ];
      default:
        return ['Surveiller les conditions météorologiques'];
    }
  }

  Map<String, dynamic> _generateAgriculturalRecommendations(List<WeatherData> forecast) {
    final avgTemp = forecast.fold(0.0, (sum, day) => sum + day.temperature) / forecast.length;
    final totalRain = forecast.fold(0.0, (sum, day) => sum + day.rainfall);
    
    return {
      'plantingAdvice': avgTemp > 25 ? 'Favorable pour plantation' : 'Attendre des températures plus élevées',
      'irrigationAdvice': totalRain > 20 ? 'Irrigation réduite' : 'Irrigation intensive nécessaire',
      'harvestAdvice': 'Récolte possible dans 3-5 jours',
      'diseaseRisk': totalRain > 30 ? 'Élevé' : 'Faible',
    };
  }

  Map<String, dynamic> _generateAgriculturalAdvice(WeatherData current, WeatherForecast forecast) {
    return {
      'current': current.agriculturalAdvice,
      'irrigation': current.irrigationAdvice,
      'diseaseRisk': current.diseaseRisk,
      'plantingWindow': forecast.plantingRecommendations,
      'harvestWindow': forecast.harvestRecommendations,
    };
  }

  Map<String, dynamic> _generateIrrigationAdvice(WeatherData current, WeatherForecast forecast) {
    return {
      'current': current.irrigationAdvice,
      'next24h': forecast.hourlyForecast.take(24).map((h) => h.irrigationAdvice).toList(),
      'recommendation': _getIrrigationRecommendation(current, forecast),
    };
  }

  List<String> _assessDiseaseRisk(WeatherData current, WeatherForecast forecast) {
    final risks = <String>[];
    
    if (current.humidity > 80) risks.add('Risque élevé de maladies fongiques');
    if (forecast.totalRainfall > 50) risks.add('Risque de pourriture des racines');
    if (current.temperature > 30 && current.humidity > 70) risks.add('Risque de rouille');
    
    return risks;
  }

  List<String> _findPlantingWindow(WeatherForecast forecast) {
    final windows = <String>[];
    
    for (int i = 0; i < forecast.dailyForecast.length; i++) {
      final day = forecast.dailyForecast[i];
      if (day.isFavorableForPlanting) {
        windows.add('${day.timestamp.day}/${day.timestamp.month}: Favorable');
      }
    }
    
    return windows;
  }

  List<String> _findHarvestWindow(WeatherForecast forecast) {
    final windows = <String>[];
    
    for (int i = 0; i < forecast.dailyForecast.length; i++) {
      final day = forecast.dailyForecast[i];
      if (day.isFavorableForHarvest) {
        windows.add('${day.timestamp.day}/${day.timestamp.month}: Favorable');
      }
    }
    
    return windows;
  }

  String _getIrrigationRecommendation(WeatherData current, WeatherForecast forecast) {
    if (current.rainfall > 5) return 'Pas d\'irrigation nécessaire';
    if (forecast.totalRainfall > 20) return 'Irrigation réduite';
    if (current.humidity < 40) return 'Irrigation intensive recommandée';
    return 'Irrigation modérée';
  }

  // Sauvegarde locale
  Future<void> _saveWeatherData(WeatherData weather) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_weatherKey, jsonEncode(weather.toJson()));
    } catch (e) {
      print('Erreur sauvegarde météo: $e');
    }
  }

  Future<void> _saveForecastData(WeatherForecast forecast) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_forecastKey, jsonEncode(forecast.toJson()));
    } catch (e) {
      print('Erreur sauvegarde prévisions: $e');
    }
  }

  Future<void> _saveAlertsData(List<WeatherAlert> alerts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alertsJson = alerts.map((alert) => alert.toJson()).toList();
      await prefs.setString(_alertsKey, jsonEncode(alertsJson));
    } catch (e) {
      print('Erreur sauvegarde alertes: $e');
    }
  }
}

// Extension pour WeatherData
extension WeatherDataExtension on WeatherData {
  WeatherData copyWith({
    String? id,
    String? location,
    double? latitude,
    double? longitude,
    double? temperature,
    double? humidity,
    double? pressure,
    double? windSpeed,
    double? windDirection,
    double? rainfall,
    double? uvIndex,
    String? condition,
    String? description,
    DateTime? timestamp,
    Map<String, dynamic>? forecast,
  }) {
    return WeatherData(
      id: id ?? this.id,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      pressure: pressure ?? this.pressure,
      windSpeed: windSpeed ?? this.windSpeed,
      windDirection: windDirection ?? this.windDirection,
      rainfall: rainfall ?? this.rainfall,
      uvIndex: uvIndex ?? this.uvIndex,
      condition: condition ?? this.condition,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      forecast: forecast ?? this.forecast,
    );
  }
}
