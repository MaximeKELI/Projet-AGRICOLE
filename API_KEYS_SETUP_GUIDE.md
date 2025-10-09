# 🔑 Guide de Configuration des Clés API

Ce guide vous explique comment obtenir et configurer les clés API nécessaires pour utiliser des données réelles dans l'application AgriGeo.

## 📋 **Clés API Requises**

### 🌤️ **Services Météo**

#### 1. **OpenWeatherMap** (Recommandé)
- **Site** : https://openweathermap.org/api
- **Gratuit** : 1,000 appels/jour
- **Processus** :
  1. Créer un compte
  2. Aller dans "API keys"
  3. Copier la clé générée
  4. Remplacer `YOUR_OPENWEATHERMAP_API_KEY` dans `lib/config/api_keys.dart`

#### 2. **WeatherAPI** (Backup)
- **Site** : https://www.weatherapi.com/
- **Gratuit** : 1 million d'appels/mois
- **Processus** : Même que OpenWeatherMap

#### 3. **WeatherBit** (Backup)
- **Site** : https://www.weatherbit.io/
- **Gratuit** : 500 appels/jour
- **Processus** : Même que OpenWeatherMap

### 🌍 **Données de Sol**

#### 1. **iSDAsoil** (Recommandé pour l'Afrique) 🌍
- **Site** : https://api.isda-africa.com/isdasoil/v2/openapi.json
- **Gratuit** : Oui
- **Spécialisé** : Données de sol africaines
- **Processus** :
  1. Aller sur https://api.isda-africa.com/isdasoil/v2/openapi.json
  2. Cliquer sur "Authorize" en haut à droite
  3. Créer un compte avec email et mot de passe
  4. Remplacer `YOUR_ISDASOIL_EMAIL` et `YOUR_ISDASOIL_PASSWORD`

#### 2. **ISRIC SoilGrids** (Backup mondial)
- **Site** : https://www.isric.org/explore/soilgrids
- **Gratuit** : Oui
- **Processus** :
  1. Créer un compte sur ISRIC
  2. Demander l'accès à l'API
  3. Recevoir la clé par email
  4. Remplacer `YOUR_SOILGRIDS_API_KEY`

#### 3. **SolGRID** (Alternative)
- **Site** : https://solgrid.org/
- **Gratuit** : Selon le plan
- **Processus** : Créer un compte et demander l'API

### 🛰️ **Imagerie Satellitaire**

#### 1. **Sentinel Hub** (Recommandé)
- **Site** : https://www.sentinel-hub.com/
- **Gratuit** : Plan gratuit disponible
- **Processus** :
  1. Créer un compte
  2. Choisir le plan gratuit
  3. Aller dans "Configuration" → "OAuth clients"
  4. Créer un nouveau client
  5. Copier Client ID et Client Secret
  6. Remplacer dans `api_keys.dart`

#### 2. **NASA Earthdata** (Pour Landsat, GPM)
- **Site** : https://earthengine.google.com/
- **Gratuit** : Oui
- **Processus** :
  1. Créer un compte Google
  2. Demander l'accès à Google Earth Engine
  3. Générer une clé API
  4. Remplacer `YOUR_NASA_EARTHDATA_API_KEY`

### 🌾 **Données Agricoles**

#### 1. **FAO** (Organisation des Nations Unies)
- **Site** : https://www.fao.org/
- **Gratuit** : Oui
- **Processus** : Créer un compte et demander l'accès API

## ⚙️ **Configuration dans l'Application**

### 1. **Ouvrir le fichier de configuration**
```bash
nano lib/config/api_keys.dart
```

### 2. **Remplacer les clés par vos vraies clés**
```dart
// Avant
static const String openWeatherMapApiKey = 'YOUR_OPENWEATHERMAP_API_KEY';

// Après
static const String openWeatherMapApiKey = 'votre_vraie_cle_ici';
```

### 3. **Vérifier la configuration**
L'application affichera automatiquement quelles clés sont configurées.

## 🔒 **Sécurité**

### ⚠️ **IMPORTANT - Ne jamais commiter les vraies clés !**

1. **Ajouter à .gitignore** :
```gitignore
lib/config/api_keys.dart
```

2. **Créer un template** :
```bash
cp lib/config/api_keys.dart lib/config/api_keys_template.dart
```

3. **Utiliser des variables d'environnement** en production

## 🚀 **Test de Configuration**

### 1. **Lancer l'application**
```bash
flutter run -d linux
```

### 2. **Vérifier les logs**
L'application affichera :
- ✅ Clés configurées
- ❌ Clés manquantes
- 🔄 Fallback vers données simulées

### 3. **Tester les services**
- Aller dans le tableau de bord
- Vérifier que les données météo sont réelles
- Tester les recommandations de cultures

## 📊 **Priorité des Services**

### **Météo** (Choisir 1 minimum)
1. OpenWeatherMap (recommandé)
2. WeatherAPI (backup)
3. WeatherBit (backup)

### **Sols** (Choisir 1 minimum)
1. ISRIC SoilGrids (recommandé)
2. SolGRID (alternative)

### **Satellites** (Choisir 1 minimum)
1. Sentinel Hub (recommandé)
2. NASA Earthdata (backup)

## 🆘 **Support**

Si vous avez des difficultés :

1. **Vérifiez les logs** de l'application
2. **Testez les clés** individuellement
3. **Consultez la documentation** des services
4. **Contactez le support** des services respectifs

## 📈 **Évolution**

Une fois les clés configurées, l'application utilisera automatiquement :
- ✅ Données météo réelles
- ✅ Données de sols réelles
- ✅ Imagerie satellitaire réelle
- ✅ Recommandations basées sur des données du Togo

Plus besoin de simulations ! 🎉
