class WeatherData {
  final String id;
  final String location;
  final double latitude;
  final double longitude;
  final double temperature;
  final double humidity;
  final double pressure;
  final double windSpeed;
  final double windDirection;
  final double rainfall;
  final double uvIndex;
  final String condition;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic> forecast;

  WeatherData({
    required this.id,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.temperature,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.windDirection,
    required this.rainfall,
    required this.uvIndex,
    required this.condition,
    required this.description,
    required this.timestamp,
    this.forecast = const {},
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      id: json['id'] ?? '',
      location: json['location'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      temperature: (json['temperature'] ?? 0.0).toDouble(),
      humidity: (json['humidity'] ?? 0.0).toDouble(),
      pressure: (json['pressure'] ?? 0.0).toDouble(),
      windSpeed: (json['windSpeed'] ?? 0.0).toDouble(),
      windDirection: (json['windDirection'] ?? 0.0).toDouble(),
      rainfall: (json['rainfall'] ?? 0.0).toDouble(),
      uvIndex: (json['uvIndex'] ?? 0.0).toDouble(),
      condition: json['condition'] ?? '',
      description: json['description'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      forecast: Map<String, dynamic>.from(json['forecast'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'temperature': temperature,
      'humidity': humidity,
      'pressure': pressure,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'rainfall': rainfall,
      'uvIndex': uvIndex,
      'condition': condition,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'forecast': forecast,
    };
  }

  // Calculs agricoles
  double get heatIndex {
    // Calcul de l'indice de chaleur pour l'agriculture
    final t = temperature;
    final h = humidity;
    return t + (0.5 * h) - 32;
  }

  double get dewPoint {
    // Point de rosée important pour les maladies fongiques
    final t = temperature;
    final h = humidity;
    return t - ((100 - h) / 5);
  }

  bool get isFavorableForPlanting {
    // Conditions favorables pour la plantation
    return temperature >= 20 && temperature <= 35 && 
           humidity >= 40 && humidity <= 80 &&
           rainfall <= 5;
  }

  bool get isFavorableForHarvest {
    // Conditions favorables pour la récolte
    return rainfall <= 2 && windSpeed <= 20;
  }

  String get agriculturalAdvice {
    if (rainfall > 10) return 'Éviter les travaux agricoles - pluie intense';
    if (temperature > 35) return 'Protéger les cultures de la chaleur excessive';
    if (humidity > 85) return 'Risque élevé de maladies fongiques';
    if (windSpeed > 25) return 'Éviter l\'application de pesticides';
    if (uvIndex > 8) return 'Protéger les cultures sensibles aux UV';
    return 'Conditions favorables pour les travaux agricoles';
  }

  String get irrigationAdvice {
    if (rainfall > 5) return 'Irrigation non nécessaire - pluie suffisante';
    if (humidity < 40) return 'Irrigation recommandée - humidité faible';
    if (temperature > 30 && humidity < 60) return 'Irrigation nécessaire - chaleur et sécheresse';
    return 'Irrigation modérée recommandée';
  }

  List<String> get diseaseRisk {
    final risks = <String>[];
    
    if (humidity > 80) {
      risks.add('Risque élevé de maladies fongiques');
    }
    if (dewPoint > 20) {
      risks.add('Risque de mildiou');
    }
    if (temperature > 25 && humidity > 70) {
      risks.add('Risque de rouille');
    }
    if (temperature < 15 && humidity > 60) {
      risks.add('Risque de pourriture');
    }
    
    return risks;
  }
}

class WeatherForecast {
  final String location;
  final List<WeatherData> dailyForecast;
  final List<WeatherData> hourlyForecast;
  final Map<String, dynamic> agriculturalRecommendations;

  WeatherForecast({
    required this.location,
    required this.dailyForecast,
    required this.hourlyForecast,
    this.agriculturalRecommendations = const {},
  });

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      location: json['location'] ?? '',
      dailyForecast: (json['dailyForecast'] as List<dynamic>?)
          ?.map((item) => WeatherData.fromJson(item))
          .toList() ?? [],
      hourlyForecast: (json['hourlyForecast'] as List<dynamic>?)
          ?.map((item) => WeatherData.fromJson(item))
          .toList() ?? [],
      agriculturalRecommendations: Map<String, dynamic>.from(
        json['agriculturalRecommendations'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'dailyForecast': dailyForecast.map((item) => item.toJson()).toList(),
      'hourlyForecast': hourlyForecast.map((item) => item.toJson()).toList(),
      'agriculturalRecommendations': agriculturalRecommendations,
    };
  }

  // Prédictions agricoles
  List<String> get plantingRecommendations {
    final recommendations = <String>[];
    
    for (final day in dailyForecast.take(7)) {
      if (day.isFavorableForPlanting) {
        recommendations.add('${day.timestamp.day}/${day.timestamp.month}: Favorable pour plantation');
      }
    }
    
    return recommendations;
  }

  List<String> get harvestRecommendations {
    final recommendations = <String>[];
    
    for (final day in dailyForecast.take(7)) {
      if (day.isFavorableForHarvest) {
        recommendations.add('${day.timestamp.day}/${day.timestamp.month}: Favorable pour récolte');
      }
    }
    
    return recommendations;
  }

  double get averageTemperature {
    if (dailyForecast.isEmpty) return 0.0;
    return dailyForecast.fold(0.0, (sum, day) => sum + day.temperature) / dailyForecast.length;
  }

  double get totalRainfall {
    return dailyForecast.fold(0.0, (sum, day) => sum + day.rainfall);
  }

  String get overallAdvice {
    final avgTemp = averageTemperature;
    final totalRain = totalRainfall;
    
    if (totalRain > 50) return 'Saison très pluvieuse - attention aux inondations';
    if (totalRain < 10) return 'Saison sèche - irrigation intensive nécessaire';
    if (avgTemp > 30) return 'Saison chaude - protéger les cultures sensibles';
    if (avgTemp < 20) return 'Saison fraîche - cultures de saison froide recommandées';
    
    return 'Conditions météorologiques équilibrées';
  }
}

class WeatherAlert {
  final String id;
  final String type;
  final String severity;
  final String title;
  final String message;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final List<String> recommendations;
  final bool isActive;

  WeatherAlert({
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.message,
    required this.location,
    required this.startTime,
    required this.endTime,
    this.recommendations = const [],
    this.isActive = true,
  });

  factory WeatherAlert.fromJson(Map<String, dynamic> json) {
    return WeatherAlert(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      severity: json['severity'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      location: json['location'] ?? '',
      startTime: DateTime.parse(json['startTime'] ?? DateTime.now().toIso8601String()),
      endTime: DateTime.parse(json['endTime'] ?? DateTime.now().toIso8601String()),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'severity': severity,
      'title': title,
      'message': message,
      'location': location,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'recommendations': recommendations,
      'isActive': isActive,
    };
  }

  String get severityColor {
    switch (severity.toLowerCase()) {
      case 'critical':
        return 'red';
      case 'warning':
        return 'orange';
      case 'info':
        return 'blue';
      default:
        return 'grey';
    }
  }

  String get severityIcon {
    switch (severity.toLowerCase()) {
      case 'critical':
        return 'dangerous';
      case 'warning':
        return 'warning';
      case 'info':
        return 'info';
      default:
        return 'notifications';
    }
  }
}
