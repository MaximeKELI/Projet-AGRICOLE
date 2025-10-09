import 'api_service_test.mocks.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projet_agricole/models/crop.dart';
import 'package:projet_agricole/models/region.dart';
import 'package:projet_agricole/services/api_service.dart';


@GenerateMocks([http.Client])
void main() {
  group('ApiService Tests', () {
    late ApiService apiService;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      apiService = ApiService();
      // Injecter le client mock dans ApiService si possible
    });

    group('Regions API', () {
      test('should fetch regions successfully', () async {
        // Arrange
        final mockResponse = '''
        [
          {
            "id": "centrale",
            "name": "Région Centrale",
            "prefectures": []
          }
        ]
        ''';
        
        when(mockClient.get(any))
            .thenAnswer((_) async => http.Response(mockResponse, 200));

        // Act
        final result = await apiService.getRegions();

        // Assert
        expect(result, isA<List<Region>>());
        expect(result.length, equals(1));
        expect(result.first.id, equals('centrale'));
        expect(result.first.name, equals('Région Centrale'));
      });

      test('should handle API error when fetching regions', () async {
        // Arrange
        when(mockClient.get(any))
            .thenAnswer((_) async => http.Response('Error', 500));

        // Act & Assert
        expect(() => apiService.getRegions(), throwsException);
      });
    });

    group('Crops API', () {
      test('should fetch crops successfully', () async {
        // Arrange
        final mockResponse = '''
        [
          {
            "id": "mais",
            "name": "Maïs",
            "description": "Céréale de base",
            "plantingSeason": "Mai-Juin",
            "harvestSeason": "Septembre-Octobre",
            "waterNeeds": "Modéré",
            "soilTypes": ["tropical", "ferralitique"]
          }
        ]
        ''';
        
        when(mockClient.get(any))
            .thenAnswer((_) async => http.Response(mockResponse, 200));

        // Act
        final result = await apiService.getCrops();

        // Assert
        expect(result, isA<List<Crop>>());
        expect(result.length, equals(1));
        expect(result.first.id, equals('mais'));
        expect(result.first.name, equals('Maïs'));
      });
    });

    group('Weather API', () {
      test('should fetch current weather successfully', () async {
        // Arrange
        final mockResponse = '''
        {
          "id": "test-id",
          "location": "Test Location",
          "latitude": 6.1319,
          "longitude": 1.2228,
          "temperature": 25.5,
          "humidity": 70.0,
          "pressure": 1013.0,
          "windSpeed": 10.0,
          "windDirection": 180.0,
          "rainfall": 0.0,
          "uvIndex": 5.0,
          "condition": "Ensoleillé",
          "description": "Conditions favorables",
          "timestamp": "2024-01-01T12:00:00Z",
          "forecast": "{}"
        }
        ''';
        
        when(mockClient.get(any))
            .thenAnswer((_) async => http.Response(mockResponse, 200));

        // Act
        final result = await apiService.getCurrentWeather(6.1319, 1.2228);

        // Assert
        expect(result, isNotNull);
        expect(result.temperature, equals(25.5));
        expect(result.humidity, equals(70.0));
        expect(result.condition, equals('Ensoleillé'));
      });
    });
  });
}
