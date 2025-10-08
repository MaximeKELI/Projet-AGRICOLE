import '../models/payment_models.dart';

class LogisticsService {
  // Transporteurs disponibles
  static final List<Map<String, dynamic>> _carriers = [
    {
      'id': 'carrier_001',
      'name': 'Transport Express Sénégal',
      'type': 'road',
      'coverage': ['Dakar', 'Thiès', 'Kaolack', 'Saint-Louis'],
      'rating': 4.5,
      'pricePerKm': 500.0,
      'minOrderValue': 10000.0,
      'maxWeight': 1000.0, // kg
      'deliveryTime': '1-2 jours',
      'contact': '+221701234567',
      'isActive': true,
    },
    {
      'id': 'carrier_002',
      'name': 'Logistics Plus',
      'type': 'road',
      'coverage': ['Dakar', 'Thiès', 'Kaolack', 'Saint-Louis', 'Ziguinchor', 'Kolda'],
      'rating': 4.2,
      'pricePerKm': 450.0,
      'minOrderValue': 15000.0,
      'maxWeight': 2000.0,
      'deliveryTime': '2-3 jours',
      'contact': '+221701234568',
      'isActive': true,
    },
    {
      'id': 'carrier_003',
      'name': 'Air Cargo Sénégal',
      'type': 'air',
      'coverage': ['Dakar', 'Ziguinchor', 'Saint-Louis'],
      'rating': 4.8,
      'pricePerKm': 2000.0,
      'minOrderValue': 50000.0,
      'maxWeight': 500.0,
      'deliveryTime': '1 jour',
      'contact': '+221701234569',
      'isActive': true,
    },
  ];

