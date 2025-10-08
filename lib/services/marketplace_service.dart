import '../models/payment_models.dart';

class MarketplaceService {
  // Produits disponibles sur la marketplace
  static final List<Product> _products = [
    Product(
      id: 'prod_001',
      name: 'Riz de Casamance',
      description: 'Riz de qualité supérieure cultivé en Casamance',
      category: 'Céréales',
      price: 200000.0,
      currency: 'FCFA',
      unit: 'tonne',
      availableQuantity: 50,
      sellerId: 'seller_001',
      images: ['rice1.jpg', 'rice2.jpg'],
      qualityGrade: 'A',
      isOrganic: true,
      isCertified: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      harvestDate: DateTime.now().subtract(const Duration(days: 15)),
      origin: 'Casamance, Sénégal',
      specifications: {
        'variety': 'NERICA',
        'moisture_content': '12%',
        'protein_content': '8.5%',
        'packaging': 'Sacs de 50kg',
      },
    ),
    Product(
      id: 'prod_002',
      name: 'Tomates de Niayes',
      description: 'Tomates fraîches cultivées dans la zone des Niayes',
      category: 'Légumes',
      price: 300000.0,
      currency: 'FCFA',
      unit: 'tonne',
      availableQuantity: 25,
      sellerId: 'seller_002',
      images: ['tomato1.jpg', 'tomato2.jpg'],
      qualityGrade: 'A',
      isOrganic: false,
      isCertified: true,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      harvestDate: DateTime.now().subtract(const Duration(days: 5)),
      origin: 'Niayes, Sénégal',
      specifications: {
        'variety': 'Roma',
        'size': 'Moyenne',
        'color': 'Rouge vif',
        'packaging': 'Cagettes de 20kg',
      },
    ),
    Product(
      id: 'prod_003',
      name: 'Mangues de Kédougou',
      description: 'Mangues sucrées de la région de Kédougou',
      category: 'Fruits',
      price: 120000.0,
      currency: 'FCFA',
      unit: 'tonne',
      availableQuantity: 40,
      sellerId: 'seller_003',
      images: ['mango1.jpg', 'mango2.jpg'],
      qualityGrade: 'A',
      isOrganic: true,
      isCertified: false,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      harvestDate: DateTime.now().subtract(const Duration(days: 3)),
      origin: 'Kédougou, Sénégal',
      specifications: {
        'variety': 'Kent',
        'maturity': 'Mûre',
        'sugar_content': '15%',
        'packaging': 'Cagettes de 15kg',
      },
    ),
  ];

