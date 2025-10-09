/// Configuration des clés API pour les services externes
/// 
/// IMPORTANT: Remplacez les valeurs par vos vraies clés API
/// Ne commitez jamais ce fichier avec de vraies clés en production !

class ApiKeys {
  // ===== MÉTÉO =====
  
  /// OpenWeatherMap API Key
  /// Obtenez votre clé sur: https://openweathermap.org/api
  static const String openWeatherMapApiKey = 'YOUR_OPENWEATHERMAP_API_KEY';
  
  /// WeatherAPI Key (anciennement api.weatherapi.com)
  /// Obtenez votre clé sur: https://www.weatherapi.com/
  static const String weatherApiApiKey = 'YOUR_WEATHERAPI_API_KEY';
  
  /// WeatherBit API Key
  /// Obtenez votre clé sur: https://www.weatherbit.io/
  static const String weatherBitApiKey = 'YOUR_WEATHERBIT_API_KEY';
  
  // ===== DONNÉES DE SOL =====
  
  /// iSDAsoil API (Recommandé pour l'Afrique)
  /// Obtenez votre compte sur: https://api.isda-africa.com/isdasoil/v2/openapi.json
  static const String isdaSoilEmail = 'YOUR_ISDASOIL_EMAIL';
  static const String isdaSoilPassword = 'YOUR_ISDASOIL_PASSWORD';
  
  /// ISRIC SoilGrids API Key
  /// Obtenez votre clé sur: https://www.isric.org/explore/soilgrids
  static const String soilGridsApiKey = 'YOUR_SOILGRIDS_API_KEY';
  
  /// SolGRID API Key (si différent de SoilGrids)
  /// Obtenez votre clé sur: https://solgrid.org/
  static const String solGridApiKey = 'YOUR_SOLGRID_API_KEY';
  
  // ===== IMAGERIE SATELLITAIRE =====
  
  /// Sentinel Hub API Key
  /// Obtenez votre clé sur: https://www.sentinel-hub.com/
  static const String sentinelHubApiKey = 'YOUR_SENTINELHUB_API_KEY';
  
  /// Sentinel Hub Client ID
  static const String sentinelHubClientId = 'YOUR_SENTINELHUB_CLIENT_ID';
  
  /// Sentinel Hub Client Secret
  static const String sentinelHubClientSecret = 'YOUR_SENTINELHUB_CLIENT_SECRET';
  
  /// NASA Earthdata API Key (pour Landsat, GPM, etc.)
  /// Obtenez votre clé sur: https://earthengine.google.com/
  static const String nasaEarthdataApiKey = 'YOUR_NASA_EARTHDATA_API_KEY';
  
  // ===== DONNÉES AGRICOLES =====
  
  /// FAO API Key (si disponible)
  /// Obtenez votre clé sur: https://www.fao.org/
  static const String faoApiKey = 'YOUR_FAO_API_KEY';
  
  /// Togo Agricultural Data API Key (si vous en créez une)
  static const String togoAgriculturalApiKey = 'YOUR_TOGO_AGRICULTURAL_API_KEY';
  
  // ===== CONFIGURATION =====
  
  /// Mode de développement (utilise des données simulées si true)
  static const bool isDevelopmentMode = true;
  
  /// Timeout pour les requêtes API (en secondes)
  static const int apiTimeoutSeconds = 30;
  
  /// Nombre maximum de tentatives en cas d'échec
  static const int maxRetryAttempts = 3;
  
  // ===== MÉTHODES UTILITAIRES =====
  
  /// Vérifie si une clé API est configurée
  static bool isApiKeyConfigured(String apiKey) {
    return apiKey.isNotEmpty && 
           !apiKey.startsWith('YOUR_') && 
           !apiKey.contains('API_KEY');
  }
  
  /// Retourne toutes les clés configurées
  static Map<String, bool> getConfiguredKeys() {
    return {
      'OpenWeatherMap': isApiKeyConfigured(openWeatherMapApiKey),
      'WeatherAPI': isApiKeyConfigured(weatherApiApiKey),
      'WeatherBit': isApiKeyConfigured(weatherBitApiKey),
      'iSDAsoil': isApiKeyConfigured(isdaSoilEmail) && isApiKeyConfigured(isdaSoilPassword),
      'SoilGrids': isApiKeyConfigured(soilGridsApiKey),
      'SolGRID': isApiKeyConfigured(solGridApiKey),
      'Sentinel Hub': isApiKeyConfigured(sentinelHubApiKey),
      'NASA Earthdata': isApiKeyConfigured(nasaEarthdataApiKey),
      'FAO': isApiKeyConfigured(faoApiKey),
      'Togo Agricultural': isApiKeyConfigured(togoAgriculturalApiKey),
    };
  }
  
  /// Retourne le nombre de clés configurées
  static int getConfiguredKeysCount() {
    return getConfiguredKeys().values.where((configured) => configured).length;
  }
  
  /// Retourne les clés manquantes
  static List<String> getMissingKeys() {
    final configured = getConfiguredKeys();
    return configured.entries
        .where((entry) => !entry.value)
        .map((entry) => entry.key)
        .toList();
  }
}