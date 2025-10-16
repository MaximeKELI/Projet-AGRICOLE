import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:app_agrigeo/utils/theme.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app_agrigeo/screens/user_model.dart';
import 'package:app_agrigeo/screens/map_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:app_agrigeo/screens/home_screen.dart';
import 'package:app_agrigeo/screens/db_universal.dart';
import 'package:app_agrigeo/screens/splash_screen.dart';
import 'package:app_agrigeo/screens/about_us_screen.dart';
import 'package:app_agrigeo/screens/settings_screen.dart';
import 'package:app_agrigeo/screens/documents_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_agrigeo/screens/api_config_screen.dart';
import 'package:app_agrigeo/screens/registration_screen.dart';
import 'package:app_agrigeo/screens/api_diagnostic_screen.dart';
import 'package:app_agrigeo/services/api_diagnostic_service.dart';
import 'package:app_agrigeo/services/real_data_integration_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('session');

  // Setup SQLite FFI on desktop (non-web)
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Ensure DB exists and print diagnostics
  try {
    final dbh = DatabaseHelper();
    await dbh.ensureInitialized();
    final path = await dbh.getDatabasePath();
    final info = await dbh.getUsersTableInfo();
    final count = await dbh.getUserCount();
    print('SQLite path: $path');
    print('users schema: $info');
    print('users count: $count');
  } catch (e) {
    print('DB init error: $e');
  }

  try {
    if (!kIsWeb && defaultTargetPlatform != TargetPlatform.linux) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print("Firebase initialisé avec succès");
    } else if (defaultTargetPlatform == TargetPlatform.linux) {
      print("Firebase désactivé sur Linux pour le développement");
    }
  } catch (e) {
    print("Erreur Firebase: $e");
  }

  // Diagnostic des clés API au démarrage
  try {
    await ApiDiagnosticService.performFullDiagnostic();
  } catch (e) {
    print("Erreur diagnostic API: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserModel()),
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
      ],
      child: AgriGeoApp(),
    ),
  );
}

// Classe pour gérer le changement de thème
class ThemeNotifier with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  ThemeNotifier() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDarkMode = prefs.getBool('darkMode') ?? false;
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    } catch (e) {
      print('Erreur lors du chargement du thème: $e');
    }
  }

  void setTheme(ThemeMode themeMode) async {
    _themeMode = themeMode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('darkMode', themeMode == ThemeMode.dark);
    } catch (e) {
      print('Erreur lors de la sauvegarde du thème: $e');
    }
  }

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    setTheme(_themeMode);
  }
}

class AgriGeoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeNotifier.themeMode,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/register': (context) => RegistrationScreen(),
        '/about': (context) => const AboutUsScreen(),
        '/main': (context) => MainScreen(),
        '/settings': (context) => SettingsScreen(),
        '/api-config': (context) => ApiConfigScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  DateTime? _lastBackPressTime;

  // Définir les écrans dans l'ordre correspondant aux indices de la barre de navigation
  final List<Widget> _screens = [
    HomeScreen(), // index 0
    MapScreen(), // index 1
    DocumentsScreen(), // index 2
  ];

  Future<void> _logout() async {
    // Afficher la boîte de dialogue de confirmation
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Déconnexion', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    // Si l'utilisateur confirme la déconnexion
    if (confirm == true) {
      final box = Hive.box('session');
      await box.clear();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/register');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_handlePageChange);
  }

  void _handlePageChange() {
    if (_pageController.page != null) {
      final newIndex = _pageController.page!.round();
      if (newIndex != _selectedIndex) {
        setState(() => _selectedIndex = newIndex);
      }
    }
  }

  void _onItemTapped(int index) {
    if (index >= 0 && index < _screens.length) {
      setState(() => _selectedIndex = index);
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_handlePageChange);
    _pageController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appuyez à nouveau pour quitter'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_selectedIndex == 0 ? 'Accueil' : _selectedIndex == 1 ? 'Carte' : 'Fiches'),
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.brightness_6),
              onPressed: () {
                themeNotifier.toggleTheme();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      themeNotifier.themeMode == ThemeMode.dark
                          ? 'Mode sombre activé'
                          : 'Mode clair activé',
                    ),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              tooltip: 'Changer le thème',
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Déconnexion',
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.pushNamed(context, '/settings'),
              tooltip: 'Paramètres',
            ),
          ],
        ),
        body: SafeArea(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              if (index >= 0 && index < _screens.length) {
                setState(() => _selectedIndex = index);
              }
            },
            children: _screens,
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
            BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Carte'),
            BottomNavigationBarItem(icon: Icon(Icons.description), label: 'Fiches'),
          ],
        ),
      ),
    );
  }
}
