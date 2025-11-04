# 🔍 Rapport de Compatibilité Frontend-Backend

## ✅ Services Compatibles

1. **weather_service.dart** ✅
   - Utilise `http://localhost:5000/api/weather/current`
   - Utilise `http://localhost:5000/api/weather/forecast`
   - Utilise `http://localhost:5000/api/weather/alerts`
   - **Status**: Compatible

2. **agricultural_service.dart** ✅
   - Utilise `http://localhost:5000/api/agricultural-metrics/*`
   - **Status**: Compatible (mais structure de données différente)

3. **document_service.dart** ⚠️
   - Endpoints utilisés:
     - `GET /api/documents` ✅
     - `GET /api/documents/category/:category` ✅
     - `GET /api/documents/region/:region` ✅
     - `POST /api/users` ✅
     - `POST /api/payments/simulate-mobile-money` ❌ **MANQUANT**
     - `GET /api/payments/access/:userId/:documentId` ❌ **MANQUANT**
     - `GET /api/documents/:id/download` ⚠️ **À vérifier**

## ❌ Problèmes Détectés

### 1. Structure AgriculturalMetrics Incompatible

**Frontend (Flutter) attend:**
- `plantedArea`, `totalCost`, `revenue`, `profit`, `status`, `weatherData`, `soilData`

**Backend (NodeJS) stocke:**
- `area`, `costPerHectare`, `expectedYield`, `actualYield`, `yieldEfficiency`, `daysToHarvest`

**Impact**: Les données ne correspondent pas entre frontend et backend.

### 2. Endpoints Manquants

- `POST /api/payments/simulate-mobile-money` - Utilisé par document_service.dart
- `GET /api/payments/access/:userId/:documentId` - Utilisé par document_service.dart
- `GET /api/documents/:id/download` - Utilisé par document_service.dart

### 3. Modèle DocumentRecommendation

**Frontend attend:**
- `fileSizeBytes`, `fileExtension`, `isActive`, `createdAt`, `updatedAt`

**Backend stocke:**
- `filePath`, `price`, `category`, `region`, `prefecture`, `createdAt`

**Impact**: Certains champs peuvent être manquants lors de la désérialisation.

## 🔧 Corrections Nécessaires

1. Mettre à jour le schéma de la base de données pour AgriculturalMetrics
2. Ajouter les endpoints manquants pour les paiements
3. Adapter le modèle DocumentRecommendation pour correspondre

