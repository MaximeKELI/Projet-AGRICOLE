import 'dart:async';
import 'dart:convert';
import 'real_weather_service.dart';
import 'package:http/http.dart' as http;

class WeatherData {
  final String location;
  final double temperature;
  final double humidity;
  final double windSpeed;
  final String windDirection;
  final double pressure;
  final double visibility;
  final String condition;
  final String description;
  final double uvIndex;
  final double rainfall;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  WeatherData({
    required this.location,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.pressure,
    required this.visibility,
    required this.condition,
    required this.description,
    required this.uvIndex,
    required this.rainfall,
    required this.timestamp,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'location': location,
    'temperature': temperature,
    'humidity': humidity,
    'windSpeed': windSpeed,
    'windDirection': windDirection,
    'pressure': pressure,
    'visibility': visibility,
    'condition': condition,
    'description': description,
    'uvIndex': uvIndex,
    'rainfall': rainfall,
    'timestamp': timestamp.toIso8601String(),
    'metadata': metadata,
  };

  factory WeatherData.fromJson(Map<String, dynamic> json) => WeatherData(
    location: json['location'],
    temperature: json['temperature'].toDouble(),
    humidity: json['humidity'].toDouble(),
    windSpeed: json['windSpeed'].toDouble(),
    windDirection: json['windDirection'],
    pressure: json['pressure'].toDouble(),
    visibility: json['visibility'].toDouble(),
    condition: json['condition'],
    description: json['description'],
    uvIndex: json['uvIndex'].toDouble(),
    rainfall: json['rainfall'].toDouble(),
    timestamp: DateTime.parse(json['timestamp']),
    metadata: json['metadata'],
  );
}

class WeatherForecast {
  final String location;
  final DateTime date;
  final double minTemperature;
  final double maxTemperature;
  final double humidity;
  final double windSpeed;
  final String condition;
  final String description;
  final double rainfall;
  final double uvIndex;
  final Map<String, dynamic>? metadata;

  WeatherForecast({
    required this.location,
    required this.date,
    required this.minTemperature,
    required this.maxTemperature,
    required this.humidity,
    required this.windSpeed,
    required this.condition,
    required this.description,
    required this.rainfall,
    required this.uvIndex,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'location': location,
    'date': date.toIso8601String(),
    'minTemperature': minTemperature,
    'maxTemperature': maxTemperature,
    'humidity': humidity,
    'windSpeed': windSpeed,
    'condition': condition,
    'description': description,
    'rainfall': rainfall,
    'uvIndex': uvIndex,
    'metadata': metadata,
  };

  factory WeatherForecast.fromJson(Map<String, dynamic> json) => WeatherForecast(
    location: json['location'],
    date: DateTime.parse(json['date']),
    minTemperature: json['minTemperature'].toDouble(),
    maxTemperature: json['maxTemperature'].toDouble(),
    humidity: json['humidity'].toDouble(),
    windSpeed: json['windSpeed'].toDouble(),
    condition: json['condition'],
    description: json['description'],
    rainfall: json['rainfall'].toDouble(),
    uvIndex: json['uvIndex'].toDouble(),
    metadata: json['metadata'],
  );
}

class WeatherAlert {
  final String id;
  final String location;
  final String type; // storm, flood, drought, heat_wave, cold_wave
  final String severity; // low, medium, high, extreme
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final List<String> recommendations;
  final Map<String, dynamic>? metadata;

  WeatherAlert({
    required this.id,
    required this.location,
    required this.type,
    required this.severity,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    this.recommendations = const [],
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'location': location,
    'type': type,
    'severity': severity,
    'title': title,
    'description': description,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'recommendations': recommendations,
    'metadata': metadata,
  };

  factory WeatherAlert.fromJson(Map<String, dynamic> json) => WeatherAlert(
    id: json['id'],
    location: json['location'],
    type: json['type'],
    severity: json['severity'],
    title: json['title'],
    description: json['description'],
    startTime: DateTime.parse(json['startTime']),
    endTime: DateTime.parse(json['endTime']),
    recommendations: List<String>.from(json['recommendations'] ?? []),
    metadata: json['metadata'],
  );
}

class WeatherService {
  static final Map<String, WeatherData> _currentWeather = {};
  static final Map<String, List<WeatherForecast>> _forecasts = {};
  static final List<WeatherAlert> _alerts = [];

  static final StreamController<WeatherData> _weatherController = StreamController<WeatherData>.broadcast();
  static final StreamController<WeatherAlert> _alertController = StreamController<WeatherAlert>.broadcast();

  // Streams publics
  static Stream<WeatherData> get weatherStream => _weatherController.stream;
  static Stream<WeatherAlert> get alertStream => _alertController.stream;

