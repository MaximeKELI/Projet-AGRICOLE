# Guide de Configuration des APIs - Application Agricole

## 🎯 Objectif
Ce guide vous aide à configurer les clés API nécessaires pour utiliser les données réelles dans l'application agricole.

## 🔑 APIs Nécessaires

### 1. **iSDAsoil API** (Recommandé pour l'Afrique)
**Service**: Analyse des sols spécialisée pour l'Afrique
**URL**: https://api.isda-africa.com/isdasoil/v2
**Gratuit**: Oui, avec compte
**Limite**: 1000 requêtes/jour

#### Configuration:
1. Visitez https://api.isda-africa.com/isdasoil/v2/openapi.json
2. Créez un compte gratuit
3. Obtenez vos identifiants (email + mot de passe)
4. Modifiez `lib/config/api_keys.dart`:
```dart
static const String isdaSoilEmail = 'votre-email@example.com';
static const String isdaSoilPassword = 'votre-mot-de-passe';
```

### 2. **OpenWeatherMap API** (Météo)
**Service**: Données météorologiques en temps réel
**URL**: https://openweathermap.org/api
**Gratuit**: Oui, jusqu'à 1000 appels/jour
**Limite**: 1000 requêtes/jour

#### Configuration:
1. Visitez https://openweathermap.org/api
2. Créez un compte gratuit
3. Obtenez votre clé API
4. Modifiez `lib/config/api_keys.dart`:
```dart
static const String openWeatherMapApiKey = 'votre-cle-openweathermap';
```

### 3. **WeatherAPI** (Météo alternative)
**Service**: Données météorologiques avec prévisions
**URL**: https://www.weatherapi.com/
**Gratuit**: Oui, jusqu'à 1M appels/mois
**Limite**: 1,000,000 requêtes/mois

#### Configuration:
1. Visitez https://www.weatherapi.com/
2. Créez un compte gratuit
3. Obtenez votre clé API
4. Modifiez `lib/config/api_keys.dart`:
```dart
static const String weatherApiApiKey = 'votre-cle-weatherapi';
```

### 4. **Sentinel Hub** (Imagerie satellitaire)
**Service**: Données satellitaires pour l'agriculture
**URL**: https://www.sentinel-hub.com/
**Gratuit**: Oui, avec compte
**Limite**: 1000 requêtes/jour

#### Configuration:
1. Visitez https://www.sentinel-hub.com/
2. Créez un compte gratuit
3. Obtenez votre token d'accès
4. Modifiez `lib/config/api_keys.dart`:
```dart
static const String sentinelHubApiKey = 'votre-token-sentinel-hub';
```

## 🚀 Configuration Rapide

### Étape 1: Ouvrir le fichier de configuration
```bash
nano lib/config/api_keys.dart
```

### Étape 2: Remplacer les clés par défaut
Remplacez toutes les valeurs `YOUR_*_API_KEY` par vos vraies clés.

### Étape 3: Tester la configuration
```bash
dart test_soil_service.dart
```

### Étape 4: Lancer l'application
```bash
flutter run
```

## 🔧 Configuration Avancée

### Mode Développement
Si vous voulez utiliser des données simulées pendant le développement:
```dart
static const bool isDevelopmentMode = true;
```

### Timeout des APIs
Ajustez le timeout selon vos besoins:
```dart
static const int apiTimeoutSeconds = 30;
```

### Nombre de tentatives
Configurez le nombre de tentatives en cas d'échec:
```dart
static const int maxRetryAttempts = 3;
```

## 📊 Vérification de la Configuration

### Diagnostic des APIs
L'application affiche automatiquement un diagnostic des APIs au démarrage.

### Test Manuel
Utilisez le fichier `test_soil_service.dart` pour tester individuellement chaque service.

### Interface Utilisateur
Dans l'application, allez dans **Paramètres > Diagnostic API** pour voir l'état de chaque API.

## 🛡️ Sécurité

### ⚠️ Important
- **NE COMMITEZ JAMAIS** vos vraies clés API dans Git
- Ajoutez `lib/config/api_keys.dart` à votre `.gitignore`
- Utilisez des variables d'environnement en production

### Variables d'Environnement (Production)
```bash
export OPENWEATHER_API_KEY="votre-cle"
export ISDA_SOIL_EMAIL="votre-email"
export ISDA_SOIL_PASSWORD="votre-mot-de-passe"
```

## 🔄 Système de Fallback

L'application fonctionne même sans clés API configurées grâce au système de fallback:

1. **APIs externes** (si configurées)
2. **Données moyennes du Togo** (basées sur les statistiques officielles)
3. **Données simulées** (en dernier recours)

## 📈 Monitoring

### Suivi des Utilisations
L'application suit automatiquement:
- Nombre d'appels par API
- Taux de succès
- Temps de réponse
- Erreurs rencontrées

### Alertes
L'application vous alerte si:
- Une API approche de sa limite
- Une API est indisponible
- Les données sont obsolètes

## 🆘 Dépannage

### Problème: "Email ou mot de passe non configuré"
**Solution**: Vérifiez que vos identifiants iSDAsoil sont correctement configurés.

### Problème: "API Key not valid"
**Solution**: Vérifiez que votre clé API est correcte et active.

### Problème: "Rate limit exceeded"
**Solution**: Attendez ou passez à une API alternative.

### Problème: "Network error"
**Solution**: Vérifiez votre connexion internet.

## 📞 Support

### Documentation des APIs
- **iSDAsoil**: https://api.isda-africa.com/isdasoil/v2/openapi.json
- **OpenWeatherMap**: https://openweathermap.org/api
- **WeatherAPI**: https://www.weatherapi.com/docs/
- **Sentinel Hub**: https://docs.sentinel-hub.com/

### Contact
Pour toute question sur la configuration des APIs, consultez la documentation de chaque service ou contactez le support technique.

---

## 🎉 Félicitations !

Une fois configurées, vos APIs vous permettront d'avoir accès à:
- ✅ **Données météo réelles** pour le Togo
- ✅ **Analyse des sols précise** basée sur iSDAsoil
- ✅ **Imagerie satellitaire** pour le suivi des cultures
- ✅ **Recommandations agricoles** personnalisées
- ✅ **Données de marché** en temps réel

Votre application agricole sera maintenant un outil professionnel et fiable ! 🇹🇬🌾
