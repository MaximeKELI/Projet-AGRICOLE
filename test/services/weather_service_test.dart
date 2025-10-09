import 'package:mockito/mockito.dart';
import 'weather_service_test.mocks.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projet_agricole/models/weather_data.dart';
import 'package:projet_agricole/services/weather_service.dart';


@GenerateMocks([WeatherService])
void main() {
  group('WeatherService Tests', () {
    late WeatherService weatherService;

    setUp(() {
      weatherService = WeatherService();
    });

    group('Weather Data Processing', () {
      test('should calculate heat index correctly', () {
        // Arrange
        final weatherData = WeatherData(
          id: 'test',
          location: 'Test',
          latitude: 6.1319,
          longitude: 1.2228,
          temperature: 30.0,
          humidity: 70.0,
          pressure: 1013.0,
          windSpeed: 10.0,
          windDirection: 180.0,
          rainfall: 0.0,
          uvIndex: 5.0,
          condition: 'Ensoleillé',
          description: 'Test',
          timestamp: DateTime.now(),
          forecast: '{}',
        );

        // Act
        final heatIndex = weatherData.heatIndex;

        // Assert
        expect(heatIndex, equals(30.0 + (0.5 * 70.0) - 32));
        expect(heatIndex, equals(33.0));
      });

      test('should calculate dew point correctly', () {
        // Arrange
        final weatherData = WeatherData(
          id: 'test',
          location: 'Test',
          latitude: 6.1319,
          longitude: 1.2228,
          temperature: 25.0,
          humidity: 60.0,
          pressure: 1013.0,
          windSpeed: 10.0,
          windDirection: 180.0,
          rainfall: 0.0,
          uvIndex: 5.0,
          condition: 'Ensoleillé',
          description: 'Test',
          timestamp: DateTime.now(),
          forecast: '{}',
        );

        // Act
        final dewPoint = weatherData.dewPoint;

        // Assert
        expect(dewPoint, equals(25.0 - ((100 - 60) / 5)));
        expect(dewPoint, equals(17.0));
      });

      test('should determine favorable planting conditions', () {
        // Arrange
        final favorableWeather = WeatherData(
          id: 'test',
          location: 'Test',
          latitude: 6.1319,
          longitude: 1.2228,
          temperature: 25.0, // Favorable
          humidity: 60.0,    // Favorable
          pressure: 1013.0,
          windSpeed: 10.0,
          windDirection: 180.0,
          rainfall: 2.0,     // Favorable
          uvIndex: 5.0,
          condition: 'Ensoleillé',
          description: 'Test',
          timestamp: DateTime.now(),
          forecast: '{}',
        );

        final unfavorableWeather = WeatherData(
          id: 'test',
          location: 'Test',
          latitude: 6.1319,
          longitude: 1.2228,
          temperature: 40.0, // Trop chaud
          humidity: 90.0,    // Trop humide
          pressure: 1013.0,
          windSpeed: 10.0,
          windDirection: 180.0,
          rainfall: 15.0,    // Trop de pluie
          uvIndex: 5.0,
          condition: 'Pluvieux',
          description: 'Test',
          timestamp: DateTime.now(),
          forecast: '{}',
        );

        // Act & Assert
        expect(favorableWeather.isFavorableForPlanting, isTrue);
        expect(unfavorableWeather.isFavorableForPlanting, isFalse);
      });

      test('should provide correct agricultural advice', () {
        // Arrange
        final highRainWeather = WeatherData(
          id: 'test',
          location: 'Test',
          latitude: 6.1319,
          longitude: 1.2228,
          temperature: 25.0,
          humidity: 60.0,
          pressure: 1013.0,
          windSpeed: 10.0,
          windDirection: 180.0,
          rainfall: 15.0, // Pluie intense
          uvIndex: 5.0,
          condition: 'Pluvieux',
          description: 'Test',
          timestamp: DateTime.now(),
          forecast: '{}',
        );

        // Act
        final advice = highRainWeather.agriculturalAdvice;

        // Assert
        expect(advice, contains('Éviter les travaux agricoles'));
        expect(advice, contains('pluie intense'));
      });

      test('should identify disease risks correctly', () {
        // Arrange
        final highHumidityWeather = WeatherData(
          id: 'test',
          location: 'Test',
          latitude: 6.1319,
          longitude: 1.2228,
          temperature: 30.0,
          humidity: 85.0, // Risque élevé
          pressure: 1013.0,
          windSpeed: 10.0,
          windDirection: 180.0,
          rainfall: 0.0,
          uvIndex: 5.0,
          condition: 'Humide',
          description: 'Test',
          timestamp: DateTime.now(),
          forecast: '{}',
        );

        // Act
        final risks = highHumidityWeather.diseaseRisk;

        // Assert
        expect(risks, contains('Risque élevé de maladies fongiques'));
      });
    });
  });
}
