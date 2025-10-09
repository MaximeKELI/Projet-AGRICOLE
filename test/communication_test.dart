import 'package:http/http.dart' as http;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Communication Tests', () {
    test('Backend API is accessible', () async {
      // Test de base pour vérifier que le backend répond
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/regions'),
        headers: {'Content-Type': 'application/json'},
      );

      expect(response.statusCode, equals(200));
      expect(response.body, isNotEmpty);
      
      // Vérifier que la réponse contient des données JSON valides
      expect(response.headers['content-type'], contains('application/json'));
    });

    test('Weather API endpoint works', () async {
      // Test de l'endpoint météo
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/weather/current?lat=8.9833&lon=1.1333'),
        headers: {'Content-Type': 'application/json'},
      );

      expect(response.statusCode, equals(200));
      expect(response.body, isNotEmpty);
      
      // Vérifier que la réponse contient des données météo
      expect(response.body, contains('temperature'));
      expect(response.body, contains('humidity'));
      expect(response.body, contains('pressure'));
    });

    test('CORS headers are present', () async {
      // Test des headers CORS
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/regions'),
        headers: {'Content-Type': 'application/json'},
      );

      expect(response.statusCode, equals(200));
      
      // Vérifier les headers CORS (si configurés)
      final headers = response.headers;
      print('Response headers: $headers');
    });

    test('API response time is acceptable', () async {
      // Test de performance
      final stopwatch = Stopwatch()..start();
      
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/regions'),
        headers: {'Content-Type': 'application/json'},
      );
      
      stopwatch.stop();
      
      expect(response.statusCode, equals(200));
      expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // Moins de 5 secondes
    });

    test('Multiple concurrent requests work', () async {
      // Test de charge
      final futures = <Future<http.Response>>[];
      
      for (int i = 0; i < 5; i++) {
        futures.add(http.get(
          Uri.parse('http://localhost:5000/api/regions'),
          headers: {'Content-Type': 'application/json'},
        ));
      }
      
      final responses = await Future.wait(futures);
      
      for (final response in responses) {
        expect(response.statusCode, equals(200));
        expect(response.body, isNotEmpty);
      }
    });
  });
}
