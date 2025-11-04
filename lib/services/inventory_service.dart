import 'dart:math';
import 'dart:async';

class InventoryItem {
  final String id;
  final String name;
  final String category;
  final String unit;
  final double currentStock;
  final double minStock;
  final double maxStock;
  final double unitPrice;
  final String currency;
  final String location;
  final DateTime lastUpdated;
  final Map<String, dynamic>? metadata;

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.currentStock,
    required this.minStock,
    required this.maxStock,
    required this.unitPrice,
    required this.currency,
    required this.location,
    required this.lastUpdated,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'unit': unit,
    'currentStock': currentStock,
    'minStock': minStock,
    'maxStock': maxStock,
    'unitPrice': unitPrice,
    'currency': currency,
    'location': location,
    'lastUpdated': lastUpdated.toIso8601String(),
    'metadata': metadata,
  };

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
    id: json['id'],
    name: json['name'],
    category: json['category'],
    unit: json['unit'],
    currentStock: json['currentStock'].toDouble(),
    minStock: json['minStock'].toDouble(),
    maxStock: json['maxStock'].toDouble(),
    unitPrice: json['unitPrice'].toDouble(),
    currency: json['currency'],
    location: json['location'],
    lastUpdated: DateTime.parse(json['lastUpdated']),
    metadata: json['metadata'],
  );
}

class StockMovement {
  final String id;
  final String itemId;
  final String type; // 'in', 'out', 'adjustment', 'transfer'
  final double quantity;
  final String reason;
  final String? reference;
  final DateTime timestamp;
  final String userId;
  final Map<String, dynamic>? metadata;

  StockMovement({
    required this.id,
    required this.itemId,
    required this.type,
    required this.quantity,
    required this.reason,
    this.reference,
    required this.timestamp,
    required this.userId,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'itemId': itemId,
    'type': type,
    'quantity': quantity,
    'reason': reason,
    'reference': reference,
    'timestamp': timestamp.toIso8601String(),
    'userId': userId,
    'metadata': metadata,
  };

  factory StockMovement.fromJson(Map<String, dynamic> json) => StockMovement(
    id: json['id'],
    itemId: json['itemId'],
    type: json['type'],
    quantity: json['quantity'].toDouble(),
    reason: json['reason'],
    reference: json['reference'],
    timestamp: DateTime.parse(json['timestamp']),
    userId: json['userId'],
    metadata: json['metadata'],
  );
}

class InventoryAlert {
  final String id;
  final String itemId;
  final String type; // 'low_stock', 'out_of_stock', 'overstock', 'expired'
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? metadata;

  InventoryAlert({
    required this.id,
    required this.itemId,
    required this.type,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'itemId': itemId,
    'type': type,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead,
    'metadata': metadata,
  };

  factory InventoryAlert.fromJson(Map<String, dynamic> json) => InventoryAlert(
    id: json['id'],
    itemId: json['itemId'],
    type: json['type'],
    message: json['message'],
    timestamp: DateTime.parse(json['timestamp']),
    isRead: json['isRead'] ?? false,
    metadata: json['metadata'],
  );
}

class InventoryService {
  static final List<InventoryItem> _items = [];
  static final List<StockMovement> _movements = [];
  static final List<InventoryAlert> _alerts = [];
  
  static final StreamController<InventoryItem> _itemController = StreamController<InventoryItem>.broadcast();
  static final StreamController<StockMovement> _movementController = StreamController<StockMovement>.broadcast();
  static final StreamController<InventoryAlert> _alertController = StreamController<InventoryAlert>.broadcast();

  // Streams publics
  static Stream<InventoryItem> get itemStream => _itemController.stream;
  static Stream<StockMovement> get movementStream => _movementController.stream;
  static Stream<InventoryAlert> get alertStream => _alertController.stream;

  // Initialiser le service
  static Future<void> initialize() async {
    // Charger les données initiales
    await _loadInitialData();
    print('InventoryService initialized.');
  }

