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
  final String type; // in, out, transfer, adjustment
  final double quantity;
  final String reason;
  final String? reference; // order_id, transfer_id, etc.
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
  final String type; // low_stock, out_of_stock, overstock, expiry
  final String message;
  final String severity; // low, medium, high, critical
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? metadata;

  InventoryAlert({
    required this.id,
    required this.itemId,
    required this.type,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.isRead = false,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'itemId': itemId,
    'type': type,
    'message': message,
    'severity': severity,
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead,
    'metadata': metadata,
  };

  factory InventoryAlert.fromJson(Map<String, dynamic> json) => InventoryAlert(
    id: json['id'],
    itemId: json['itemId'],
    type: json['type'],
    message: json['message'],
    severity: json['severity'],
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
    await _loadInitialData();
  }

  // Charger les données initiales
  static Future<void> _loadInitialData() async {
    // Simuler des données d'inventaire
    _items.addAll([
      InventoryItem(
        id: 'item_001',
        name: 'Riz de Casamance',
        category: 'Céréales',
        unit: 'tonnes',
        currentStock: 25.5,
        minStock: 10.0,
        maxStock: 50.0,
        unitPrice: 200000.0,
        currency: 'FCFA',
        location: 'Entrepôt A',
        lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      InventoryItem(
        id: 'item_002',
        name: 'Tomates de Niayes',
        category: 'Légumes',
        unit: 'tonnes',
        currentStock: 8.2,
        minStock: 5.0,
        maxStock: 20.0,
        unitPrice: 300000.0,
        currency: 'FCFA',
        location: 'Entrepôt B',
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      InventoryItem(
        id: 'item_003',
        name: 'Mangues de Kédougou',
        category: 'Fruits',
        unit: 'tonnes',
        currentStock: 15.8,
        minStock: 8.0,
        maxStock: 30.0,
        unitPrice: 120000.0,
        currency: 'FCFA',
        location: 'Entrepôt C',
        lastUpdated: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      InventoryItem(
        id: 'item_004',
        name: 'Arachides',
        category: 'Légumineuses',
        unit: 'tonnes',
        currentStock: 2.1,
        minStock: 5.0,
        maxStock: 15.0,
        unitPrice: 180000.0,
        currency: 'FCFA',
        location: 'Entrepôt A',
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
    ]);

    // Vérifier les alertes
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
  static Future<void> updateItem(InventoryItem updatedItem) async {
    final index = _items.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _items[index] = updatedItem;
      _itemController.add(updatedItem);
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
    await _updateStock(itemId, type, quantity);
  }

  // Mettre à jour le stock
  static Future<void> _updateStock(String itemId, String type, double quantity) async {
    final itemIndex = _items.indexWhere((item) => item.id == itemId);
    if (itemIndex == -1) return;

    final item = _items[itemIndex];
    double newStock = item.currentStock;

    switch (type) {
      case 'in':
        newStock += quantity;
        break;
      case 'out':
        newStock -= quantity;
        break;
      case 'adjustment':
        newStock = quantity;
        break;
      case 'transfer':
        // Pour les transferts, on peut avoir des mouvements in/out séparés
        break;
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

    _items[itemIndex] = updatedItem;
    _itemController.add(updatedItem);
    _checkAlerts();
  }

  // Vérifier les alertes
  static void _checkAlerts() {
    for (var item in _items) {
      _checkItemAlerts(item);
    }
  }

  // Vérifier les alertes pour un article
  static void _checkItemAlerts(InventoryItem item) {
    // Supprimer les anciennes alertes pour cet article
    _alerts.removeWhere((alert) => alert.itemId == item.id && 
        (alert.type == 'low_stock' || alert.type == 'out_of_stock' || alert.type == 'overstock'));

    // Vérifier le stock bas
    if (item.currentStock <= 0) {
      _addAlert(InventoryAlert(
        id: 'alert_${DateTime.now().millisecondsSinceEpoch}',
        itemId: item.id,
        type: 'out_of_stock',
        message: '${item.name} est en rupture de stock',
        severity: 'critical',
        timestamp: DateTime.now(),
      ));
    } else if (item.currentStock <= item.minStock) {
      _addAlert(InventoryAlert(
        id: 'alert_${DateTime.now().millisecondsSinceEpoch}',
        itemId: item.id,
        type: 'low_stock',
        message: '${item.name} - Stock bas (${item.currentStock} ${item.unit})',
        severity: 'high',
        timestamp: DateTime.now(),
      ));
    }

    // Vérifier le surstock
    if (item.currentStock >= item.maxStock) {
      _addAlert(InventoryAlert(
        id: 'alert_${DateTime.now().millisecondsSinceEpoch}',
        itemId: item.id,
        type: 'overstock',
        message: '${item.name} - Surstock (${item.currentStock} ${item.unit})',
        severity: 'medium',
        timestamp: DateTime.now(),
      ));
    }
  }

  // Ajouter une alerte
  static void _addAlert(InventoryAlert alert) {
    _alerts.add(alert);
    _alertController.add(alert);
  }

  // Obtenir les mouvements de stock
  static List<StockMovement> getMovements({
    String? itemId,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    var movements = List<StockMovement>.from(_movements);

    if (itemId != null) {
      movements = movements.where((m) => m.itemId == itemId).toList();
    }

    if (type != null) {
      movements = movements.where((m) => m.type == type).toList();
    }

    if (startDate != null) {
      movements = movements.where((m) => m.timestamp.isAfter(startDate)).toList();
    }

    if (endDate != null) {
      movements = movements.where((m) => m.timestamp.isBefore(endDate)).toList();
    }

    // Trier par date décroissante
    movements.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return movements;
  }

  // Obtenir les alertes
  static List<InventoryAlert> getAlerts({
    String? severity,
    bool? isRead,
  }) {
    var alerts = List<InventoryAlert>.from(_alerts);

    if (severity != null) {
      alerts = alerts.where((a) => a.severity == severity).toList();
    }

    if (isRead != null) {
      alerts = alerts.where((a) => a.isRead == isRead).toList();
    }

    // Trier par date décroissante
    alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return alerts;
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
        severity: alert.severity,
        timestamp: alert.timestamp,
        isRead: true,
        metadata: alert.metadata,
      );
    }
  }

  // Obtenir les statistiques d'inventaire
  static Map<String, dynamic> getInventoryStatistics() {
    final totalItems = _items.length;
    final totalValue = _items.fold(0.0, (sum, item) => sum + (item.currentStock * item.unitPrice));
    final lowStockItems = _items.where((item) => item.currentStock <= item.minStock).length;
    final outOfStockItems = _items.where((item) => item.currentStock <= 0).length;
    final overstockItems = _items.where((item) => item.currentStock >= item.maxStock).length;
    final totalAlerts = _alerts.length;
    final unreadAlerts = _alerts.where((alert) => !alert.isRead).length;

    return {
      'totalItems': totalItems,
      'totalValue': totalValue,
      'lowStockItems': lowStockItems,
      'outOfStockItems': outOfStockItems,
      'overstockItems': overstockItems,
      'totalAlerts': totalAlerts,
      'unreadAlerts': unreadAlerts,
      'averageStockLevel': totalItems > 0 ? _items.fold(0.0, (sum, item) => sum + item.currentStock) / totalItems : 0.0,
      'stockTurnover': _calculateStockTurnover(),
    };
  }

  // Calculer la rotation des stocks
  static double _calculateStockTurnover() {
    if (_items.isEmpty) return 0.0;

    final totalValue = _items.fold(0.0, (sum, item) => sum + (item.currentStock * item.unitPrice));
    final totalMovements = _movements.where((m) => m.type == 'out').fold(0.0, (sum, m) {
      final item = _items.firstWhere((i) => i.id == m.itemId, orElse: () => _items.first);
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
