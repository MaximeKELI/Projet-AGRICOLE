import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'real_weather_service.dart';

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

  // Obtenir la météo actuelle
  static Future<WeatherData> getCurrentWeather(String location) async {
    try {
      // Parser les coordonnées si c'est une chaîne de coordonnées
      double? lat, lon;
      if (location.contains(',')) {
        final coords = location.split(',');
        lat = double.tryParse(coords[0]);
        lon = double.tryParse(coords[1]);
      }
      
      // Utiliser le service météo réel si on a des coordonnées
      if (lat != null && lon != null) {
        final realWeatherData = await RealWeatherService.getCurrentWeather(
          latitude: lat,
          longitude: lon,
        );
        
        final weather = WeatherData(
          location: realWeatherData['location'] ?? location,
          temperature: realWeatherData['temperature'] ?? 25.0,
          humidity: realWeatherData['humidity'] ?? 60.0,
          windSpeed: realWeatherData['windSpeed'] ?? 5.0,
          windDirection: _getWindDirectionFromDegrees(realWeatherData['windDirection'] ?? 0.0),
          pressure: realWeatherData['pressure'] ?? 1010.0,
          visibility: realWeatherData['visibility'] ?? 8.0,
          condition: realWeatherData['condition'] ?? 'Ensoleillé',
          description: realWeatherData['description'] ?? 'Conditions normales',
          uvIndex: realWeatherData['uvIndex'] ?? 5.0,
          rainfall: realWeatherData['rainfall'] ?? 0.0,
          timestamp: DateTime.now(),
        );

        _currentWeather[location] = weather;
        _weatherController.add(weather);
        return weather;
      }
    } catch (e) {
      print('Erreur météo réelle: $e');
    }
    
    // Fallback vers données simulées si erreur
    await Future.delayed(const Duration(seconds: 1));
    final random = Random();

    final weather = WeatherData(
      location: location,
      temperature: 25.0 + random.nextDouble() * 10, // 25-35°C
      humidity: 60.0 + random.nextDouble() * 30, // 60-90%
      windSpeed: 5.0 + random.nextDouble() * 15, // 5-20 km/h
      windDirection: _getRandomWindDirection(),
      pressure: 1010 + random.nextDouble() * 20, // 1010-1030 hPa
      visibility: 8.0 + random.nextDouble() * 4, // 8-12 km
      condition: _getRandomCondition(),
      description: _getRandomDescription(),
      uvIndex: 3.0 + random.nextDouble() * 8, // 3-11
      rainfall: random.nextDouble() * 5, // 0-5 mm
      timestamp: DateTime.now(),
    );

    _currentWeather[location] = weather;
    _weatherController.add(weather);
    return weather;
  }

  // Obtenir les prévisions météo
  static Future<List<WeatherForecast>> getWeatherForecast(String location, {int days = 3}) async {
    await Future.delayed(const Duration(seconds: 1));
    final random = Random();
    final List<WeatherForecast> forecasts = [];

    for (int i = 1; i <= days; i++) {
      forecasts.add(
        WeatherForecast(
          location: location,
          date: DateTime.now().add(Duration(days: i)),
          minTemperature: 20.0 + random.nextDouble() * 5,
          maxTemperature: 28.0 + random.nextDouble() * 7,
          humidity: 65.0 + random.nextDouble() * 20,
          windSpeed: 8.0 + random.nextDouble() * 12,
          condition: _getRandomCondition(),
          description: _getRandomDescription(),
          rainfall: random.nextDouble() * 3,
          uvIndex: 3.0 + random.nextDouble() * 8,
        ),
      );
    }

    _forecasts[location] = forecasts;
    return forecasts;
  }

  // Obtenir les alertes météo
  static Future<List<WeatherAlert>> getWeatherAlerts(String location) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final random = Random();
    
    if (random.nextBool()) {
      final alert = WeatherAlert(
        id: 'alert_${DateTime.now().millisecondsSinceEpoch}',
        location: location,
        type: _getRandomAlertType(),
        severity: _getRandomSeverity(),
        title: _getAlertTitle(_getRandomAlertType()),
        description: _getAlertDescription(_getRandomAlertType(), _getRandomSeverity()),
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 24)),
        recommendations: _getAlertRecommendations(_getRandomAlertType()),
      );
      
      _alerts.add(alert);
      _alertController.add(alert);
    }

    return _alerts;
  }

  // Obtenir les recommandations agricoles
  static Future<List<String>> getAgriculturalRecommendations(String location) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final random = Random();
    
    final recommendations = [
      'Irriguer les cultures le matin tôt',
      'Surveiller les signes de stress hydrique',
      'Ajuster la fertilisation selon les conditions',
      'Protéger les cultures sensibles au vent',
      'Planifier les récoltes selon la météo',
    ];

    return recommendations.take(2 + random.nextInt(3)).toList();
  }

  // Méthodes utilitaires
  static String _getRandomWindDirection() {
    final directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    return directions[Random().nextInt(directions.length)];
  }

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

  static String _getRandomCondition() {
    final conditions = ['Ensoleillé', 'Nuageux', 'Partiellement nuageux', 'Pluvieux', 'Orageux'];
    return conditions[Random().nextInt(conditions.length)];
  }

  static String _getRandomDescription() {
    final descriptions = [
      'Ciel dégagé',
      'Quelques nuages',
      'Nuages épars',
      'Averses légères',
      'Pluie modérée',
    ];
    return descriptions[Random().nextInt(descriptions.length)];
  }

  static String _getRandomAlertType() {
    final types = ['storm', 'flood', 'drought', 'heat_wave', 'cold_wave'];
    return types[Random().nextInt(types.length)];
  }

  static String _getRandomSeverity() {
    final severities = ['low', 'medium', 'high', 'extreme'];
    return severities[Random().nextInt(severities.length)];
  }

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