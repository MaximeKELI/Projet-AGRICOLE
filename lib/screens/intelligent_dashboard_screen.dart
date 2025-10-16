import 'dart:async';
import 'package:intl/intl.dart';
import 'marketplace_screen.dart';
import '../screens/user_model.dart';
import 'package:flutter/material.dart';
import '../models/payment_models.dart';
import '../services/sync_service.dart';
import '../services/chat_service.dart';
import 'package:provider/provider.dart';
import '../services/payment_service.dart';
import '../services/storage_service.dart';
import '../services/weather_service.dart';
import '../services/graphics_service.dart';
import '../services/analytics_service.dart';
import '../services/inventory_service.dart';
import '../services/animation_service.dart';
import 'package:geolocator/geolocator.dart';
import '../models/agricultural_metrics.dart';
import '../widgets/soil_analysis_widget.dart';
import '../services/agricultural_service.dart';
import '../services/notification_service.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// Classe de traduction
class AppLocalizations {
  static const Map<String, Map<String, String>> _translations = {
    'fr': {
      'dashboard_title': 'Tableau de Bord Intelligent',
      'weather_current': 'Météo Actuelle',
      'ai_recommendations': 'Recommandations IA',
      'alerts_agricultural': 'Alertes Agricoles',
      'overview': 'Vue d\'ensemble',
      'crops': 'Cultures',
      'total_area': 'Surface Totale',
      'revenue': 'Revenus',
      'profit': 'Profit',
      'analyses': 'Analyses',
      'crop_distribution': 'Répartition par Type de Culture',
      'revenue_by_region': 'Revenus par Région',
      'recent_crops': 'Cultures Récentes',
      'quick_actions': 'Actions Rapides',
      'new_crop': 'Nouvelle Culture',
      'reports': 'Rapports',
      'search': 'Rechercher',
      'export': 'Exporter',
      'settings': 'Paramètres',
      'refresh': 'Actualiser',
      'temperature': 'Température',
      'humidity': 'Humidité',
      'wind': 'Vent',
      'condition': 'Condition',
      'forecast_3_days': 'Prévisions 3 jours',
      'today': 'Aujourd\'hui',
      'tomorrow': 'Demain',
      'day_after_tomorrow': 'Après-demain',
      'sunny': 'Ensoleillé',
      'cloudy': 'Nuageux',
      'rainy': 'Pluie',
      'irrigation_optimization': 'Optimisation de l\'irrigation',
      'fertilization_recommended': 'Fertilisation recommandée',
      'crop_rotation': 'Rotation des cultures',
      'phytosanitary_treatment': 'Traitement phytosanitaire',
      'spacing_optimization': 'Optimisation de l\'espacement',
      'harvest_planning': 'Planification de récolte',
      'performance_metrics': 'Métriques de Performance',
      'roi': 'ROI',
      'efficiency': 'Efficacité',
      'average_yield': 'Rendement Moyen',
      'trend': 'Tendance',
      'return_on_investment': 'Retour sur investissement',
      'revenue_per_crop': 'Revenus par culture',
      'average_area_per_crop': 'Surface moyenne par culture',
      'monthly_growth': 'Croissance mensuelle',
      'hectares': 'hectares',
      'fcfa': 'FCFA',
      'tonnes': 'tonnes',
      'ha': 'ha',
      't': 't',
      'planted': 'Planté',
      'growing': 'En croissance',
      'ready_to_harvest': 'Prêt à récolter',
      'harvested': 'Récolté',
      'region': 'Région',
      'area': 'Surface',
      'expected_yield': 'Rendement attendu',
      'actual_yield': 'Rendement actuel',
      'efficiency_percent': 'Efficacité',
      'total_cost': 'Coût total',
      'status': 'Statut',
      'close': 'Fermer',
      'see_all_alerts': 'Voir toutes les alertes',
      'add_crop_success': 'Culture ajoutée avec succès!',
      'export_pdf': 'Export PDF en cours...',
      'export_excel': 'Export Excel en cours...',
      'export_image': 'Capture d\'écran en cours...',
      'search_and_filters': 'Recherche et Filtres',
      'search_crop': 'Rechercher une culture',
      'filter_by_crop_type': 'Filtrer par type de culture',
      'apply': 'Appliquer',
      'cancel': 'Annuler',
      'results': 'résultat(s)',
      'auto_refresh_notification': 'Données actualisées automatiquement',
      'settings_saved': 'Paramètres sauvegardés avec succès!',
    },
    'en': {
      'dashboard_title': 'Intelligent Dashboard',
      'weather_current': 'Current Weather',
      'ai_recommendations': 'AI Recommendations',
      'alerts_agricultural': 'Agricultural Alerts',
      'overview': 'Overview',
      'crops': 'Crops',
      'total_area': 'Total Area',
      'revenue': 'Revenue',
      'profit': 'Profit',
      'analyses': 'Analyses',
      'crop_distribution': 'Distribution by Crop Type',
      'revenue_by_region': 'Revenue by Region',
      'recent_crops': 'Recent Crops',
      'quick_actions': 'Quick Actions',
      'new_crop': 'New Crop',
      'reports': 'Reports',
      'search': 'Search',
      'export': 'Export',
      'settings': 'Settings',
      'refresh': 'Refresh',
      'temperature': 'Temperature',
      'humidity': 'Humidity',
      'wind': 'Wind',
      'condition': 'Condition',
      'forecast_3_days': '3-day Forecast',
      'today': 'Today',
      'tomorrow': 'Tomorrow',
      'day_after_tomorrow': 'Day After Tomorrow',
      'sunny': 'Sunny',
      'cloudy': 'Cloudy',
      'rainy': 'Rainy',
      'irrigation_optimization': 'Irrigation Optimization',
      'fertilization_recommended': 'Recommended Fertilization',
      'crop_rotation': 'Crop Rotation',
      'phytosanitary_treatment': 'Phytosanitary Treatment',
      'spacing_optimization': 'Spacing Optimization',
      'harvest_planning': 'Harvest Planning',
      'performance_metrics': 'Performance Metrics',
      'roi': 'ROI',
      'efficiency': 'Efficiency',
      'average_yield': 'Average Yield',
      'trend': 'Trend',
      'return_on_investment': 'Return on Investment',
      'revenue_per_crop': 'Revenue per crop',
      'average_area_per_crop': 'Average area per crop',
      'monthly_growth': 'Monthly growth',
      'hectares': 'hectares',
      'fcfa': 'FCFA',
      'tonnes': 'tonnes',
      'ha': 'ha',
      't': 't',
      'planted': 'Planted',
      'growing': 'Growing',
      'ready_to_harvest': 'Ready to Harvest',
      'harvested': 'Harvested',
      'region': 'Region',
      'area': 'Area',
      'expected_yield': 'Expected Yield',
      'actual_yield': 'Actual Yield',
      'efficiency_percent': 'Efficiency',
      'total_cost': 'Total Cost',
      'status': 'Status',
      'close': 'Close',
      'see_all_alerts': 'See all alerts',
      'add_crop_success': 'Crop added successfully!',
      'export_pdf': 'PDF export in progress...',
      'export_excel': 'Excel export in progress...',
      'export_image': 'Screenshot in progress...',
      'search_and_filters': 'Search and Filters',
      'search_crop': 'Search for a crop',
      'filter_by_crop_type': 'Filter by crop type',
      'apply': 'Apply',
      'cancel': 'Cancel',
      'results': 'result(s)',
      'auto_refresh_notification': 'Data automatically refreshed',
      'settings_saved': 'Settings saved successfully!',
    },
    'ar': {
      'dashboard_title': 'لوحة التحكم الذكية',
      'weather_current': 'الطقس الحالي',
      'ai_recommendations': 'توصيات الذكاء الاصطناعي',
      'alerts_agricultural': 'تنبيهات زراعية',
      'overview': 'نظرة عامة',
      'crops': 'المحاصيل',
      'total_area': 'المساحة الإجمالية',
      'revenue': 'الإيرادات',
      'profit': 'الربح',
      'analyses': 'التحليلات',
      'crop_distribution': 'التوزيع حسب نوع المحصول',
      'revenue_by_region': 'الإيرادات حسب المنطقة',
      'recent_crops': 'المحاصيل الأخيرة',
      'quick_actions': 'إجراءات سريعة',
      'new_crop': 'محصول جديد',
      'reports': 'التقارير',
      'search': 'بحث',
      'export': 'تصدير',
      'settings': 'الإعدادات',
      'refresh': 'تحديث',
      'temperature': 'درجة الحرارة',
      'humidity': 'الرطوبة',
      'wind': 'الرياح',
      'condition': 'الحالة',
      'forecast_3_days': 'توقعات 3 أيام',
      'today': 'اليوم',
      'tomorrow': 'غداً',
      'day_after_tomorrow': 'بعد غد',
      'sunny': 'مشمس',
      'cloudy': 'غائم',
      'rainy': 'ممطر',
      'irrigation_optimization': 'تحسين الري',
      'fertilization_recommended': 'تسميد موصى به',
      'crop_rotation': 'دوران المحاصيل',
      'phytosanitary_treatment': 'معالجة وقائية',
      'spacing_optimization': 'تحسين المسافات',
      'harvest_planning': 'تخطيط الحصاد',
      'performance_metrics': 'مقاييس الأداء',
      'roi': 'عائد الاستثمار',
      'efficiency': 'الكفاءة',
      'average_yield': 'متوسط الإنتاج',
      'trend': 'الاتجاه',
      'return_on_investment': 'عائد الاستثمار',
      'revenue_per_crop': 'الإيرادات لكل محصول',
      'average_area_per_crop': 'متوسط المساحة لكل محصول',
      'monthly_growth': 'النمو الشهري',
      'hectares': 'هكتار',
      'fcfa': 'فرنك أفريقي',
      'tonnes': 'طن',
      'ha': 'هكتار',
      't': 'طن',
      'planted': 'مزروع',
      'growing': 'ينمو',
      'ready_to_harvest': 'جاهز للحصاد',
      'harvested': 'محصود',
      'region': 'المنطقة',
      'area': 'المساحة',
      'expected_yield': 'الإنتاج المتوقع',
      'actual_yield': 'الإنتاج الفعلي',
      'efficiency_percent': 'الكفاءة',
      'total_cost': 'التكلفة الإجمالية',
      'status': 'الحالة',
      'close': 'إغلاق',
      'see_all_alerts': 'عرض جميع التنبيهات',
      'add_crop_success': 'تم إضافة المحصول بنجاح!',
      'export_pdf': 'جاري تصدير PDF...',
      'export_excel': 'جاري تصدير Excel...',
      'export_image': 'جاري التقاط صورة...',
      'search_and_filters': 'البحث والمرشحات',
      'search_crop': 'البحث عن محصول',
      'filter_by_crop_type': 'تصفية حسب نوع المحصول',
      'apply': 'تطبيق',
      'cancel': 'إلغاء',
      'results': 'نتيجة',
      'auto_refresh_notification': 'تم تحديث البيانات تلقائياً',
      'settings_saved': 'تم حفظ الإعدادات بنجاح!',
    },
  };