  // Initialiser le service
  static Future<void> initialize() async {
    print('WeatherService initialized.');
  }

  // Obtenir la météo actuelle - UNIQUEMENT depuis le backend NodeJS avec données réelles
  static Future<WeatherData> getCurrentWeather(String location) async {
    try {
      // Parser les coordonnées si c'est une chaîne de coordonnées
      double? lat, lon;
      if (location.contains(',')) {
        final coords = location.split(',');
        lat = double.tryParse(coords[0]);
        lon = double.tryParse(coords[1]);
      }
      
      // Si on a des coordonnées, utiliser le backend NodeJS
      if (lat != null && lon != null) {
        try {
          final response = await http.get(
            Uri.parse('http://localhost:5000/api/weather/current?latitude=$lat&longitude=$lon'),
            headers: {'Content-Type': 'application/json'},
          ).timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            
            // Vérifier que toutes les données requises sont présentes
            if (data['temperature'] == null || data['humidity'] == null) {
              throw Exception('Données météo incomplètes depuis le backend');
            }
            
            final weather = WeatherData(
              location: data['location'] ?? location,
              temperature: data['temperature'].toDouble(),
              humidity: data['humidity'].toDouble(),
              windSpeed: (data['windSpeed'] ?? 0.0).toDouble(),
              windDirection: _getWindDirectionFromDegrees((data['windDirection'] ?? 0.0).toDouble()),
              pressure: (data['pressure'] ?? 0.0).toDouble(),
              visibility: (data['visibility'] ?? 0.0).toDouble(),
              condition: data['condition'] ?? 'Unknown',
              description: data['description'] ?? '',
              uvIndex: (data['uvIndex'] ?? 0.0).toDouble(),
              rainfall: (data['rainfall'] ?? 0.0).toDouble(),
              timestamp: DateTime.parse(data['timestamp'] ?? DateTime.now().toIso8601String()),
            );

            _currentWeather[location] = weather;
            _weatherController.add(weather);
            return weather;
          } else {
            throw Exception('Erreur API: ${response.statusCode}');
          }
        } catch (e) {
          print('Erreur lors de l\'appel au backend: $e');
          // Tentative avec le service météo réel en fallback
          try {
        final realWeatherData = await RealWeatherService.getCurrentWeather(
          latitude: lat,
          longitude: lon,
        );
            
            // Vérifier que les données réelles sont présentes
            if (realWeatherData['temperature'] == null || realWeatherData['humidity'] == null) {
              throw Exception('Données météo incomplètes depuis RealWeatherService');
            }
        
        final weather = WeatherData(
          location: realWeatherData['location'] ?? location,
              temperature: realWeatherData['temperature'],
              humidity: realWeatherData['humidity'],
              windSpeed: realWeatherData['windSpeed'] ?? 0.0,
          windDirection: _getWindDirectionFromDegrees(realWeatherData['windDirection'] ?? 0.0),
              pressure: realWeatherData['pressure'] ?? 0.0,
              visibility: realWeatherData['visibility'] ?? 0.0,
              condition: realWeatherData['condition'] ?? 'Unknown',
              description: realWeatherData['description'] ?? '',
              uvIndex: realWeatherData['uvIndex'] ?? 0.0,
          rainfall: realWeatherData['rainfall'] ?? 0.0,
          timestamp: DateTime.now(),
        );

        _currentWeather[location] = weather;
        _weatherController.add(weather);
        return weather;
          } catch (fallbackError) {
            print('Erreur fallback météo: $fallbackError');
            // Si aucune source de données n'est disponible, lancer une erreur
            throw Exception('Impossible de récupérer les données météo. Veuillez vérifier votre connexion et la configuration de l\'API OpenWeather.');
          }
        }
      }
      
      // Si les coordonnées ne sont pas valides, lancer une erreur
      throw Exception('Impossible de parser les coordonnées de la location. Format attendu: "latitude,longitude" ou coordonnées valides.');
    } catch (e) {
      print('Erreur météo: $e');
      // Si aucune donnée n'est disponible, retourner une erreur plutôt que des données fictives
      throw Exception('Impossible de récupérer les données météo. Veuillez vérifier votre connexion et la configuration de l\'API.');
    }
  }

