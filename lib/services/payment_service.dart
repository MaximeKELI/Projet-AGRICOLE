import '../models/payment_models.dart';

class PaymentService {
  // Méthodes de paiement disponibles
  static final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      id: 'orange_money',
      name: 'Orange Money',
      type: 'mobile_money',
      icon: '🟠',
      config: {
        'merchant_code': 'AGRICOLE001',
        'api_key': 'your_orange_money_api_key',
        'callback_url': 'https://yourapp.com/payment/callback',
      },
    ),
    PaymentMethod(
      id: 'mtn_money',
      name: 'MTN Mobile Money',
      type: 'mobile_money',
      icon: '🟡',
      config: {
        'merchant_id': 'AGRICOLE002',
        'api_key': 'your_mtn_money_api_key',
        'callback_url': 'https://yourapp.com/payment/callback',
      },
    ),
    PaymentMethod(
      id: 'wave',
      name: 'Wave',
      type: 'mobile_money',
      icon: '🌊',
      config: {
        'merchant_id': 'AGRICOLE003',
        'api_key': 'your_wave_api_key',
        'callback_url': 'https://yourapp.com/payment/callback',
      },
    ),
    PaymentMethod(
      id: 'visa_mastercard',
      name: 'Visa/Mastercard',
      type: 'card',
      icon: '💳',
      config: {
        'stripe_publishable_key': 'pk_test_your_stripe_key',
        'stripe_secret_key': 'sk_test_your_stripe_secret',
      },
    ),
    PaymentMethod(
      id: 'bank_transfer',
      name: 'Virement Bancaire',
      type: 'bank_transfer',
      icon: '🏦',
      config: {
        'bank_name': 'Banque Atlantique',
        'account_number': '1234567890',
        'swift_code': 'ATLNSNDA',
      },
    ),
    PaymentMethod(
      id: 'crypto',
      name: 'Cryptomonnaie',
      type: 'crypto',
      icon: '₿',
      config: {
        'accepted_currencies': ['BTC', 'ETH', 'USDT'],
        'wallet_address': 'your_crypto_wallet_address',
      },
    ),
    PaymentMethod(
      id: 'cash_on_delivery',
      name: 'Paiement à la Livraison',
      type: 'cash',
      icon: '💰',
    ),
  ];

  // Obtenir toutes les méthodes de paiement
  static List<PaymentMethod> getPaymentMethods() {
    return _paymentMethods.where((method) => method.isActive).toList();
  }

  // Obtenir les méthodes de paiement par type
  static List<PaymentMethod> getPaymentMethodsByType(String type) {
    return _paymentMethods.where((method) => method.type == type && method.isActive).toList();
  }

  // Traiter un paiement
  static Future<PaymentTransaction> processPayment({
    required String orderId,
    required String paymentMethodId,
    required double amount,
    required String currency,
    Map<String, dynamic>? metadata,
  }) async {
    // Simulation du traitement de paiement
    await Future.delayed(const Duration(seconds: 2));

    final paymentMethod = _paymentMethods.firstWhere(
      (method) => method.id == paymentMethodId,
      orElse: () => throw Exception('Méthode de paiement non trouvée'),
    );

    // Simulation de différents taux de succès selon la méthode
    final successRate = _getSuccessRate(paymentMethod.type);
    final isSuccess = (DateTime.now().millisecondsSinceEpoch % 100) < (successRate * 100);

    final transaction = PaymentTransaction(
      id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
      orderId: orderId,
      paymentMethodId: paymentMethodId,
      amount: amount,
      currency: currency,
      status: isSuccess ? 'completed' : 'failed',
      createdAt: DateTime.now(),
      completedAt: isSuccess ? DateTime.now() : null,
      transactionReference: isSuccess ? 'ref_${DateTime.now().millisecondsSinceEpoch}' : null,
      metadata: metadata,
    );

    return transaction;
  }

  // Obtenir le taux de succès selon le type de paiement
  static double _getSuccessRate(String type) {
    switch (type) {
      case 'mobile_money':
        return 0.95; // 95% de succès
      case 'card':
        return 0.90; // 90% de succès
      case 'bank_transfer':
        return 0.85; // 85% de succès
      case 'crypto':
        return 0.80; // 80% de succès
      case 'cash':
        return 1.0; // 100% de succès (paiement à la livraison)
      default:
        return 0.70; // 70% de succès par défaut
    }
  }

  // Vérifier le statut d'un paiement
  static Future<PaymentTransaction> checkPaymentStatus(String transactionId) async {
    // Simulation de la vérification du statut
    await Future.delayed(const Duration(seconds: 1));

    // Dans une vraie implémentation, on ferait un appel API
    return PaymentTransaction(
      id: transactionId,
      orderId: 'order_123',
      paymentMethodId: 'orange_money',
      amount: 50000.0,
      currency: 'FCFA',
      status: 'completed',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      completedAt: DateTime.now().subtract(const Duration(minutes: 3)),
      transactionReference: 'ref_123456789',
    );
  }

  // Obtenir l'historique des paiements
  static Future<List<PaymentTransaction>> getPaymentHistory({
    String? userId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Simulation de l'historique des paiements
    await Future.delayed(const Duration(seconds: 1));

    final List<PaymentTransaction> transactions = [
      PaymentTransaction(
        id: 'txn_001',
        orderId: 'order_001',
        paymentMethodId: 'orange_money',
        amount: 25000.0,
        currency: 'FCFA',
        status: 'completed',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        completedAt: DateTime.now().subtract(const Duration(days: 1)),
        transactionReference: 'ref_001',
      ),
      PaymentTransaction(
        id: 'txn_002',
        orderId: 'order_002',
        paymentMethodId: 'mtn_money',
        amount: 15000.0,
        currency: 'FCFA',
        status: 'completed',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        completedAt: DateTime.now().subtract(const Duration(days: 3)),
        transactionReference: 'ref_002',
      ),
      PaymentTransaction(
        id: 'txn_003',
        orderId: 'order_003',
        paymentMethodId: 'visa_mastercard',
        amount: 75000.0,
        currency: 'FCFA',
        status: 'pending',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];

    // Filtrer selon les paramètres
    var filteredTransactions = transactions;

    if (status != null) {
      filteredTransactions = filteredTransactions.where((t) => t.status == status).toList();
    }

    if (startDate != null) {
      filteredTransactions = filteredTransactions.where((t) => t.createdAt.isAfter(startDate)).toList();
    }

    if (endDate != null) {
      filteredTransactions = filteredTransactions.where((t) => t.createdAt.isBefore(endDate)).toList();
    }

    return filteredTransactions;
  }

  // Calculer les frais de transaction
  static double calculateTransactionFees({
    required double amount,
    required String paymentMethodId,
    required String currency,
  }) {
    final paymentMethod = _paymentMethods.firstWhere(
      (method) => method.id == paymentMethodId,
      orElse: () => throw Exception('Méthode de paiement non trouvée'),
    );

    double feePercentage = 0.0;

    switch (paymentMethod.type) {
      case 'mobile_money':
        feePercentage = 0.015; // 1.5%
        break;
      case 'card':
        feePercentage = 0.029; // 2.9%
        break;
      case 'bank_transfer':
        feePercentage = 0.005; // 0.5%
        break;
      case 'crypto':
        feePercentage = 0.01; // 1%
        break;
      case 'cash':
        feePercentage = 0.0; // Pas de frais
        break;
      default:
        feePercentage = 0.02; // 2% par défaut
    }

    return amount * feePercentage;
  }

  // Obtenir les statistiques de paiement
  static Future<Map<String, dynamic>> getPaymentStatistics({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Simulation des statistiques
    await Future.delayed(const Duration(seconds: 1));

    return {
      'totalTransactions': 156,
      'totalAmount': 2500000.0,
      'successRate': 0.92,
      'averageTransactionAmount': 16025.64,
      'paymentMethodsBreakdown': {
        'mobile_money': 0.65,
        'card': 0.20,
        'bank_transfer': 0.10,
        'crypto': 0.03,
        'cash': 0.02,
      },
      'monthlyGrowth': 0.15,
      'topPaymentMethod': 'orange_money',
    };
  }

  // Rembourser un paiement
  static Future<PaymentTransaction> refundPayment({
    required String transactionId,
    required double amount,
    String? reason,
  }) async {
    // Simulation du remboursement
    await Future.delayed(const Duration(seconds: 2));

    final originalTransaction = await checkPaymentStatus(transactionId);

    final refundTransaction = PaymentTransaction(
      id: 'refund_${DateTime.now().millisecondsSinceEpoch}',
      orderId: originalTransaction.orderId,
      paymentMethodId: originalTransaction.paymentMethodId,
      amount: -amount, // Montant négatif pour le remboursement
      currency: originalTransaction.currency,
      status: 'refunded',
      createdAt: DateTime.now(),
      completedAt: DateTime.now(),
      transactionReference: 'refund_ref_${DateTime.now().millisecondsSinceEpoch}',
      metadata: {'reason': reason, 'original_transaction_id': transactionId},
    );

    return refundTransaction;
  }
}
