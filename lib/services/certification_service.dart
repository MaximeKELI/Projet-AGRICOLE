import '../models/payment_models.dart';

class CertificationService {
  // Certifications disponibles
  static final List<Certification> _certifications = [
    Certification(
      id: 'cert_001',
      name: 'Agriculture Biologique',
      type: 'organic',
      issuer: 'Ministère de l\'Agriculture du Sénégal',
      issuedDate: DateTime.now().subtract(const Duration(days: 180)),
      expiryDate: DateTime.now().add(const Duration(days: 185)),
      status: 'active',
      certificateNumber: 'BIO-SN-2024-001',
      documentUrl: 'https://certificates.gov.sn/bio/001.pdf',
    ),
    Certification(
      id: 'cert_002',
      name: 'Fair Trade',
      type: 'fair_trade',
      issuer: 'Fairtrade International',
      issuedDate: DateTime.now().subtract(const Duration(days: 90)),
      expiryDate: DateTime.now().add(const Duration(days: 275)),
      status: 'active',
      certificateNumber: 'FT-SN-2024-002',
      documentUrl: 'https://fairtrade.org/certificates/002.pdf',
    ),
    Certification(
      id: 'cert_003',
      name: 'HACCP',
      type: 'quality',
      issuer: 'ISO Sénégal',
      issuedDate: DateTime.now().subtract(const Duration(days: 30)),
      expiryDate: DateTime.now().add(const Duration(days: 335)),
      status: 'active',
      certificateNumber: 'HACCP-SN-2024-003',
      documentUrl: 'https://iso.sn/certificates/haccp/003.pdf',
    ),
  ];

  // Obtenir toutes les certifications
  static Future<List<Certification>> getCertifications({
    String? type,
    String? status,
    String? issuer,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    var certifications = List<Certification>.from(_certifications);

    if (type != null) {
      certifications = certifications.where((c) => c.type == type).toList();
    }

    if (status != null) {
      certifications = certifications.where((c) => c.status == status).toList();
    }

    if (issuer != null) {
      certifications = certifications.where((c) => c.issuer.contains(issuer)).toList();
    }

    return certifications;
  }

  // Vérifier la validité d'une certification
  static Future<bool> isCertificationValid(String certificateNumber) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final certification = _certifications.firstWhere(
      (c) => c.certificateNumber == certificateNumber,
      orElse: () => throw Exception('Certification non trouvée'),
    );

    return certification.status == 'active' && 
           certification.expiryDate.isAfter(DateTime.now());
  }

  // Obtenir les certifications par produit
  static Future<List<Certification>> getProductCertifications(String productId) async {
    await Future.delayed(const Duration(seconds: 1));

    // Simulation - dans une vraie implémentation, on ferait une requête
    // pour obtenir les certifications liées à un produit spécifique
    return _certifications.where((c) => c.status == 'active').toList();
  }