  static String getCurrentLanguage() {
    return 'fr'; // Par défaut
  }

  static String translate(String key, {String? languageCode}) {
    final lang = languageCode ?? getCurrentLanguage();
    return _translations[lang]?[key] ?? _translations['fr']?[key] ?? key;
  }

  static bool isRTL(String languageCode) {
    return languageCode == 'ar';
  }
}

class IntelligentDashboardScreen extends StatefulWidget {
  const IntelligentDashboardScreen({Key? key}) : super(key: key);

  @override
  _IntelligentDashboardScreenState createState() => _IntelligentDashboardScreenState();
}

class _IntelligentDashboardScreenState extends State<IntelligentDashboardScreen>
    with TickerProviderStateMixin {
  final AgriculturalService _agriculturalService = AgriculturalService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  DashboardSummary? _dashboardSummary;
  List<Map<String, dynamic>> _alerts = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  // Nouvelles données pour les fonctionnalités avancées
  Map<String, dynamic>? _weatherData;
  List<Map<String, dynamic>> _aiRecommendations = [];
  bool _isDarkMode = false;
  List<String> _filteredCropTypes = [];
  String _searchQuery = '';
  List<AgriculturalMetrics> _filteredCrops = [];
  
  // Paramètres avancés
  Map<String, dynamic> _settings = {
    'theme': {
      'isDarkMode': false,
      'primaryColor': 'green',
      'accentColor': 'blue',
      'fontSize': 'medium',
    },
    'notifications': {
      'enabled': true,
      'weatherAlerts': true,
      'aiRecommendations': true,
      'cropReminders': true,
      'soundEnabled': true,
      'vibrationEnabled': true,
    },
    'display': {
      'showWeather': true,
      'showSoilAnalysis': true,
      'showAIRecommendations': true,
      'showPerformanceMetrics': true,
      'showCharts': true,
      'compactMode': false,
      'animationsEnabled': true,
    },
    'data': {
      'autoRefresh': true,
      'refreshInterval': 30, // minutes
      'cacheEnabled': true,
      'syncEnabled': true,
      'backupEnabled': true,
    },
    'weather': {
      'location': 'Dakar',
      'unit': 'celsius',
      'forecastDays': 3,
      'autoLocation': true,
    },
    'ai': {
      'enabled': true,
      'learningMode': true,
      'recommendationLevel': 'medium', // low, medium, high
      'autoOptimization': true,
    },
    'language': {
      'code': 'fr', // fr, en, ar, es, pt
      'name': 'Français',
      'rtl': false, // Right-to-left for Arabic
    },
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _initializeServices();
    _loadDashboardData();
    _loadWeatherData();
    _generateAIRecommendations();
    _setupNotifications();
    _setupAutoRefresh();
  }

  Future<void> _initializeServices() async {
    try {
      // Initialiser tous les services avec gestion d'erreur
      try {
        await NotificationService.initialize();
      } catch (e) {
        print('Erreur notifications: $e');
      }
      
      try {
        await ChatService.initialize();
      } catch (e) {
        print('Erreur chat: $e');
      }
      
      try {
        await InventoryService.initialize();
      } catch (e) {
        print('Erreur inventaire: $e');
      }
      
      try {
        await WeatherService.initialize();
      } catch (e) {
        print('Erreur météo: $e');
      }
      
      // Démarrer la synchronisation automatique
      try {
        SyncService.startAutoSync();
      } catch (e) {
        print('Erreur sync: $e');
      }
      
      // Charger les paramètres sauvegardés
      try {
        final savedSettings = await StorageService.getSettings();
        if (savedSettings != null) {
          setState(() {
            _settings = savedSettings;
          });
          _applySettings();
        }
      } catch (e) {
        print('Erreur paramètres: $e');
      }
      
      print('Services initialisés (certains peuvent avoir échoué)');
    } catch (e) {
      print('Erreur lors de l\'initialisation des services: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    SyncService.stopAutoSync();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final user = Provider.of<UserModel>(context, listen: false);
      if (!user.isLoggedIn || user.email == null) {
        setState(() {
          _errorMessage = 'Utilisateur non connecté';
          _isLoading = false;
        });
        return;
      }

      final summary = await _agriculturalService.getDashboardSummary(user.email!);
      final alerts = await _agriculturalService.getAgriculturalAlerts(user.email!);

      setState(() {
        _dashboardSummary = summary;
        _alerts = alerts;
        _isLoading = false;
        _filteredCrops = summary.recentCrops;
      });

      _animationController.forward();
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadWeatherData() async {
    try {
      // Obtenir la localisation actuelle
      final location = await _getCurrentLocation();
      if (location == null) {
        // Fallback vers une localisation par défaut (Lomé, Togo)
        await _loadWeatherForDefaultLocation();
        return;
      }

      // Charger les données météo réelles
      final currentWeather = await WeatherService.getCurrentWeather(location);
      final forecast = await WeatherService.getWeatherForecast(location);
      final alerts = await WeatherService.getWeatherAlerts(location);
      final recommendations = await WeatherService.getAgriculturalRecommendations(location);

      setState(() {
        _weatherData = {
          'temperature': currentWeather.temperature,
          'humidity': currentWeather.humidity,
          'windSpeed': currentWeather.windSpeed,
          'condition': currentWeather.condition,
          'location': currentWeather.location,
          'forecast': forecast.take(3).map((f) => {
            'day': _getDayName(f.date),
            'temp': f.maxTemperature,
            'condition': f.condition,
            'icon': _getWeatherIcon(f.condition),
          }).toList(),
          'alerts': alerts.map((a) => {
            'type': a.type,
            'message': a.description,
            'severity': a.severity,
          }).toList(),
          'recommendations': recommendations,
        };
      });
    } catch (e) {
      print('Erreur chargement météo: $e');
      // Fallback vers des données par défaut
      await _loadWeatherForDefaultLocation();
    }
  }

  Future<String?> _getCurrentLocation() async {
    try {
      // Vérifier si les services de localisation sont activés
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Services de localisation désactivés');
        return null;
      }

      // Vérifier les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Permission de localisation refusée');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Permission de localisation définitivement refusée');
        return null;
      }

      // Obtenir la position actuelle
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 10),
      );

      return '${position.latitude},${position.longitude}';
    } catch (e) {
      print('Erreur géolocalisation: $e');
      return null;
    }
  }

  Future<void> _loadWeatherForDefaultLocation() async {
    // Localisation par défaut : Lomé, Togo
    const defaultLocation = '6.1725,1.2314';
    
    try {
      final currentWeather = await WeatherService.getCurrentWeather(defaultLocation);
      final forecast = await WeatherService.getWeatherForecast(defaultLocation);
      final alerts = await WeatherService.getWeatherAlerts(defaultLocation);
      final recommendations = await WeatherService.getAgriculturalRecommendations(defaultLocation);

      setState(() {
        _weatherData = {
          'temperature': currentWeather.temperature,
          'humidity': currentWeather.humidity,
          'windSpeed': currentWeather.windSpeed,
          'condition': currentWeather.condition,
          'location': 'Lomé, Togo',
          'forecast': forecast.take(3).map((f) => {
            'day': _getDayName(f.date),
            'temp': f.maxTemperature,
            'condition': f.condition,
            'icon': _getWeatherIcon(f.condition),
          }).toList(),
          'alerts': alerts.map((a) => {
            'type': a.type,
            'message': a.description,
            'severity': a.severity,
          }).toList(),
          'recommendations': recommendations,
        };
      });
    } catch (e) {
      print('Erreur chargement météo par défaut: $e');
    }
  }

  String _getDayName(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) return 'Aujourd\'hui';
    if (difference == 1) return 'Demain';
    if (difference == 2) return 'Après-demain';
    
    return '${date.day}/${date.month}';
  }

  String _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'ensoleillé':
      case 'sunny':
        return '☀️';
      case 'nuageux':
      case 'cloudy':
        return '⛅';
      case 'pluie':
      case 'rain':
        return '🌧️';
      case 'orage':
      case 'storm':
        return '⛈️';
      default:
        return '🌤️';
    }
  }

  Future<void> _generateAIRecommendations() async {
    if (!_isAIEnabled()) return;
    
    try {
      // Simulation de recommandations IA basées sur les données
      await Future.delayed(const Duration(milliseconds: 500));
      
      final allRecommendations = [
        {
          'title': 'Optimisation de l\'irrigation',
          'description': 'Réduire l\'arrosage de 15% cette semaine pour économiser l\'eau',
          'priority': 'high',
          'category': 'irrigation',
          'impact': '+8% efficacité',
          'icon': Icons.water_drop,
        },
        {
          'title': 'Fertilisation recommandée',
          'description': 'Appliquer de l\'engrais azoté sur les cultures de maïs',
          'priority': 'medium',
          'category': 'fertilization',
          'impact': '+12% rendement',
          'icon': Icons.eco,
        },
        {
          'title': 'Rotation des cultures',
          'description': 'Planifier la rotation avec des légumineuses pour enrichir le sol',
          'priority': 'low',
          'category': 'planning',
          'impact': '+5% qualité sol',
          'icon': Icons.rotate_right,
        },
        {
          'title': 'Traitement phytosanitaire',
          'description': 'Appliquer un traitement préventif contre les parasites',
          'priority': 'high',
          'category': 'protection',
          'impact': '+15% santé',
          'icon': Icons.medical_services,
        },
        {
          'title': 'Optimisation de l\'espacement',
          'description': 'Ajuster l\'espacement entre les plants pour maximiser le rendement',
          'priority': 'medium',
          'category': 'optimization',
          'impact': '+6% rendement',
          'icon': Icons.grid_view,
        },
        {
          'title': 'Planification de récolte',
          'description': 'Programmer la récolte pour optimiser la qualité',
          'priority': 'low',
          'category': 'harvest',
          'impact': '+3% qualité',
          'icon': Icons.schedule,
        },
      ];
      
      // Filtrer selon le niveau de recommandations
      final level = _getRecommendationLevel();
      List<Map<String, dynamic>> filteredRecommendations = [];
      
      switch (level) {
        case 'low':
          filteredRecommendations = allRecommendations.where((rec) => rec['priority'] == 'high').toList();
          break;
        case 'medium':
          filteredRecommendations = allRecommendations.where((rec) => 
            rec['priority'] == 'high' || rec['priority'] == 'medium').toList();
          break;
        case 'high':
          filteredRecommendations = allRecommendations;
          break;
        default:
          filteredRecommendations = allRecommendations.where((rec) => 
            rec['priority'] == 'high' || rec['priority'] == 'medium').toList();
      }
      
      setState(() {
        _aiRecommendations = filteredRecommendations;
      });
    } catch (e) {
      print('Erreur génération recommandations: $e');
    }
  }

  void _setupNotifications() {
    if (!_areNotificationsEnabled()) return;
    
    // Simulation de notifications push selon les paramètres
    if (_settings['notifications']['aiRecommendations'] == true) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _showNotification('Nouvelle recommandation IA disponible', 'Vérifiez les suggestions d\'optimisation');
        }
      });
    }
    
    if (_settings['notifications']['weatherAlerts'] == true) {
      Future.delayed(const Duration(seconds: 10), () {
        if (mounted) {
          _showNotification('Alerte météo', 'Pluie prévue dans 2 jours - Préparez vos cultures');
        }
      });
    }
    
    if (_settings['notifications']['cropReminders'] == true) {
      Future.delayed(const Duration(seconds: 15), () {
        if (mounted) {
          _showNotification('Rappel Culture', 'Il est temps de vérifier l\'état de vos cultures de maïs');
        }
      });
    }
  }

  void _setupAutoRefresh() {
    if (!(_settings['data']['autoRefresh'] as bool)) return;
    
    final interval = _settings['data']['refreshInterval'] as int;
    Timer.periodic(Duration(minutes: interval), (timer) {
      if (mounted) {
        _loadDashboardData();
        if (_isWeatherEnabled()) {
          _loadWeatherData();
        }
        if (_isAIEnabled()) {
          _generateAIRecommendations();
        }
        
        // Afficher une notification discrète
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Données actualisées automatiquement'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green[600],
          ),
        );
      } else {
        timer.cancel();
      }
    });
  }

  void _showNotification(String title, String message) {
    // Vérifier les paramètres de notification
    final soundEnabled = _settings['notifications']['soundEnabled'] as bool;
    final vibrationEnabled = _settings['notifications']['vibrationEnabled'] as bool;
    
    // Simuler les effets sonores et de vibration
    if (soundEnabled) {
      // Dans une vraie app, on jouerait un son
      print('🔊 Son de notification joué');
    }
    
    if (vibrationEnabled) {
      // Dans une vraie app, on déclencherait la vibration
      print('📳 Vibration activée');
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (soundEnabled) const Icon(Icons.volume_up, size: 16, color: Colors.white),
                if (vibrationEnabled) const Icon(Icons.vibration, size: 16, color: Colors.white),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            Text(message),
          ],
        ),
        backgroundColor: _getAccentColor(),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Voir',
          textColor: Colors.white,
          onPressed: () {
            // Naviguer vers la section appropriée
            if (title.contains('recommandation')) {
              _scrollToSection('recommendations');
            } else if (title.contains('météo')) {
              _scrollToSection('weather');
            } else if (title.contains('Culture')) {
              _scrollToSection('crops');
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(t('dashboard_title')),
          backgroundColor: _getPrimaryColor(),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: _toggleDarkMode,
            tooltip: _isDarkMode ? 'Mode clair' : 'Mode sombre',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: _onTimeRangeSelected,
            itemBuilder: (context) => [
              const PopupMenuItem(value: '1d', child: Text('1 jour')),
              const PopupMenuItem(value: '7d', child: Text('7 jours')),
              const PopupMenuItem(value: '30d', child: Text('30 jours')),
              const PopupMenuItem(value: '90d', child: Text('3 mois')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
            tooltip: 'Paramètres',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorWidget()
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_settings['display']['showWeather'] == true) ...[
                          _buildWeatherSection(),
                          const SizedBox(height: 20),
                        ],
                        if (_settings['display']['showSoilAnalysis'] == true) ...[
                          _buildSoilAnalysisSection(),
                          const SizedBox(height: 20),
                        ],
                        if (_settings['display']['showAIRecommendations'] == true) ...[
                          _buildAIRecommendationsSection(),
                          const SizedBox(height: 20),
                        ],
                        _buildAlertsSection(),
                        const SizedBox(height: 20),
                        _buildSummaryCards(),
                        const SizedBox(height: 20),
                        if (_settings['display']['showCharts'] == true) ...[
                        _buildChartsSection(),
                        const SizedBox(height: 20),
                        ],
                        if (_settings['display']['showPerformanceMetrics'] == true) ...[
                          _buildPerformanceMetricsSection(),
                          const SizedBox(height: 20),
                        ],
                        _buildRecentCropsSection(),
                        const SizedBox(height: 20),
                        _buildQuickActionsSection(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildWeatherSection() {
    if (_weatherData == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.wb_sunny, color: Colors.orange[700]),
                const SizedBox(width: 8),
        Text(
          t('weather_current'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
                const Spacer(),
                Text(
                  _getTemperatureDisplay(_weatherData!['temperature']),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildWeatherInfo(t('humidity'), '${_weatherData!['humidity']}%', Icons.water_drop),
                ),
                Expanded(
                  child: _buildWeatherInfo(t('wind'), '${_weatherData!['windSpeed']} km/h', Icons.air),
                ),
                Expanded(
                  child: _buildWeatherInfo(t('condition'), _weatherData!['condition'], Icons.cloud),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              t('forecast_3_days'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _weatherData!['forecast'].length,
                itemBuilder: (context, index) {
                  final forecast = _weatherData!['forecast'][index];
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (_isDarkMode ? Colors.grey[800] : Colors.grey[100])?.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(forecast['icon'], style: const TextStyle(fontSize: 24)),
                        const SizedBox(height: 4),
                        Text(forecast['day'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        Text(_getTemperatureDisplay(forecast['temp']), style: const TextStyle(fontSize: 14)),
                        Text(forecast['condition'], style: const TextStyle(fontSize: 10)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherInfo(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue[600], size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildSoilAnalysisSection() {
    // Coordonnées par défaut pour Lomé, Togo
    const double defaultLatitude = 6.1725;
    const double defaultLongitude = 1.2314;
    
    return SoilAnalysisWidget(
      latitude: defaultLatitude,
      longitude: defaultLongitude,
      cropType: 'maïs', // Culture par défaut
    );
  }

  Widget _buildAIRecommendationsSection() {
    if (_aiRecommendations.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: Colors.purple[700]),
                const SizedBox(width: 8),
        Text(
          t('ai_recommendations'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_aiRecommendations.length} suggestions',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.purple[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._aiRecommendations.map((recommendation) => _buildRecommendationItem(recommendation)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(Map<String, dynamic> recommendation) {
    final priority = recommendation['priority'] as String;
    final priorityColor = priority == 'high' ? Colors.red : priority == 'medium' ? Colors.orange : Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: priorityColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: priorityColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            recommendation['icon'],
            color: priorityColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        recommendation['title'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: priorityColor.withOpacity(0.8),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: priorityColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        recommendation['impact'],
                        style: TextStyle(
                          fontSize: 10,
                          color: priorityColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  recommendation['description'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
                ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadDashboardData,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection() {
    if (_alerts.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications_active, color: Colors.orange[700]),
                const SizedBox(width: 8),
                Text(
          t('alerts_agricultural'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._alerts.take(3).map((alert) => _buildAlertItem(alert)),
            if (_alerts.length > 3)
              TextButton(
                onPressed: () => _showAllAlerts(),
                child: Text('Voir toutes les alertes (${_alerts.length})'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem(Map<String, dynamic> alert) {

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getSeverityColor(alert['severity']).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getSeverityColor(alert['severity']).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(_getSeverityIcon(alert['severity']), color: _getSeverityColor(alert['severity']), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert['title'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getSeverityColor(alert['severity']).withOpacity(0.8),
                  ),
                ),
                Text(
                  alert['message'],
                  style: TextStyle(color: _getSeverityColor(alert['severity']).withOpacity(0.7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    if (_dashboardSummary == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vue d\'ensemble',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildSummaryCard(
              'Cultures',
              _dashboardSummary!.totalCrops.toString(),
              Icons.agriculture,
              Colors.green,
            ),
            _buildSummaryCard(
              'Surface Totale',
              '${_dashboardSummary!.totalArea.toStringAsFixed(1)} ha',
              Icons.terrain,
              Colors.blue,
            ),
            _buildSummaryCard(
              'Revenus',
              '${_dashboardSummary!.totalRevenue.toStringAsFixed(0)} FCFA',
              Icons.attach_money,
              Colors.green[700]!,
            ),
            _buildSummaryCard(
              'Profit',
              '${_dashboardSummary!.totalProfit.toStringAsFixed(0)} FCFA',
              Icons.trending_up,
              Colors.orange,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection() {
    if (_dashboardSummary == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analyses',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Répartition par Type de Culture',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: SfCircularChart(
                    series: <PieSeries<MapEntry<String, double>, String>>[
                      PieSeries<MapEntry<String, double>, String>(
                        dataSource: _dashboardSummary!.cropsByType.entries.toList(),
                        xValueMapper: (MapEntry<String, double> data, _) => data.key,
                        yValueMapper: (MapEntry<String, double> data, _) => data.value,
                        dataLabelSettings: const DataLabelSettings(
                          isVisible: true,
                          labelPosition: ChartDataLabelPosition.outside,
                        ),
                        enableTooltip: true,
                        explode: true,
                        explodeOffset: '10%',
                        animationDuration: 1000,
                      ),
                    ],
                    legend: const Legend(
                      isVisible: true,
                      position: LegendPosition.bottom,
                      overflowMode: LegendItemOverflowMode.wrap,
                    ),
                    tooltipBehavior: TooltipBehavior(enable: true),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Revenus par Région',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: SfCartesianChart(
                    primaryXAxis: const CategoryAxis(
                      title: AxisTitle(text: 'Régions'),
                    ),
                    primaryYAxis: NumericAxis(
                      title: const AxisTitle(text: 'Revenus (FCFA)'),
                      numberFormat: NumberFormat.compact(),
                    ),
                    series: <ColumnSeries<MapEntry<String, double>, String>>[
                      ColumnSeries<MapEntry<String, double>, String>(
                        dataSource: _dashboardSummary!.revenueByRegion.entries.toList(),
                        xValueMapper: (MapEntry<String, double> data, _) => data.key,
                        yValueMapper: (MapEntry<String, double> data, _) => data.value,
                        dataLabelSettings: const DataLabelSettings(
                          isVisible: true,
                          labelPosition: ChartDataLabelPosition.outside,
                        ),
                        enableTooltip: true,
                        animationDuration: 1000,
                        gradient: LinearGradient(
                          colors: [Colors.blue[400]!, Colors.blue[600]!],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ],
                    tooltipBehavior: TooltipBehavior(enable: true),
                    zoomPanBehavior: ZoomPanBehavior(
                      enablePinching: true,
                      enableDoubleTapZooming: true,
                      enablePanning: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceMetricsSection() {
    if (_dashboardSummary == null) return const SizedBox.shrink();

    // Calcul des métriques de performance
    final roi = _dashboardSummary!.totalProfit / _dashboardSummary!.totalRevenue * 100;
    final efficiency = _dashboardSummary!.totalCrops > 0 ? 
        (_dashboardSummary!.totalRevenue / _dashboardSummary!.totalCrops) : 0.0;
    final avgYield = _dashboardSummary!.totalCrops > 0 ? 
        (_dashboardSummary!.totalArea / _dashboardSummary!.totalCrops) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Métriques de Performance',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildPerformanceCard(
              'ROI',
              '${roi.toStringAsFixed(1)}%',
              Icons.trending_up,
              roi > 20 ? Colors.green : roi > 10 ? Colors.orange : Colors.red,
              'Retour sur investissement',
            ),
            _buildPerformanceCard(
              'Efficacité',
              '${efficiency.toStringAsFixed(0)} FCFA/culture',
              Icons.speed,
              efficiency > 50000 ? Colors.green : efficiency > 25000 ? Colors.orange : Colors.red,
              'Revenus par culture',
            ),
            _buildPerformanceCard(
              'Rendement Moyen',
              '${avgYield.toStringAsFixed(1)} ha/culture',
              Icons.agriculture,
              avgYield > 2 ? Colors.green : avgYield > 1 ? Colors.orange : Colors.red,
              'Surface moyenne par culture',
            ),
            _buildPerformanceCard(
              'Tendance',
              '+12.5%',
              Icons.show_chart,
              Colors.green,
              'Croissance mensuelle',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPerformanceCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCropsSection() {
    if (_dashboardSummary == null || _filteredCrops.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
      children: [
        Text(
          'Cultures Récentes',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
            ),
            const Spacer(),
            if (_searchQuery.isNotEmpty || _filteredCropTypes.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_filteredCrops.length} résultat(s)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        ..._filteredCrops.map((crop) => _buildCropCard(crop)),
      ],
    );
  }

  Widget _buildCropCard(AgriculturalMetrics crop) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(crop.status),
          child: Icon(
            _getStatusIcon(crop.status),
            color: Colors.white,
          ),
        ),
        title: Text(crop.cropType),
        subtitle: Text('${crop.plantedArea.toStringAsFixed(1)} ha - ${crop.region}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${crop.yieldEfficiency.toStringAsFixed(1)}%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: crop.yieldEfficiency >= 80 ? Colors.green : Colors.orange,
              ),
            ),
            Text(
              crop.status,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        onTap: () => _showCropDetails(crop),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('quick_actions'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            ElevatedButton.icon(
                onPressed: _addNewCrop,
                icon: const Icon(Icons.add),
                label: Text(t('new_crop')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                  foregroundColor: Colors.white,
                ),
              ),
            ElevatedButton.icon(
                onPressed: _viewReports,
                icon: const Icon(Icons.assessment),
                label: Text(t('reports')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                ),
            ),
            ElevatedButton.icon(
              onPressed: _showSearchDialog,
              icon: const Icon(Icons.search),
              label: Text(t('search')),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[800],
                foregroundColor: Colors.white,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _exportData,
              icon: const Icon(Icons.download),
              label: Text(t('export')),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[800],
                foregroundColor: Colors.white,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _openMarketplace,
              icon: const Icon(Icons.store),
              label: const Text('Marketplace'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[800],
                foregroundColor: Colors.white,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _openPayments,
              icon: const Icon(Icons.payment),
              label: const Text('Paiements'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[800],
                foregroundColor: Colors.white,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _openChat,
              icon: const Icon(Icons.chat),
              label: const Text('Chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[800],
                foregroundColor: Colors.white,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _openInventory,
              icon: const Icon(Icons.inventory),
              label: const Text('Stocks'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[800],
                foregroundColor: Colors.white,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _openAnalytics,
              icon: const Icon(Icons.analytics),
              label: const Text('Analytics'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple[800],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'planted':
        return Colors.blue;
      case 'growing':
        return Colors.green;
      case 'ready_to_harvest':
        return Colors.orange;
      case 'harvested':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'planted':
        return Icons.eco;
      case 'growing':
        return Icons.trending_up;
      case 'ready_to_harvest':
        return Icons.agriculture;
      case 'harvested':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  void _showAllAlerts() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Toutes les Alertes'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _alerts.length,
            itemBuilder: (context, index) => _buildAlertItem(_alerts[index]),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showCropDetails(AgriculturalMetrics crop) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(crop.cropType),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Région: ${crop.region}'),
            Text('Surface: ${crop.plantedArea.toStringAsFixed(1)} ha'),
            Text('Rendement attendu: ${crop.expectedYield.toStringAsFixed(1)} tonnes'),
            Text('Rendement actuel: ${crop.actualYield.toStringAsFixed(1)} tonnes'),
            Text('Efficacité: ${crop.yieldEfficiency.toStringAsFixed(1)}%'),
            Text('Coût total: ${crop.totalCost.toStringAsFixed(0)} FCFA'),
            Text('Revenus: ${crop.revenue.toStringAsFixed(0)} FCFA'),
            Text('Profit: ${crop.profit.toStringAsFixed(0)} FCFA'),
            Text('Statut: ${crop.status}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _addNewCrop() {
    showDialog(
      context: context,
      builder: (context) => _AddCropDialog(
        onCropAdded: (cropData) {
          _handleNewCropAdded(cropData);
        },
      ),
    );
  }

  void _handleNewCropAdded(Map<String, dynamic> cropData) {
    // Simuler l'ajout d'une nouvelle culture
    setState(() {
      if (_dashboardSummary != null) {
        // Mettre à jour les données du dashboard
        _dashboardSummary = DashboardSummary(
          totalCrops: _dashboardSummary!.totalCrops + 1,
          totalArea: _dashboardSummary!.totalArea + (cropData['area'] as double),
          totalRevenue: _dashboardSummary!.totalRevenue + (cropData['expectedRevenue'] as double),
          totalProfit: _dashboardSummary!.totalProfit + (cropData['expectedProfit'] as double),
          totalExpectedYield: _dashboardSummary!.totalExpectedYield + (cropData['expectedYield'] as double),
          totalActualYield: _dashboardSummary!.totalActualYield,
          totalCost: _dashboardSummary!.totalCost + (cropData['cost'] as double),
          averageYieldEfficiency: _dashboardSummary!.averageYieldEfficiency,
          averageProfitMargin: _dashboardSummary!.averageProfitMargin,
          cropsByType: Map.from(_dashboardSummary!.cropsByType)
            ..update(cropData['type'] as String, (value) => value + 1, ifAbsent: () => 1),
          revenueByRegion: Map.from(_dashboardSummary!.revenueByRegion)
            ..update(cropData['region'] as String, (value) => value + (cropData['expectedRevenue'] as double), ifAbsent: () => cropData['expectedRevenue'] as double),
          recentCrops: [
            AgriculturalMetrics(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              userId: 'current_user',
              cropType: cropData['type'] as String,
              region: cropData['region'] as String,
              plantedArea: cropData['area'] as double,
              expectedYield: cropData['expectedYield'] as double,
              actualYield: 0.0,
              totalCost: cropData['cost'] as double,
              revenue: 0.0,
              profit: -(cropData['cost'] as double),
              status: 'planted',
              plantingDate: DateTime.now(),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
            ..._dashboardSummary!.recentCrops.take(4),
          ],
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Culture ${cropData['type']} ajoutée avec succès!'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Voir',
          textColor: Colors.white,
          onPressed: () {
            // Scroll vers la section des cultures récentes
          },
        ),
      ),
    );
  }

  void _viewReports() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ReportsScreen(
          dashboardSummary: _dashboardSummary,
          weatherData: _weatherData,
          aiRecommendations: _aiRecommendations,
        ),
      ),
    );
  }

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
      _settings['theme']['isDarkMode'] = _isDarkMode;
    });
    _saveSettings();
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _SettingsScreen(
          settings: _settings,
          onSettingsChanged: (newSettings) {
            setState(() {
              _settings = newSettings;
              _isDarkMode = _settings['theme']['isDarkMode'] as bool;
            });
            _saveSettings();
            _applySettings();
          },
        ),
      ),
    );
  }

  void _saveSettings() {
    // Simuler la sauvegarde des paramètres
    // Dans une vraie app, on utiliserait SharedPreferences ou une base de données
    print('Paramètres sauvegardés: $_settings');
  }

  void _applySettings() {
    // Appliquer les paramètres en temps réel
    if (_settings['display']['showWeather'] == false) {
      _weatherData = null;
    } else {
      _loadWeatherData();
    }
    
    if (_settings['display']['showAIRecommendations'] == false) {
      _aiRecommendations.clear();
    } else {
      _generateAIRecommendations();
    }
    
    // Appliquer les paramètres de thème
    _applyThemeSettings();
    
    // Appliquer les paramètres de performance
    _applyPerformanceSettings();
    
    // Recharger les données si nécessaire
    if (_settings['data']['autoRefresh'] == true) {
      _loadDashboardData();
    }
  }

  void _applyThemeSettings() {
    // Appliquer les couleurs du thème
    // Les couleurs seront appliquées lors du prochain rebuild
    setState(() {
      // Force le rebuild pour appliquer les nouvelles couleurs
    });
  }

  void _applyPerformanceSettings() {
    // Appliquer les paramètres de performance
    final animationsEnabled = _settings['display']['animationsEnabled'] as bool;
    
    if (!animationsEnabled) {
      _animationController.stop();
    } else {
      _animationController.forward();
    }
    
    // Le mode compact sera appliqué dans les widgets
  }

  void _onTimeRangeSelected(String timeRange) {
    // Recharger les données avec le nouveau filtre de temps
    _loadDashboardData();
  }

  void _exportData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exporter les Données'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choisissez le format d\'export:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('PDF'),
              subtitle: const Text('Rapport complet en PDF'),
              onTap: () {
                Navigator.pop(context);
                _exportToPDF();
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text('Excel'),
              subtitle: const Text('Données en format Excel'),
              onTap: () {
                Navigator.pop(context);
                _exportToExcel();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image, color: Colors.blue),
              title: const Text('Image'),
              subtitle: const Text('Capture d\'écran du dashboard'),
              onTap: () {
                Navigator.pop(context);
                _exportToImage();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _openMarketplace() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MarketplaceScreen(),
      ),
    );
  }

  void _openPayments() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _PaymentsScreen(),
      ),
    );
  }

  void _openChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ChatScreen(),
      ),
    );
  }

  void _openInventory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _InventoryScreen(),
      ),
    );
  }

  void _openAnalytics() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _AnalyticsScreen(),
      ),
    );
  }

  void _exportToPDF() {
    // Simulation d'export PDF
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export PDF en cours...'),
        backgroundColor: Colors.red,
      ),
    );
    
    // Simuler le téléchargement
    Future.delayed(const Duration(seconds: 2), () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rapport PDF généré avec succès!'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _exportToExcel() {
    // Simulation d'export Excel
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export Excel en cours...'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Simuler le téléchargement
    Future.delayed(const Duration(seconds: 2), () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fichier Excel généré avec succès!'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _exportToImage() {
    // Simulation d'export image
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Capture d\'écran en cours...'),
        backgroundColor: Colors.blue,
      ),
    );
    
    // Simuler la capture
    Future.delayed(const Duration(seconds: 1), () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image sauvegardée dans la galerie!'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _applyFilters() {
    if (_dashboardSummary == null) return;
    
    List<AgriculturalMetrics> filtered = _dashboardSummary!.recentCrops;
    
    // Filtrer par recherche textuelle
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((crop) =>
        crop.cropType.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        crop.region.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    // Filtrer par type de culture
    if (_filteredCropTypes.isNotEmpty) {
      filtered = filtered.where((crop) =>
        _filteredCropTypes.contains(crop.cropType)
      ).toList();
    }
    
    setState(() {
      _filteredCrops = filtered;
    });
  }

  void _scrollToSection(String section) {
    // Simulation du scroll vers une section spécifique
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigation vers la section $section'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // Méthodes utilitaires pour les paramètres
  Color _getPrimaryColor() {
    final colorName = _settings['theme']['primaryColor'] as String;
    return _getColorFromName(colorName);
  }

  Color _getAccentColor() {
    final colorName = _settings['theme']['accentColor'] as String;
    return _getColorFromName(colorName);
  }

  Color _getColorFromName(String colorName) {
    switch (colorName) {
      case 'green': return Colors.green[800]!;
      case 'blue': return Colors.blue[800]!;
      case 'red': return Colors.red[800]!;
      case 'purple': return Colors.purple[800]!;
      case 'orange': return Colors.orange[800]!;
      case 'teal': return Colors.teal[800]!;
      default: return Colors.green[800]!;
    }
  }

  String _getTemperatureUnit() {
    return _settings['weather']['unit'] as String;
  }

  String _getRecommendationLevel() {
    return _settings['ai']['recommendationLevel'] as String;
  }

  bool _isAIEnabled() {
    return _settings['ai']['enabled'] as bool;
  }

  bool _isWeatherEnabled() {
    return _settings['display']['showWeather'] as bool;
  }

  bool _areNotificationsEnabled() {
    return _settings['notifications']['enabled'] as bool;
  }

  // Méthodes de traduction
  String t(String key) {
    final languageCode = _settings['language']['code'] as String;
    return AppLocalizations.translate(key, languageCode: languageCode);
  }

  bool _isRTL() {
    final languageCode = _settings['language']['code'] as String;
    return AppLocalizations.isRTL(languageCode);
  }

  String _getTemperatureDisplay(double celsius) {
    final unit = _getTemperatureUnit();
    if (unit == 'fahrenheit') {
      final fahrenheit = (celsius * 9/5) + 32;
      return '${fahrenheit.toStringAsFixed(1)}°F';
    } else {
      return '${celsius.toStringAsFixed(1)}°C';
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recherche et Filtres'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Rechercher une culture',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _applyFilters();
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Filtrer par type de culture:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['Maïs', 'Riz', 'Tomate', 'Oignon', 'Arachide'].map((type) {
                return FilterChip(
                  label: Text(type),
                  selected: _filteredCropTypes.contains(type),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _filteredCropTypes.add(type);
                      } else {
                        _filteredCropTypes.remove(type);
                      }
                      _applyFilters();
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _applyFilters();
            },
            child: const Text('Appliquer'),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'info':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Icons.dangerous;
      case 'warning':
        return Icons.warning;
      case 'info':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }
}

class _AddCropDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onCropAdded;

  const _AddCropDialog({required this.onCropAdded});

  @override
  _AddCropDialogState createState() => _AddCropDialogState();
}

class _AddCropDialogState extends State<_AddCropDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cropTypeController = TextEditingController();
  final _regionController = TextEditingController();
  final _areaController = TextEditingController();
  final _expectedYieldController = TextEditingController();
  final _costController = TextEditingController();
  
  String _selectedCropType = 'Maïs';
  String _selectedRegion = 'Dakar';
  
  final List<String> _cropTypes = ['Maïs', 'Riz', 'Tomate', 'Oignon', 'Arachide', 'Mangue', 'Banane'];
  final List<String> _regions = ['Dakar', 'Thiès', 'Kaolack', 'Saint-Louis', 'Ziguinchor', 'Kolda'];

  @override
  void dispose() {
    _cropTypeController.dispose();
    _regionController.dispose();
    _areaController.dispose();
    _expectedYieldController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter une Nouvelle Culture'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedCropType,
                decoration: const InputDecoration(
                  labelText: 'Type de culture',
                  border: OutlineInputBorder(),
                ),
                items: _cropTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCropType = newValue!;
                  });
                },
                validator: (value) => value == null ? 'Sélectionnez un type de culture' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRegion,
                decoration: const InputDecoration(
                  labelText: 'Région',
                  border: OutlineInputBorder(),
                ),
                items: _regions.map((String region) {
                  return DropdownMenuItem<String>(
                    value: region,
                    child: Text(region),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRegion = newValue!;
                  });
                },
                validator: (value) => value == null ? 'Sélectionnez une région' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _areaController,
                decoration: const InputDecoration(
                  labelText: 'Surface (hectares)',
                  border: OutlineInputBorder(),
                  suffixText: 'ha',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Entrez la surface';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Entrez un nombre valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _expectedYieldController,
                decoration: const InputDecoration(
                  labelText: 'Rendement attendu (tonnes)',
                  border: OutlineInputBorder(),
                  suffixText: 't',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Entrez le rendement attendu';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Entrez un nombre valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _costController,
                decoration: const InputDecoration(
                  labelText: 'Coût d\'investissement',
                  border: OutlineInputBorder(),
                  suffixText: 'FCFA',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Entrez le coût d\'investissement';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Entrez un nombre valide';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: const Text('Ajouter'),
        ),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final area = double.parse(_areaController.text);
      final expectedYield = double.parse(_expectedYieldController.text);
      final cost = double.parse(_costController.text);
      
      // Calculer les revenus et profits estimés
      final pricePerTon = _getPricePerTon(_selectedCropType);
      final expectedRevenue = expectedYield * pricePerTon;
      final expectedProfit = expectedRevenue - cost;

      final cropData = {
        'type': _selectedCropType,
        'region': _selectedRegion,
        'area': area,
        'expectedYield': expectedYield,
        'cost': cost,
        'expectedRevenue': expectedRevenue,
        'expectedProfit': expectedProfit,
      };

      widget.onCropAdded(cropData);
      Navigator.pop(context);
    }
  }

  double _getPricePerTon(String cropType) {
    // Prix approximatifs par tonne en FCFA
    switch (cropType) {
      case 'Maïs':
        return 150000;
      case 'Riz':
        return 200000;
      case 'Tomate':
        return 300000;
      case 'Oignon':
        return 250000;
      case 'Arachide':
        return 180000;
      case 'Mangue':
        return 120000;
      case 'Banane':
        return 80000;
      default:
        return 150000;
    }
  }
}

class _ReportsScreen extends StatelessWidget {
  final DashboardSummary? dashboardSummary;
  final Map<String, dynamic>? weatherData;
  final List<Map<String, dynamic>> aiRecommendations;

  const _ReportsScreen({
    required this.dashboardSummary,
    required this.weatherData,
    required this.aiRecommendations,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapports Agricoles'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _exportReport(context),
            tooltip: 'Exporter le rapport',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReportHeader(),
            const SizedBox(height: 20),
            _buildSummaryReport(),
            const SizedBox(height: 20),
            _buildWeatherReport(),
            const SizedBox(height: 20),
            _buildRecommendationsReport(),
            const SizedBox(height: 20),
            _buildPerformanceReport(),
          ],
        ),
      ),
    );
  }

  Widget _buildReportHeader() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rapport Agricole',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Généré le ${DateFormat('dd/MM/yyyy à HH:mm').format(DateTime.now())}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tableau de Bord Intelligent - Agriculture',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryReport() {
    if (dashboardSummary == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Résumé Exécutif',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(height: 16),
            _buildReportRow('Total des Cultures', '${dashboardSummary!.totalCrops}'),
            _buildReportRow('Surface Totale', '${dashboardSummary!.totalArea.toStringAsFixed(1)} hectares'),
            _buildReportRow('Revenus Totaux', '${NumberFormat('#,##0').format(dashboardSummary!.totalRevenue)} FCFA'),
            _buildReportRow('Profit Total', '${NumberFormat('#,##0').format(dashboardSummary!.totalProfit)} FCFA'),
            _buildReportRow('ROI', '${(dashboardSummary!.totalProfit / dashboardSummary!.totalRevenue * 100).toStringAsFixed(1)}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherReport() {
    if (weatherData == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Conditions Météorologiques',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange[800],
              ),
            ),
            const SizedBox(height: 16),
            _buildReportRow('Température Actuelle', '${weatherData!['temperature']}°C'),
            _buildReportRow('Humidité', '${weatherData!['humidity']}%'),
            _buildReportRow('Vitesse du Vent', '${weatherData!['windSpeed']} km/h'),
            _buildReportRow('Condition', weatherData!['condition']),
            const SizedBox(height: 12),
            Text(
              'Prévisions 3 jours:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...weatherData!['forecast'].map<Widget>((forecast) => 
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('${forecast['day']}: ${forecast['temp']}°C - ${forecast['condition']}'),
              ),
            ).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsReport() {
    if (aiRecommendations.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommandations IA',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.purple[800],
              ),
            ),
            const SizedBox(height: 16),
            ...aiRecommendations.map((rec) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(rec['icon'], color: _getPriorityColor(rec['priority']), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          rec['title'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getPriorityColor(rec['priority']),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(rec['priority']).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          rec['impact'],
                          style: TextStyle(
                            fontSize: 10,
                            color: _getPriorityColor(rec['priority']),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(rec['description']),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceReport() {
    if (dashboardSummary == null) return const SizedBox.shrink();

    final roi = dashboardSummary!.totalProfit / dashboardSummary!.totalRevenue * 100;
    final efficiency = dashboardSummary!.totalCrops > 0 ? 
        (dashboardSummary!.totalRevenue / dashboardSummary!.totalCrops) : 0.0;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analyse de Performance',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.indigo[800],
              ),
            ),
            const SizedBox(height: 16),
            _buildReportRow('ROI', '${roi.toStringAsFixed(1)}%'),
            _buildReportRow('Efficacité par Culture', '${efficiency.toStringAsFixed(0)} FCFA'),
            _buildReportRow('Rendement Moyen', '${(dashboardSummary!.totalArea / dashboardSummary!.totalCrops).toStringAsFixed(1)} ha/culture'),
            _buildReportRow('Tendance', '+12.5% (croissance mensuelle)'),
            const SizedBox(height: 12),
            Text(
              'Répartition par Type:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...dashboardSummary!.cropsByType.entries.map((entry) => 
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('${entry.key}: ${entry.value.toInt()} cultures'),
              ),
            ).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildReportRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _exportReport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export du rapport en cours...'),
        backgroundColor: Colors.blue,
      ),
    );
    
    Future.delayed(const Duration(seconds: 2), () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rapport exporté avec succès!'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }
}

class _PaymentsScreen extends StatefulWidget {
  @override
  _PaymentsScreenState createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<_PaymentsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<PaymentMethod> _paymentMethods = [];
  List<PaymentTransaction> _transactions = [];
  Map<String, dynamic> _statistics = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final paymentMethods = PaymentService.getPaymentMethods();
      final transactions = await PaymentService.getPaymentHistory();
      final statistics = await PaymentService.getPaymentStatistics();

      setState(() {
        _paymentMethods = paymentMethods;
        _transactions = transactions;
        _statistics = statistics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiements'),
        backgroundColor: Colors.teal[800],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.payment), text: 'Méthodes'),
            Tab(icon: Icon(Icons.history), text: 'Historique'),
            Tab(icon: Icon(Icons.analytics), text: 'Statistiques'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPaymentMethodsTab(),
          _buildTransactionsTab(),
          _buildStatisticsTab(),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _paymentMethods.length,
      itemBuilder: (context, index) {
        final method = _paymentMethods[index];
        return _buildPaymentMethodCard(method);
      },
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod method) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Text(
          method.icon,
          style: const TextStyle(fontSize: 32),
        ),
        title: Text(
          method.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(_getPaymentMethodDescription(method.type)),
        trailing: Switch(
          value: method.isActive,
          onChanged: (value) {
            setState(() {
              // Dans une vraie implémentation, on mettrait à jour en base de données
            });
          },
        ),
        onTap: () => _showPaymentMethodDetails(method),
      ),
    );
  }

  Widget _buildTransactionsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final transaction = _transactions[index];
        return _buildTransactionCard(transaction);
      },
    );
  }

  Widget _buildTransactionCard(PaymentTransaction transaction) {
    final method = _paymentMethods.firstWhere(
      (m) => m.id == transaction.paymentMethodId,
      orElse: () => PaymentMethod(
        id: 'unknown',
        name: 'Inconnu',
        type: 'unknown',
        icon: '❓',
      ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaction #${transaction.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTransactionStatusColor(transaction.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getTransactionStatusText(transaction.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(method.icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(method.name),
                const Spacer(),
                Text(
                  '${NumberFormat.currency(symbol: '', decimalDigits: 0).format(transaction.amount)} ${transaction.currency}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(transaction.createdAt)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (transaction.transactionReference != null)
              Text(
                'Référence: ${transaction.transactionReference}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatCard(
          'Transactions Totales',
          '${_statistics['totalTransactions']}',
          Icons.receipt,
          Colors.blue,
        ),
        _buildStatCard(
          'Montant Total',
          '${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_statistics['totalAmount'])} FCFA',
          Icons.attach_money,
          Colors.green,
        ),
        _buildStatCard(
          'Taux de Succès',
          '${(_statistics['successRate'] * 100).toStringAsFixed(1)}%',
          Icons.check_circle,
          Colors.orange,
        ),
        _buildStatCard(
          'Montant Moyen',
          '${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_statistics['averageTransactionAmount'])} FCFA',
          Icons.trending_up,
          Colors.purple,
        ),
        _buildStatCard(
          'Croissance Mensuelle',
          '${(_statistics['monthlyGrowth'] * 100).toStringAsFixed(1)}%',
          Icons.trending_up,
          Colors.teal,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPaymentMethodDescription(String type) {
    switch (type) {
      case 'mobile_money':
        return 'Paiement mobile (Orange Money, MTN, Wave)';
      case 'card':
        return 'Carte bancaire (Visa, Mastercard)';
      case 'bank_transfer':
        return 'Virement bancaire';
      case 'crypto':
        return 'Cryptomonnaie (Bitcoin, Ethereum)';
      case 'cash':
        return 'Paiement à la livraison';
      default:
        return 'Méthode de paiement';
    }
  }

  Color _getTransactionStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      case 'refunded':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getTransactionStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Terminé';
      case 'pending':
        return 'En attente';
      case 'failed':
        return 'Échoué';
      case 'refunded':
        return 'Remboursé';
      default:
        return status;
    }
  }

  void _showPaymentMethodDetails(PaymentMethod method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(method.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${_getPaymentMethodDescription(method.type)}'),
            const SizedBox(height: 8),
            Text('Statut: ${method.isActive ? 'Actif' : 'Inactif'}'),
            if (method.config != null) ...[
              const SizedBox(height: 8),
              const Text('Configuration:'),
              ...method.config!.entries.map((entry) => 
                Text('  ${entry.key}: ${entry.value}')),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}

class _ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<_ChatScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<ChatRoom> _rooms = [];
  List<ChatMessage> _messages = [];
  String _selectedRoomId = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadChatData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadChatData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final rooms = ChatService.getRooms();
      setState(() {
        _rooms = rooms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: Colors.indigo[800],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.chat_bubble), text: 'Conversations'),
            Tab(icon: Icon(Icons.people), text: 'Contacts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRoomsTab(),
          _buildContactsTab(),
        ],
      ),
    );
  }

  Widget _buildRoomsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _rooms.length,
      itemBuilder: (context, index) {
        final room = _rooms[index];
        return _buildRoomCard(room);
      },
    );
  }

  Widget _buildRoomCard(ChatRoom room) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.indigo[800],
          child: Text(
            room.name[0].toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          room.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(room.lastMessage ?? 'Aucun message'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (room.unreadCount > 0)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${room.unreadCount}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            const SizedBox(height: 4),
            Text(
              room.lastMessageTime != null 
                  ? DateFormat('HH:mm').format(room.lastMessageTime!)
                  : '',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        onTap: () => _openChatRoom(room),
      ),
    );
  }

  Widget _buildContactsTab() {
    return const Center(
      child: Text('Fonctionnalité de contacts en cours de développement'),
    );
  }

  void _openChatRoom(ChatRoom room) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ChatRoomScreen(room: room),
      ),
    );
  }
}

class _ChatRoomScreen extends StatefulWidget {
  final ChatRoom room;

  const _ChatRoomScreen({required this.room});

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<_ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<ChatMessage> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final messages = ChatService.getMessages(widget.room.id);
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.room.name),
        backgroundColor: Colors.indigo[800],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _buildMessageBubble(message);
                    },
                  ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isMe = message.senderId == 'user_001';
    
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isMe ? Colors.indigo[800] : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                message.senderName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                  fontSize: 12,
                ),
              ),
            Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.grey[600],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Tapez votre message...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onSubmitted: (value) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send),
            color: Colors.indigo[800],
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    ChatService.sendMessage(
      roomId: widget.room.id,
      content: content,
    );

    _messageController.clear();
    _loadMessages();
  }
}

class _InventoryScreen extends StatefulWidget {
  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<_InventoryScreen> {
  List<InventoryItem> _items = [];
  List<InventoryAlert> _alerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInventoryData();
  }

  Future<void> _loadInventoryData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final items = InventoryService.getItems();
      final alerts = InventoryService.getAlerts();
      setState(() {
        _items = items;
        _alerts = alerts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Stocks'),
        backgroundColor: Colors.brown[800],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_alerts.isNotEmpty) _buildAlertsSection(),
                Expanded(child: _buildItemsList()),
              ],
            ),
    );
  }

  Widget _buildAlertsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.orange[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alertes Stock',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange[800],
            ),
          ),
          const SizedBox(height: 8),
          ..._alerts.take(3).map((alert) => Text(
                '• ${alert.message}',
                style: TextStyle(color: Colors.orange[700]),
              )),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return _buildItemCard(item);
      },
    );
  }

  Widget _buildItemCard(InventoryItem item) {
    final stockPercentage = item.currentStock / item.maxStock;
    final isLowStock = item.currentStock <= item.minStock;
    final isOutOfStock = item.currentStock <= 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOutOfStock
                        ? Colors.red
                        : isLowStock
                            ? Colors.orange
                            : Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isOutOfStock
                        ? 'Rupture'
                        : isLowStock
                            ? 'Stock bas'
                            : 'En stock',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Stock: ${item.currentStock} ${item.unit}'),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: stockPercentage,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                isOutOfStock
                    ? Colors.red
                    : isLowStock
                        ? Colors.orange
                        : Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Min: ${item.minStock} ${item.unit}'),
                Text('Max: ${item.maxStock} ${item.unit}'),
                Text(
                  '${NumberFormat.currency(symbol: '', decimalDigits: 0).format(item.unitPrice)} ${item.currency}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsScreen extends StatefulWidget {
  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<_AnalyticsScreen> {
  Map<String, dynamic> _performanceData = {};
  List<Map<String, dynamic>> _recommendations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final performance = await AnalyticsService.analyzeAgriculturalPerformance(
        userId: 'user_001',
      );
      final recommendations = await AnalyticsService.getPersonalizedRecommendations(
        userId: 'user_001',
      );
      setState(() {
        _performanceData = performance;
        _recommendations = recommendations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Avancés'),
        backgroundColor: Colors.deepPurple[800],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPerformanceSection(),
                  const SizedBox(height: 24),
                  _buildRecommendationsSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildPerformanceSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Agricole',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildMetricCard('Efficacité Rendement', '${(_performanceData['yieldEfficiency'] * 100).toStringAsFixed(1)}%', Colors.green),
            _buildMetricCard('Efficacité Coûts', '${(_performanceData['costEfficiency'] * 100).toStringAsFixed(1)}%', Colors.blue),
            _buildMetricCard('Marge Bénéfice', '${(_performanceData['profitMargin'] * 100).toStringAsFixed(1)}%', Colors.orange),
            _buildMetricCard('Score Global', '${(_performanceData['overallScore'] * 100).toStringAsFixed(1)}%', Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recommandations Personnalisées',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._recommendations.map((rec) => _buildRecommendationCard(rec)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(Map<String, dynamic> recommendation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              recommendation['title'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(recommendation['description']),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(recommendation['priority']),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    recommendation['priority'].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Impact: ${recommendation['impact']}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class _SettingsScreen extends StatefulWidget {
  final Map<String, dynamic> settings;
  final Function(Map<String, dynamic>) onSettingsChanged;

  const _SettingsScreen({
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<_SettingsScreen> {
  late Map<String, dynamic> _currentSettings;

  @override
  void initState() {
    super.initState();
    _currentSettings = Map.from(widget.settings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: 'Sauvegarder',
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildLanguageSection(),
          _buildThemeSection(),
          _buildDisplaySection(),
          _buildNotificationSection(),
          _buildDataSection(),
          _buildWeatherSection(),
          _buildAISection(),
          _buildAdvancedSection(),
        ],
      ),
    );
  }

  Widget _buildLanguageSection() {
    return _buildSectionCard(
      title: 'Langue et Régionalisation',
      icon: Icons.language,
      children: [
        ListTile(
          title: const Text('Langue de l\'Interface'),
          subtitle: Text(_currentSettings['language']['name']),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => _showLanguagePicker(),
        ),
        SwitchListTile(
          title: const Text('Support RTL'),
          subtitle: const Text('Direction droite à gauche (Arabe)'),
          value: _currentSettings['language']['rtl'] as bool,
          onChanged: (value) {
            setState(() {
              _currentSettings['language']['rtl'] = value;
            });
          },
        ),
        ListTile(
          title: const Text('Format des Nombres'),
          subtitle: const Text('Séparateur décimal et milliers'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => _showNumberFormatPicker(),
        ),
        ListTile(
          title: const Text('Format de Date'),
          subtitle: const Text('Affichage des dates'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => _showDateFormatPicker(),
        ),
      ],
    );
  }

  Widget _buildThemeSection() {
    return _buildSectionCard(
      title: 'Thème et Apparence',
      icon: Icons.palette,
      children: [
        SwitchListTile(
          title: const Text('Mode Sombre'),
          subtitle: const Text('Activer le thème sombre'),
          value: _currentSettings['theme']['isDarkMode'] as bool,
          onChanged: (value) {
            setState(() {
              _currentSettings['theme']['isDarkMode'] = value;
            });
          },
        ),
        ListTile(
          title: const Text('Couleur Principale'),
          subtitle: Text(_currentSettings['theme']['primaryColor']),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => _showColorPicker('primaryColor'),
        ),
        ListTile(
          title: const Text('Couleur d\'Accent'),
          subtitle: Text(_currentSettings['theme']['accentColor']),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => _showColorPicker('accentColor'),
        ),
        ListTile(
          title: const Text('Taille de Police'),
          subtitle: Text(_currentSettings['theme']['fontSize']),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => _showFontSizePicker(),
        ),
      ],
    );
  }

  Widget _buildDisplaySection() {
    return _buildSectionCard(
      title: 'Affichage',
      icon: Icons.visibility,
      children: [
        SwitchListTile(
          title: const Text('Section Météo'),
          subtitle: const Text('Afficher les informations météo'),
          value: _currentSettings['display']['showWeather'] as bool,
          onChanged: (value) {
            setState(() {
              _currentSettings['display']['showWeather'] = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Analyse du Sol'),
          subtitle: const Text('Afficher l\'analyse des données de sol'),
          value: _currentSettings['display']['showSoilAnalysis'] as bool,
          onChanged: (value) {
            setState(() {
              _currentSettings['display']['showSoilAnalysis'] = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Recommandations IA'),
          subtitle: const Text('Afficher les suggestions IA'),
          value: _currentSettings['display']['showAIRecommendations'] as bool,
          onChanged: (value) {
            setState(() {
              _currentSettings['display']['showAIRecommendations'] = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Métriques de Performance'),
          subtitle: const Text('Afficher les indicateurs de performance'),
          value: _currentSettings['display']['showPerformanceMetrics'] as bool,
          onChanged: (value) {
            setState(() {
              _currentSettings['display']['showPerformanceMetrics'] = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Graphiques'),
          subtitle: const Text('Afficher les graphiques et analyses'),
          value: _currentSettings['display']['showCharts'] as bool,
          onChanged: (value) {
            setState(() {
              _currentSettings['display']['showCharts'] = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Mode Compact'),
          subtitle: const Text('Interface plus dense'),
          value: _currentSettings['display']['compactMode'] as bool,
          onChanged: (value) {
            setState(() {
              _currentSettings['display']['compactMode'] = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Animations'),
          subtitle: const Text('Activer les animations'),
          value: _currentSettings['display']['animationsEnabled'] as bool,
          onChanged: (value) {
            setState(() {
              _currentSettings['display']['animationsEnabled'] = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildNotificationSection() {
    return _buildSectionCard(
      title: 'Notifications',
      icon: Icons.notifications,
      children: [
        SwitchListTile(
          title: const Text('Notifications Actives'),
          subtitle: const Text('Activer toutes les notifications'),
          value: _currentSettings['notifications']['enabled'] as bool,
          onChanged: (value) {
            setState(() {
              _currentSettings['notifications']['enabled'] = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Alertes Météo'),
          subtitle: const Text('Notifications météorologiques'),
          value: _currentSettings['notifications']['weatherAlerts'] as bool,
          onChanged: (value) {
            setState(() {
              _currentSettings['notifications']['weatherAlerts'] = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Recommandations IA'),
          subtitle: const Text('Notifications des suggestions IA'),
          value: _currentSettings['notifications']['aiRecommendations'] as bool,
          onChanged: (value) {
            setState(() {
              _currentSettings['notifications']['aiRecommendations'] = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Rappels Cultures'),
          subtitle: const Text('Rappels pour les cultures'),
          value: _currentSettings['notifications']['cropReminders'] as bool,
          onChanged: (value) {
            setState(() {
              _currentSettings['notifications']['cropReminders'] = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Son'),
          subtitle: const Text('Activer les sons de notification'),
          value: _currentSettings['notifications']['soundEnabled'] as bool,
          onChanged: (value) {
            setState(() {
              _currentSettings['notifications']['soundEnabled'] = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Vibration'),
          subtitle: const Text('Activer la vibration'),
          value: _currentSettings['notifications']['vibrationEnabled'] as bool,
          onChanged: (value) {
            setState(() {
              _currentSettings['notifications']['vibrationEnabled'] = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDataSection() {
    return _buildSectionCard(
      title: 'Données et Synchronisation',
      icon: Icons.storage,
      children: [
        SwitchListTile(
          title: const Text('Actualisation Automatique'),
          subtitle: const Text('Actualiser les données automatiquement'),
          value: _currentSettings['data']['autoRefresh'] as bool,
          onChanged: (value) {
            setState(() {
              _currentSettings['data']['autoRefresh'] = value;
            });
          },
        ),
        ListTile(
          title: const Text('Intervalle d\'Actualisation'),
          subtitle: Text('${_currentSettings['data']['refreshInterval']} minutes'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => _showRefreshIntervalPicker(),
        ),
        SwitchListTile(
          title: const Text('Cache Local'),
          subtitle: const Text('Utiliser le cache pour améliorer les performances'),
          value: _currentSettings['data']['cacheEnabled'] as bool,
          onChanged: (value) {
            setState(() {
              _currentSettings['data']['cacheEnabled'] = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Synchronisation'),
          subtitle: const Text('Synchroniser avec le cloud'),
          value: _currentSettings['data']['syncEnabled'] as bool,
          onChanged: (value) {
            setState(() {
              _currentSettings['data']['syncEnabled'] = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Sauvegarde Automatique'),
          subtitle: const Text('Sauvegarder automatiquement les données'),
          value: _currentSettings['data']['backupEnabled'] as bool,
          onChanged: (value) {
            setState(() {
              _currentSettings['data']['backupEnabled'] = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildWeatherSection() {
    return _buildSectionCard(
      title: 'Météo et Localisation',
      icon: Icons.wb_sunny,
      children: [
        ListTile(
          title: const Text('Localisation'),
          subtitle: Text(_currentSettings['weather']['location']),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => _showLocationPicker(),
        ),
        ListTile(
          title: const Text('Unité de Température'),
          subtitle: Text(_currentSettings['weather']['unit'] == 'celsius' ? 'Celsius' : 'Fahrenheit'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => _showTemperatureUnitPicker(),
        ),
        ListTile(
          title: const Text('Jours de Prévision'),
          subtitle: Text('${_currentSettings['weather']['forecastDays']} jours'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => _showForecastDaysPicker(),
        ),
        SwitchListTile(
          title: const Text('Localisation Automatique'),
          subtitle: const Text('Détecter automatiquement la position'),
          value: _currentSettings['weather']['autoLocation'] as bool,
          onChanged: (value) {
            setState(() {
              _currentSettings['weather']['autoLocation'] = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildAISection() {
    return _buildSectionCard(
      title: 'Intelligence Artificielle',
      icon: Icons.psychology,
      children: [
        SwitchListTile(
          title: const Text('IA Activée'),
          subtitle: const Text('Activer les fonctionnalités IA'),
          value: _currentSettings['ai']['enabled'] as bool,
          onChanged: (value) {
            setState(() {
              _currentSettings['ai']['enabled'] = value;
            });
          },
        ),
        SwitchListTile(
          title: const Text('Mode Apprentissage'),
          subtitle: const Text('L\'IA apprend de vos préférences'),
          value: _currentSettings['ai']['learningMode'] as bool,
          onChanged: (value) {
            setState(() {
              _currentSettings['ai']['learningMode'] = value;
            });
          },
        ),
        ListTile(
          title: const Text('Niveau de Recommandations'),
          subtitle: Text(_getRecommendationLevelText(_currentSettings['ai']['recommendationLevel'])),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => _showRecommendationLevelPicker(),
        ),
        SwitchListTile(
          title: const Text('Optimisation Automatique'),
          subtitle: const Text('Optimiser automatiquement les paramètres'),
          value: _currentSettings['ai']['autoOptimization'] as bool,
          onChanged: (value) {
            setState(() {
              _currentSettings['ai']['autoOptimization'] = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildAdvancedSection() {
    return _buildSectionCard(
      title: 'Paramètres Avancés',
      icon: Icons.settings_applications,
      children: [
        ListTile(
          title: const Text('Réinitialiser les Paramètres'),
          subtitle: const Text('Restaurer les paramètres par défaut'),
          trailing: const Icon(Icons.restore),
          onTap: _resetSettings,
        ),
        ListTile(
          title: const Text('Exporter les Paramètres'),
          subtitle: const Text('Sauvegarder la configuration'),
          trailing: const Icon(Icons.download),
          onTap: _exportSettings,
        ),
        ListTile(
          title: const Text('Importer les Paramètres'),
          subtitle: const Text('Charger une configuration'),
          trailing: const Icon(Icons.upload),
          onTap: _importSettings,
        ),
        ListTile(
          title: const Text('À Propos'),
          subtitle: const Text('Version et informations'),
          trailing: const Icon(Icons.info),
          onTap: _showAbout,
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  void _saveSettings() {
    widget.onSettingsChanged(_currentSettings);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Paramètres sauvegardés avec succès!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  void _showColorPicker(String colorType) {
    final colors = ['green', 'blue', 'red', 'purple', 'orange', 'teal'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choisir la couleur ${colorType == 'primaryColor' ? 'principale' : 'd\'accent'}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: colors.map((color) => ListTile(
            title: Text(color.toUpperCase()),
            leading: CircleAvatar(backgroundColor: _getColorFromName(color)),
            onTap: () {
              setState(() {
                _currentSettings['theme'][colorType] = color;
              });
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showFontSizePicker() {
    final sizes = ['small', 'medium', 'large'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Taille de Police'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: sizes.map((size) => ListTile(
            title: Text(_getFontSizeText(size)),
            onTap: () {
              setState(() {
                _currentSettings['theme']['fontSize'] = size;
              });
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showRefreshIntervalPicker() {
    final intervals = [5, 15, 30, 60, 120];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Intervalle d\'Actualisation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: intervals.map((interval) => ListTile(
            title: Text('$interval minutes'),
            onTap: () {
              setState(() {
                _currentSettings['data']['refreshInterval'] = interval;
              });
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showLocationPicker() {
    final locations = ['Dakar', 'Thiès', 'Kaolack', 'Saint-Louis', 'Ziguinchor', 'Kolda'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Localisation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: locations.map((location) => ListTile(
            title: Text(location),
            onTap: () {
              setState(() {
                _currentSettings['weather']['location'] = location;
              });
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showTemperatureUnitPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unité de Température'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Celsius (°C)'),
              onTap: () {
                setState(() {
                  _currentSettings['weather']['unit'] = 'celsius';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Fahrenheit (°F)'),
              onTap: () {
                setState(() {
                  _currentSettings['weather']['unit'] = 'fahrenheit';
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showForecastDaysPicker() {
    final days = [1, 3, 5, 7];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Jours de Prévision'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: days.map((day) => ListTile(
            title: Text('$day jour${day > 1 ? 's' : ''}'),
            onTap: () {
              setState(() {
                _currentSettings['weather']['forecastDays'] = day;
              });
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showRecommendationLevelPicker() {
    final levels = ['low', 'medium', 'high'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Niveau de Recommandations'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: levels.map((level) => ListTile(
            title: Text(_getRecommendationLevelText(level)),
            onTap: () {
              setState(() {
                _currentSettings['ai']['recommendationLevel'] = level;
              });
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showLanguagePicker() {
    final languages = [
      {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
      {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
      {'code': 'ar', 'name': 'العربية', 'flag': '🇸🇦'},
      {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
      {'code': 'pt', 'name': 'Português', 'flag': '🇵🇹'},
    ];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir la Langue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) => ListTile(
            leading: Text(lang['flag']!, style: const TextStyle(fontSize: 24)),
            title: Text(lang['name']!),
            trailing: _currentSettings['language']['code'] == lang['code'] 
                ? const Icon(Icons.check, color: Colors.green) 
                : null,
            onTap: () {
              setState(() {
                _currentSettings['language']['code'] = lang['code']!;
                _currentSettings['language']['name'] = lang['name']!;
                _currentSettings['language']['rtl'] = lang['code'] == 'ar';
              });
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showNumberFormatPicker() {
    final formats = [
      {'name': 'Français (1 234,56)', 'separator': ',', 'thousands': ' '},
      {'name': 'Anglais (1,234.56)', 'separator': '.', 'thousands': ','},
      {'name': 'Arabe (١٬٢٣٤٫٥٦)', 'separator': '.', 'thousands': '٬'},
    ];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Format des Nombres'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: formats.map((format) => ListTile(
            title: Text(format['name']!),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Format sélectionné: ${format['name']}')),
              );
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showDateFormatPicker() {
    final formats = [
      {'name': 'DD/MM/YYYY', 'format': 'dd/MM/yyyy'},
      {'name': 'MM/DD/YYYY', 'format': 'MM/dd/yyyy'},
      {'name': 'YYYY-MM-DD', 'format': 'yyyy-MM-dd'},
      {'name': 'DD MMM YYYY', 'format': 'dd MMM yyyy'},
    ];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Format de Date'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: formats.map((format) => ListTile(
            title: Text(format['name']!),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Format sélectionné: ${format['name']}')),
              );
            },
          )).toList(),
        ),
      ),
    );
  }

  void _resetSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialiser les Paramètres'),
        content: const Text('Êtes-vous sûr de vouloir restaurer les paramètres par défaut ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentSettings = {
                  'theme': {
                    'isDarkMode': false,
                    'primaryColor': 'green',
                    'accentColor': 'blue',
                    'fontSize': 'medium',
                  },
                  'notifications': {
                    'enabled': true,
                    'weatherAlerts': true,
                    'aiRecommendations': true,
                    'cropReminders': true,
                    'soundEnabled': true,
                    'vibrationEnabled': true,
                  },
                  'display': {
                    'showWeather': true,
                    'showSoilAnalysis': true,
                    'showAIRecommendations': true,
                    'showPerformanceMetrics': true,
                    'showCharts': true,
                    'compactMode': false,
                    'animationsEnabled': true,
                  },
                  'data': {
                    'autoRefresh': true,
                    'refreshInterval': 30,
                    'cacheEnabled': true,
                    'syncEnabled': true,
                    'backupEnabled': true,
                  },
                  'weather': {
                    'location': 'Dakar',
                    'unit': 'celsius',
                    'forecastDays': 3,
                    'autoLocation': true,
                  },
                  'ai': {
                    'enabled': true,
                    'learningMode': true,
                    'recommendationLevel': 'medium',
                    'autoOptimization': true,
                  },
                  'language': {
                    'code': 'fr',
                    'name': 'Français',
                    'rtl': false,
                  },
                };
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Paramètres réinitialisés!'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );
  }

  void _exportSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export des paramètres en cours...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _importSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Import des paramètres en cours...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('À Propos'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tableau de Bord Agricole Intelligent'),
            SizedBox(height: 8),
            Text('Version: 2.0.0'),
            Text('Développé avec Flutter'),
            SizedBox(height: 16),
            Text('Fonctionnalités:'),
            Text('• Gestion des cultures'),
            Text('• Météo en temps réel'),
            Text('• Recommandations IA'),
            Text('• Analyses avancées'),
            Text('• Paramètres personnalisables'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Color _getColorFromName(String colorName) {
    switch (colorName) {
      case 'green': return Colors.green;
      case 'blue': return Colors.blue;
      case 'red': return Colors.red;
      case 'purple': return Colors.purple;
      case 'orange': return Colors.orange;
      case 'teal': return Colors.teal;
      default: return Colors.grey;
    }
  }

  String _getFontSizeText(String size) {
    switch (size) {
      case 'small': return 'Petit';
      case 'medium': return 'Moyen';
      case 'large': return 'Grand';
      default: return 'Moyen';
    }
  }

  String _getRecommendationLevelText(String level) {
    switch (level) {
      case 'low': return 'Faible (moins de suggestions)';
      case 'medium': return 'Moyen (équilibré)';
      case 'high': return 'Élevé (beaucoup de suggestions)';
      default: return 'Moyen';
    }
  }
}
