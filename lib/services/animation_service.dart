import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimationService {
  // Animation de particules flottantes
  static Widget createFloatingParticles({
    required Widget child,
    int particleCount = 20,
    Color particleColor = Colors.white,
    double opacity = 0.6,
  }) {
    return Stack(
      children: [
        child,
        ...List.generate(particleCount, (index) {
          return _FloatingParticle(
            color: particleColor,
            opacity: opacity,
            delay: Duration(milliseconds: index * 100),
          );
        }),
      ],
    );
  }

  // Animation de gradient animé
  static Widget createAnimatedGradient({
    required List<Color> colors,
    required Widget child,
    Duration duration = const Duration(seconds: 3),
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
              stops: [
                value,
                (value + 0.3) % 1.0,
                (value + 0.6) % 1.0,
              ],
            ),
          ),
          child: child,
        );
      },
    );
  }

  // Animation de morphing de formes
  static Widget createMorphingShape({
    required Widget child,
    Duration duration = const Duration(seconds: 2),
  }) {
    return AnimatedBuilder(
      animation: AlwaysStoppedAnimation(0.0),
      builder: (context, _) {
        return TweenAnimationBuilder<double>(
          duration: duration,
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, _) {
            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(value * math.pi * 2),
              child: child,
            );
          },
        );
      },
    );
  }

  // Animation de vague liquide
  static Widget createLiquidWave({
    required Widget child,
    Color waveColor = Colors.blue,
    double amplitude = 20.0,
    Duration duration = const Duration(seconds: 2),
  }) {
    return CustomPaint(
      painter: _LiquidWavePainter(
        color: waveColor,
        amplitude: amplitude,
        duration: duration,
      ),
      child: child,
    );
  }

  // Animation de glitch
  static Widget createGlitchEffect({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, _) {
        return Transform(
          transform: Matrix4.identity()
            ..translate(
              (math.Random().nextDouble() - 0.5) * 10 * value,
              (math.Random().nextDouble() - 0.5) * 10 * value,
            ),
          child: Opacity(
            opacity: 0.8 + 0.2 * math.sin(value * math.pi * 4),
            child: child,
          ),
        );
      },
    );
  }

  // Animation de pulsation
  static Widget createPulseAnimation({
    required Widget child,
    double scale = 1.1,
    Duration duration = const Duration(seconds: 1),
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 1.0, end: scale),
      builder: (context, value, _) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
    );
  }

  // Animation de rotation 3D
  static Widget create3DRotation({
    required Widget child,
    Duration duration = const Duration(seconds: 2),
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, _) {
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(value * math.pi * 2)
            ..rotateY(value * math.pi * 2),
          child: child,
        );
      },
    );
  }

  // Animation de particules d'étoiles
  static Widget createStarField({
    required Widget child,
    int starCount = 50,
    Color starColor = Colors.white,
  }) {
    return Stack(
      children: [
        child,
        ...List.generate(starCount, (index) {
          return _StarParticle(
            color: starColor,
            delay: Duration(milliseconds: index * 50),
          );
        }),
      ],
    );
  }

  // Animation de néon
  static Widget createNeonEffect({
    required Widget child,
    Color glowColor = Colors.cyan,
    double blurRadius = 20.0,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.8),
            blurRadius: blurRadius,
            spreadRadius: 5.0,
          ),
          BoxShadow(
            color: glowColor.withOpacity(0.4),
            blurRadius: blurRadius * 2,
            spreadRadius: 10.0,
          ),
        ],
      ),
      child: child,
    );
  }

  // Animation de liquide qui coule
  static Widget createLiquidDrip({
    required Widget child,
    Color liquidColor = Colors.blue,
    Duration duration = const Duration(seconds: 3),
  }) {
    return CustomPaint(
      painter: _LiquidDripPainter(
        color: liquidColor,
        duration: duration,
      ),
      child: child,
    );
  }

  // Animation de hologramme
  static Widget createHologramEffect({
    required Widget child,
    Duration duration = const Duration(seconds: 2),
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, _) {
        return Opacity(
          opacity: 0.7 + 0.3 * math.sin(value * math.pi * 2),
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(value * math.pi * 0.1),
            child: child,
          ),
        );
      },
    );
  }
}

class _FloatingParticle extends StatefulWidget {
  final Color color;
  final double opacity;
  final Duration delay;

  const _FloatingParticle({
    required this.color,
    required this.opacity,
    required this.delay,
  });

  @override
  _FloatingParticleState createState() => _FloatingParticleState();
}

class _FloatingParticleState extends State<_FloatingParticle>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
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
        _controller.repeat(reverse: true);
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
        return Positioned(
          left: math.Random().nextDouble() * MediaQuery.of(context).size.width,
          top: math.Random().nextDouble() * MediaQuery.of(context).size.height,
          child: Opacity(
            opacity: widget.opacity * (1 - _animation.value),
            child: Transform.translate(
              offset: Offset(
                0,
                -50 * _animation.value,
              ),
              child: Container(
                width: 4.0,
                height: 4.0,
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

class _StarParticle extends StatefulWidget {
  final Color color;
  final Duration delay;

  const _StarParticle({
    required this.color,
    required this.delay,
  });

  @override
  _StarParticleState createState() => _StarParticleState();
}

class _StarParticleState extends State<_StarParticle>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
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
        _controller.repeat(reverse: true);
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
        return Positioned(
          left: math.Random().nextDouble() * MediaQuery.of(context).size.width,
          top: math.Random().nextDouble() * MediaQuery.of(context).size.height,
          child: Transform.scale(
            scale: 0.5 + 0.5 * _animation.value,
            child: Opacity(
              opacity: 0.3 + 0.7 * _animation.value,
              child: Icon(
                Icons.star,
                color: widget.color,
                size: 8.0,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LiquidWavePainter extends CustomPainter {
  final Color color;
  final double amplitude;
  final Duration duration;

  _LiquidWavePainter({
    required this.color,
    required this.amplitude,
    required this.duration,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final path = Path();
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;

    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x += 1.0) {
      final y = size.height * 0.7 + 
          amplitude * math.sin((x / size.width * 2 * math.pi) + time);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _LiquidDripPainter extends CustomPainter {
  final Color color;
  final Duration duration;

  _LiquidDripPainter({
    required this.color,
    required this.duration,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final dripCount = 5;

    for (int i = 0; i < dripCount; i++) {
      final x = (size.width / dripCount) * i + (size.width / dripCount) / 2;
      final y = size.height * 0.3 + 
          (size.height * 0.4) * ((time + i) % 1.0);

      canvas.drawCircle(
        Offset(x, y),
        3.0 + 2.0 * math.sin(time * 2 + i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