  // Obtenir les transporteurs disponibles
  static Future<List<Map<String, dynamic>>> getAvailableCarriers({
    String? region,
    double? weight,
    double? orderValue,
    String? deliveryType,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    var carriers = _carriers.where((carrier) => carrier['isActive'] == true).toList();

    // Filtrer par région
    if (region != null) {
      carriers = carriers.where((carrier) => 
          (carrier['coverage'] as List).contains(region)).toList();
    }

    // Filtrer par poids
    if (weight != null) {
      carriers = carriers.where((carrier) => 
          weight <= carrier['maxWeight']).toList();
    }

    // Filtrer par valeur de commande
    if (orderValue != null) {
      carriers = carriers.where((carrier) => 
          orderValue >= carrier['minOrderValue']).toList();
    }

    // Filtrer par type de livraison
    if (deliveryType != null) {
      carriers = carriers.where((carrier) => 
          carrier['type'] == deliveryType).toList();
    }

    return carriers;
  }

  // Calculer les frais de livraison
  static Future<Map<String, dynamic>> calculateShippingCost({
    required String origin,
    required String destination,
    required double weight,
    required double orderValue,
    String? carrierId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Calculer la distance (simulation)
    final distance = _calculateDistance(origin, destination);
    
    // Obtenir le transporteur
    Map<String, dynamic>? carrier;
    if (carrierId != null) {
      carrier = _carriers.firstWhere(
        (c) => c['id'] == carrierId,
        orElse: () => _carriers.first,
      );
    } else {
      // Choisir le transporteur le plus approprié
      carrier = _getBestCarrier(weight, orderValue, destination);
    }

    // Calculer le coût de base
    double baseCost = distance * carrier!['pricePerKm'];
    
    // Ajouter des frais selon le poids
    if (weight > 100) {
      baseCost += (weight - 100) * 50; // 50 FCFA par kg supplémentaire
    }

    // Ajouter des frais selon la valeur
    if (orderValue > 100000) {
      baseCost += orderValue * 0.01; // 1% de la valeur pour l'assurance
    }

    // Frais de manutention
    double handlingFee = 2000.0;

    // Frais de livraison express (si applicable)
    double expressFee = 0.0;
    if (carrier['deliveryTime'] == '1 jour') {
      expressFee = baseCost * 0.5; // 50% de frais supplémentaires
    }

    final totalCost = baseCost + handlingFee + expressFee;

    return {
      'carrier': carrier,
      'distance': distance,
      'baseCost': baseCost,
      'handlingFee': handlingFee,
      'expressFee': expressFee,
      'totalCost': totalCost,
      'estimatedDeliveryTime': carrier['deliveryTime'],
      'breakdown': {
        'distance_km': distance,
        'price_per_km': carrier['pricePerKm'],
        'weight_kg': weight,
        'order_value': orderValue,
      },
    };
  }

  // Calculer la distance entre deux régions (simulation)
  static double _calculateDistance(String origin, String destination) {
    final distances = {
      'Dakar': {
        'Dakar': 0,
        'Thiès': 70,
        'Kaolack': 200,
        'Saint-Louis': 260,
        'Ziguinchor': 450,
        'Kolda': 400,
      },
      'Thiès': {
        'Dakar': 70,
        'Thiès': 0,
        'Kaolack': 130,
        'Saint-Louis': 190,
        'Ziguinchor': 380,
        'Kolda': 330,
      },
      'Kaolack': {
        'Dakar': 200,
        'Thiès': 130,
        'Kaolack': 0,
        'Saint-Louis': 320,
        'Ziguinchor': 250,
        'Kolda': 200,
      },
      'Saint-Louis': {
        'Dakar': 260,
        'Thiès': 190,
        'Kaolack': 320,
        'Saint-Louis': 0,
        'Ziguinchor': 710,
        'Kolda': 660,
      },
      'Ziguinchor': {
        'Dakar': 450,
        'Thiès': 380,
        'Kaolack': 250,
        'Saint-Louis': 710,
        'Ziguinchor': 0,
        'Kolda': 50,
      },
      'Kolda': {
        'Dakar': 400,
        'Thiès': 330,
        'Kaolack': 200,
        'Saint-Louis': 660,
        'Ziguinchor': 50,
        'Kolda': 0,
      },
    };

    return distances[origin]?[destination]?.toDouble() ?? 100.0;
  }

  // Choisir le meilleur transporteur
  static Map<String, dynamic> _getBestCarrier(double weight, double orderValue, String destination) {
    var suitableCarriers = _carriers.where((carrier) => 
        carrier['isActive'] == true &&
        weight <= carrier['maxWeight'] &&
        orderValue >= carrier['minOrderValue'] &&
        (carrier['coverage'] as List).contains(destination)).toList();

    if (suitableCarriers.isEmpty) {
      return _carriers.first;
    }

    // Trier par note (rating) décroissante
    suitableCarriers.sort((a, b) => (b['rating'] as double).compareTo(a['rating'] as double));
    
    return suitableCarriers.first;
  }

  // Créer un envoi
  static Future<Map<String, dynamic>> createShipment({
    required String orderId,
    required String carrierId,
    required String origin,
    required String destination,
    required double weight,
    required List<String> items,
    Map<String, dynamic>? metadata,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final carrier = _carriers.firstWhere((c) => c['id'] == carrierId);
    final distance = _calculateDistance(origin, destination);
    final shippingCost = await calculateShippingCost(
      origin: origin,
      destination: destination,
      weight: weight,
      orderValue: 0.0,
      carrierId: carrierId,
    );

    final shipment = {
      'id': 'shipment_${DateTime.now().millisecondsSinceEpoch}',
      'orderId': orderId,
      'carrierId': carrierId,
      'carrier': carrier,
      'origin': origin,
      'destination': destination,
      'weight': weight,
      'items': items,
      'distance': distance,
      'cost': shippingCost['totalCost'],
      'status': 'pending',
      'trackingNumber': 'TRK${DateTime.now().millisecondsSinceEpoch}',
      'createdAt': DateTime.now(),
      'estimatedDelivery': DateTime.now().add(const Duration(days: 2)),
      'metadata': metadata,
    };

    return shipment;
  }

  // Suivre un envoi
  static Future<Map<String, dynamic>> trackShipment(String trackingNumber) async {
    await Future.delayed(const Duration(seconds: 1));

    // Simulation du suivi
    final statuses = ['pending', 'picked_up', 'in_transit', 'out_for_delivery', 'delivered'];
    final randomStatus = statuses[DateTime.now().millisecond % statuses.length];

    return {
      'trackingNumber': trackingNumber,
      'status': randomStatus,
      'currentLocation': 'Dakar, Sénégal',
      'lastUpdate': DateTime.now().subtract(const Duration(hours: 2)),
      'estimatedDelivery': DateTime.now().add(const Duration(days: 1)),
      'history': [
        {
          'status': 'pending',
          'location': 'Entrepôt Dakar',
          'timestamp': DateTime.now().subtract(const Duration(days: 1)),
          'description': 'Commande reçue et en attente de prise en charge',
        },
        {
          'status': 'picked_up',
          'location': 'Entrepôt Dakar',
          'timestamp': DateTime.now().subtract(const Duration(hours: 20)),
          'description': 'Commande prise en charge par le transporteur',
        },
        {
          'status': 'in_transit',
          'location': 'Route vers destination',
          'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
          'description': 'En cours de transport vers la destination',
        },
      ],
    };
  }

  // Obtenir les statistiques de logistique
  static Future<Map<String, dynamic>> getLogisticsStatistics() async {
    await Future.delayed(const Duration(seconds: 1));

    return {
      'totalShipments': 1250,
      'deliveredOnTime': 1100,
      'onTimeDeliveryRate': 0.88,
      'averageDeliveryTime': 2.3, // jours
      'totalCarriers': _carriers.length,
      'activeCarriers': _carriers.where((c) => c['isActive'] == true).length,
      'averageShippingCost': 15000.0,
      'topRegions': {
        'Dakar': 0.45,
        'Thiès': 0.20,
        'Kaolack': 0.15,
        'Saint-Louis': 0.10,
        'Ziguinchor': 0.10,
      },
      'monthlyGrowth': 0.18,
    };
  }

  // Obtenir les régions de livraison
  static Future<List<String>> getDeliveryRegions() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return ['Dakar', 'Thiès', 'Kaolack', 'Saint-Louis', 'Ziguinchor', 'Kolda'];
  }

  // Calculer le temps de livraison estimé
  static Future<String> getEstimatedDeliveryTime({
    required String origin,
    required String destination,
    String? carrierId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final distance = _calculateDistance(origin, destination);
    
    if (carrierId != null) {
      final carrier = _carriers.firstWhere((c) => c['id'] == carrierId);
      return carrier['deliveryTime'];
    }

    // Estimation basée sur la distance
    if (distance <= 100) {
      return '1 jour';
    } else if (distance <= 300) {
      return '2-3 jours';
    } else {
      return '3-5 jours';
    }
  }
}