  // Charger les données initiales - UNIQUEMENT depuis le backend ou la base de données locale de l'utilisateur
  static Future<void> _loadInitialData() async {
    // Aucune donnée inventée n'est chargée
    // Les données doivent être fournies par l'utilisateur ou récupérées depuis le backend
    // Vérifier les alertes si des données existent déjà
    _checkAlerts();
  }

  // Obtenir tous les articles
  static List<InventoryItem> getItems() {
    return List.from(_items);
  }

  // Obtenir un article par ID
  static InventoryItem? getItem(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  // Ajouter un article
  static Future<void> addItem(InventoryItem item) async {
    _items.add(item);
    _itemController.add(item);
    _checkAlerts();
  }

  // Mettre à jour un article
  static Future<void> updateItem(InventoryItem item) async {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index] = item;
      _itemController.add(item);
      _checkAlerts();
    }
  }

  // Supprimer un article
  static Future<void> deleteItem(String id) async {
    _items.removeWhere((item) => item.id == id);
    _movements.removeWhere((movement) => movement.itemId == id);
    _alerts.removeWhere((alert) => alert.itemId == id);
  }

  // Ajouter un mouvement de stock
  static Future<void> addStockMovement({
    required String itemId,
    required String type,
    required double quantity,
    required String reason,
    String? reference,
    String userId = 'user_001',
    Map<String, dynamic>? metadata,
  }) async {
    final movement = StockMovement(
      id: 'movement_${DateTime.now().millisecondsSinceEpoch}',
      itemId: itemId,
      type: type,
      quantity: quantity,
      reason: reason,
      reference: reference,
      timestamp: DateTime.now(),
      userId: userId,
      metadata: metadata,
    );

    _movements.add(movement);
    _movementController.add(movement);

    // Mettre à jour le stock
    final item = getItem(itemId);
    if (item != null) {
      double newStock = item.currentStock;
      if (type == 'in') {
        newStock += quantity;
      } else if (type == 'out') {
        newStock -= quantity;
      } else if (type == 'adjustment') {
        newStock = quantity;
      }

      final updatedItem = InventoryItem(
        id: item.id,
        name: item.name,
        category: item.category,
        unit: item.unit,
        currentStock: newStock,
        minStock: item.minStock,
        maxStock: item.maxStock,
        unitPrice: item.unitPrice,
        currency: item.currency,
        location: item.location,
        lastUpdated: DateTime.now(),
        metadata: item.metadata,
      );

      await updateItem(updatedItem);
    }
  }

  // Vérifier les alertes
  static void _checkAlerts() {
    for (final item in _items) {
      // Alerte stock bas
      if (item.currentStock <= item.minStock && item.currentStock > 0) {
        final alert = InventoryAlert(
          id: 'alert_${item.id}_low_${DateTime.now().millisecondsSinceEpoch}',
          itemId: item.id,
          type: 'low_stock',
          message: 'Stock bas pour ${item.name}. Quantité actuelle: ${item.currentStock} ${item.unit}',
          timestamp: DateTime.now(),
        );
        _alerts.add(alert);
        _alertController.add(alert);
      }

      // Alerte rupture de stock
      if (item.currentStock <= 0) {
        final alert = InventoryAlert(
          id: 'alert_${item.id}_out_${DateTime.now().millisecondsSinceEpoch}',
          itemId: item.id,
          type: 'out_of_stock',
          message: 'Rupture de stock pour ${item.name}',
          timestamp: DateTime.now(),
        );
        _alerts.add(alert);
        _alertController.add(alert);
      }

      // Alerte surstock
      if (item.currentStock >= item.maxStock) {
        final alert = InventoryAlert(
          id: 'alert_${item.id}_over_${DateTime.now().millisecondsSinceEpoch}',
          itemId: item.id,
          type: 'overstock',
          message: 'Surstock pour ${item.name}. Quantité actuelle: ${item.currentStock} ${item.unit}',
          timestamp: DateTime.now(),
        );
        _alerts.add(alert);
        _alertController.add(alert);
      }
    }
  }

