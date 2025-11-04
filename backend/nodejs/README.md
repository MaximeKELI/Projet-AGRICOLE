# 🌾 AGRICOLE Backend NodeJS

Backend NodeJS pour la plateforme agricole AGRICOLE, remplaçant le backend C# précédent.

## 📋 Prérequis

- Node.js 18+ 
- npm ou yarn

## 🚀 Installation

1. **Installer les dépendances**
```bash
cd backend/nodejs
npm install
```

2. **Configurer les variables d'environnement**
```bash
cp .env.example .env
```

Puis éditez le fichier `.env` et ajoutez vos clés API :

```env
PORT=5000
DB_PATH=./agriculture.db

# Clés API - OBLIGATOIRES pour les données réelles
OPENWEATHER_API_KEY=your_openweather_api_key_here
GOOGLE_MAPS_API_KEY=your_google_maps_api_key_here

ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080
```

### 🔑 Obtenir les clés API

#### OpenWeather API (pour les données météo réelles)
1. Créez un compte sur [OpenWeather](https://openweathermap.org/api)
2. Obtenez votre clé API gratuite (Free tier disponible)
3. Ajoutez-la dans le fichier `.env`

#### Google Maps API (optionnel, pour la géolocalisation)
1. Créez un projet sur [Google Cloud Console](https://console.cloud.google.com/)
2. Activez l'API Google Maps
3. Créez une clé API
4. Ajoutez-la dans le fichier `.env`

## 🏃 Démarrage

### Mode développement
```bash
npm run dev
```

### Mode production
```bash
npm start
```

Le serveur sera accessible sur `http://localhost:5000`

## 📡 Endpoints API

### Santé
- `GET /health` - Vérifier l'état du serveur

### Utilisateurs
- `GET /api/users/:id` - Récupérer un utilisateur
- `GET /api/users/email/:email` - Récupérer un utilisateur par email
- `POST /api/users` - Créer un utilisateur
- `GET /api/users/:userId/purchases` - Récupérer les achats d'un utilisateur

### Cultures
- `GET /api/crops` - Liste des cultures
- `GET /api/crops/:cropId` - Détails d'une culture
- `GET /api/crops/recommended/:soilTypeId` - Cultures recommandées pour un type de sol
- `GET /api/crops/:cropId/activities/upcoming?plantingDate=YYYY-MM-DD` - Activités à venir

### Régions
- `GET /api/regions` - Liste des régions
- `GET /api/regions/:regionId/prefectures` - Préfectures d'une région
- `GET /api/regions/:regionId/communes` - Communes d'une région

### Météo (Données réelles via OpenWeather)
- `GET /api/weather/current?latitude=X&longitude=Y` - Météo actuelle
- `GET /api/weather/forecast?latitude=X&longitude=Y&days=5` - Prévisions météo
- `GET /api/weather/alerts` - Alertes météo actives
- `GET /api/weather/alerts/:type` - Alertes par type
- `POST /api/weather/alerts` - Créer une alerte météo

### Paiements
- `POST /api/payments/initiate` - Initier un paiement
- `POST /api/payments/process` - Traiter un paiement
- `GET /api/payments/:id` - Récupérer un paiement
- `GET /api/payments/history/:userId` - Historique des paiements

### Documents
- `GET /api/documents` - Liste des documents
- `GET /api/documents/:id` - Détails d'un document
- `GET /api/documents/category/:category` - Documents par catégorie
- `GET /api/documents/region/:region` - Documents par région
- `GET /api/documents/prefecture/:prefecture` - Documents par préfecture

### Métriques Agricoles
- `GET /api/agricultural-metrics/user/:userId` - Métriques d'un utilisateur
- `GET /api/agricultural-metrics/:id` - Détails d'une métrique
- `POST /api/agricultural-metrics` - Créer une métrique
- `PUT /api/agricultural-metrics/:id` - Mettre à jour une métrique
- `DELETE /api/agricultural-metrics/:id` - Supprimer une métrique

## 🗄️ Base de données

La base de données SQLite est créée automatiquement au premier démarrage. Elle contient :
- Users (utilisateurs)
- Regions, Prefectures, Communes (géolocalisation)
- SoilTypes, Crops (données agricoles)
- WeatherAlerts (alertes météo)
- Payments, UserPurchases (paiements)
- AgriculturalMetrics (métriques agricoles)
- DocumentRecommendations (documents)

## ⚠️ Important

**Ce backend utilise uniquement des données réelles :**
- Les données météo proviennent de l'API OpenWeather (nécessite une clé API)
- Aucune donnée fictive n'est générée
- Si les données ne sont pas disponibles, une erreur claire est retournée

## 🔧 Configuration

Toutes les configurations se font via le fichier `.env`. Assurez-vous de :
1. Configurer `OPENWEATHER_API_KEY` pour les données météo réelles
2. Configurer le `PORT` si nécessaire (par défaut 5000)
3. Configurer `ALLOWED_ORIGINS` pour le CORS si nécessaire

## 📝 Notes

- Le backend est compatible avec l'ancien backend C# (mêmes endpoints)
- Les données sont stockées dans SQLite (fichier `agriculture.db`)
- Les données initiales (régions, cultures, types de sol) sont chargées automatiquement

