# Documentation du Système de Paiement - Fiches Agricoles

## Vue d'ensemble

Le système de paiement pour les fiches de recommandation agricole est maintenant entièrement opérationnel. Il permet aux utilisateurs d'acheter et d'accéder à des documents PDF de recommandations agricoles spécifiques aux régions du Togo.

## Architecture du Système

### Modèles de Données

1. **User** - Gestion des utilisateurs
   - Id, Name, Email, PhoneNumber, CreatedAt
   - Collection de Purchases

2. **DocumentRecommendation** - Fiches PDF
   - Id, Title, Description, FilePath, Price, Category
   - Region, Prefecture, FileSize, IsActive
   - Collection de Purchases

3. **Payment** - Transactions de paiement
   - Id, UserId, DocumentId, Amount, Currency
   - PaymentMethod, Status, TransactionId, PaymentDetails
   - CreatedAt, CompletedAt, Notes

4. **UserPurchase** - Achats utilisateur
   - Id, UserId, DocumentId, PaymentId
   - PurchaseDate, PricePaid, IsActive
   - AccessExpiryDate, MaxDownloads, DownloadCount

### Services Implémentés

1. **PaymentService** - Gestion des paiements
   - InitiatePaymentAsync() - Initiation de paiement
   - ProcessPaymentAsync() - Traitement
   - CompletePaymentAsync() - Finalisation
   - FailPaymentAsync() - Échec
   - VerifyPaymentAsync() - Vérification
   - GrantDocumentAccessAsync() - Attribution d'accès
   - CheckDocumentAccessAsync() - Vérification d'accès

2. **DocumentService** - Gestion des documents
   - GetAllAsync() - Liste des documents
   - GetByCategoryAsync() - Filtrage par catégorie
   - GetByRegionAsync() - Filtrage par région
   - SeedDocumentsAsync() - Initialisation des données

### API Endpoints

#### Utilisateurs (`/api/users`)
- `POST /` - Créer un utilisateur
- `GET /{id}` - Obtenir un utilisateur
- `PUT /{id}` - Mettre à jour un utilisateur
- `GET /{id}/purchases` - Achats de l'utilisateur

#### Documents (`/api/documents`)
- `GET /` - Liste tous les documents
- `GET /category/{category}` - Documents par catégorie
- `GET /region/{region}` - Documents par région
- `GET /prefecture/{prefecture}` - Documents par préfecture
- `GET /{id}/download?userId={userId}` - Télécharger un document

#### Paiements (`/api/payments`)
- `POST /initiate` - Initier un paiement
- `POST /{id}/process` - Traiter un paiement
- `POST /{id}/complete` - Finaliser un paiement
- `POST /{id}/fail` - Marquer comme échec
- `GET /{id}/verify` - Vérifier un paiement
- `GET /access/{userId}/{documentId}` - Vérifier l'accès
- `POST /simulate-mobile-money` - Simuler paiement mobile money
- `GET /user/{userId}` - Paiements d'un utilisateur

## Documents Disponibles

Le système est pré-chargé avec 3 documents de recommandation :

1. **Guide agricole - Blitta** (2000 FCFA)
   - Région Centrale, Préfecture Blitta
   - Catégorie : technique

2. **Recommandations de culture - Préfecture de Mô** (2200 FCFA)
   - Région Plateaux, Préfecture Mô
   - Catégorie : culture

3. **Recommandations de cultures - Fiches Tchamba** (2500 FCFA)
   - Région Centrale, Préfecture Tchamba
   - Catégorie : culture

## Flux de Paiement

### 1. Initiation
```json
POST /api/payments/initiate
{
  "userId": "user-guid",
  "documentId": "doc_tchamba",
  "paymentMethod": "mobile_money"
}
```

### 2. Simulation Mobile Money
```json
POST /api/payments/simulate-mobile-money
{
  "userId": "user-guid",
  "documentId": "doc_tchamba",
  "phoneNumber": "+22890123456",
  "amount": 2500
}
```

### 3. Vérification d'accès
```
GET /api/payments/access/{userId}/{documentId}
```

### 4. Téléchargement
```
GET /api/documents/{documentId}/download?userId={userId}
```

## Sécurité et Contrôles

- **Contrôle d'accès** : Seuls les utilisateurs ayant acheté un document peuvent y accéder
- **Limites de téléchargement** : Système de comptage des téléchargements
- **Expiration d'accès** : Possibilité de définir une date d'expiration
- **Validation des paiements** : Vérification des transactions avant attribution d'accès

## Base de Données

- **SQLite** pour le développement
- **Entity Framework Core** pour l'ORM
- **Migrations automatiques** avec `EnsureCreated()`
- **Données de test** pré-chargées automatiquement

## Tests

Le système inclut des scripts de test automatisés :
- `test_payment_flow.sh` - Test du flux de base
- `test_complete_flow.sh` - Test complet du système

## Configuration

### Chaîne de connexion
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Data Source=agriculture.db"
  }
}
```

### CORS
- Configuré pour accepter toutes les origines (développement)
- Headers et méthodes autorisés

### JSON
- Sérialisation avec gestion des références circulaires
- Format indenté pour la lisibilité

## Prochaines Étapes

1. **Intégration de vrais processeurs de paiement**
   - Stripe, PayPal, Mobile Money (MTN, Moov)

2. **Authentification et autorisation**
   - JWT tokens
   - Rôles utilisateur

3. **Interface Flutter**
   - UI pour parcourir les documents
   - Interface de paiement
   - Lecteur PDF intégré

4. **Optimisations**
   - Cache pour les documents fréquents
   - Compression des PDF
   - CDN pour la distribution

## Statut Actuel

✅ **SYSTÈME ENTIÈREMENT FONCTIONNEL**

- API REST complète et testée
- Base de données opérationnelle
- Flux de paiement simulé fonctionnel
- Contrôle d'accès aux documents
- Documentation complète
- Scripts de test automatisés

Le backend est prêt pour l'intégration avec l'application Flutter mobile.
