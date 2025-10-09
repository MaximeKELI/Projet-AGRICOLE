import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Simple Communication Tests', () {
    const String baseUrl = 'http://localhost:5000';

    test('Backend is running and accessible', () async {
      final response = await http.get(Uri.parse('$baseUrl/api/regions'));
      expect(response.statusCode, 200);
      final regions = json.decode(response.body) as List;
      expect(regions.length, greaterThan(0));
      print('✅ Backend accessible - ${regions.length} régions trouvées');
    });

    test('Weather API is working', () async {
      final response = await http.get(
        Uri.parse('$baseUrl/api/Weather/current?lat=8.9833&lon=1.1333'),
      );
      expect(response.statusCode, 200);
      final weather = json.decode(response.body) as Map<String, dynamic>;
      expect(weather, containsPair('temperature', isA<num>()));
      print('✅ API météo fonctionnelle - Température: ${weather['temperature']}°C');
    });

    test('Crops API is working', () async {
      final response = await http.get(Uri.parse('$baseUrl/api/Crops'));
      expect(response.statusCode, 200);
      final crops = json.decode(response.body) as List;
      expect(crops.length, greaterThan(0));
      print('✅ API cultures fonctionnelle - ${crops.length} cultures trouvées');
    });

    test('Database is accessible through API', () async {
      // Test de récupération des communes
      final response = await http.get(Uri.parse('$baseUrl/api/Regions/centrale/prefectures'));
      expect(response.statusCode, 200);
      final prefectures = json.decode(response.body) as List;
      expect(prefectures.length, greaterThan(0));
      print('✅ Base de données accessible - ${prefectures.length} préfectures trouvées');
    });

    test('Complete data flow test', () async {
      // 1. Récupérer les régions
      final regionsResponse = await http.get(Uri.parse('$baseUrl/api/regions'));
      expect(regionsResponse.statusCode, 200);
      final regions = json.decode(regionsResponse.body) as List;
      print('✅ Étape 1: ${regions.length} régions récupérées');

      // 2. Récupérer les cultures
      final cropsResponse = await http.get(Uri.parse('$baseUrl/api/Crops'));
      expect(cropsResponse.statusCode, 200);
      final crops = json.decode(cropsResponse.body) as List;
      print('✅ Étape 2: ${crops.length} cultures récupérées');

      // 3. Récupérer les données météo
      final weatherResponse = await http.get(
        Uri.parse('$baseUrl/api/Weather/current?lat=8.9833&lon=1.1333'),
      );
      expect(weatherResponse.statusCode, 200);
      final weather = json.decode(weatherResponse.body) as Map<String, dynamic>;
      print('✅ Étape 3: Données météo récupérées - ${weather['temperature']}°C');

      // 4. Récupérer les préfectures d'une région
      final prefecturesResponse = await http.get(
        Uri.parse('$baseUrl/api/Regions/centrale/prefectures'),
      );
      expect(prefecturesResponse.statusCode, 200);
      final prefectures = json.decode(prefecturesResponse.body) as List;
      print('✅ Étape 4: ${prefectures.length} préfectures récupérées');

      // 5. Récupérer les communes d'une préfecture
      if (prefectures.isNotEmpty) {
        final prefectureId = prefectures.first['id'] as String;
        final communesResponse = await http.get(
          Uri.parse('$baseUrl/api/Prefectures/$prefectureId/communes'),
        );
        expect(communesResponse.statusCode, 200);
        final communes = json.decode(communesResponse.body) as List;
        print('✅ Étape 5: ${communes.length} communes récupérées');
      }

      print('✅ Test de flux de données complet réussi !');
    });
  });
}
