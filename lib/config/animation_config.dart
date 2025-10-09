import 'package:flutter/material.dart';

class AnimationConfig {
  // Durées d'animation
  static const Duration fast = Duration(milliseconds: 300);
  static const Duration medium = Duration(milliseconds: 600);
  static const Duration slow = Duration(milliseconds: 1000);
  static const Duration verySlow = Duration(milliseconds: 2000);

  // Couleurs d'animation
  static const List<Color> gradientColors = [
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFF9C27B0),
    Color(0xFFFF9800),
  ];

  // Paramètres de particules
  static const int defaultParticleCount = 20;
  static const double defaultParticleOpacity = 0.6;
  static const Duration defaultParticleDuration = Duration(seconds: 3);

  // Paramètres d'effets
  static const double defaultBlurRadius = 10.0;
  static const double defaultOpacity = 0.2;
  static const double defaultGlowIntensity = 1.0;
}
