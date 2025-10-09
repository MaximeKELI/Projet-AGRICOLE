import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyUserData = 'user_data';
  static const String _keyDashboardData = 'dashboard_data';
  static const String _keySettings = 'app_settings';
  static const String _keyOfflineData = 'offline_data';
  static const String _keySyncQueue = 'sync_queue';
  static const String _keyLastSync = 'last_sync';

  // Sauvegarder les données utilisateur
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserData, jsonEncode(userData));
  }

  // Charger les données utilisateur
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_keyUserData);
    if (userDataString != null) {
      return jsonDecode(userDataString) as Map<String, dynamic>;
    }
    return null;
  }

  // Sauvegarder les données du dashboard
  static Future<void> saveDashboardData(Map<String, dynamic> dashboardData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDashboardData, jsonEncode(dashboardData));
  }

  // Charger les données du dashboard
  static Future<Map<String, dynamic>?> getDashboardData() async {
    final prefs = await SharedPreferences.getInstance();
    final dashboardDataString = prefs.getString(_keyDashboardData);
    if (dashboardDataString != null) {
      return jsonDecode(dashboardDataString) as Map<String, dynamic>;
    }
    return null;
  }

  // Sauvegarder les paramètres
  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySettings, jsonEncode(settings));
  }

  // Charger les paramètres
  static Future<Map<String, dynamic>?> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsString = prefs.getString(_keySettings);
    if (settingsString != null) {
      return jsonDecode(settingsString) as Map<String, dynamic>;
    }
    return null;
  }

  // Sauvegarder les données hors ligne
  static Future<void> saveOfflineData(String key, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final offlineData = await getOfflineData();
    offlineData[key] = data;
    await prefs.setString(_keyOfflineData, jsonEncode(offlineData));
  }

  // Charger les données hors ligne
  static Future<Map<String, dynamic>> getOfflineData() async {
    final prefs = await SharedPreferences.getInstance();
    final offlineDataString = prefs.getString(_keyOfflineData);
    if (offlineDataString != null) {
      return jsonDecode(offlineDataString) as Map<String, dynamic>;
    }
    return {};
  }

  // Ajouter une action à la queue de synchronisation
  static Future<void> addToSyncQueue(String action, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final syncQueue = await getSyncQueue();
    syncQueue.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'action': action,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
      'retryCount': 0,
    });
    await prefs.setString(_keySyncQueue, jsonEncode(syncQueue));
  }

  // Obtenir la queue de synchronisation
  static Future<List<Map<String, dynamic>>> getSyncQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final syncQueueString = prefs.getString(_keySyncQueue);
    if (syncQueueString != null) {
      final List<dynamic> queue = jsonDecode(syncQueueString);
      return queue.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Nettoyer la queue de synchronisation
  static Future<void> clearSyncQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySyncQueue);
  }

  // Marquer la dernière synchronisation
  static Future<void> markLastSync() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastSync, DateTime.now().toIso8601String());
  }

  // Obtenir la dernière synchronisation
  static Future<DateTime?> getLastSync() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSyncString = prefs.getString(_keyLastSync);
    if (lastSyncString != null) {
      return DateTime.parse(lastSyncString);
    }
    return null;
  }

  // Vérifier si les données sont périmées
  static Future<bool> isDataStale({Duration maxAge = const Duration(minutes: 30)}) async {
    final lastSync = await getLastSync();
    if (lastSync == null) return true;
    return DateTime.now().difference(lastSync) > maxAge;
  }

  // Sauvegarder les données de cache
  static Future<void> saveCacheData(String key, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await prefs.setString('cache_$key', jsonEncode(cacheData));
  }

  // Charger les données de cache
  static Future<Map<String, dynamic>?> getCacheData(String key, {Duration maxAge = const Duration(hours: 1)}) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheString = prefs.getString('cache_$key');
    if (cacheString != null) {
      final cacheData = jsonDecode(cacheString) as Map<String, dynamic>;
      final timestamp = DateTime.parse(cacheData['timestamp']);
      if (DateTime.now().difference(timestamp) <= maxAge) {
        return cacheData['data'] as Map<String, dynamic>;
      }
    }
    return null;
  }

  // Nettoyer le cache
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (String key in keys) {
      if (key.startsWith('cache_')) {
        await prefs.remove(key);
      }
    }
  }

  // Obtenir la taille du stockage utilisé
  static Future<int> getStorageSize() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    int totalSize = 0;
    for (String key in keys) {
      final value = prefs.getString(key);
      if (value != null) {
        totalSize += value.length;
      }
    }
    return totalSize;
  }

  // Nettoyer les données anciennes
  static Future<void> cleanupOldData({Duration maxAge = const Duration(days: 30)}) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final cutoffDate = DateTime.now().subtract(maxAge);
    
    for (String key in keys) {
      if (key.startsWith('cache_')) {
        final value = prefs.getString(key);
        if (value != null) {
          try {
            final data = jsonDecode(value) as Map<String, dynamic>;
            final timestamp = DateTime.parse(data['timestamp']);
            if (timestamp.isBefore(cutoffDate)) {
              await prefs.remove(key);
            }
          } catch (e) {
            // Ignorer les erreurs de parsing
          }
        }
      }
    }
  }
}
