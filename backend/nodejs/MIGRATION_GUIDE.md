# 🔄 Guide de Migration de la Base de Données

## 📋 Description

Script de migration pour mettre à jour les tables existantes de la base de données SQLite sans perdre de données.

## 🚀 Utilisation

### Exécuter la migration

```bash
cd backend/nodejs
npm run migrate
```

### Ce que fait la migration

1. **Table `agricultural_metrics`:**
   - Ajoute les colonnes manquantes: `plantedArea`, `totalCost`, `revenue`, `profit`, `status`, `weatherData`, `soilData`
   - Copie les valeurs de `area` vers `plantedArea` si nécessaire
   - Calcule `costPerHectare` à partir de `totalCost` et `area` si possible

2. **Table `document_recommendations`:**
   - Ajoute les colonnes manquantes: `fileSizeBytes`, `fileExtension`, `isActive`, `updatedAt`
   - Met à jour `updatedAt` avec `createdAt` si nécessaire

## ✅ Sécurité

- ✅ **Aucune donnée n'est supprimée**
- ✅ Les colonnes existantes ne sont pas modifiées
- ✅ Les colonnes déjà présentes sont ignorées
- ✅ Les valeurs par défaut sont appliquées pour les nouvelles colonnes

## 📊 Résultat

Après la migration, toutes les tables sont compatibles avec:
- ✅ Le modèle Flutter `AgriculturalMetrics`
- ✅ Le modèle Flutter `DocumentRecommendation`
- ✅ Tous les endpoints API

## 🔄 Exécution Automatique

La migration peut être exécutée plusieurs fois en toute sécurité - elle détecte les colonnes existantes et ne les recrée pas.

## ⚠️ Note

Si vous avez des données existantes dans `agricultural_metrics`:
- Les valeurs de `area` seront copiées vers `plantedArea` si `plantedArea` est NULL
- `costPerHectare` sera calculé automatiquement si `totalCost` et `area` sont disponibles
- Les nouvelles colonnes auront des valeurs par défaut (NULL pour les nombres, "planted" pour status, "{}" pour les JSON)

## 🎯 Prochaines Étapes

Après la migration:
1. ✅ Les services Flutter peuvent maintenant utiliser toutes les fonctionnalités
2. ✅ Les données existantes sont préservées
3. ✅ Les nouvelles données utiliseront tous les champs disponibles

