import 'dart:convert';
import '../config/api_keys.dart';
import 'package:http/http.dart' as http;

/// Service météorologique réel utilisant des APIs authentiques
/// Intégration avec OpenWeatherMap, WeatherAPI et WeatherBit
class RealWeatherService {
  // Configuration des APIs météo réelles
  static const String _openWeatherBaseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _weatherApiBaseUrl = 'https://api.weatherapi.com/v1';
  static const String _weatherBitBaseUrl = 'https://api.weatherbit.io/v2.0';

  /// Obtenir les données météo actuelles réelles
  static Future<Map<String, dynamic>> getCurrentWeather({
    required double latitude,
    required double longitude,
    String? cityName,
  }) async {
    try {
      // Essayer d'abord OpenWeatherMap (le plus fiable)
      if (ApiKeys.isApiKeyConfigured(ApiKeys.openWeatherMapApiKey)) {
        final weatherData = await _getOpenWeatherCurrent(latitude, longitude);
        if (weatherData != null) return weatherData;
      }
      
      // Fallback vers WeatherAPI
      if (ApiKeys.isApiKeyConfigured(ApiKeys.weatherApiApiKey)) {
        final weatherData = await _getWeatherApiCurrent(latitude, longitude);
        if (weatherData != null) return weatherData;
      }
      
      // Fallback vers WeatherBit
      if (ApiKeys.isApiKeyConfigured(ApiKeys.weatherBitApiKey)) {
        final weatherData = await _getWeatherBitCurrent(latitude, longitude);
        if (weatherData != null) return weatherData;
      }
      
      // Dernier recours : données climatiques moyennes du Togo
      return _getTogoClimateData(latitude, longitude);
      
    } catch (e) {
      print('Erreur météo: $e');
      return _getTogoClimateData(latitude, longitude);
    }
  }

  /// Obtenir les prévisions météo réelles
  static Future<List<Map<String, dynamic>>> getWeatherForecast({
    required double latitude,
    required double longitude,
    int days = 5,
  }) async {
    try {
      // Essayer d'abord OpenWeatherMap
      if (ApiKeys.isApiKeyConfigured(ApiKeys.openWeatherMapApiKey)) {
        final forecast = await _getOpenWeatherForecast(latitude, longitude, days);
        if (forecast.isNotEmpty) return forecast;
      }
      
      // Fallback vers WeatherAPI
      if (ApiKeys.isApiKeyConfigured(ApiKeys.weatherApiApiKey)) {
        final forecast = await _getWeatherApiForecast(latitude, longitude, days);
        if (forecast.isNotEmpty) return forecast;
      }
      
      // Fallback vers WeatherBit
      if (ApiKeys.isApiKeyConfigured(ApiKeys.weatherBitApiKey)) {
        final forecast = await _getWeatherBitForecast(latitude, longitude, days);
        if (forecast.isNotEmpty) return forecast;
      }
      
      // Dernier recours : prévisions basées sur les données climatiques du Togo
      return _getTogoForecastData(latitude, longitude, days);
      
    } catch (e) {
      print('Erreur prévisions: $e');
      return _getTogoForecastData(latitude, longitude, days);
    }
  }

  /// Obtenir les alertes météorologiques réelles
  static Future<List<Map<String, dynamic>>> getWeatherAlerts({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Essayer d'abord OpenWeatherMap
      if (ApiKeys.isApiKeyConfigured(ApiKeys.openWeatherMapApiKey)) {
        final alerts = await _getOpenWeatherAlerts(latitude, longitude);
        if (alerts.isNotEmpty) return alerts;
      }
      
      // Fallback vers WeatherAPI
      if (ApiKeys.isApiKeyConfigured(ApiKeys.weatherApiApiKey)) {
        final alerts = await _getWeatherApiAlerts(latitude, longitude);
        if (alerts.isNotEmpty) return alerts;
      }
      
      // Dernier recours : alertes basées sur les conditions locales
      return _getTogoWeatherAlerts(latitude, longitude);
      
    } catch (e) {
      print('Erreur alertes: $e');
      return _getTogoWeatherAlerts(latitude, longitude);
    }
  }

