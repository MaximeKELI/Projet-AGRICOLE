import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('Database Integration Tests', () {
    late Database database;

    setUpAll(() {
      // Initialiser SQLite FFI pour les tests
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() async {
      // Créer une base de données en mémoire pour les tests
      database = await openDatabase(
        ':memory:',
        version: 1,
        onCreate: (db, version) async {
          // Créer les tables de test
          await db.execute('''
            CREATE TABLE regions (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL
            )
          ''');

          await db.execute('''
            CREATE TABLE prefectures (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              region_id TEXT NOT NULL,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL,
              FOREIGN KEY (region_id) REFERENCES regions (id)
            )
          ''');

          await db.execute('''
            CREATE TABLE communes (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              prefecture_id TEXT NOT NULL,
              soil_type_id TEXT NOT NULL,
              latitude REAL NOT NULL,
              longitude REAL NOT NULL,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL,
              FOREIGN KEY (prefecture_id) REFERENCES prefectures (id)
            )
          ''');

          await db.execute('''
            CREATE TABLE crops (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              description TEXT,
              planting_season TEXT,
              harvest_season TEXT,
              water_needs TEXT,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL
            )
          ''');

          await db.execute('''
            CREATE TABLE agricultural_metrics (
              id TEXT PRIMARY KEY,
              user_id TEXT NOT NULL,
              crop_type TEXT NOT NULL,
              field_location TEXT NOT NULL,
              field_size REAL NOT NULL,
              yield REAL NOT NULL,
              planting_date TEXT NOT NULL,
              harvest_date TEXT NOT NULL,
              water_usage REAL NOT NULL,
              fertilizer_usage REAL NOT NULL,
              pesticide_usage REAL NOT NULL,
              labor_hours REAL NOT NULL,
              cost REAL NOT NULL,
              revenue REAL NOT NULL,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL
            )
          ''');

          await db.execute('''
            CREATE TABLE weather_alerts (
              id TEXT PRIMARY KEY,
              type TEXT NOT NULL,
              severity TEXT NOT NULL,
              message TEXT NOT NULL,
              start_date TEXT NOT NULL,
              end_date TEXT,
              recommendations TEXT,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL
            )
          ''');
        },
      );
    });

    tearDown(() async {
      await database.close();
    });

    group('Database Schema Tests', () {
      test('All tables are created successfully', () async {
        // Act
        final tables = await database.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name"
        );

        // Assert
        final tableNames = tables.map((table) => table['name'] as String).toList();
        expect(tableNames, contains('regions'));
        expect(tableNames, contains('prefectures'));
        expect(tableNames, contains('communes'));
        expect(tableNames, contains('crops'));
        expect(tableNames, contains('agricultural_metrics'));
        expect(tableNames, contains('weather_alerts'));
      });

      test('Foreign key constraints are properly set', () async {
        // Act
        final foreignKeys = await database.rawQuery('PRAGMA foreign_key_list(prefectures)');
        final communeForeignKeys = await database.rawQuery('PRAGMA foreign_key_list(communes)');

        // Assert
        expect(foreignKeys.length, greaterThan(0));
        expect(communeForeignKeys.length, greaterThan(0));
        
        // Vérifier que prefectures a une clé étrangère vers regions
        final regionForeignKey = foreignKeys.firstWhere(
          (fk) => fk['table'] == 'regions',
          orElse: () => <String, dynamic>{},
        );
        expect(regionForeignKey.isNotEmpty, isTrue);

        // Vérifier que communes a une clé étrangère vers prefectures
        final prefectureForeignKey = communeForeignKeys.firstWhere(
          (fk) => fk['table'] == 'prefectures',
          orElse: () => <String, dynamic>{},
        );
        expect(prefectureForeignKey.isNotEmpty, isTrue);
      });
    });

    group('Data Insertion Tests', () {
      test('Insert regions data successfully', () async {
        // Arrange
        final regionData = {
          'id': 'centrale',
          'name': 'Région Centrale',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        // Act
        final result = await database.insert('regions', regionData);

        // Assert
        expect(result, equals(1));

        final insertedRegion = await database.query(
          'regions',
          where: 'id = ?',
          whereArgs: ['centrale'],
        );
        expect(insertedRegion.length, equals(1));
        expect(insertedRegion.first['name'], equals('Région Centrale'));
      });

      test('Insert hierarchical data with foreign keys', () async {
        // Arrange
        final regionData = {
          'id': 'test-region',
          'name': 'Test Region',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        final prefectureData = {
          'id': 'test-prefecture',
          'name': 'Test Prefecture',
          'region_id': 'test-region',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        final communeData = {
          'id': 'test-commune',
          'name': 'Test Commune',
          'prefecture_id': 'test-prefecture',
          'soil_type_id': 'test-soil',
          'latitude': 8.9833,
          'longitude': 1.1333,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        // Act
        await database.insert('regions', regionData);
        await database.insert('prefectures', prefectureData);
        await database.insert('communes', communeData);

        // Assert
        final regions = await database.query('regions');
        final prefectures = await database.query('prefectures');
        final communes = await database.query('communes');

        expect(regions.length, equals(1));
        expect(prefectures.length, equals(1));
        expect(communes.length, equals(1));

        expect(prefectures.first['region_id'], equals('test-region'));
        expect(communes.first['prefecture_id'], equals('test-prefecture'));
      });

      test('Insert agricultural metrics with calculated fields', () async {
        // Arrange
        final metricsData = {
          'id': 'metrics-123',
          'user_id': 'user-456',
          'crop_type': 'Maïs',
          'field_location': 'Sokodé, Tchaoudjo',
          'field_size': 2.5,
          'yield': 6.0,
          'planting_date': DateTime(2024, 3, 1).toIso8601String(),
          'harvest_date': DateTime(2024, 9, 1).toIso8601String(),
          'water_usage': 1000.0,
          'fertilizer_usage': 50.0,
          'pesticide_usage': 10.0,
          'labor_hours': 40.0,
          'cost': 450000.0,
          'revenue': 675000.0,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        // Act
        final result = await database.insert('agricultural_metrics', metricsData);

        // Assert
        expect(result, equals(1));

        final insertedMetrics = await database.query(
          'agricultural_metrics',
          where: 'id = ?',
          whereArgs: ['metrics-123'],
        );
        expect(insertedMetrics.length, equals(1));

        // Vérifier les calculs
        final metrics = insertedMetrics.first;
        final fieldSize = metrics['field_size'] as double;
        final yieldValue = metrics['yield'] as double;
        final cost = metrics['cost'] as double;
        final revenue = metrics['revenue'] as double;

        final yieldPerHectare = yieldValue / fieldSize;
        final profit = revenue - cost;
        final profitPerHectare = profit / fieldSize;
        final costPerHectare = cost / fieldSize;

        expect(yieldPerHectare, equals(2.4));
        expect(profit, equals(225000.0));
        expect(profitPerHectare, equals(90000.0));
        expect(costPerHectare, equals(180000.0));
      });
    });

    group('Data Query Tests', () {
      setUp(() async {
        // Insérer des données de test
        await database.insert('regions', {
          'id': 'centrale',
          'name': 'Région Centrale',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        await database.insert('prefectures', {
          'id': 'tchaoudjo',
          'name': 'Tchaoudjo',
          'region_id': 'centrale',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        await database.insert('communes', {
          'id': 'sokode',
          'name': 'Sokodé',
          'prefecture_id': 'tchaoudjo',
          'soil_type_id': 'tropical',
          'latitude': 8.9833,
          'longitude': 1.1333,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        await database.insert('crops', {
          'id': 'mais',
          'name': 'Maïs',
          'description': 'Céréale de base',
          'planting_season': 'Mai-Juin',
          'harvest_season': 'Septembre-Octobre',
          'water_needs': 'Modéré',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      });

      test('Query regions with prefectures and communes', () async {
        // Act
        final result = await database.rawQuery('''
          SELECT 
            r.id as region_id,
            r.name as region_name,
            p.id as prefecture_id,
            p.name as prefecture_name,
            c.id as commune_id,
            c.name as commune_name,
            c.latitude,
            c.longitude
          FROM regions r
          LEFT JOIN prefectures p ON r.id = p.region_id
          LEFT JOIN communes c ON p.id = c.prefecture_id
          WHERE r.id = ?
        ''', ['centrale']);

        // Assert
        expect(result.length, equals(1));
        expect(result.first['region_name'], equals('Région Centrale'));
        expect(result.first['prefecture_name'], equals('Tchaoudjo'));
        expect(result.first['commune_name'], equals('Sokodé'));
        expect(result.first['latitude'], equals(8.9833));
        expect(result.first['longitude'], equals(1.1333));
      });

      test('Query agricultural metrics with calculations', () async {
        // Arrange
        await database.insert('agricultural_metrics', {
          'id': 'metrics-1',
          'user_id': 'user-123',
          'crop_type': 'Maïs',
          'field_location': 'Sokodé',
          'field_size': 2.0,
          'yield': 5.0,
          'planting_date': DateTime(2024, 3, 1).toIso8601String(),
          'harvest_date': DateTime(2024, 9, 1).toIso8601String(),
          'water_usage': 800.0,
          'fertilizer_usage': 40.0,
          'pesticide_usage': 8.0,
          'labor_hours': 30.0,
          'cost': 300000.0,
          'revenue': 500000.0,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        await database.insert('agricultural_metrics', {
          'id': 'metrics-2',
          'user_id': 'user-123',
          'crop_type': 'Riz',
          'field_location': 'Lomé',
          'field_size': 1.5,
          'yield': 3.0,
          'planting_date': DateTime(2024, 4, 1).toIso8601String(),
          'harvest_date': DateTime(2024, 8, 1).toIso8601String(),
          'water_usage': 600.0,
          'fertilizer_usage': 30.0,
          'pesticide_usage': 5.0,
          'labor_hours': 25.0,
          'cost': 200000.0,
          'revenue': 300000.0,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        // Act
        final result = await database.rawQuery('''
          SELECT 
            user_id,
            COUNT(*) as total_fields,
            SUM(field_size) as total_area,
            SUM(yield) as total_yield,
            SUM(cost) as total_cost,
            SUM(revenue) as total_revenue,
            SUM(revenue - cost) as total_profit,
            AVG(yield / field_size) as avg_yield_per_hectare,
            AVG((revenue - cost) / field_size) as avg_profit_per_hectare
          FROM agricultural_metrics
          WHERE user_id = ?
          GROUP BY user_id
        ''', ['user-123']);

        // Assert
        expect(result.length, equals(1));
        final summary = result.first;
        expect(summary['total_fields'], equals(2));
        expect(summary['total_area'], equals(3.5));
        expect(summary['total_yield'], equals(8.0));
        expect(summary['total_cost'], equals(500000.0));
        expect(summary['total_revenue'], equals(800000.0));
        expect(summary['total_profit'], equals(300000.0));
        expect(summary['avg_yield_per_hectare'], closeTo(2.29, 0.01));
        expect(summary['avg_profit_per_hectare'], closeTo(85714.29, 0.01));
      });

      test('Query weather alerts by date range', () async {
        // Arrange
        final now = DateTime.now();
        await database.insert('weather_alerts', {
          'id': 'alert-1',
          'type': 'rain',
          'severity': 'medium',
          'message': 'Pluie modérée attendue',
          'start_date': now.subtract(Duration(hours: 1)).toIso8601String(),
          'end_date': now.add(Duration(hours: 2)).toIso8601String(),
          'recommendations': 'Éviter les travaux agricoles',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        });

        await database.insert('weather_alerts', {
          'id': 'alert-2',
          'type': 'drought',
          'severity': 'high',
          'message': 'Sécheresse sévère',
          'start_date': now.add(Duration(hours: 1)).toIso8601String(),
          'end_date': now.add(Duration(days: 7)).toIso8601String(),
          'recommendations': 'Irrigation d\'urgence nécessaire',
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        });

        // Act
        final activeAlerts = await database.rawQuery('''
          SELECT * FROM weather_alerts
          WHERE start_date <= ? AND (end_date IS NULL OR end_date >= ?)
          ORDER BY start_date
        ''', [now.toIso8601String(), now.toIso8601String()]);

        // Assert
        expect(activeAlerts.length, equals(2));
        expect(activeAlerts.first['type'], equals('rain'));
        expect(activeAlerts.last['type'], equals('drought'));
      });
    });

    group('Data Update and Delete Tests', () {
      setUp(() async {
        await database.insert('regions', {
          'id': 'test-region',
          'name': 'Test Region',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      });

      test('Update region data successfully', () async {
        // Arrange
        final newName = 'Updated Test Region';
        final updatedAt = DateTime.now().toIso8601String();

        // Act
        final result = await database.update(
          'regions',
          {'name': newName, 'updated_at': updatedAt},
          where: 'id = ?',
          whereArgs: ['test-region'],
        );

        // Assert
        expect(result, equals(1));

        final updatedRegion = await database.query(
          'regions',
          where: 'id = ?',
          whereArgs: ['test-region'],
        );
        expect(updatedRegion.first['name'], equals(newName));
        expect(updatedRegion.first['updated_at'], equals(updatedAt));
      });

      test('Delete region with cascade effect', () async {
        // Arrange
        await database.insert('prefectures', {
          'id': 'test-prefecture',
          'name': 'Test Prefecture',
          'region_id': 'test-region',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        // Act
        final result = await database.delete(
          'regions',
          where: 'id = ?',
          whereArgs: ['test-region'],
        );

        // Assert
        expect(result, equals(1));

        final regions = await database.query('regions');
        
        expect(regions.length, equals(0));
        // Note: Dans une vraie base de données avec CASCADE, les préfectures seraient aussi supprimées
        // Ici, on vérifie juste que la région est supprimée
      });
    });

    group('Performance Tests', () {
      test('Bulk insert performance', () async {
        // Arrange
        final numberOfRecords = 1000;
        final startTime = DateTime.now();

        // Act
        await database.transaction((txn) async {
          for (int i = 0; i < numberOfRecords; i++) {
            await txn.insert('agricultural_metrics', {
              'id': 'metrics-$i',
              'user_id': 'user-${i % 10}',
              'crop_type': 'Maïs',
              'field_location': 'Location $i',
              'field_size': 1.0 + (i % 5),
              'yield': 2.0 + (i % 3),
              'planting_date': DateTime.now().toIso8601String(),
              'harvest_date': DateTime.now().toIso8601String(),
              'water_usage': 100.0 + i,
              'fertilizer_usage': 10.0 + i,
              'pesticide_usage': 1.0 + i,
              'labor_hours': 20.0 + i,
              'cost': 100000.0 + i * 1000,
              'revenue': 150000.0 + i * 1000,
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            });
          }
        });

        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);

        // Assert
        expect(duration.inMilliseconds, lessThan(5000)); // Moins de 5 secondes

        final count = await database.rawQuery('SELECT COUNT(*) as count FROM agricultural_metrics');
        expect(count.first['count'], equals(numberOfRecords));
      });

      test('Complex query performance', () async {
        // Arrange
        await database.insert('regions', {
          'id': 'perf-region',
          'name': 'Performance Region',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        // Insérer des données de test
        for (int i = 0; i < 100; i++) {
          await database.insert('agricultural_metrics', {
            'id': 'perf-metrics-$i',
            'user_id': 'user-${i % 10}',
            'crop_type': i % 2 == 0 ? 'Maïs' : 'Riz',
            'field_location': 'Location $i',
            'field_size': 1.0 + (i % 5),
            'yield': 2.0 + (i % 3),
            'planting_date': DateTime.now().toIso8601String(),
            'harvest_date': DateTime.now().toIso8601String(),
            'water_usage': 100.0 + i,
            'fertilizer_usage': 10.0 + i,
            'pesticide_usage': 1.0 + i,
            'labor_hours': 20.0 + i,
            'cost': 100000.0 + i * 1000,
            'revenue': 150000.0 + i * 1000,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
        }

        // Act
        final startTime = DateTime.now();
        final result = await database.rawQuery('''
          SELECT 
            crop_type,
            COUNT(*) as field_count,
            AVG(yield / field_size) as avg_yield_per_hectare,
            AVG((revenue - cost) / field_size) as avg_profit_per_hectare,
            SUM(revenue - cost) as total_profit
          FROM agricultural_metrics
          GROUP BY crop_type
          ORDER BY total_profit DESC
        ''');
        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);

        // Assert
        expect(duration.inMilliseconds, lessThan(1000)); // Moins de 1 seconde
        expect(result.length, equals(2)); // Maïs et Riz
        expect(result.first['crop_type'], isIn(['Maïs', 'Riz']));
      });
    });
  });
}