  // Obtenir tous les produits
  static Future<List<Product>> getProducts({
    String? category,
    String? qualityGrade,
    bool? isOrganic,
    bool? isCertified,
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    String? sortBy, // price, date, rating
    String? sortOrder, // asc, desc
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    var filteredProducts = List<Product>.from(_products);

    // Filtrer par catégorie
    if (category != null) {
      filteredProducts = filteredProducts.where((p) => p.category == category).toList();
    }

    // Filtrer par grade de qualité
    if (qualityGrade != null) {
      filteredProducts = filteredProducts.where((p) => p.qualityGrade == qualityGrade).toList();
    }

    // Filtrer par bio
    if (isOrganic != null) {
      filteredProducts = filteredProducts.where((p) => p.isOrganic == isOrganic).toList();
    }

    // Filtrer par certifié
    if (isCertified != null) {
      filteredProducts = filteredProducts.where((p) => p.isCertified == isCertified).toList();
    }

    // Recherche textuelle
    if (searchQuery != null && searchQuery.isNotEmpty) {
      filteredProducts = filteredProducts.where((p) =>
          p.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
          p.origin.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    }

    // Filtrer par prix
    if (minPrice != null) {
      filteredProducts = filteredProducts.where((p) => p.price >= minPrice).toList();
    }
    if (maxPrice != null) {
      filteredProducts = filteredProducts.where((p) => p.price <= maxPrice).toList();
    }

    // Trier
    if (sortBy != null) {
      switch (sortBy) {
        case 'price':
          filteredProducts.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'date':
          filteredProducts.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          break;
        case 'rating':
          // Dans une vraie implémentation, on utiliserait les notes
          break;
      }

      if (sortOrder == 'desc') {
        filteredProducts = filteredProducts.reversed.toList();
      }
    }

    return filteredProducts;
  }

  // Obtenir un produit par ID
  static Future<Product?> getProductById(String productId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }

  // Créer une commande
  static Future<Order> createOrder({
    required String buyerId,
    required List<OrderItem> items,
    required ShippingAddress shippingAddress,
    Map<String, dynamic>? metadata,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    // Calculer le montant total
    double totalAmount = 0.0;
    for (var item in items) {
      totalAmount += item.totalPrice;
    }

    // Calculer les frais de livraison
    final shippingCost = _calculateShippingCost(shippingAddress, totalAmount);
    totalAmount += shippingCost;

    final order = Order(
      id: 'order_${DateTime.now().millisecondsSinceEpoch}',
      buyerId: buyerId,
      sellerId: items.first.productId, // Simplification - en réalité il faudrait gérer plusieurs vendeurs
      items: items,
      totalAmount: totalAmount,
      currency: 'FCFA',
      status: 'pending',
      paymentStatus: 'pending',
      shippingAddress: shippingAddress,
      createdAt: DateTime.now(),
      metadata: {
        ...?metadata,
        'shipping_cost': shippingCost,
      },
    );

    return order;
  }

  // Calculer les frais de livraison
  static double _calculateShippingCost(ShippingAddress address, double orderAmount) {
    // Frais de base
    double baseCost = 5000.0;

    // Frais selon la région
    switch (address.region) {
      case 'Dakar':
        return baseCost;
      case 'Thiès':
      case 'Kaolack':
        return baseCost * 1.5;
      case 'Saint-Louis':
      case 'Ziguinchor':
        return baseCost * 2.0;
      default:
        return baseCost * 2.5;
    }
  }

  // Obtenir les prix du marché
  static Future<List<MarketPrice>> getMarketPrices({
    String? productId,
    String? region,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final List<MarketPrice> prices = [
      MarketPrice(
        productId: 'prod_001',
        productName: 'Riz de Casamance',
        region: 'Dakar',
        price: 200000.0,
        currency: 'FCFA',
        unit: 'tonne',
        date: DateTime.now().subtract(const Duration(days: 1)),
        source: 'market',
        priceChange: 2.5,
        trend: 'up',
      ),
      MarketPrice(
        productId: 'prod_001',
        productName: 'Riz de Casamance',
        region: 'Thiès',
        price: 195000.0,
        currency: 'FCFA',
        unit: 'tonne',
        date: DateTime.now().subtract(const Duration(days: 1)),
        source: 'market',
        priceChange: -1.2,
        trend: 'down',
      ),
      MarketPrice(
        productId: 'prod_002',
        productName: 'Tomates de Niayes',
        region: 'Dakar',
        price: 300000.0,
        currency: 'FCFA',
        unit: 'tonne',
        date: DateTime.now().subtract(const Duration(days: 1)),
        source: 'market',
        priceChange: 5.0,
        trend: 'up',
      ),
    ];

    var filteredPrices = prices;

    if (productId != null) {
      filteredPrices = filteredPrices.where((p) => p.productId == productId).toList();
    }

    if (region != null) {
      filteredPrices = filteredPrices.where((p) => p.region == region).toList();
    }

    return filteredPrices;
  }

  // Obtenir les catégories de produits
  static Future<List<String>> getProductCategories() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return ['Céréales', 'Légumes', 'Fruits', 'Tubercules', 'Épices', 'Légumineuses'];
  }

  // Obtenir les statistiques de la marketplace
  static Future<Map<String, dynamic>> getMarketplaceStatistics() async {
    await Future.delayed(const Duration(seconds: 1));

    return {
      'totalProducts': _products.length,
      'totalSellers': 3,
      'totalOrders': 156,
      'totalRevenue': 2500000.0,
      'averageOrderValue': 16025.64,
      'topCategories': {
        'Céréales': 0.40,
        'Légumes': 0.30,
        'Fruits': 0.20,
        'Tubercules': 0.10,
      },
      'organicProducts': _products.where((p) => p.isOrganic).length,
      'certifiedProducts': _products.where((p) => p.isCertified).length,
      'monthlyGrowth': 0.25,
    };
  }

  // Obtenir les commandes d'un utilisateur
  static Future<List<Order>> getUserOrders(String userId) async {
    await Future.delayed(const Duration(seconds: 1));

    // Simulation des commandes
    final List<Order> orders = [
      Order(
        id: 'order_001',
        buyerId: userId,
        sellerId: 'seller_001',
        items: [
          OrderItem(
            productId: 'prod_001',
            productName: 'Riz de Casamance',
            quantity: 2,
            unitPrice: 200000.0,
            totalPrice: 400000.0,
            unit: 'tonne',
          ),
        ],
        totalAmount: 410000.0,
        currency: 'FCFA',
        status: 'delivered',
        paymentStatus: 'paid',
        shippingAddress: ShippingAddress(
          id: 'addr_001',
          fullName: 'Mamadou Diallo',
          address: 'Rue 10, Point E',
          city: 'Dakar',
          region: 'Dakar',
          country: 'Sénégal',
          postalCode: '10000',
          phoneNumber: '+221701234567',
          email: 'mamadou@example.com',
        ),
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        deliveredAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];

    return orders;
  }

  // Mettre à jour le statut d'une commande
  static Future<Order> updateOrderStatus({
    required String orderId,
    required String status,
    Map<String, dynamic>? metadata,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    // Dans une vraie implémentation, on mettrait à jour en base de données
    final order = Order(
      id: orderId,
      buyerId: 'buyer_001',
      sellerId: 'seller_001',
      items: [],
      totalAmount: 0.0,
      currency: 'FCFA',
      status: status,
      paymentStatus: 'paid',
      shippingAddress: ShippingAddress(
        id: 'addr_001',
        fullName: 'Mamadou Diallo',
        address: 'Rue 10, Point E',
        city: 'Dakar',
        region: 'Dakar',
        country: 'Sénégal',
        postalCode: '10000',
        phoneNumber: '+221701234567',
      ),
      createdAt: DateTime.now(),
      metadata: metadata,
    );

    return order;
  }
}
