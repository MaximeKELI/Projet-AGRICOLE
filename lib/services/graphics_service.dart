import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';

class GraphicsService {
  // Créer un gradient animé complexe
  static Widget createComplexGradient({
    required List<Color> colors,
    required Widget child,
    Duration duration = const Duration(seconds: 4),
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: begin,
              end: end,
              colors: colors,
              stops: [
                (value * 0.3) % 1.0,
                (value * 0.5) % 1.0,
                (value * 0.7) % 1.0,
                (value * 0.9) % 1.0,
              ],
            ),
          ),
          child: child,
        );
      },
    );
  }

  // Créer un effet de verre (glassmorphism)
  static Widget createGlassEffect({
    required Widget child,
    double opacity = 0.2,
    double blur = 10.0,
    Color tintColor = Colors.white,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: tintColor.withOpacity(opacity),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  // Créer un effet de néon animé
  static Widget createAnimatedNeon({
    required Widget child,
    Color glowColor = Colors.cyan,
    double intensity = 1.0,
    Duration duration = const Duration(seconds: 2),
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, _) {
        final glowIntensity = intensity * (0.5 + 0.5 * math.sin(value * math.pi * 2));
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: glowColor.withOpacity(0.8 * glowIntensity),
                blurRadius: 20 * glowIntensity,
                spreadRadius: 5 * glowIntensity,
              ),
              BoxShadow(
                color: glowColor.withOpacity(0.4 * glowIntensity),
                blurRadius: 40 * glowIntensity,
                spreadRadius: 10 * glowIntensity,
              ),
              BoxShadow(
                color: glowColor.withOpacity(0.2 * glowIntensity),
                blurRadius: 60 * glowIntensity,
                spreadRadius: 15 * glowIntensity,
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }

  // Créer un effet de particules en arrière-plan
  static Widget createParticleBackground({
    required Widget child,
    int particleCount = 30,
    Color particleColor = Colors.white,
    double particleSize = 2.0,
    Duration duration = const Duration(seconds: 10),
  }) {
    return Stack(
      children: [
        child,
        ...List.generate(particleCount, (index) {
          return _ParticleBackground(
            color: particleColor,
            size: particleSize,
            duration: duration,
            delay: Duration(milliseconds: index * 100),
          );
        }),
      ],
    );
  }

  // Créer un effet de liquide morphing
  static Widget createLiquidMorphing({
    required Widget child,
    Color liquidColor = Colors.blue,
    Duration duration = const Duration(seconds: 3),
  }) {
    return CustomPaint(
      painter: _LiquidMorphingPainter(
        color: liquidColor,
        duration: duration,
      ),
      child: child,
    );
  }

  // Créer un effet de hologramme
  static Widget createHologramEffect({
    required Widget child,
    Duration duration = const Duration(seconds: 2),
    Color scanlineColor = Colors.green,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, _) {
        return Stack(
          children: [
            child,
            CustomPaint(
              painter: _HologramPainter(
                color: scanlineColor,
                progress: value,
              ),
              size: Size.infinite,
            ),
          ],
        );
      },
    );
  }

  // Créer un effet de glitch
  static Widget createGlitchEffect({
    required Widget child,
    Duration duration = const Duration(milliseconds: 200),
    Color glitchColor = Colors.red,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, _) {
        final random = math.Random();
        final glitchIntensity = random.nextDouble() * value;
        
        return Stack(
          children: [
            child,
            if (glitchIntensity > 0.7)
              Transform.translate(
                offset: Offset(
                  (random.nextDouble() - 0.5) * 10 * glitchIntensity,
                  (random.nextDouble() - 0.5) * 10 * glitchIntensity,
                ),
                child: Opacity(
                  opacity: glitchIntensity * 0.3,
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      glitchColor,
                      BlendMode.overlay,
                    ),
                    child: child,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // Créer un effet de matrice (Matrix rain)
  static Widget createMatrixRain({
    required Widget child,
    Color matrixColor = Colors.green,
    Duration duration = const Duration(seconds: 5),
  }) {
    return Stack(
      children: [
        child,
        CustomPaint(
          painter: _MatrixRainPainter(
            color: matrixColor,
            duration: duration,
          ),
          size: Size.infinite,
        ),
      ],
    );
  }

  // Créer un effet de vortex
  static Widget createVortexEffect({
    required Widget child,
    Color vortexColor = Colors.purple,
    Duration duration = const Duration(seconds: 4),
  }) {
    return CustomPaint(
      painter: _VortexPainter(
        color: vortexColor,
        duration: duration,
      ),
      child: child,
    );
  }

  // Créer un effet de circuit électronique
  static Widget createCircuitEffect({
    required Widget child,
    Color circuitColor = Colors.blue,
    Duration duration = const Duration(seconds: 3),
  }) {
    return CustomPaint(
      painter: _CircuitPainter(
        color: circuitColor,
        duration: duration,
      ),
      child: child,
    );
  }

  // Créer un effet de data stream
  static Widget createDataStream({
    required Widget child,
    Color streamColor = Colors.cyan,
    Duration duration = const Duration(seconds: 2),
  }) {
    return CustomPaint(
      painter: _DataStreamPainter(
        color: streamColor,
        duration: duration,
      ),
      child: child,
    );
  }
}

class _ParticleBackground extends StatefulWidget {
  final Color color;
  final double size;
  final Duration duration;
  final Duration delay;

  const _ParticleBackground({
    required this.color,
    required this.size,
    required this.duration,
    required this.delay,
  });

  @override
  _ParticleBackgroundState createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<_ParticleBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.repeat();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final random = math.Random();
        return Positioned(
          left: random.nextDouble() * MediaQuery.of(context).size.width,
          top: random.nextDouble() * MediaQuery.of(context).size.height,
          child: Transform.translate(
            offset: Offset(
              math.sin(_animation.value * math.pi * 2) * 50,
              math.cos(_animation.value * math.pi * 2) * 50,
            ),
            child: Opacity(
              opacity: 0.3 + 0.7 * math.sin(_animation.value * math.pi),
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LiquidMorphingPainter extends CustomPainter {
  final Color color;
  final Duration duration;

  _LiquidMorphingPainter({
    required this.color,
    required this.duration,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final path = Path();

    // Créer des formes liquides qui se transforment
    for (int i = 0; i < 3; i++) {
      final centerX = size.width * (0.2 + i * 0.3);
      final centerY = size.height * 0.5;
      final radius = 50 + 30 * math.sin(time + i);

      path.addOval(Rect.fromCircle(
        center: Offset(centerX, centerY),
        radius: radius,
      ));
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _HologramPainter extends CustomPainter {
  final Color color;
  final double progress;

  _HologramPainter({
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.1)
      ..strokeWidth = 1.0;

    // Lignes de scan holographiques
    for (int i = 0; i < 20; i++) {
      final y = (size.height / 20) * i + (progress * size.height);
      canvas.drawLine(
        Offset(0, y % size.height),
        Offset(size.width, y % size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _MatrixRainPainter extends CustomPainter {
  final Color color;
  final Duration duration;

  _MatrixRainPainter({
    required this.color,
    required this.duration,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.6);

    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final random = math.Random();

    // Générer des caractères de pluie Matrix
    for (int i = 0; i < 50; i++) {
      final x = (size.width / 50) * i;
      final y = (time * 100 + i * 20) % size.height;
      
      final char = String.fromCharCode(0x30A0 + random.nextInt(96));
      final textPainter = TextPainter(
        text: TextSpan(
          text: char,
          style: TextStyle(
            color: color.withOpacity(0.8),
            fontSize: 12.0,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _VortexPainter extends CustomPainter {
  final Color color;
  final Duration duration;

  _VortexPainter({
    required this.color,
    required this.duration,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final center = Offset(size.width / 2, size.height / 2);

    // Créer un vortex spiral
    for (int i = 0; i < 10; i++) {
      final radius = 20 + i * 20;
      final angle = time * 2 + i * 0.5;
      
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      canvas.drawCircle(
        Offset(x, y),
        3.0,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _CircuitPainter extends CustomPainter {
  final Color color;
  final Duration duration;

  _CircuitPainter({
    required this.color,
    required this.duration,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = 1.0;

    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;

    // Dessiner des circuits électroniques
    for (int i = 0; i < 20; i++) {
      final x1 = (size.width / 20) * i;
      final y1 = size.height * 0.3 + 50 * math.sin(time + i);
      final x2 = (size.width / 20) * (i + 1);
      final y2 = size.height * 0.7 + 50 * math.cos(time + i);

      canvas.drawLine(
        Offset(x1, y1),
        Offset(x2, y2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _DataStreamPainter extends CustomPainter {
  final Color color;
  final Duration duration;

  _DataStreamPainter({
    required this.color,
    required this.duration,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..strokeWidth = 2.0;

    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;

    // Créer des flux de données
    for (int i = 0; i < 10; i++) {
      final x = (size.width / 10) * i;
      final y = (time * 100 + i * 50) % size.height;
      
      canvas.drawCircle(
        Offset(x, y),
        3.0,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
