import 'package:flutter/material.dart';

class AppTheme {
  // Couleurs de base
  static const Color primaryGreen = Color(0xFF2E7D32); // Vert forêt
  static const Color earthBrown = Color(0xFF6D4C41); // Marron terreux
  static const Color sunAmber = Color(0xFFFFA000); // Orange soleil
  static const Color errorRed = Color(0xFFD32F2F); // Rouge d'erreur
  static const Color soilBeige = Color(0xFFFFF3E0); // Beige sol

  static const String _themeKey = 'isDarkMode';

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.green,
      primaryColor: Colors.green[800],
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.green[800],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black87),
      ),
      iconTheme: const IconThemeData(color: Colors.black87),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.green[800],
        unselectedItemColor: Colors.grey,
      ),
      colorScheme: ColorScheme.light(
        primary: Colors.green[800]!,
        secondary: Colors.green[600]!,
        surface: Colors.white,
        background: Colors.white,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black87,
        onBackground: Colors.black87,
        onError: Colors.white,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.green,
      primaryColor: Colors.green[800],
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.green[900],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: const Color(0xFF1E1E1E),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white70),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: Colors.green[400],
        unselectedItemColor: Colors.grey,
      ),
      colorScheme: ColorScheme.dark(
        primary: Colors.green[800]!,
        secondary: Colors.green[600]!,
        surface: const Color(0xFF1E1E1E),
        background: const Color(0xFF121212),
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,
        onError: Colors.white,
      ),
    );
  }

  static Future<bool> getThemeMode() async {
    // This method is no longer used as the theme mode is managed by the ThemeProvider
    throw UnimplementedError();
  }

  static Future<void> setThemeMode(bool isDarkMode) async {
    // This method is no longer used as the theme mode is managed by the ThemeProvider
    throw UnimplementedError();
  }

  // TextTheme personnalisé
  static const TextTheme _agricultureTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.25,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: primaryGreen,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      height: 1.5,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
  );

  // Style des boutons élevés
  static final ElevatedButtonThemeData _elevatedButtonTheme =
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: _agricultureTextTheme.labelLarge?.copyWith(color: Colors.white),
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
    ),
  );

  // Style des boutons outlined
  static final OutlinedButtonThemeData _outlinedButtonTheme =
      OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      side: const BorderSide(color: primaryGreen),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
    ),
  );

  // Style des champs de formulaire
  static const InputDecorationTheme _inputDecorationTheme = InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: sunAmber),
    ),
    floatingLabelStyle: TextStyle(color: sunAmber),
  );

  // Style des cartes de cultures
  static const CardTheme _cropCardTheme = CardTheme(
    elevation: 2,
    margin: EdgeInsets.all(8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  );

  // Méthode pour le style des statuts de culture
  static TextStyle cropStatusStyle(CropStatus status) {
    switch (status) {
      case CropStatus.healthy:
        return const TextStyle(color: primaryGreen, fontWeight: FontWeight.bold);
      case CropStatus.warning:
        return const TextStyle(color: sunAmber, fontWeight: FontWeight.bold);
      case CropStatus.critical:
        return const TextStyle(color: errorRed, fontWeight: FontWeight.bold);
    }
  }
}

// Enum pour le statut des cultures
enum CropStatus { healthy, warning, critical }

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  
  bool get isDarkMode => _isDarkMode;
  
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
