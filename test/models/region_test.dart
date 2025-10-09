import 'package:flutter_test/flutter_test.dart';
import 'package:projet_agricole/models/region.dart';

void main() {
  group('Region Model Tests', () {
    test('should create region from JSON', () {
      // Arrange
      final json = {
        'id': 'centrale',
        'name': 'Région Centrale',
        'prefectures': [
          {
            'id': 'tchaoudjo',
            'name': 'Tchaoudjo',
            'regionId': 'centrale',
            'communes': [
              {
                'id': 'sokode',
                'name': 'Sokodé',
                'prefectureId': 'tchaoudjo',
                'soilTypeId': 'tropical',
                'latitude': 8.9833,
                'longitude': 1.1333
              }
            ]
          }
        ]
      };

      // Act
      final region = Region.fromJson(json);

      // Assert
      expect(region.id, equals('centrale'));
      expect(region.name, equals('Région Centrale'));
      expect(region.prefectures.length, equals(1));
      expect(region.prefectures.first.id, equals('tchaoudjo'));
      expect(region.prefectures.first.communes.length, equals(1));
      expect(region.prefectures.first.communes.first.name, equals('Sokodé'));
    });

    test('should convert region to JSON', () {
      // Arrange
      final region = Region(
        id: 'test-id',
        name: 'Test Region',
        prefectures: [],
      );

      // Act
      final json = region.toJson();

      // Assert
      expect(json['id'], equals('test-id'));
      expect(json['name'], equals('Test Region'));
      expect(json['prefectures'], isA<List>());
    });

    test('should handle null prefectures', () {
      // Arrange
      final json = {
        'id': 'test',
        'name': 'Test Region',
        'prefectures': null
      };

      // Act
      final region = Region.fromJson(json);

      // Assert
      expect(region.prefectures, isEmpty);
    });
  });
}
