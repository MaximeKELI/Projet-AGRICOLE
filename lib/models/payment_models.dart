// Modèles pour le système de paiement et commercialisation

class PaymentMethod {
  final String id;
  final String name;
  final String type; // mobile_money, card, bank_transfer, cash, crypto
  final String icon;
  final bool isActive;
  final Map<String, dynamic>? config;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    this.isActive = true,
    this.config,
  });
}

class PaymentTransaction {
  final String id;
  final String orderId;
  final String paymentMethodId;
  final double amount;
  final String currency;
  final String status; // pending, completed, failed, refunded
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? transactionReference;
  final Map<String, dynamic>? metadata;

  PaymentTransaction({
    required this.id,
    required this.orderId,
    required this.paymentMethodId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.transactionReference,
    this.metadata,
  });
}

class Order {
  final String id;
  final String buyerId;
  final String sellerId;
  final List<OrderItem> items;
  final double totalAmount;
  final String currency;
  final String status; // pending, confirmed, shipped, delivered, cancelled
  final String paymentStatus; // pending, paid, failed, refunded
  final ShippingAddress shippingAddress;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final Map<String, dynamic>? metadata;

  Order({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.items,
    required this.totalAmount,
    required this.currency,
    required this.status,
    required this.paymentStatus,
    required this.shippingAddress,
    required this.createdAt,
    this.deliveredAt,
    this.metadata,
  });
}

class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String unit; // kg, tonnes, pieces
  final Map<String, dynamic>? specifications;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.unit,
    this.specifications,
  });
}

class ShippingAddress {
  final String id;
  final String fullName;
  final String address;
  final String city;
  final String region;
  final String country;
  final String postalCode;
  final String phoneNumber;
  final String? email;
  final Map<String, double>? coordinates; // lat, lng

  ShippingAddress({
    required this.id,
    required this.fullName,
    required this.address,
    required this.city,
    required this.region,
    required this.country,
    required this.postalCode,
    required this.phoneNumber,
    this.email,
    this.coordinates,
  });
}

class Product {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String currency;
  final String unit;
  final int availableQuantity;
  final String sellerId;
  final List<String> images;
  final Map<String, dynamic>? specifications;
  final String qualityGrade; // A, B, C
  final bool isOrganic;
  final bool isCertified;
  final DateTime createdAt;
  final DateTime? harvestDate;
  final String origin;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.currency,
    required this.unit,
    required this.availableQuantity,
    required this.sellerId,
    required this.images,
    this.specifications,
    required this.qualityGrade,
    this.isOrganic = false,
    this.isCertified = false,
    required this.createdAt,
    this.harvestDate,
    required this.origin,
  });
}

class MarketPrice {
  final String productId;
  final String productName;
  final String region;
  final double price;
  final String currency;
  final String unit;
  final DateTime date;
  final String source; // market, government, international
  final double? priceChange; // % change from previous period
  final String trend; // up, down, stable

  MarketPrice({
    required this.productId,
    required this.productName,
    required this.region,
    required this.price,
    required this.currency,
    required this.unit,
    required this.date,
    required this.source,
    this.priceChange,
    required this.trend,
  });
}

class Certification {
  final String id;
  final String name;
  final String type; // organic, fair_trade, quality, export
  final String issuer;
  final DateTime issuedDate;
  final DateTime expiryDate;
  final String status; // active, expired, pending
  final String certificateNumber;
  final String? documentUrl;

  Certification({
    required this.id,
    required this.name,
    required this.type,
    required this.issuer,
    required this.issuedDate,
    required this.expiryDate,
    required this.status,
    required this.certificateNumber,
    this.documentUrl,
  });
}

class ExportImport {
  final String id;
  final String type; // export, import
  final String productId;
  final String destinationCountry;
  final String originCountry;
  final double quantity;
  final String unit;
  final double value;
  final String currency;
  final String status; // pending, approved, shipped, delivered
  final DateTime createdAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final List<String> requiredDocuments;
  final Map<String, dynamic>? customsInfo;

  ExportImport({
    required this.id,
    required this.type,
    required this.productId,
    required this.destinationCountry,
    required this.originCountry,
    required this.quantity,
    required this.unit,
    required this.value,
    required this.currency,
    required this.status,
    required this.createdAt,
    this.shippedAt,
    this.deliveredAt,
    required this.requiredDocuments,
    this.customsInfo,
  });
}
