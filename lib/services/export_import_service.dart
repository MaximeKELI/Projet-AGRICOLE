import '../models/payment_models.dart';

class ExportImportService {
  // Pays de destination pour les exportations
  static final List<Map<String, dynamic>> _exportDestinations = [
    {
      'country': 'France',
      'code': 'FR',
      'region': 'Europe',
      'requirements': ['Certificat phytosanitaire', 'HACCP', 'Traçabilité'],
      'tariffs': 0.05, // 5%
      'shippingTime': '7-10 jours',
      'currency': 'EUR',
      'exchangeRate': 655.0, // 1 EUR = 655 FCFA
    },
    {
      'country': 'Espagne',
      'code': 'ES',
      'region': 'Europe',
      'requirements': ['Certificat phytosanitaire', 'HACCP', 'Traçabilité'],
      'tariffs': 0.06,
      'shippingTime': '8-12 jours',
      'currency': 'EUR',
      'exchangeRate': 655.0,
    },
    {
      'country': 'Maroc',
      'code': 'MA',
      'region': 'Afrique',
      'requirements': ['Certificat phytosanitaire', 'Traçabilité'],
      'tariffs': 0.02,
      'shippingTime': '3-5 jours',
      'currency': 'MAD',
      'exchangeRate': 60.0, // 1 MAD = 60 FCFA
    },
    {
      'country': 'Côte d\'Ivoire',
      'code': 'CI',
      'region': 'Afrique',
      'requirements': ['Certificat phytosanitaire'],
      'tariffs': 0.01,
      'shippingTime': '2-3 jours',
      'currency': 'XOF',
      'exchangeRate': 1.0, // Même devise
    },
    {
      'country': 'États-Unis',
      'code': 'US',
      'region': 'Amérique',
      'requirements': ['FDA', 'USDA', 'HACCP', 'Traçabilité complète'],
      'tariffs': 0.15,
      'shippingTime': '15-20 jours',
      'currency': 'USD',
      'exchangeRate': 600.0, // 1 USD = 600 FCFA
    },
  ];

