import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'storage_service.dart';
import 'payment_service.dart';
import 'logistics_service.dart';
import 'marketplace_service.dart';
import 'agricultural_service.dart';
import 'certification_service.dart';
import 'export_import_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncService {
  static Timer? _syncTimer;
  static bool _isOnline = true;
  static StreamController<bool> _connectionController = StreamController<bool>.broadcast();

  // Stream pour écouter les changements de connectivité
  static Stream<bool> get connectionStream => _connectionController.stream;

  // Vérifier la connectivité
  static Future<bool> checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      _isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      _isOnline = false;
    }
    _connectionController.add(_isOnline);
    return _isOnline;
  }

  // Démarrer la synchronisation automatique
  static void startAutoSync({Duration interval = const Duration(minutes: 5)}) {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(interval, (timer) async {
      if (await checkConnectivity()) {
        await syncPendingData();
      }
    });
  }

  // Arrêter la synchronisation automatique
  static void stopAutoSync() {
    _syncTimer?.cancel();
  }

  // Synchroniser toutes les données
  static Future<void> syncAllData() async {
    if (!await checkConnectivity()) {
      throw Exception('Pas de connexion internet');
    }

    try {
      // Synchroniser les données du dashboard
      await _syncDashboardData();
      
      // Synchroniser les données de la marketplace
      await _syncMarketplaceData();
      
      // Synchroniser les données de paiement
      await _syncPaymentData();
      
      // Synchroniser les données de logistique
      await _syncLogisticsData();
      
      // Synchroniser les données de certification
      await _syncCertificationData();
      
      // Synchroniser les données d'export/import
      await _syncExportImportData();
      
      // Marquer la synchronisation comme terminée
      await StorageService.markLastSync();
      
      print('Synchronisation terminée avec succès');
    } catch (e) {
      print('Erreur lors de la synchronisation: $e');
      rethrow;
    }
  }

  // Synchroniser les données du dashboard
  static Future<void> _syncDashboardData() async {
    try {
      final agriculturalService = AgriculturalService();
      final userEmail = 'user@example.com'; // Récupérer depuis les données utilisateur
      
      final summary = await agriculturalService.getDashboardSummary(userEmail);
      final alerts = await agriculturalService.getAgriculturalAlerts(userEmail);
      
      await StorageService.saveDashboardData({
        'summary': {
          'totalCrops': summary.totalCrops,
          'totalArea': summary.totalArea,
          'totalRevenue': summary.totalRevenue,
          'totalProfit': summary.totalProfit,
          'recentCrops': summary.recentCrops.map((crop) => {
            'id': crop.id,
            'cropType': crop.cropType,
            'area': crop.area,
            'expectedYield': crop.expectedYield,
            'actualYield': crop.actualYield,
            'efficiency': crop.efficiency,
            'region': crop.region,
            'status': crop.status,
          }).toList(),
        },
        'alerts': alerts,
        'lastSync': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Erreur sync dashboard: $e');
    }
  }

  // Synchroniser les données de la marketplace
  static Future<void> _syncMarketplaceData() async {
    try {
      final products = await MarketplaceService.getProducts();
      final marketPrices = await MarketplaceService.getMarketPrices();
      final statistics = await MarketplaceService.getMarketplaceStatistics();
      
      await StorageService.saveOfflineData('marketplace', {
        'products': products.map((product) => {
          'id': product.id,
          'name': product.name,
          'description': product.description,
          'category': product.category,
          'price': product.price,
          'currency': product.currency,
          'unit': product.unit,
          'availableQuantity': product.availableQuantity,
          'sellerId': product.sellerId,
          'images': product.images,
          'qualityGrade': product.qualityGrade,
          'isOrganic': product.isOrganic,
          'isCertified': product.isCertified,
          'origin': product.origin,
        }).toList(),
        'marketPrices': marketPrices.map((price) => {
          'productId': price.productId,
          'productName': price.productName,
          'region': price.region,
          'price': price.price,
          'currency': price.currency,
          'unit': price.unit,
          'date': price.date.toIso8601String(),
          'source': price.source,
          'priceChange': price.priceChange,
          'trend': price.trend,
        }).toList(),
        'statistics': statistics,
        'lastSync': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Erreur sync marketplace: $e');
    }
  }

  // Synchroniser les données de paiement
  static Future<void> _syncPaymentData() async {
    try {
      final transactions = await PaymentService.getPaymentHistory();
      final statistics = await PaymentService.getPaymentStatistics();
      
      await StorageService.saveOfflineData('payments', {
        'transactions': transactions.map((transaction) => {
          'id': transaction.id,
          'orderId': transaction.orderId,
          'paymentMethodId': transaction.paymentMethodId,
          'amount': transaction.amount,
          'currency': transaction.currency,
          'status': transaction.status,
          'createdAt': transaction.createdAt.toIso8601String(),
          'completedAt': transaction.completedAt?.toIso8601String(),
          'transactionReference': transaction.transactionReference,
        }).toList(),
        'statistics': statistics,
        'lastSync': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Erreur sync payments: $e');
    }
  }

  // Synchroniser les données de logistique
  static Future<void> _syncLogisticsData() async {
    try {
      final carriers = await LogisticsService.getAvailableCarriers();
      final statistics = await LogisticsService.getLogisticsStatistics();
      
      await StorageService.saveOfflineData('logistics', {
        'carriers': carriers,
        'statistics': statistics,
        'lastSync': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Erreur sync logistics: $e');
    }
  }

  // Synchroniser les données de certification
  static Future<void> _syncCertificationData() async {
    try {
      final certifications = await CertificationService.getCertifications();
      final statistics = await CertificationService.getCertificationStatistics();
      
      await StorageService.saveOfflineData('certifications', {
        'certifications': certifications.map((cert) => {
          'id': cert.id,
          'name': cert.name,
          'type': cert.type,
          'issuer': cert.issuer,
          'issuedDate': cert.issuedDate.toIso8601String(),
          'expiryDate': cert.expiryDate.toIso8601String(),
          'status': cert.status,
          'certificateNumber': cert.certificateNumber,
          'documentUrl': cert.documentUrl,
        }).toList(),
        'statistics': statistics,
        'lastSync': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Erreur sync certifications: $e');
    }
  }

  // Synchroniser les données d'export/import
  static Future<void> _syncExportImportData() async {
    try {
      final destinations = await ExportImportService.getExportDestinations();
      final statistics = await ExportImportService.getExportStatistics();
      final exchangeRates = await ExportImportService.getExchangeRates();
      
      await StorageService.saveOfflineData('export_import', {
        'destinations': destinations,
        'statistics': statistics,
        'exchangeRates': exchangeRates,
        'lastSync': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Erreur sync export/import: $e');
    }
  }

  // Synchroniser les données en attente
  static Future<void> syncPendingData() async {
    final syncQueue = await StorageService.getSyncQueue();
    
    for (var item in syncQueue) {
      try {
        await _processSyncItem(item);
        // Retirer l'item de la queue après succès
        syncQueue.remove(item);
      } catch (e) {
        // Incrémenter le compteur de retry
        item['retryCount'] = (item['retryCount'] ?? 0) + 1;
        
        // Si trop de tentatives, retirer de la queue
        if (item['retryCount'] > 3) {
          syncQueue.remove(item);
        }
      }
    }
    
    // Sauvegarder la queue mise à jour
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sync_queue', jsonEncode(syncQueue));
  }

  // Traiter un item de synchronisation
  static Future<void> _processSyncItem(Map<String, dynamic> item) async {
    final action = item['action'] as String;
    final data = item['data'] as Map<String, dynamic>;
    
    switch (action) {
      case 'create_order':
        await _syncCreateOrder(data);
        break;
      case 'update_crop':
        await _syncUpdateCrop(data);
        break;
      case 'create_payment':
        await _syncCreatePayment(data);
        break;
      case 'update_settings':
        await _syncUpdateSettings(data);
        break;
      default:
        print('Action de synchronisation inconnue: $action');
    }
  }

  // Synchroniser la création d'une commande
  static Future<void> _syncCreateOrder(Map<String, dynamic> data) async {
    // Implémentation de la synchronisation des commandes
    print('Synchronisation création commande: $data');
  }

  // Synchroniser la mise à jour d'une culture
  static Future<void> _syncUpdateCrop(Map<String, dynamic> data) async {
    // Implémentation de la synchronisation des cultures
    print('Synchronisation mise à jour culture: $data');
  }

  // Synchroniser la création d'un paiement
  static Future<void> _syncCreatePayment(Map<String, dynamic> data) async {
    // Implémentation de la synchronisation des paiements
    print('Synchronisation création paiement: $data');
  }

  // Synchroniser la mise à jour des paramètres
  static Future<void> _syncUpdateSettings(Map<String, dynamic> data) async {
    await StorageService.saveSettings(data);
  }

  // Obtenir les données hors ligne
  static Future<Map<String, dynamic>?> getOfflineData(String key) async {
    return await StorageService.getOfflineData()[key];
  }

  // Vérifier si les données sont disponibles hors ligne
  static Future<bool> hasOfflineData(String key) async {
    final offlineData = await StorageService.getOfflineData();
    return offlineData.containsKey(key);
  }

  // Forcer la synchronisation
  static Future<void> forceSync() async {
    await syncAllData();
  }

  // Obtenir le statut de synchronisation
  static Future<Map<String, dynamic>> getSyncStatus() async {
    final lastSync = await StorageService.getLastSync();
    final syncQueue = await StorageService.getSyncQueue();
    final isOnline = await checkConnectivity();
    
    return {
      'isOnline': isOnline,
      'lastSync': lastSync?.toIso8601String(),
      'pendingItems': syncQueue.length,
      'isDataStale': await StorageService.isDataStale(),
    };
  }

  // Nettoyer les données
  static Future<void> cleanup() async {
    await StorageService.cleanupOldData();
    await StorageService.clearCache();
  }
}