  // Créer une nouvelle certification
  static Future<Certification> createCertification({
    required String name,
    required String type,
    required String issuer,
    required String certificateNumber,
    required DateTime expiryDate,
    String? documentUrl,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    final certification = Certification(
      id: 'cert_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      type: type,
      issuer: issuer,
      issuedDate: DateTime.now(),
      expiryDate: expiryDate,
      status: 'active',
      certificateNumber: certificateNumber,
      documentUrl: documentUrl,
    );

    _certifications.add(certification);
    return certification;
  }

  // Obtenir les types de certification disponibles
  static Future<List<Map<String, dynamic>>> getCertificationTypes() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      {
        'id': 'organic',
        'name': 'Agriculture Biologique',
        'description': 'Certification pour les produits issus de l\'agriculture biologique',
        'requirements': [
          'Aucun pesticide chimique',
          'Engrais naturels uniquement',
          'Rotation des cultures',
          'Traçabilité complète',
        ],
        'validityPeriod': 365, // jours
        'cost': 50000.0, // FCFA
      },
      {
        'id': 'fair_trade',
        'name': 'Commerce Équitable',
        'description': 'Certification pour le commerce équitable',
        'requirements': [
          'Prix minimum garanti',
          'Conditions de travail décentes',
          'Respect de l\'environnement',
          'Développement communautaire',
        ],
        'validityPeriod': 365,
        'cost': 75000.0,
      },
      {
        'id': 'quality',
        'name': 'Qualité HACCP',
        'description': 'Certification de qualité et sécurité alimentaire',
        'requirements': [
          'Analyse des dangers',
          'Points de contrôle critiques',
          'Procédures de surveillance',
          'Documentation complète',
        ],
        'validityPeriod': 365,
        'cost': 100000.0,
      },
      {
        'id': 'export',
        'name': 'Export International',
        'description': 'Certification pour l\'exportation internationale',
        'requirements': [
          'Normes phytosanitaires',
          'Traçabilité complète',
          'Emballage conforme',
          'Documentation douanière',
        ],
        'validityPeriod': 180,
        'cost': 150000.0,
      },
    ];
  }

  // Obtenir les organismes de certification
  static Future<List<Map<String, dynamic>>> getCertificationBodies() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      {
        'id': 'org_001',
        'name': 'Ministère de l\'Agriculture du Sénégal',
        'type': 'government',
        'website': 'https://agriculture.gouv.sn',
        'contact': '+221338211234',
        'email': 'certification@agriculture.gouv.sn',
        'certifications': ['organic', 'quality'],
      },
      {
        'id': 'org_002',
        'name': 'Fairtrade International',
        'type': 'international',
        'website': 'https://fairtrade.org',
        'contact': '+33123456789',
        'email': 'senegal@fairtrade.org',
        'certifications': ['fair_trade'],
      },
      {
        'id': 'org_003',
        'name': 'ISO Sénégal',
        'type': 'international',
        'website': 'https://iso.sn',
        'contact': '+221338211235',
        'email': 'info@iso.sn',
        'certifications': ['quality', 'export'],
      },
      {
        'id': 'org_004',
        'name': 'Ecocert',
        'type': 'private',
        'website': 'https://ecocert.com',
        'contact': '+33123456790',
        'email': 'senegal@ecocert.com',
        'certifications': ['organic', 'fair_trade'],
      },
    ];
  }

  // Obtenir les statistiques de certification
  static Future<Map<String, dynamic>> getCertificationStatistics() async {
    await Future.delayed(const Duration(seconds: 1));

    final activeCertifications = _certifications.where((c) => c.status == 'active').length;
    final expiredCertifications = _certifications.where((c) => c.status == 'expired').length;
    final pendingCertifications = _certifications.where((c) => c.status == 'pending').length;

    return {
      'totalCertifications': _certifications.length,
      'activeCertifications': activeCertifications,
      'expiredCertifications': expiredCertifications,
      'pendingCertifications': pendingCertifications,
      'certificationRate': 0.85, // 85% des produits certifiés
      'topCertificationTypes': {
        'organic': 0.40,
        'quality': 0.30,
        'fair_trade': 0.20,
        'export': 0.10,
      },
      'averageCertificationCost': 75000.0,
      'certificationBodies': 4,
      'monthlyGrowth': 0.12,
    };
  }

  // Vérifier l'éligibilité à une certification
  static Future<Map<String, dynamic>> checkCertificationEligibility({
    required String productId,
    required String certificationType,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    // Simulation de la vérification d'éligibilité
    final isEligible = DateTime.now().millisecond % 2 == 0; // 50% de chance

    return {
      'isEligible': isEligible,
      'requirements': [
        'Produit cultivé selon les normes',
        'Traçabilité complète',
        'Documentation à jour',
        'Inspection sur site',
      ],
      'estimatedCost': 75000.0,
      'estimatedTime': '30-45 jours',
      'nextSteps': isEligible ? [
        'Soumettre la demande',
        'Payer les frais',
        'Programmer l\'inspection',
        'Recevoir la certification',
      ] : [
        'Améliorer les pratiques',
        'Mettre à jour la documentation',
        'Reprogrammer la vérification',
      ],
    };
  }

  // Obtenir les certifications expirant bientôt
  static Future<List<Certification>> getExpiringCertifications({
    int daysAhead = 30,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final cutoffDate = DateTime.now().add(Duration(days: daysAhead));
    
    return _certifications.where((c) => 
        c.status == 'active' && 
        c.expiryDate.isBefore(cutoffDate) &&
        c.expiryDate.isAfter(DateTime.now())).toList();
  }

  // Renouveler une certification
  static Future<Certification> renewCertification({
    required String certificationId,
    required DateTime newExpiryDate,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    final index = _certifications.indexWhere((c) => c.id == certificationId);
    if (index == -1) {
      throw Exception('Certification non trouvée');
    }

    final oldCertification = _certifications[index];
    final renewedCertification = Certification(
      id: oldCertification.id,
      name: oldCertification.name,
      type: oldCertification.type,
      issuer: oldCertification.issuer,
      issuedDate: DateTime.now(),
      expiryDate: newExpiryDate,
      status: 'active',
      certificateNumber: oldCertification.certificateNumber,
      documentUrl: oldCertification.documentUrl,
    );

    _certifications[index] = renewedCertification;
    return renewedCertification;
  }
}