  // Obtenir les destinations d'exportation
  static Future<List<Map<String, dynamic>>> getExportDestinations({
    String? region,
    String? productType,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    var destinations = List<Map<String, dynamic>>.from(_exportDestinations);

    if (region != null) {
      destinations = destinations.where((d) => d['region'] == region).toList();
    }

    // Filtrer selon le type de produit
    if (productType != null) {
      destinations = destinations.where((d) => 
          _isProductAllowedForExport(productType, d['requirements'])).toList();
    }

    return destinations;
  }

  // Vérifier si un produit peut être exporté vers une destination
  static bool _isProductAllowedForExport(String productType, List<String> requirements) {
    // Simulation - dans une vraie implémentation, on vérifierait
    // les réglementations spécifiques pour chaque produit
    return true;
  }

  // Calculer les coûts d'exportation
  static Future<Map<String, dynamic>> calculateExportCosts({
    required String destinationCountry,
    required String productId,
    required double quantity,
    required String unit,
    required double productValue,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final destination = _exportDestinations.firstWhere(
      (d) => d['code'] == destinationCountry,
      orElse: () => throw Exception('Destination non trouvée'),
    );

    // Coût de base du produit
    double baseCost = productValue;

    // Frais de douane
    double customsDuty = productValue * destination['tariffs'];

    // Frais de transport
    double shippingCost = _calculateShippingCost(destination, quantity, unit);

    // Frais de certification
    double certificationCost = _calculateCertificationCost(destination['requirements']);

    // Frais de documentation
    double documentationCost = 50000.0; // FCFA

    // Assurance
    double insuranceCost = productValue * 0.01; // 1%

    // Frais bancaires
    double bankingFees = productValue * 0.005; // 0.5%

    final totalCost = baseCost + customsDuty + shippingCost + 
                     certificationCost + documentationCost + 
                     insuranceCost + bankingFees;

    return {
      'destination': destination,
      'baseCost': baseCost,
      'customsDuty': customsDuty,
      'shippingCost': shippingCost,
      'certificationCost': certificationCost,
      'documentationCost': documentationCost,
      'insuranceCost': insuranceCost,
      'bankingFees': bankingFees,
      'totalCost': totalCost,
      'totalCostInDestinationCurrency': totalCost / destination['exchangeRate'],
      'breakdown': {
        'product_value': productValue,
        'quantity': quantity,
        'unit': unit,
        'tariff_rate': destination['tariffs'],
        'shipping_time': destination['shippingTime'],
      },
    };
  }

  // Calculer les coûts de transport
  static double _calculateShippingCost(Map<String, dynamic> destination, double quantity, String unit) {
    // Coût de base par tonne
    double baseCostPerTon = 150000.0; // FCFA

    // Multiplicateur selon la destination
    double destinationMultiplier = 1.0;
    switch (destination['region']) {
      case 'Europe':
        destinationMultiplier = 2.5;
        break;
      case 'Amérique':
        destinationMultiplier = 3.0;
        break;
      case 'Afrique':
        destinationMultiplier = 1.2;
        break;
    }

    // Convertir la quantité en tonnes
    double quantityInTons = quantity;
    if (unit == 'kg') {
      quantityInTons = quantity / 1000;
    }

    return baseCostPerTon * destinationMultiplier * quantityInTons;
  }

  // Calculer les coûts de certification
  static double _calculateCertificationCost(List<String> requirements) {
    double totalCost = 0.0;

    for (String requirement in requirements) {
      switch (requirement) {
        case 'Certificat phytosanitaire':
          totalCost += 25000.0;
          break;
        case 'HACCP':
          totalCost += 100000.0;
          break;
        case 'FDA':
          totalCost += 200000.0;
          break;
        case 'USDA':
          totalCost += 150000.0;
          break;
        case 'Traçabilité':
          totalCost += 50000.0;
          break;
        case 'Traçabilité complète':
          totalCost += 100000.0;
          break;
      }
    }

    return totalCost;
  }

  // Créer une demande d'exportation
  static Future<ExportImport> createExportRequest({
    required String productId,
    required String destinationCountry,
    required double quantity,
    required String unit,
    required double value,
    required String sellerId,
    Map<String, dynamic>? metadata,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    final destination = _exportDestinations.firstWhere(
      (d) => d['code'] == destinationCountry,
    );

    final exportRequest = ExportImport(
      id: 'export_${DateTime.now().millisecondsSinceEpoch}',
      type: 'export',
      productId: productId,
      destinationCountry: destinationCountry,
      originCountry: 'SN',
      quantity: quantity,
      unit: unit,
      value: value,
      currency: 'FCFA',
      status: 'pending',
      createdAt: DateTime.now(),
      requiredDocuments: destination['requirements'],
      customsInfo: {
        'destination': destination,
        'estimated_shipping_time': destination['shippingTime'],
        'tariff_rate': destination['tariffs'],
      },
    );

    return exportRequest;
  }

  // Obtenir les documents requis pour l'exportation
  static Future<List<Map<String, dynamic>>> getRequiredDocuments({
    required String destinationCountry,
    required String productType,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final destination = _exportDestinations.firstWhere(
      (d) => d['code'] == destinationCountry,
    );

    final List<Map<String, dynamic>> documents = [];

    for (String requirement in destination['requirements']) {
      documents.add({
        'name': requirement,
        'description': _getDocumentDescription(requirement),
        'issuer': _getDocumentIssuer(requirement),
        'cost': _getDocumentCost(requirement),
        'validity': _getDocumentValidity(requirement),
        'processingTime': _getDocumentProcessingTime(requirement),
      });
    }

    return documents;
  }

  // Obtenir la description d'un document
  static String _getDocumentDescription(String documentName) {
    switch (documentName) {
      case 'Certificat phytosanitaire':
        return 'Certificat attestant que les produits sont exempts de parasites et maladies';
      case 'HACCP':
        return 'Certificat d\'analyse des dangers et points critiques pour leur maîtrise';
      case 'FDA':
        return 'Approbation de la Food and Drug Administration américaine';
      case 'USDA':
        return 'Certificat du Département de l\'Agriculture des États-Unis';
      case 'Traçabilité':
        return 'Documentation complète de la traçabilité du produit';
      case 'Traçabilité complète':
        return 'Système de traçabilité avancé avec numéros de lot';
      default:
        return 'Document requis pour l\'exportation';
    }
  }

  // Obtenir l'émetteur d'un document
  static String _getDocumentIssuer(String documentName) {
    switch (documentName) {
      case 'Certificat phytosanitaire':
        return 'Ministère de l\'Agriculture du Sénégal';
      case 'HACCP':
        return 'ISO Sénégal';
      case 'FDA':
        return 'Food and Drug Administration (États-Unis)';
      case 'USDA':
        return 'Département de l\'Agriculture (États-Unis)';
      case 'Traçabilité':
        return 'Organisme de certification agréé';
      case 'Traçabilité complète':
        return 'Organisme de certification international';
      default:
        return 'Organisme compétent';
    }
  }

  // Obtenir le coût d'un document
  static double _getDocumentCost(String documentName) {
    switch (documentName) {
      case 'Certificat phytosanitaire':
        return 25000.0;
      case 'HACCP':
        return 100000.0;
      case 'FDA':
        return 200000.0;
      case 'USDA':
        return 150000.0;
      case 'Traçabilité':
        return 50000.0;
      case 'Traçabilité complète':
        return 100000.0;
      default:
        return 30000.0;
    }
  }

  // Obtenir la validité d'un document
  static int _getDocumentValidity(String documentName) {
    switch (documentName) {
      case 'Certificat phytosanitaire':
        return 14; // jours
      case 'HACCP':
        return 365; // jours
      case 'FDA':
        return 180; // jours
      case 'USDA':
        return 180; // jours
      case 'Traçabilité':
        return 365; // jours
      case 'Traçabilité complète':
        return 365; // jours
      default:
        return 30; // jours
    }
  }

  // Obtenir le temps de traitement d'un document
  static String _getDocumentProcessingTime(String documentName) {
    switch (documentName) {
      case 'Certificat phytosanitaire':
        return '3-5 jours';
      case 'HACCP':
        return '30-45 jours';
      case 'FDA':
        return '60-90 jours';
      case 'USDA':
        return '45-60 jours';
      case 'Traçabilité':
        return '15-30 jours';
      case 'Traçabilité complète':
        return '30-45 jours';
      default:
        return '7-14 jours';
    }
  }

  // Obtenir les statistiques d'exportation
  static Future<Map<String, dynamic>> getExportStatistics() async {
    await Future.delayed(const Duration(seconds: 1));

    return {
      'totalExports': 245,
      'totalValue': 12500000.0, // FCFA
      'topDestinations': {
        'France': 0.35,
        'Espagne': 0.25,
        'Maroc': 0.20,
        'Côte d\'Ivoire': 0.15,
        'États-Unis': 0.05,
      },
      'topProducts': {
        'Riz': 0.40,
        'Tomates': 0.25,
        'Mangues': 0.20,
        'Arachides': 0.15,
      },
      'averageExportValue': 51020.41,
      'successRate': 0.92,
      'monthlyGrowth': 0.22,
      'pendingExports': 15,
      'completedExports': 230,
    };
  }

  // Obtenir les taux de change
  static Future<Map<String, double>> getExchangeRates() async {
    await Future.delayed(const Duration(seconds: 1));

    return {
      'EUR': 655.0,
      'USD': 600.0,
      'MAD': 60.0,
      'XOF': 1.0,
    };
  }

  // Suivre une exportation
  static Future<Map<String, dynamic>> trackExport(String exportId) async {
    await Future.delayed(const Duration(seconds: 1));

    // Simulation du suivi d'exportation
    final statuses = ['pending', 'documents_ready', 'shipped', 'in_transit', 'delivered'];
    final randomStatus = statuses[DateTime.now().millisecond % statuses.length];

    return {
      'exportId': exportId,
      'status': randomStatus,
      'currentLocation': 'Dakar, Sénégal',
      'lastUpdate': DateTime.now().subtract(const Duration(hours: 4)),
      'estimatedDelivery': DateTime.now().add(const Duration(days: 5)),
      'documentsStatus': {
        'phytosanitary': 'approved',
        'haccp': 'pending',
        'traceability': 'approved',
      },
      'shippingInfo': {
        'carrier': 'Maersk',
        'containerNumber': 'MSKU1234567',
        'vessel': 'MSC LORETO',
        'departurePort': 'Dakar',
        'arrivalPort': 'Le Havre',
      },
    };
  }
}