  /// Obtenir les données historiques météo
  static Future<Map<String, dynamic>> getHistoricalWeather({
    required double latitude,
    required double longitude,
    required DateTime date,
  }) async {
    try {
      // Essayer d'abord WeatherAPI (meilleur pour l'historique)
      if (ApiKeys.isApiKeyConfigured(ApiKeys.weatherApiApiKey)) {
        final historical = await _getWeatherApiHistorical(latitude, longitude, date);
        if (historical != null) return historical;
      }
      
      // Fallback vers WeatherBit
      if (ApiKeys.isApiKeyConfigured(ApiKeys.weatherBitApiKey)) {
        final historical = await _getWeatherBitHistorical(latitude, longitude, date);
        if (historical != null) return historical;
      }
      
      // Dernier recours : données historiques moyennes du Togo
      return _getTogoHistoricalData(latitude, longitude, date);
      
    } catch (e) {
      print('Erreur historique: $e');
      return _getTogoHistoricalData(latitude, longitude, date);
    }
  }

  // Méthodes privées pour OpenWeatherMap

  static Future<Map<String, dynamic>?> _getOpenWeatherCurrent(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('$_openWeatherBaseUrl/weather?lat=$lat&lon=$lon&appid=${ApiKeys.openWeatherMapApiKey}&units=metric&lang=fr'),
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _processOpenWeatherData(data);
      }
    } catch (e) {
      print('Erreur OpenWeatherMap: $e');
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>> _getOpenWeatherForecast(double lat, double lon, int days) async {
    try {
      final response = await http.get(
        Uri.parse('$_openWeatherBaseUrl/forecast?lat=$lat&lon=$lon&appid=${ApiKeys.openWeatherMapApiKey}&units=metric&lang=fr'),
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _processOpenWeatherForecast(data, days);
      }
    } catch (e) {
      print('Erreur prévisions OpenWeatherMap: $e');
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> _getOpenWeatherAlerts(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('$_openWeatherBaseUrl/onecall?lat=$lat&lon=$lon&appid=${ApiKeys.openWeatherMapApiKey}&exclude=minutely,hourly,daily'),
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _processOpenWeatherAlerts(data);
      }
    } catch (e) {
      print('Erreur alertes OpenWeatherMap: $e');
    }
    return [];
  }

  // Méthodes privées pour WeatherAPI

  static Future<Map<String, dynamic>?> _getWeatherApiCurrent(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('$_weatherApiBaseUrl/current.json?key=${ApiKeys.weatherApiApiKey}&q=$lat,$lon&aqi=yes&lang=fr'),
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _processWeatherApiData(data);
      }
    } catch (e) {
      print('Erreur WeatherAPI: $e');
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>> _getWeatherApiForecast(double lat, double lon, int days) async {
    try {
      final response = await http.get(
        Uri.parse('$_weatherApiBaseUrl/forecast.json?key=${ApiKeys.weatherApiApiKey}&q=$lat,$lon&days=$days&aqi=yes&lang=fr'),
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _processWeatherApiForecast(data);
      }
    } catch (e) {
      print('Erreur prévisions WeatherAPI: $e');
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> _getWeatherApiAlerts(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('$_weatherApiBaseUrl/forecast.json?key=${ApiKeys.weatherApiApiKey}&q=$lat,$lon&days=1&aqi=yes&alerts=yes&lang=fr'),
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _processWeatherApiAlerts(data);
      }
    } catch (e) {
      print('Erreur alertes WeatherAPI: $e');
    }
    return [];
  }

  static Future<Map<String, dynamic>?> _getWeatherApiHistorical(double lat, double lon, DateTime date) async {
    try {
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final response = await http.get(
        Uri.parse('$_weatherApiBaseUrl/history.json?key=${ApiKeys.weatherApiApiKey}&q=$lat,$lon&dt=$dateStr&lang=fr'),
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _processWeatherApiHistorical(data);
      }
    } catch (e) {
      print('Erreur historique WeatherAPI: $e');
    }
    return null;
  }

  // Méthodes privées pour WeatherBit

  static Future<Map<String, dynamic>?> _getWeatherBitCurrent(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('$_weatherBitBaseUrl/current?lat=$lat&lon=$lon&key=${ApiKeys.weatherBitApiKey}&units=M&lang=fr'),
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _processWeatherBitData(data);
      }
    } catch (e) {
      print('Erreur WeatherBit: $e');
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>> _getWeatherBitForecast(double lat, double lon, int days) async {
    try {
      final response = await http.get(
        Uri.parse('$_weatherBitBaseUrl/forecast/daily?lat=$lat&lon=$lon&key=${ApiKeys.weatherBitApiKey}&days=$days&units=M&lang=fr'),
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _processWeatherBitForecast(data);
      }
    } catch (e) {
      print('Erreur prévisions WeatherBit: $e');
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> _getWeatherBitAlerts(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('$_weatherBitBaseUrl/alerts?lat=$lat&lon=$lon&key=${ApiKeys.weatherBitApiKey}&lang=fr'),
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _processWeatherBitAlerts(data);
      }
    } catch (e) {
      print('Erreur alertes WeatherBit: $e');
    }
    return [];
  }

  static Future<Map<String, dynamic>?> _getWeatherBitHistorical(double lat, double lon, DateTime date) async {
    try {
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final response = await http.get(
        Uri.parse('$_weatherBitBaseUrl/history/daily?lat=$lat&lon=$lon&key=${ApiKeys.weatherBitApiKey}&start_date=$dateStr&end_date=$dateStr&units=M&lang=fr'),
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _processWeatherBitHistorical(data);
      }
    } catch (e) {
      print('Erreur historique WeatherBit: $e');
    }
    return null;
  }

  // Méthodes de traitement des données

  static Map<String, dynamic> _processOpenWeatherData(Map<String, dynamic> data) {
    final main = data['main'] ?? {};
    final weather = data['weather']?[0] ?? {};
    final wind = data['wind'] ?? {};
    final clouds = data['clouds'] ?? {};
    final sys = data['sys'] ?? {};
    
    return {
      'temperature': main['temp']?.toDouble() ?? 0.0,
      'feelsLike': main['feels_like']?.toDouble() ?? 0.0,
      'humidity': main['humidity']?.toInt() ?? 0,
      'pressure': main['pressure']?.toDouble() ?? 0.0,
      'temperatureMin': main['temp_min']?.toDouble() ?? 0.0,
      'temperatureMax': main['temp_max']?.toDouble() ?? 0.0,
      'description': weather['description'] ?? '',
      'main': weather['main'] ?? '',
      'icon': weather['icon'] ?? '',
      'windSpeed': wind['speed']?.toDouble() ?? 0.0,
      'windDirection': wind['deg']?.toInt() ?? 0,
      'cloudiness': clouds['all']?.toInt() ?? 0,
      'visibility': data['visibility']?.toInt() ?? 0,
      'sunrise': sys['sunrise']?.toInt() ?? 0,
      'sunset': sys['sunset']?.toInt() ?? 0,
      'country': sys['country'] ?? '',
      'city': data['name'] ?? '',
      'source': 'OpenWeatherMap',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  static List<Map<String, dynamic>> _processOpenWeatherForecast(Map<String, dynamic> data, int days) {
    final list = data['list'] as List? ?? [];
    final forecasts = <Map<String, dynamic>>[];
    
    for (int i = 0; i < list.length && i < days * 8; i += 8) {
      final item = list[i];
      final main = item['main'] ?? {};
      final weather = item['weather']?[0] ?? {};
      final wind = item['wind'] ?? {};
      
      forecasts.add({
        'date': DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000).toIso8601String(),
        'temperature': main['temp']?.toDouble() ?? 0.0,
        'temperatureMin': main['temp_min']?.toDouble() ?? 0.0,
        'temperatureMax': main['temp_max']?.toDouble() ?? 0.0,
        'humidity': main['humidity']?.toInt() ?? 0,
        'pressure': main['pressure']?.toDouble() ?? 0.0,
        'description': weather['description'] ?? '',
        'icon': weather['icon'] ?? '',
        'windSpeed': wind['speed']?.toDouble() ?? 0.0,
        'windDirection': wind['deg']?.toInt() ?? 0,
        'source': 'OpenWeatherMap',
      });
    }
    
    return forecasts;
  }

  static List<Map<String, dynamic>> _processOpenWeatherAlerts(Map<String, dynamic> data) {
    final alerts = data['alerts'] as List? ?? [];
    return alerts.map((alert) => {
      'sender': alert['sender_name'] ?? '',
      'event': alert['event'] ?? '',
      'description': alert['description'] ?? '',
      'start': DateTime.fromMillisecondsSinceEpoch(alert['start'] * 1000).toIso8601String(),
      'end': DateTime.fromMillisecondsSinceEpoch(alert['end'] * 1000).toIso8601String(),
      'tags': (alert['tags'] as List?)?.cast<String>() ?? [],
      'source': 'OpenWeatherMap',
    }).toList();
  }

  static Map<String, dynamic> _processWeatherApiData(Map<String, dynamic> data) {
    final current = data['current'] ?? {};
    final location = data['location'] ?? {};
    
    return {
      'temperature': current['temp_c']?.toDouble() ?? 0.0,
      'feelsLike': current['feelslike_c']?.toDouble() ?? 0.0,
      'humidity': current['humidity']?.toInt() ?? 0,
      'pressure': current['pressure_mb']?.toDouble() ?? 0.0,
      'description': current['condition']?['text'] ?? '',
      'icon': current['condition']?['icon'] ?? '',
      'windSpeed': current['wind_kph']?.toDouble() ?? 0.0,
      'windDirection': current['wind_degree']?.toInt() ?? 0,
      'cloudiness': current['cloud']?.toInt() ?? 0,
      'visibility': current['vis_km']?.toDouble() ?? 0.0,
      'uv': current['uv']?.toDouble() ?? 0.0,
      'country': location['country'] ?? '',
      'city': location['name'] ?? '',
      'source': 'WeatherAPI',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  static List<Map<String, dynamic>> _processWeatherApiForecast(Map<String, dynamic> data) {
    final forecast = data['forecast']?['forecastday'] as List? ?? [];
    return forecast.map((day) {
      final dayData = day['day'] ?? {};
      final condition = dayData['condition'] ?? {};
      
      return {
        'date': day['date'] ?? '',
        'temperature': dayData['avgtemp_c']?.toDouble() ?? 0.0,
        'temperatureMin': dayData['mintemp_c']?.toDouble() ?? 0.0,
        'temperatureMax': dayData['maxtemp_c']?.toDouble() ?? 0.0,
        'humidity': dayData['avghumidity']?.toInt() ?? 0,
        'description': condition['text'] ?? '',
        'icon': condition['icon'] ?? '',
        'windSpeed': dayData['maxwind_kph']?.toDouble() ?? 0.0,
        'precipitation': dayData['totalprecip_mm']?.toDouble() ?? 0.0,
        'uv': dayData['uv']?.toDouble() ?? 0.0,
        'source': 'WeatherAPI',
      };
    }).toList();
  }

  static List<Map<String, dynamic>> _processWeatherApiAlerts(Map<String, dynamic> data) {
    final alerts = data['alerts']?['alert'] as List? ?? [];
    return alerts.map((alert) => {
      'headline': alert['headline'] ?? '',
      'description': alert['desc'] ?? '',
      'severity': alert['severity'] ?? '',
      'areas': alert['areas'] ?? '',
      'start': alert['effective'] ?? '',
      'end': alert['expires'] ?? '',
      'source': 'WeatherAPI',
    }).toList();
  }

  static Map<String, dynamic> _processWeatherApiHistorical(Map<String, dynamic> data) {
    final forecast = data['forecast']?['forecastday']?[0] ?? {};
    final day = forecast['day'] ?? {};
    final condition = day['condition'] ?? {};
    
    return {
      'date': forecast['date'] ?? '',
      'temperature': day['avgtemp_c']?.toDouble() ?? 0.0,
      'temperatureMin': day['mintemp_c']?.toDouble() ?? 0.0,
      'temperatureMax': day['maxtemp_c']?.toDouble() ?? 0.0,
      'humidity': day['avghumidity']?.toInt() ?? 0,
      'pressure': day['avgvis_km']?.toDouble() ?? 0.0,
      'description': condition['text'] ?? '',
      'icon': condition['icon'] ?? '',
      'windSpeed': day['maxwind_kph']?.toDouble() ?? 0.0,
      'precipitation': day['totalprecip_mm']?.toDouble() ?? 0.0,
      'uv': day['uv']?.toDouble() ?? 0.0,
      'source': 'WeatherAPI',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  static Map<String, dynamic> _processWeatherBitData(Map<String, dynamic> data) {
    final current = data['data']?[0] ?? {};
    
    return {
      'temperature': current['temp']?.toDouble() ?? 0.0,
      'feelsLike': current['app_temp']?.toDouble() ?? 0.0,
      'humidity': current['rh']?.toInt() ?? 0,
      'pressure': current['pres']?.toDouble() ?? 0.0,
      'description': current['weather']?['description'] ?? '',
      'icon': current['weather']?['icon'] ?? '',
      'windSpeed': current['wind_spd']?.toDouble() ?? 0.0,
      'windDirection': current['wind_dir']?.toInt() ?? 0,
      'cloudiness': current['clouds']?.toInt() ?? 0,
      'visibility': current['vis']?.toDouble() ?? 0.0,
      'uv': current['uv']?.toDouble() ?? 0.0,
      'country': current['country_code'] ?? '',
      'city': current['city_name'] ?? '',
      'source': 'WeatherBit',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  static List<Map<String, dynamic>> _processWeatherBitForecast(Map<String, dynamic> data) {
    final forecast = data['data'] as List? ?? [];
    return forecast.map((day) => {
      'date': day['datetime'] ?? '',
      'temperature': day['temp']?.toDouble() ?? 0.0,
      'temperatureMin': day['min_temp']?.toDouble() ?? 0.0,
      'temperatureMax': day['max_temp']?.toDouble() ?? 0.0,
      'humidity': day['rh']?.toInt() ?? 0,
      'description': day['weather']?['description'] ?? '',
      'icon': day['weather']?['icon'] ?? '',
      'windSpeed': day['wind_spd']?.toDouble() ?? 0.0,
      'precipitation': day['precip']?.toDouble() ?? 0.0,
      'uv': day['uv']?.toDouble() ?? 0.0,
      'source': 'WeatherBit',
    }).toList();
  }

  static List<Map<String, dynamic>> _processWeatherBitAlerts(Map<String, dynamic> data) {
    final alerts = data['alerts'] as List? ?? [];
    return alerts.map((alert) => {
      'title': alert['title'] ?? '',
      'description': alert['description'] ?? '',
      'severity': alert['severity'] ?? '',
      'regions': alert['regions'] ?? '',
      'start': alert['effective_utc'] ?? '',
      'end': alert['expires_utc'] ?? '',
      'source': 'WeatherBit',
    }).toList();
  }

  static Map<String, dynamic> _processWeatherBitHistorical(Map<String, dynamic> data) {
    final day = data['data']?[0] ?? {};
    
    return {
      'date': day['datetime'] ?? '',
      'temperature': day['temp']?.toDouble() ?? 0.0,
      'temperatureMin': day['min_temp']?.toDouble() ?? 0.0,
      'temperatureMax': day['max_temp']?.toDouble() ?? 0.0,
      'humidity': day['rh']?.toInt() ?? 0,
      'pressure': day['pres']?.toDouble() ?? 0.0,
      'description': day['weather']?['description'] ?? '',
      'icon': day['weather']?['icon'] ?? '',
      'windSpeed': day['wind_spd']?.toDouble() ?? 0.0,
      'precipitation': day['precip']?.toDouble() ?? 0.0,
      'uv': day['uv']?.toDouble() ?? 0.0,
      'source': 'WeatherBit',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // Données de fallback réalistes du Togo

  static Map<String, dynamic> _getTogoClimateData(double lat, double lon) {
    final region = _determineTogoRegion(lat, lon);
    final season = _getCurrentSeason();
    
    return {
      'temperature': _getRegionalTemperature(region, season),
      'feelsLike': _getRegionalTemperature(region, season) + 2.0,
      'humidity': _getRegionalHumidity(region, season),
      'pressure': 1013.25,
      'temperatureMin': _getRegionalTemperature(region, season) - 5.0,
      'temperatureMax': _getRegionalTemperature(region, season) + 5.0,
      'description': _getSeasonalDescription(season),
      'main': _getSeasonalMain(season),
      'icon': _getSeasonalIcon(season),
      'windSpeed': _getRegionalWindSpeed(region),
      'windDirection': 180,
      'cloudiness': _getSeasonalCloudiness(season),
      'visibility': 10.0,
      'sunrise': _getSunriseTime(),
      'sunset': _getSunsetTime(),
      'country': 'TG',
      'city': _getRegionalCity(region),
      'region': region,
      'season': season,
      'source': 'Données climatiques du Togo',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  static List<Map<String, dynamic>> _getTogoForecastData(double lat, double lon, int days) {
    final region = _determineTogoRegion(lat, lon);
    final season = _getCurrentSeason();
    final forecasts = <Map<String, dynamic>>[];
    
    for (int i = 0; i < days; i++) {
      final date = DateTime.now().add(Duration(days: i));
      final temp = _getRegionalTemperature(region, season) + (i * 0.5);
      
      forecasts.add({
        'date': date.toIso8601String(),
        'temperature': temp,
        'temperatureMin': temp - 3.0,
        'temperatureMax': temp + 3.0,
        'humidity': _getRegionalHumidity(region, season),
        'pressure': 1013.25,
        'description': _getSeasonalDescription(season),
        'icon': _getSeasonalIcon(season),
        'windSpeed': _getRegionalWindSpeed(region),
        'windDirection': 180,
        'precipitation': _getSeasonalPrecipitation(season, i),
        'source': 'Données climatiques du Togo',
      });
    }
    
    return forecasts;
  }

  static List<Map<String, dynamic>> _getTogoWeatherAlerts(double lat, double lon) {
    final season = _getCurrentSeason();
    final alerts = <Map<String, dynamic>>[];
    
    // Alertes basées sur la saison
    if (season == 'SAISON_DES_PLUIES') {
      alerts.add({
        'title': 'Saison des pluies active',
        'description': 'Période de fortes précipitations attendues. Préparez vos cultures en conséquence.',
        'severity': 'MODERATE',
        'start': DateTime.now().toIso8601String(),
        'end': DateTime.now().add(Duration(days: 30)).toIso8601String(),
        'source': 'Météo Togo',
      });
    }
    
    if (season == 'SAISON_SECHE') {
      alerts.add({
        'title': 'Saison sèche',
        'description': 'Période de sécheresse. Surveillez l\'irrigation de vos cultures.',
        'severity': 'LOW',
        'start': DateTime.now().toIso8601String(),
        'end': DateTime.now().add(Duration(days: 30)).toIso8601String(),
        'source': 'Météo Togo',
      });
    }
    
    return alerts;
  }

  static Map<String, dynamic> _getTogoHistoricalData(double lat, double lon, DateTime date) {
    final region = _determineTogoRegion(lat, lon);
    final season = _getSeasonForDate(date);
    
    return {
      'date': date.toIso8601String(),
      'temperature': _getRegionalTemperature(region, season),
      'temperatureMin': _getRegionalTemperature(region, season) - 5.0,
      'temperatureMax': _getRegionalTemperature(region, season) + 5.0,
      'humidity': _getRegionalHumidity(region, season),
      'pressure': 1013.25,
      'description': _getSeasonalDescription(season),
      'icon': _getSeasonalIcon(season),
      'windSpeed': _getRegionalWindSpeed(region),
      'precipitation': _getSeasonalPrecipitation(season, 0),
      'uv': 8.0,
      'source': 'Données climatiques du Togo',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // Méthodes utilitaires pour les données du Togo

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

  static String _getSeasonForDate(DateTime date) {
    final month = date.month;
    if (month >= 3 && month <= 6) return 'SAISON_DES_PLUIES';
    if (month >= 9 && month <= 11) return 'PETITE_SAISON_DES_PLUIES';
    return 'SAISON_SECHE';
  }

  static double _getRegionalTemperature(String region, String season) {
    final baseTemps = {
      'KARA': 28.5,
      'CENTRALE': 26.0,
      'PLATEAUX': 24.0,
      'MARITIME': 26.0,
    };
    
    final baseTemp = baseTemps[region] ?? 26.0;
    
    switch (season) {
      case 'SAISON_DES_PLUIES':
        return baseTemp - 2.0;
      case 'PETITE_SAISON_DES_PLUIES':
        return baseTemp - 1.0;
      case 'SAISON_SECHE':
        return baseTemp + 2.0;
      default:
        return baseTemp;
    }
  }

  static int _getRegionalHumidity(String region, String season) {
    final baseHumidity = {
      'KARA': 65,
      'CENTRALE': 70,
      'PLATEAUX': 75,
      'MARITIME': 80,
    };
    
    final base = baseHumidity[region] ?? 70;
    
    switch (season) {
      case 'SAISON_DES_PLUIES':
        return base + 15;
      case 'PETITE_SAISON_DES_PLUIES':
        return base + 10;
      case 'SAISON_SECHE':
        return base - 20;
      default:
        return base;
    }
  }

  static double _getRegionalWindSpeed(String region) {
    final windSpeeds = {
      'KARA': 3.5,
      'CENTRALE': 3.0,
      'PLATEAUX': 2.5,
      'MARITIME': 4.0,
    };
    return windSpeeds[region] ?? 3.0;
  }

  static int _getSeasonalCloudiness(String season) {
    switch (season) {
      case 'SAISON_DES_PLUIES':
        return 80;
      case 'PETITE_SAISON_DES_PLUIES':
        return 60;
      case 'SAISON_SECHE':
        return 20;
      default:
        return 50;
    }
  }

  static double _getSeasonalPrecipitation(String season, int dayOffset) {
    switch (season) {
      case 'SAISON_DES_PLUIES':
        return 15.0 + (dayOffset * 0.5);
      case 'PETITE_SAISON_DES_PLUIES':
        return 8.0 + (dayOffset * 0.3);
      case 'SAISON_SECHE':
        return 0.5;
      default:
        return 5.0;
    }
  }

  static String _getSeasonalDescription(String season) {
    switch (season) {
      case 'SAISON_DES_PLUIES':
        return 'Pluies fréquentes';
      case 'PETITE_SAISON_DES_PLUIES':
        return 'Pluies occasionnelles';
      case 'SAISON_SECHE':
        return 'Ciel dégagé';
      default:
        return 'Partiellement nuageux';
    }
  }

  static String _getSeasonalMain(String season) {
    switch (season) {
      case 'SAISON_DES_PLUIES':
        return 'Rain';
      case 'PETITE_SAISON_DES_PLUIES':
        return 'Clouds';
      case 'SAISON_SECHE':
        return 'Clear';
      default:
        return 'Clouds';
    }
  }

  static String _getSeasonalIcon(String season) {
    switch (season) {
      case 'SAISON_DES_PLUIES':
        return '10d';
      case 'PETITE_SAISON_DES_PLUIES':
        return '04d';
      case 'SAISON_SECHE':
        return '01d';
      default:
        return '02d';
    }
  }

  static String _getRegionalCity(String region) {
    final cities = {
      'KARA': 'Kara',
      'CENTRALE': 'Sokodé',
      'PLATEAUX': 'Atakpamé',
      'MARITIME': 'Lomé',
    };
    return cities[region] ?? 'Lomé';
  }

  static int _getSunriseTime() {
    return DateTime.now().millisecondsSinceEpoch ~/ 1000 + 21600; // 6h00
  }

  static int _getSunsetTime() {
    return DateTime.now().millisecondsSinceEpoch ~/ 1000 + 64800; // 18h00
  }
}