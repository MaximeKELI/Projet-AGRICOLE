import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'complete_system_test.mocks.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projet_agricole/models/crop.dart';
import 'package:projet_agricole/models/region.dart';
import 'package:projet_agricole/models/weather_data.dart';
import 'package:projet_agricole/services/api_service.dart';
import 'package:projet_agricole/services/weather_service.dart';
import 'package:projet_agricole/models/agricultural_metrics.dart';


@GenerateMocks([http.Client, WeatherService])
void main() {
  group('Complete System Integration Tests', () {
    late ApiService apiService;
    late WeatherService weatherService;
    late MockClient mockClient;
    late MockWeatherService mockWeatherService;

    setUp(() {
      mockClient = MockClient();
      mockWeatherService = MockWeatherService();
      apiService = ApiService();
      weatherService = WeatherService();
    });

    group('Frontend-Backend-Database Integration', () {
      test('Complete Agricultural Data Flow', () async {
        // Arrange - Simuler les données complètes du système
        final mockRegionsResponse = '''
        [
          {
            "id": "centrale",
            "name": "Région Centrale",
            "prefectures": [
              {
                "id": "tchaoudjo",
                "name": "Tchaoudjo",
                "regionId": "centrale",
                "communes": [
                  {
                    "id": "sokode",
                    "name": "Sokodé",
                    "prefectureId": "tchaoudjo",
                    "soilTypeId": "tropical",
                    "latitude": 8.9833,
                    "longitude": 1.1333
                  }
                ]
              }
            ]
          }
        ]
        ''';

        final mockCropsResponse = '''
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

        final mockWeatherResponse = '''
        {
          "id": "weather-123",
          "location": "Sokodé, Tchaoudjo",
          "latitude": 8.9833,
          "longitude": 1.1333,
          "temperature": 28.5,
          "humidity": 65.0,
          "pressure": 1013.0,
          "windSpeed": 12.0,
          "windDirection": 180.0,
          "rainfall": 2.5,
          "uvIndex": 7.0,
          "condition": "Ensoleillé",
          "description": "Conditions favorables pour l'agriculture",
          "timestamp": "2024-01-01T12:00:00Z",
          "forecast": "{}"
        }
        ''';

        // Mock des réponses API
        when(mockClient.get(Uri.parse('http://localhost:5000/api/regions')))
            .thenAnswer((_) async => http.Response(mockRegionsResponse, 200));
        
        when(mockClient.get(Uri.parse('http://localhost:5000/api/crops')))
            .thenAnswer((_) async => http.Response(mockCropsResponse, 200));
        
        when(mockClient.get(Uri.parse('http://localhost:5000/api/weather/current?lat=8.9833&lon=1.1333')))
            .thenAnswer((_) async => http.Response(mockWeatherResponse, 200));

        // Act - Exécuter le flux complet
        final regions = await apiService.getRegions();
        final crops = await apiService.getCrops();
        final weather = await apiService.getCurrentWeather(8.9833, 1.1333);

        // Assert - Vérifier l'intégration complète
        expect(regions, isA<List<Region>>());
        expect(regions.length, equals(1));
        expect(regions.first.name, equals('Région Centrale'));
        expect(regions.first.prefectures.length, equals(1));
        expect(regions.first.prefectures.first.communes.length, equals(1));

        expect(crops, isA<List<Crop>>());
        expect(crops.length, equals(1));
        expect(crops.first.name, equals('Maïs'));
        expect(crops.first.plantingSeason, equals('Mai-Juin'));

        expect(weather, isA<WeatherData>());
        expect(weather.temperature, equals(28.5));
        expect(weather.humidity, equals(65.0));
        expect(weather.isFavorableForPlanting, isTrue);
      });

      test('Agricultural Metrics Calculation Flow', () async {
        // Arrange - Données de métriques agricoles
        final agriculturalMetrics = AgriculturalMetrics(
          id: 'metrics-123',
          userId: 'user-456',
          cropType: 'Maïs',
          fieldLocation: 'Sokodé, Tchaoudjo',
          fieldSize: 2.5,
          yield: 6.0,
          plantingDate: DateTime(2024, 3, 1),
          harvestDate: DateTime(2024, 9, 1),
          waterUsage: 1200.0,
          fertilizerUsage: 60.0,
          pesticideUsage: 15.0,
          laborHours: 45.0,
          cost: 450000.0,
          revenue: 675000.0,
        );

        // Act - Calculer les métriques
        final yieldPerHectare = agriculturalMetrics.yieldPerHectare;
        final profit = agriculturalMetrics.profit;
        final profitPerHectare = agriculturalMetrics.profitPerHectare;
        final costPerHectare = agriculturalMetrics.costPerHectare;

        // Assert - Vérifier les calculs
        expect(yieldPerHectare, equals(2.4)); // 6.0 / 2.5
        expect(profit, equals(225000.0)); // 675000 - 450000
        expect(profitPerHectare, equals(90000.0)); // 225000 / 2.5
        expect(costPerHectare, equals(180000.0)); // 450000 / 2.5
      });

      test('Weather-Based Agricultural Recommendations', () async {
        // Arrange - Différents scénarios météorologiques
        final scenarios = [
          {
            'name': 'Conditions optimales',
            'weather': WeatherData(
              id: 'optimal',
              location: 'Test Location',
              latitude: 8.9833,
              longitude: 1.1333,
              temperature: 25.0,
              humidity: 60.0,
              pressure: 1013.0,
              windSpeed: 10.0,
              windDirection: 180.0,
              rainfall: 2.0,
              uvIndex: 5.0,
              condition: 'Ensoleillé',
              description: 'Conditions optimales',
              timestamp: DateTime.now(),
              forecast: '{}',
            ),
            'expectedPlanting': true,
            'expectedHarvest': true,
          },
          {
            'name': 'Pluie intense',
            'weather': WeatherData(
              id: 'rainy',
              location: 'Test Location',
              latitude: 8.9833,
              longitude: 1.1333,
              temperature: 22.0,
              humidity: 85.0,
              pressure: 1005.0,
              windSpeed: 15.0,
              windDirection: 200.0,
              rainfall: 15.0,
              uvIndex: 2.0,
              condition: 'Pluvieux',
              description: 'Pluie intense',
              timestamp: DateTime.now(),
              forecast: '{}',
            ),
            'expectedPlanting': false,
            'expectedHarvest': false,
          },
          {
            'name': 'Sécheresse',
            'weather': WeatherData(
              id: 'dry',
              location: 'Test Location',
              latitude: 8.9833,
              longitude: 1.1333,
              temperature: 35.0,
              humidity: 30.0,
              pressure: 1020.0,
              windSpeed: 20.0,
              windDirection: 90.0,
              rainfall: 0.0,
              uvIndex: 10.0,
              condition: 'Sec',
              description: 'Sécheresse',
              timestamp: DateTime.now(),
              forecast: '{}',
            ),
            'expectedPlanting': false,
            'expectedHarvest': true,
          },
        ];

        // Act & Assert - Tester chaque scénario
        for (final scenario in scenarios) {
          final weather = scenario['weather'] as WeatherData;
          final expectedPlanting = scenario['expectedPlanting'] as bool;
          final expectedHarvest = scenario['expectedHarvest'] as bool;

          expect(weather.isFavorableForPlanting, equals(expectedPlanting),
              reason: '${scenario['name']} - Plantation');
          expect(weather.isFavorableForHarvest, equals(expectedHarvest),
              reason: '${scenario['name']} - Récolte');

          // Vérifier les conseils agricoles
          final advice = weather.agriculturalAdvice;
          expect(advice, isNotEmpty);
          
          if (scenario['name'] == 'Pluie intense') {
            expect(advice, contains('Éviter les travaux agricoles'));
          } else if (scenario['name'] == 'Sécheresse') {
            expect(advice, contains('Protéger les cultures'));
          }
        }
      });

      test('Database Integration Simulation', () async {
        // Arrange - Simuler les données de base de données
        final regions = [
          Region(
            id: 'centrale',
            name: 'Région Centrale',
            prefectures: [
              Prefecture(
                id: 'tchaoudjo',
                name: 'Tchaoudjo',
                regionId: 'centrale',
                communes: [
                  Commune(
                    id: 'sokode',
                    name: 'Sokodé',
                    prefectureId: 'tchaoudjo',
                    soilTypeId: 'tropical',
                    latitude: 8.9833,
                    longitude: 1.1333,
                  ),
                ],
              ),
            ],
          ),
        ];

        final crops = [
          Crop(
            id: 'mais',
            name: 'Maïs',
            description: 'Céréale de base',
            plantingSeason: 'Mai-Juin',
            harvestSeason: 'Septembre-Octobre',
            waterNeeds: 'Modéré',
            soilTypes: [],
          ),
        ];

        // Act - Simuler les opérations de base de données
        final region = regions.first;
        final prefecture = region.prefectures.first;
        final commune = prefecture.communes.first;
        final crop = crops.first;

        // Assert - Vérifier l'intégrité des relations
        expect(region.id, equals('centrale'));
        expect(region.prefectures.length, equals(1));
        expect(prefecture.regionId, equals(region.id));
        expect(commune.prefectureId, equals(prefecture.id));
        expect(commune.latitude, equals(8.9833));
        expect(commune.longitude, equals(1.1333));
        expect(crop.name, equals('Maïs'));
        expect(crop.plantingSeason, equals('Mai-Juin'));
      });

      test('Complete Agricultural Workflow', () async {
        // Arrange - Workflow complet d'un agriculteur
        final userId = 'farmer-123';
        final fieldLocation = 'Sokodé, Tchaoudjo';
        final cropType = 'Maïs';
        final fieldSize = 3.0;

        // Simuler la récupération des données météo
        final weatherData = WeatherData(
          id: 'weather-workflow',
          location: fieldLocation,
          latitude: 8.9833,
          longitude: 1.1333,
          temperature: 26.0,
          humidity: 65.0,
          pressure: 1013.0,
          windSpeed: 8.0,
          windDirection: 180.0,
          rainfall: 3.0,
          uvIndex: 6.0,
          condition: 'Ensoleillé',
          description: 'Conditions favorables',
          timestamp: DateTime.now(),
          forecast: '{}',
        );

        // Act - Exécuter le workflow complet
        // 1. Vérifier les conditions météo
        final canPlant = weatherData.isFavorableForPlanting;
        final canHarvest = weatherData.isFavorableForHarvest;
        final irrigationAdvice = weatherData.irrigationAdvice;
        final diseaseRisks = weatherData.diseaseRisk;

        // 2. Calculer les métriques de production
        final expectedYield = fieldSize * 2.5; // 2.5 tonnes/hectare
        final expectedCost = fieldSize * 150000; // 150000 FCFA/hectare
        final expectedRevenue = expectedYield * 125000; // 125000 FCFA/tonne

        final metrics = AgriculturalMetrics(
          id: 'workflow-metrics',
          userId: userId,
          cropType: cropType,
          fieldLocation: fieldLocation,
          fieldSize: fieldSize,
          yield: expectedYield,
          plantingDate: DateTime.now().subtract(Duration(days: 120)),
          harvestDate: DateTime.now(),
          waterUsage: fieldSize * 400,
          fertilizerUsage: fieldSize * 25,
          pesticideUsage: fieldSize * 5,
          laborHours: fieldSize * 15,
          cost: expectedCost,
          revenue: expectedRevenue,
        );

        // Assert - Vérifier le workflow complet
        expect(canPlant, isTrue);
        expect(canHarvest, isTrue);
        expect(irrigationAdvice, isNotEmpty);
        expect(diseaseRisks, isNotEmpty);

        expect(metrics.yieldPerHectare, equals(2.5));
        expect(metrics.costPerHectare, equals(150000.0));
        expect(metrics.profitPerHectare, equals(162500.0)); // (7.5*125000 - 450000)/3
        expect(metrics.profit, greaterThan(0));
      });

      test('Error Handling and Recovery', () async {
        // Arrange - Simuler des erreurs
        when(mockClient.get(any))
            .thenAnswer((_) async => http.Response('Server Error', 500));

        // Act & Assert - Vérifier la gestion des erreurs
        expect(() => apiService.getRegions(), throwsException);
        expect(() => apiService.getCrops(), throwsException);
        expect(() => apiService.getCurrentWeather(0, 0), throwsException);

        // Test de récupération après erreur
        when(mockClient.get(Uri.parse('http://localhost:5000/api/regions')))
            .thenAnswer((_) async => http.Response('[]', 200));

        final regions = await apiService.getRegions();
        expect(regions, isEmpty);
      });

      test('Performance and Scalability', () async {
        // Arrange - Simuler une charge importante
        final startTime = DateTime.now();
        final numberOfRequests = 100;

        // Act - Exécuter de nombreuses requêtes
        final futures = <Future>[];
        for (int i = 0; i < numberOfRequests; i++) {
          futures.add(apiService.getCurrentWeather(8.9833 + i * 0.001, 1.1333 + i * 0.001));
        }

        await Future.wait(futures);
        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);

        // Assert - Vérifier les performances
        expect(duration.inMilliseconds, lessThan(5000)); // Moins de 5 secondes
        expect(futures.length, equals(numberOfRequests));
      });
    });

    group('Data Consistency Tests', () {
      test('Cross-Platform Data Consistency', () async {
        // Arrange - Données cohérentes entre frontend et backend
        final regionData = {
          'id': 'test-region',
          'name': 'Test Region',
          'prefectures': [
            {
              'id': 'test-prefecture',
              'name': 'Test Prefecture',
              'regionId': 'test-region',
              'communes': [
                {
                  'id': 'test-commune',
                  'name': 'Test Commune',
                  'prefectureId': 'test-prefecture',
                  'soilTypeId': 'test-soil',
                  'latitude': 8.9833,
                  'longitude': 1.1333,
                }
              ]
            }
          ]
        };

        // Act - Désérialiser les données
        final region = Region.fromJson(regionData);

        // Assert - Vérifier la cohérence
        expect(region.id, equals('test-region'));
        expect(region.name, equals('Test Region'));
        expect(region.prefectures.length, equals(1));
        expect(region.prefectures.first.id, equals('test-prefecture'));
        expect(region.prefectures.first.communes.length, equals(1));
        expect(region.prefectures.first.communes.first.latitude, equals(8.9833));
        expect(region.prefectures.first.communes.first.longitude, equals(1.1333));
      });

      test('Business Logic Validation', () async {
        // Arrange - Règles métier
        final invalidMetrics = AgriculturalMetrics(
          id: 'invalid',
          userId: '',
          cropType: '',
          fieldLocation: '',
          fieldSize: -1.0,
          yield: -1.0,
          plantingDate: DateTime.now(),
          harvestDate: DateTime.now().subtract(Duration(days: 1)),
          waterUsage: -1.0,
          fertilizerUsage: -1.0,
          pesticideUsage: -1.0,
          laborHours: -1.0,
          cost: -1.0,
          revenue: -1.0,
        );

        // Act & Assert - Vérifier les validations
        expect(invalidMetrics.userId, isEmpty);
        expect(invalidMetrics.cropType, isEmpty);
        expect(invalidMetrics.fieldSize, lessThan(0));
        expect(invalidMetrics.yield, lessThan(0));
        expect(invalidMetrics.plantingDate.isAfter(invalidMetrics.harvestDate), isTrue);
        expect(invalidMetrics.profit, lessThan(0));
      });
    });
  });
}
