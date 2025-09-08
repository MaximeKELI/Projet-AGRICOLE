# Agriculture API - Base de données Backend C# avec SQLite

## 📋 Description
API REST complète pour la gestion des données agricoles du Togo, développée en C# avec Entity Framework Core et SQLite.

## 🏗️ Architecture
- **Framework**: ASP.NET Core 8.0
- **Base de données**: SQLite avec Entity Framework Core
- **Pattern**: Repository + Service Layer
- **Documentation**: Swagger/OpenAPI

## 🌍 Données disponibles
- **5 régions** du Togo avec leurs préfectures et communes
- **7 types de sols** avec caractéristiques détaillées
- **3 cultures principales** (Maïs, Riz, Arachide)
- **Activités agricoles** avec calendriers de plantation
- **Alertes météorologiques**

## 🚀 Démarrage rapide

### Installation
```bash
cd backend/AgricultureAPI
dotnet restore
dotnet build
dotnet run
```

L'API sera disponible sur `http://localhost:5000`

### Documentation Swagger
Accédez à `http://localhost:5000/swagger` pour la documentation interactive.

## 📡 Endpoints principaux

### Régions et Localisation
- `GET /api/regions` - Liste des régions
- `GET /api/regions/{id}/prefectures` - Préfectures d'une région
- `GET /api/prefectures/{id}/communes` - Communes d'une préfecture
- `GET /api/communes/nearby?latitude=X&longitude=Y&radiusKm=Z` - Communes proches

### Sols et Cultures
- `GET /api/communes/{id}/soil-type` - Type de sol d'une commune
- `GET /api/crops/{id}` - Détails d'une culture
- `GET /api/crops/recommended/{soilTypeId}` - Cultures recommandées pour un sol
- `GET /api/crops/{id}/activities/upcoming?plantingDate=YYYY-MM-DD` - Activités à venir

### Météo
- `GET /api/weather/alerts` - Alertes météo actives
- `POST /api/weather/alerts` - Créer une alerte météo
- `GET /api/weather/alerts/{type}` - Alertes par type

## 📊 Exemples d'utilisation

### Obtenir les régions
```bash
curl http://localhost:5000/api/regions
```

### Trouver le type de sol de Lomé
```bash
curl http://localhost:5000/api/communes/lome/soil-type
```

### Cultures recommandées pour sol argilo-sableux
```bash
curl http://localhost:5000/api/crops/recommended/argilo_sableux
```

### Communes proches de Lomé (rayon 50km)
```bash
curl "http://localhost:5000/api/communes/nearby?latitude=6.1319&longitude=1.2228&radiusKm=50"
```

### Créer une alerte météo
```bash
curl -X POST http://localhost:5000/api/weather/alerts \
  -H "Content-Type: application/json" \
  -d '{
    "id": "alert_001",
    "type": "rain",
    "severity": "high",
    "message": "Fortes pluies prévues",
    "startDate": "2024-09-09T00:00:00",
    "endDate": "2024-09-11T00:00:00",
    "recommendations": "Éviter les travaux de semis"
  }'
```

## 🗄️ Structure de la base de données

### Tables principales
- **Regions** - Régions administratives
- **Prefectures** - Préfectures par région
- **Communes** - Communes avec coordonnées GPS
- **SoilTypes** - Types de sols avec caractéristiques
- **Crops** - Cultures disponibles
- **SoilTypeCrops** - Relations sols-cultures compatibles
- **CropActivities** - Activités par culture
- **PlantingSchedules** - Calendriers de plantation
- **WeatherAlerts** - Alertes météorologiques

## 🔧 Configuration

### Chaîne de connexion
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Data Source=agriculture.db"
  }
}
```

### CORS
L'API est configurée pour accepter toutes les origines en développement.

## 📈 Fonctionnalités avancées
- **Recherche géographique** par coordonnées GPS
- **Recommandations de cultures** basées sur le type de sol
- **Calendrier agricole** avec rappels d'activités
- **Gestion des alertes météo** en temps réel
- **Sérialisation JSON** optimisée (évite les références circulaires)

## 🛠️ Technologies utilisées
- ASP.NET Core 8.0
- Entity Framework Core 8.0
- SQLite
- Swagger/OpenAPI
- AutoMapper (configuré)

## 📝 Notes
- Les données sont automatiquement initialisées au premier démarrage
- La base de données SQLite est créée dans le répertoire du projet
- L'API supporte les opérations CRUD complètes
- Format JSON avec indentation pour faciliter le débogage