  // Obtenir les prévisions météo - UNIQUEMENT depuis le backend NodeJS avec données réelles
  static Future<List<WeatherForecast>> getWeatherForecast(String location, {int days = 3}) async {
    try {
      // Parser les coordonnées si c'est une chaîne de coordonnées
      double? lat, lon;
      if (location.contains(',')) {
        final coords = location.split(',');
        lat = double.tryParse(coords[0]);
        lon = double.tryParse(coords[1]);
      }
      
      // Si on a des coordonnées, utiliser le backend NodeJS
      if (lat != null && lon != null) {
        try {
          final response = await http.get(
            Uri.parse('http://localhost:5000/api/weather/forecast?latitude=$lat&longitude=$lon&days=$days'),
            headers: {'Content-Type': 'application/json'},
          ).timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            final List<dynamic> data = jsonDecode(response.body);
            final forecasts = data.map((item) {
              // Vérifier que les données requises sont présentes
              if (item['date'] == null || item['minTemperature'] == null || item['maxTemperature'] == null) {
                throw Exception('Données de prévision incomplètes');
              }
              
              return WeatherForecast(
                location: item['location'] ?? location,
                date: DateTime.parse(item['date']),
                minTemperature: item['minTemperature'].toDouble(),
                maxTemperature: item['maxTemperature'].toDouble(),
                humidity: (item['humidity'] ?? 0.0).toDouble(),
                windSpeed: (item['windSpeed'] ?? 0.0).toDouble(),
                condition: item['condition'] ?? 'Unknown',
                description: item['description'] ?? '',
                rainfall: (item['rainfall'] ?? 0.0).toDouble(),
                uvIndex: (item['uvIndex'] ?? 0.0).toDouble(),
              );
            }).toList();

            _forecasts[location] = forecasts;
            return forecasts;
          } else {
            throw Exception('Erreur API: ${response.statusCode}');
          }
        } catch (e) {
          print('Erreur lors de l\'appel au backend: $e');
          // Fallback vers le service météo réel
          final realForecasts = await RealWeatherService.getWeatherForecast(
            latitude: lat,
            longitude: lon,
            days: days,
          );
          
          final forecasts = realForecasts.map((item) {
            // Vérifier que les données requises sont présentes
            if (item['date'] == null || item['temperatureMin'] == null || item['temperatureMax'] == null) {
              throw Exception('Données de prévision incomplètes depuis RealWeatherService');
            }
            
            return WeatherForecast(
              location: item['city'] ?? location,
              date: DateTime.parse(item['date']),
              minTemperature: item['temperatureMin'].toDouble(),
              maxTemperature: item['temperatureMax'].toDouble(),
              humidity: (item['humidity'] ?? 0.0).toDouble(),
              windSpeed: (item['windSpeed'] ?? 0.0).toDouble(),
              condition: item['main'] ?? 'Unknown',
              description: item['description'] ?? '',
              rainfall: (item['precipitation'] ?? 0.0).toDouble(),
              uvIndex: (item['uv'] ?? 0.0).toDouble(),
            );
          }).toList();

    _forecasts[location] = forecasts;
    return forecasts;
        } catch (fallbackError) {
          print('Erreur fallback prévisions: $fallbackError');
          throw Exception('Impossible de récupérer les prévisions météo. Veuillez vérifier votre connexion et la configuration de l\'API OpenWeather.');
        }
      }
      
      // Si les coordonnées ne sont pas valides, lancer une erreur
      throw Exception('Impossible de parser les coordonnées de la location. Format attendu: "latitude,longitude" ou coordonnées valides.');
    } catch (e) {
      print('Erreur prévisions: $e');
      throw Exception('Impossible de récupérer les prévisions météo. Veuillez vérifier votre connexion et la configuration de l\'API.');
    }
  }

  // Obtenir les alertes météo - UNIQUEMENT depuis le backend NodeJS avec données réelles
  static Future<List<WeatherAlert>> getWeatherAlerts(String location) async {
    try {
      // Essayer d'abord le backend NodeJS
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/weather/alerts'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final alerts = data.map((item) {
          final recommendationsJson = item['recommendations'];
          final recommendations = recommendationsJson != null 
            ? (recommendationsJson is String ? jsonDecode(recommendationsJson) : recommendationsJson)
            : <String>[];
          
          return WeatherAlert(
            id: item['id'],
            location: item['location'] ?? location,
            type: item['type'],
            severity: item['severity'],
            title: item['title'],
            description: item['description'] ?? '',
            startTime: DateTime.parse(item['startTime']),
            endTime: DateTime.parse(item['endTime']),
            recommendations: List<String>.from(recommendations),
          );
        }).toList();

