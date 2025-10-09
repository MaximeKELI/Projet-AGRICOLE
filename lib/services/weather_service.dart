import 'dart:math';
import 'dart:async';
import 'dart:convert';

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
    required this.recommendations,
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
    recommendations: List<String>.from(json['recommendations']),
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
    // Initialisation du service météo
    print('Service météo initialisé');
  }

  // API Key pour OpenWeatherMap (à remplacer par votre vraie clé)
  static const String _apiKey = 'your_openweathermap_api_key_here';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  // Obtenir la météo actuelle
  static Future<WeatherData> getCurrentWeather(String location) async {
    // Simulation de données météo (dans une vraie implémentation, on ferait un appel API)
    await Future.delayed(const Duration(seconds: 1));

    final random = Random();
    final weatherData = WeatherData(
      location: location,
      temperature: 25.0 + random.nextDouble() * 15.0, // 25-40°C
      humidity: 40.0 + random.nextDouble() * 40.0, // 40-80%
      windSpeed: random.nextDouble() * 20.0, // 0-20 km/h
      windDirection: _getRandomWindDirection(),
      pressure: 1010.0 + random.nextDouble() * 20.0, // 1010-1030 hPa
      visibility: 8.0 + random.nextDouble() * 2.0, // 8-10 km
      condition: _getRandomCondition(),
      description: _getRandomDescription(),
      uvIndex: random.nextDouble() * 11.0, // 0-11
      rainfall: random.nextDouble() * 10.0, // 0-10 mm
      timestamp: DateTime.now(),
      metadata: {
        'source': 'simulation',
        'accuracy': 0.85,
      },
    );

    _currentWeather[location] = weatherData;
    _weatherController.add(weatherData);

    return weatherData;
  }

  // Obtenir les prévisions météo
  static Future<List<WeatherForecast>> getWeatherForecast(String location, {int days = 5}) async {
    // Simulation de prévisions météo
    await Future.delayed(const Duration(seconds: 1));

    final forecasts = <WeatherForecast>[];
    final random = Random();

    for (int i = 0; i < days; i++) {
      final date = DateTime.now().add(Duration(days: i));
      final baseTemp = 25.0 + random.nextDouble() * 15.0;
      
      forecasts.add(WeatherForecast(
        location: location,
        date: date,
        minTemperature: baseTemp - 5.0 - random.nextDouble() * 5.0,
        maxTemperature: baseTemp + random.nextDouble() * 5.0,
        humidity: 40.0 + random.nextDouble() * 40.0,
        windSpeed: random.nextDouble() * 20.0,
        condition: _getRandomCondition(),
        description: _getRandomDescription(),
        rainfall: random.nextDouble() * 15.0,
        uvIndex: random.nextDouble() * 11.0,
        metadata: {
          'source': 'simulation',
          'confidence': 0.75 + random.nextDouble() * 0.2,
        },
      ));
    }

    _forecasts[location] = forecasts;
    return forecasts;
  }

  // Obtenir les alertes météo
  static Future<List<WeatherAlert>> getWeatherAlerts(String location) async {
    // Simulation d'alertes météo
    await Future.delayed(const Duration(milliseconds: 500));

    final alerts = <WeatherAlert>[];
    final random = Random();

    // Simuler quelques alertes occasionnelles
    if (random.nextDouble() < 0.3) { // 30% de chance d'avoir une alerte
      final alertTypes = ['storm', 'flood', 'drought', 'heat_wave', 'cold_wave'];
      final severities = ['low', 'medium', 'high', 'extreme'];
      
      final alertType = alertTypes[random.nextInt(alertTypes.length)];
      final severity = severities[random.nextInt(severities.length)];
      
      final alert = WeatherAlert(
        id: 'alert_${DateTime.now().millisecondsSinceEpoch}',
        location: location,
        type: alertType,
        severity: severity,
        title: _getAlertTitle(alertType, severity),
        description: _getAlertDescription(alertType, severity),
        startTime: DateTime.now(),
        endTime: DateTime.now().add(Duration(hours: 6 + random.nextInt(48))),
        recommendations: _getAlertRecommendations(alertType),
        metadata: {
          'source': 'simulation',
          'confidence': 0.8 + random.nextDouble() * 0.2,
        },
      );

      alerts.add(alert);
      _alerts.add(alert);
      _alertController.add(alert);
    }

    return alerts;
  }

  // Obtenir les données météo historiques
  static Future<List<WeatherData>> getHistoricalWeather(
    String location, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Simulation de données historiques
    await Future.delayed(const Duration(seconds: 1));

    final historicalData = <WeatherData>[];
    final random = Random();
    final days = endDate.difference(startDate).inDays;

    for (int i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));
      final baseTemp = 25.0 + random.nextDouble() * 15.0;
      
      historicalData.add(WeatherData(
        location: location,
        temperature: baseTemp,
        humidity: 40.0 + random.nextDouble() * 40.0,
        windSpeed: random.nextDouble() * 20.0,
        windDirection: _getRandomWindDirection(),
        pressure: 1010.0 + random.nextDouble() * 20.0,
        visibility: 8.0 + random.nextDouble() * 2.0,
        condition: _getRandomCondition(),
        description: _getRandomDescription(),
        uvIndex: random.nextDouble() * 11.0,
        rainfall: random.nextDouble() * 10.0,
        timestamp: date,
        metadata: {
          'source': 'historical_simulation',
          'quality': 'good',
        },
      ));
    }

    return historicalData;
  }

  // Obtenir les recommandations agricoles basées sur la météo
  static Future<List<String>> getAgriculturalRecommendations(
    String location, {
    String? cropType,
  }) async {
    final weather = await getCurrentWeather(location);
    final recommendations = <String>[];

    // Recommandations basées sur la température
    if (weather.temperature > 35) {
      recommendations.add('Température élevée - Augmenter l\'irrigation et protéger les cultures du soleil');
    } else if (weather.temperature < 15) {
      recommendations.add('Température basse - Protéger les cultures sensibles au froid');
    }

    // Recommandations basées sur l'humidité
    if (weather.humidity > 80) {
      recommendations.add('Humidité élevée - Surveiller les maladies fongiques et améliorer la ventilation');
    } else if (weather.humidity < 40) {
      recommendations.add('Humidité faible - Augmenter l\'irrigation et utiliser du paillage');
    }

    // Recommandations basées sur la pluviométrie
    if (weather.rainfall > 20) {
      recommendations.add('Pluie importante - Éviter les traitements et surveiller le drainage');
    } else if (weather.rainfall < 5) {
      recommendations.add('Sécheresse - Programmer l\'irrigation et réduire la fertilisation');
    }

    // Recommandations basées sur le vent
    if (weather.windSpeed > 15) {
      recommendations.add('Vent fort - Reporter les traitements et protéger les cultures fragiles');
    }

    // Recommandations basées sur l'index UV
    if (weather.uvIndex > 8) {
      recommendations.add('Index UV élevé - Éviter les travaux en plein soleil et protéger les cultures');
    }

    // Recommandations spécifiques aux cultures
    if (cropType != null) {
      recommendations.addAll(_getCropSpecificRecommendations(cropType, weather));
    }

    return recommendations;
  }

  // Obtenir les recommandations spécifiques aux cultures
  static List<String> _getCropSpecificRecommendations(String cropType, WeatherData weather) {
    final recommendations = <String>[];

    switch (cropType.toLowerCase()) {
      case 'riz':
        if (weather.temperature > 30 && weather.humidity > 70) {
          recommendations.add('Riz - Conditions idéales pour la croissance, surveiller les maladies');
        }
        if (weather.rainfall < 10) {
          recommendations.add('Riz - Besoin d\'irrigation supplémentaire');
        }
        break;
      case 'tomates':
        if (weather.humidity > 80) {
          recommendations.add('Tomates - Risque élevé de mildiou, traiter préventivement');
        }
        if (weather.temperature > 35) {
          recommendations.add('Tomates - Protéger du stress thermique avec de l\'ombrage');
        }
        break;
      case 'mangues':
        if (weather.rainfall > 15) {
          recommendations.add('Mangues - Éviter la récolte par temps humide');
        }
        if (weather.windSpeed > 10) {
          recommendations.add('Mangues - Risque de chute des fruits, récolter rapidement');
        }
        break;
    }

    return recommendations;
  }

  // Obtenir les conditions météo optimales pour une culture
  static Map<String, dynamic> getOptimalConditions(String cropType) {
    switch (cropType.toLowerCase()) {
      case 'riz':
        return {
          'temperature': {'min': 20, 'max': 35, 'optimal': 28},
          'humidity': {'min': 60, 'max': 90, 'optimal': 75},
          'rainfall': {'min': 100, 'max': 200, 'optimal': 150},
          'soilMoisture': {'min': 80, 'max': 100, 'optimal': 90},
        };
      case 'tomates':
        return {
          'temperature': {'min': 18, 'max': 30, 'optimal': 24},
          'humidity': {'min': 50, 'max': 70, 'optimal': 60},
          'rainfall': {'min': 50, 'max': 100, 'optimal': 75},
          'soilMoisture': {'min': 60, 'max': 80, 'optimal': 70},
        };
      case 'mangues':
        return {
          'temperature': {'min': 20, 'max': 35, 'optimal': 28},
          'humidity': {'min': 50, 'max': 80, 'optimal': 65},
          'rainfall': {'min': 100, 'max': 200, 'optimal': 150},
          'soilMoisture': {'min': 70, 'max': 90, 'optimal': 80},
        };
      default:
        return {
          'temperature': {'min': 20, 'max': 30, 'optimal': 25},
          'humidity': {'min': 60, 'max': 80, 'optimal': 70},
          'rainfall': {'min': 100, 'max': 150, 'optimal': 125},
          'soilMoisture': {'min': 70, 'max': 85, 'optimal': 77},
        };
    }
  }

  // Obtenir une direction de vent aléatoire
  static String _getRandomWindDirection() {
    final directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    return directions[Random().nextInt(directions.length)];
  }

  // Obtenir une condition météo aléatoire
  static String _getRandomCondition() {
    final conditions = ['clear', 'cloudy', 'partly_cloudy', 'rainy', 'stormy', 'foggy'];
    return conditions[Random().nextInt(conditions.length)];
  }

  // Obtenir une description météo aléatoire
  static String _getRandomDescription() {
    final descriptions = [
      'Ciel dégagé',
      'Nuageux',
      'Partiellement nuageux',
      'Pluvieux',
      'Orageux',
      'Brouillard',
      'Ensoleillé',
      'Couvert',
    ];
    return descriptions[Random().nextInt(descriptions.length)];
  }

  // Obtenir le titre d'une alerte
  static String _getAlertTitle(String type, String severity) {
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

  // Obtenir la description d'une alerte
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

  // Obtenir les recommandations d'alerte
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
          'Protéger les cultures sensibles',
          'Utiliser des serres ou des tunnels',
          'Surveiller les températures',
        ];
      default:
        return [
          'Surveiller les conditions météorologiques',
          'Adapter les pratiques agricoles',
          'Protéger les cultures et les équipements',
        ];
    }
  }

  // Nettoyer les données anciennes
  static void cleanupOldData({Duration maxAge = const Duration(days: 7)}) {
    final cutoffDate = DateTime.now().subtract(maxAge);
    _alerts.removeWhere((alert) => alert.endTime.isBefore(cutoffDate));
  }
}