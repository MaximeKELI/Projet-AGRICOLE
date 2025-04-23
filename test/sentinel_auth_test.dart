import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  group('Sentinel Hub Authentication Tests', () {
    const String clientId = '177c8a67-3479-4bb7-aca2-60828ab3d919';
    const String clientSecret = 'CGx9UfyFVYgrhhU8IMln4gXl0J90cZYl';
    const String tokenEndpoint = 'https://services.sentinel-hub.com/oauth/token';

    test('Authentication request returns 200 status code', () async {
      final response = await http.post(
        Uri.parse(tokenEndpoint),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'client_credentials',
          'client_id': clientId,
          'client_secret': clientSecret,
        },
      );

      expect(response.statusCode, 200);
    });

    test('Authentication response contains access token', () async {
      final response = await http.post(
        Uri.parse(tokenEndpoint),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'client_credentials',
          'client_id': clientId,
          'client_secret': clientSecret,
        },
      );

      final data = json.decode(response.body);
      expect(data, contains('access_token'));
      expect(data['access_token'], isA<String>());
      expect(data['access_token'].length, greaterThan(0));
    });

    test('Authentication response contains token type', () async {
      final response = await http.post(
        Uri.parse(tokenEndpoint),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'client_credentials',
          'client_id': clientId,
          'client_secret': clientSecret,
        },
      );

      final data = json.decode(response.body);
      expect(data, contains('token_type'));
      expect(data['token_type'], equals('Bearer'));
    });

    test('Authentication response contains expires_in', () async {
      final response = await http.post(
        Uri.parse(tokenEndpoint),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'client_credentials',
          'client_id': clientId,
          'client_secret': clientSecret,
        },
      );

      final data = json.decode(response.body);
      expect(data, contains('expires_in'));
      expect(data['expires_in'], isA<int>());
      expect(data['expires_in'], greaterThan(0));
    });
  });
} 