  // Obtenir les alertes
  static List<InventoryAlert> getAlerts() {
    return List.from(_alerts);
  }

  // Marquer une alerte comme lue
  static Future<void> markAlertAsRead(String alertId) async {
    final index = _alerts.indexWhere((alert) => alert.id == alertId);
    if (index != -1) {
      final alert = _alerts[index];
      _alerts[index] = InventoryAlert(
        id: alert.id,
        itemId: alert.itemId,
        type: alert.type,
        message: alert.message,
        timestamp: alert.timestamp,
        isRead: true,
        metadata: alert.metadata,
      );
    }
  }

  // Obtenir les mouvements de stock
  static List<StockMovement> getMovements({int limit = 50}) {
    final movements = List<StockMovement>.from(_movements);
    movements.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return movements.take(limit).toList();
  }

  // Obtenir les statistiques
  static Map<String, dynamic> getStatistics() {
    final totalItems = _items.length;
    final totalValue = _items.fold(0.0, (sum, item) => sum + (item.currentStock * item.unitPrice));
    final lowStockItems = _items.where((item) => item.currentStock <= item.minStock && item.currentStock > 0).length;
    final outOfStockItems = _items.where((item) => item.currentStock <= 0).length;
    final overstockItems = _items.where((item) => item.currentStock >= item.maxStock).length;

    return {
      'totalItems': totalItems,
      'totalValue': totalValue,
      'lowStockItems': lowStockItems,
      'outOfStockItems': outOfStockItems,
      'overstockItems': overstockItems,
      'totalMovements': _movements.length,
      'unreadAlerts': _alerts.where((alert) => !alert.isRead).length,
    };
  }

  // Obtenir les articles par catégorie
  static List<InventoryItem> getItemsByCategory(String category) {
    return _items.where((item) => item.category.toLowerCase() == category.toLowerCase()).toList();
  }

  // Obtenir la valeur totale du stock
  static double getTotalStockValue() {
    return _items.fold(0.0, (sum, item) => sum + (item.currentStock * item.unitPrice));
  }

  // Obtenir le taux de rotation des stocks
  static double getStockTurnoverRate() {
    if (_items.isEmpty) return 0.0;
    
    final totalValue = getTotalStockValue();
    final totalMovements = _movements.fold(0.0, (sum, m) {
      final item = getItem(m.itemId);
      if (item == null) return sum;
      return sum + (m.quantity * item.unitPrice);
    });

    return totalValue > 0 ? totalMovements / totalValue : 0.0;
  }

  // Obtenir les articles en rupture de stock
  static List<InventoryItem> getOutOfStockItems() {
    return _items.where((item) => item.currentStock <= 0).toList();
  }

  // Obtenir les articles en stock bas
  static List<InventoryItem> getLowStockItems() {
    return _items.where((item) => item.currentStock > 0 && item.currentStock <= item.minStock).toList();
  }

  // Obtenir les articles en surstock
  static List<InventoryItem> getOverstockItems() {
    return _items.where((item) => item.currentStock >= item.maxStock).toList();
  }

  // Rechercher des articles
  static List<InventoryItem> searchItems(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _items.where((item) =>
        item.name.toLowerCase().contains(lowercaseQuery) ||
        item.category.toLowerCase().contains(lowercaseQuery) ||
        item.location.toLowerCase().contains(lowercaseQuery)).toList();
  }

  // Obtenir l'historique des mouvements pour un article
  static List<StockMovement> getItemHistory(String itemId, {int limit = 50}) {
    final movements = _movements.where((m) => m.itemId == itemId).toList();
    movements.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return movements.take(limit).toList();
  }

  // Nettoyer les données anciennes
  static void cleanupOldData({Duration maxAge = const Duration(days: 90)}) {
    final cutoffDate = DateTime.now().subtract(maxAge);
    _movements.removeWhere((movement) => movement.timestamp.isBefore(cutoffDate));
    _alerts.removeWhere((alert) => alert.timestamp.isBefore(cutoffDate) && alert.isRead);
  }
}