        _alerts.clear();
        _alerts.addAll(alerts);
        return alerts;
      }
    } catch (e) {
      print('Erreur lors de la récupération des alertes: $e');
      // Si aucune alerte n'est disponible, retourner une liste vide plutôt que des données fictives
      return [];
    }
    
    return [];
  }

  // Obtenir les recommandations agricoles - depuis les données météo réelles
  static Future<List<String>> getAgriculturalRecommendations(String location) async {
    try {
      // Récupérer la météo actuelle pour générer des recommandations basées sur les vraies données
      final weather = await getCurrentWeather(location);
      
      final recommendations = <String>[];
      
      // Recommandations basées sur les vraies données météo
      if (weather.temperature > 35) {
        recommendations.add('Température élevée: Augmenter l\'irrigation et fournir de l\'ombrage aux cultures sensibles');
      }
      
      if (weather.temperature < 15) {
        recommendations.add('Température basse: Protéger les cultures sensibles au froid');
      }
      
      if (weather.humidity < 40) {
        recommendations.add('Humidité faible: Irrigation recommandée pour maintenir l\'humidité du sol');
      }
      
      if (weather.rainfall > 20) {
        recommendations.add('Pluies abondantes: Vérifier le drainage des champs et protéger les cultures sensibles');
      }
      
      if (weather.windSpeed > 30) {
        recommendations.add('Vents forts: Protéger les cultures et les équipements');
      }
      
      if (weather.rainfall == 0 && weather.humidity < 50) {
        recommendations.add('Conditions sèches: Planifier l\'irrigation d\'urgence');
      }
      
      // Si aucune recommandation spécifique, retourner une recommandation générale
      return recommendations.isNotEmpty 
        ? recommendations 
        : ['Conditions météorologiques favorables pour les activités agricoles'];
    } catch (e) {
      print('Erreur lors de la récupération des recommandations: $e');
      return ['Impossible de générer des recommandations. Vérifiez votre connexion.'];
    }
  }

  // Méthodes utilitaires
  static String _getWindDirectionFromDegrees(double degrees) {
    if (degrees >= 337.5 || degrees < 22.5) return 'N';
    if (degrees >= 22.5 && degrees < 67.5) return 'NE';
    if (degrees >= 67.5 && degrees < 112.5) return 'E';
    if (degrees >= 112.5 && degrees < 157.5) return 'SE';
    if (degrees >= 157.5 && degrees < 202.5) return 'S';
    if (degrees >= 202.5 && degrees < 247.5) return 'SW';
    if (degrees >= 247.5 && degrees < 292.5) return 'W';
    if (degrees >= 292.5 && degrees < 337.5) return 'NW';
    return 'N';
  }

  // Méthodes avec Random() supprimées - elles ne sont plus utilisées car toutes les données viennent du backend

  static String _getAlertTitle(String type) {
    switch (type) {
      case 'storm':
        return 'Alerte Orage';
      case 'flood':
        return 'Alerte Inondation';
      case 'drought':
        return 'Alerte Sécheresse';
      case 'heat_wave':
        return 'Alerte Canicule';
      case 'cold_wave':
        return 'Alerte Froid';
      default:
        return 'Alerte Météo';
    }
  }

  static String _getAlertDescription(String type, String severity) {
    switch (type) {
      case 'storm':
        return 'Orage violent prévu avec des vents forts et de la grêle possible';
      case 'flood':
        return 'Risque d\'inondation élevé dû aux fortes pluies';
      case 'drought':
        return 'Période de sécheresse prolongée, irrigation recommandée';
      case 'heat_wave':
        return 'Vague de chaleur intense, protéger les cultures et les travailleurs';
      case 'cold_wave':
        return 'Températures très basses, risque de gel pour les cultures sensibles';
      default:
        return 'Conditions météorologiques extrêmes prévues';
    }
  }

  static List<String> _getAlertRecommendations(String type) {
    switch (type) {
      case 'storm':
        return [
          'Reporter tous les travaux en plein air',
          'Protéger les équipements et les cultures',
          'Éviter les zones exposées',
        ];
      case 'flood':
        return [
          'Améliorer le drainage des champs',
          'Déplacer les équipements en hauteur',
          'Surveiller les niveaux d\'eau',
        ];
      case 'drought':
        return [
          'Programmer l\'irrigation d\'urgence',
          'Utiliser du paillage pour conserver l\'humidité',
          'Réduire la fertilisation',
        ];
      case 'heat_wave':
        return [
          'Augmenter l\'irrigation',
          'Fournir de l\'ombrage aux cultures',
          'Éviter les travaux aux heures chaudes',
        ];
      case 'cold_wave':
        return [
          'Protéger les cultures sensibles au gel',
          'Utiliser des couvertures ou des tunnels',
          'Surveiller les températures nocturnes',
        ];
      default:
        return [
          'Surveiller les conditions météorologiques',
          'Adapter les pratiques agricoles',
          'Rester informé des alertes',
        ];
    }
  }
}