# 🔄 Guide de Migration - Backend C# vers NodeJS

Ce guide explique comment migrer de l'ancien backend C# vers le nouveau backend NodeJS avec des données réelles.

## 📋 Changements Principaux

### ✅ Ce qui a changé

1. **Backend migré de C# vers NodeJS**
   - Ancien: `backend/AgricultureAPI/` (C# .NET)
   - Nouveau: `backend/nodejs/` (NodeJS + Express)

2. **Données réelles uniquement**
   - ❌ Plus de données fictives ou générées aléatoirement
   - ✅ Données météo réelles via OpenWeather API
   - ✅ Données réelles uniquement - si elles n'existent pas, erreur claire

3. **Configuration des APIs**
   - Utilisation de clés API réelles (OpenWeather, etc.)
   - Configuration via fichier `.env`

## 🚀 Installation du Nouveau Backend

### 1. Installer NodeJS (si pas déjà installé)

```bash
# Vérifier la version
node --version  # Doit être 18+

# Installer NodeJS si nécessaire
# Ubuntu/Debian:
sudo apt-get install nodejs npm

# macOS:
brew install node
```

### 2. Installer les dépendances

```bash
cd backend/nodejs
npm install
```

### 3. Configurer les variables d'environnement

```bash
# Créer le fichier .env
cp .env.example .env

# Éditer le fichier .env et ajouter vos clés API
nano .env
```

**Configuration minimale requise:**

```env
PORT=5000
DB_PATH=./agriculture.db

# OBLIGATOIRE pour les données météo réelles
OPENWEATHER_API_KEY=your_openweather_api_key_here

# Optionnel
GOOGLE_MAPS_API_KEY=your_google_maps_api_key_here
```

### 4. Obtenir une clé API OpenWeather (GRATUIT)

1. Créer un compte sur [OpenWeather](https://openweathermap.org/api)
2. Aller dans "API keys"
3. Copier votre clé API (Free tier disponible)
4. L'ajouter dans le fichier `.env`

### 5. Démarrer le serveur

```bash
# Mode développement (avec auto-reload)
npm run dev

# Mode production
npm start
```

Le serveur sera disponible sur `http://localhost:5000`

## 📱 Mise à jour du Frontend Flutter

Le frontend Flutter a déjà été mis à jour pour utiliser le nouveau backend NodeJS. Les changements principaux:

### Services mis à jour:

- ✅ `weather_service.dart` - Utilise maintenant le backend NodeJS pour les données météo réelles
- ✅ `agricultural_service.dart` - Compatible avec le nouveau backend
- ✅ `document_service.dart` - Compatible avec le nouveau backend

### Points importants:

1. **Données réelles uniquement**: Toutes les données fictives ont été supprimées
2. **Gestion d'erreurs**: Si les données ne sont pas disponibles, une erreur claire est affichée
3. **Pas de données inventées**: Si les statistiques n'existent pas, elles sont laissées vides

## 🔍 Vérification

### Tester le backend NodeJS

```bash
# Vérifier que le serveur fonctionne
curl http://localhost:5000/health

# Tester les endpoints
curl http://localhost:5000/api/regions
curl http://localhost:5000/api/crops
```

### Tester les données météo réelles

```bash
# Remplacez LAT et LON par des coordonnées réelles (ex: Lomé, Togo)
curl "http://localhost:5000/api/weather/current?latitude=6.1375&longitude=1.2123"
```

**⚠️ Important**: Si vous n'avez pas configuré `OPENWEATHER_API_KEY`, vous recevrez une erreur claire indiquant que la clé API n'est pas configurée.

## 🗑️ Ancien Backend C#

L'ancien backend C# dans `backend/AgricultureAPI/` peut être conservé pour référence, mais **ne sera plus utilisé**. Le nouveau backend NodeJS le remplace complètement.

## 📊 Comparaison des Endpoints

Tous les endpoints sont **compatibles** avec l'ancien backend:

| Endpoint | Ancien (C#) | Nouveau (NodeJS) | Statut |
|----------|------------|------------------|--------|
| `GET /api/users/:id` | ✅ | ✅ | Compatible |
| `GET /api/crops` | ✅ | ✅ | Compatible |
| `GET /api/regions` | ✅ | ✅ | Compatible |
| `GET /api/weather/current` | ✅ | ✅ | **Amélioré - données réelles** |
| `GET /api/weather/forecast` | ✅ | ✅ | **Amélioré - données réelles** |
| `GET /api/payments/*` | ✅ | ✅ | Compatible |
| `GET /api/documents` | ✅ | ✅ | Compatible |
| `GET /api/agricultural-metrics/*` | ✅ | ✅ | Compatible |

## ⚠️ Points d'Attention

1. **Clé API OpenWeather obligatoire**
   - Sans cette clé, les données météo ne fonctionneront pas
   - Une erreur claire sera affichée si la clé n'est pas configurée

2. **Pas de données fictives**
   - Si les données n'existent pas, elles seront vides ou une erreur sera affichée
   - Plus de génération aléatoire de données

3. **Base de données SQLite**
   - La base de données est créée automatiquement au premier démarrage
   - Les données initiales (régions, cultures) sont chargées automatiquement

## 🆘 Support

Si vous rencontrez des problèmes:

1. Vérifiez que NodeJS est installé: `node --version`
2. Vérifiez que les dépendances sont installées: `npm install`
3. Vérifiez que le fichier `.env` est correctement configuré
4. Vérifiez que le serveur NodeJS est démarré: `npm start`
5. Vérifiez les logs du serveur pour les erreurs

## 📝 Notes

- Le backend NodeJS est compatible avec l'ancien backend C# (mêmes endpoints)
- Les données sont stockées dans SQLite (fichier `agriculture.db`)
- Les données initiales (régions, cultures, types de sol) sont chargées automatiquement
- **Toutes les données sont réelles** - aucune donnée fictive n'est générée

