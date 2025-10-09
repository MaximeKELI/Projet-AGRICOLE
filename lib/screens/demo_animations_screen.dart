import 'package:flutter/material.dart';
import '../services/graphics_service.dart';
import '../services/animation_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DemoAnimationsScreen extends StatefulWidget {
  const DemoAnimationsScreen({Key? key}) : super(key: key);

  @override
  _DemoAnimationsScreenState createState() => _DemoAnimationsScreenState();
}

class _DemoAnimationsScreenState extends State<DemoAnimationsScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _particleController;
  late AnimationController _glowController;
  
  int _currentDemo = 0;
  final List<String> _demoTitles = [
    'Particules Flottantes',
    'Effet de Verre',
    'Néon Animé',
    'Morphing 3D',
    'Vagues Liquides',
    'Effet Glitch',
    'Hologramme',
    'Matrice Rain',
    'Vortex Spiral',
    'Circuit Électronique',
  ];

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _particleController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _startAnimations();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _particleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _startAnimations() {
    _mainController.repeat(reverse: true);
    _particleController.repeat();
    _glowController.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple[900]!,
              Colors.blue[900]!,
              Colors.indigo[900]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildDemoContent(),
              ),
              _buildNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          Expanded(
            child: Text(
              'Démonstrations d\'Animations',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoContent() {
    return PageView.builder(
      itemCount: _demoTitles.length,
      onPageChanged: (index) {
        setState(() {
          _currentDemo = index;
        });
      },
      itemBuilder: (context, index) {
        return _buildDemoPage(index);
      },
    );
  }

  Widget _buildDemoPage(int index) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            _demoTitles[index],
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: -0.3, end: 0),
          const SizedBox(height: 30),
          Expanded(
            child: _buildDemoWidget(index),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoWidget(int index) {
    switch (index) {
      case 0:
        return _buildFloatingParticlesDemo();
      case 1:
        return _buildGlassEffectDemo();
      case 2:
        return _buildAnimatedNeonDemo();
      case 3:
        return _buildMorphing3DDemo();
      case 4:
        return _buildLiquidWaveDemo();
      case 5:
        return _buildGlitchEffectDemo();
      case 6:
        return _buildHologramDemo();
      case 7:
        return _buildMatrixRainDemo();
      case 8:
        return _buildVortexDemo();
      case 9:
        return _buildCircuitDemo();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFloatingParticlesDemo() {
    return AnimationService.createFloatingParticles(
      particleCount: 30,
      particleColor: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.withOpacity(0.3), Colors.purple.withOpacity(0.3)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            'Particules flottantes\navec animation fluide',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassEffectDemo() {
    return GraphicsService.createGlassEffect(
      opacity: 0.2,
      blur: 20,
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.cyan.withOpacity(0.3), Colors.blue.withOpacity(0.3)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            'Effet de verre\n(Glassmorphism)',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedNeonDemo() {
    return AnimationService.createAnimatedNeon(
      glowColor: Colors.cyan,
      intensity: 1.5,
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            'NÉON ANIMÉ',
            style: TextStyle(
              fontSize: 24,
              color: Colors.cyan,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMorphing3DDemo() {
    return AnimationService.create3DRotation(
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.withOpacity(0.7), Colors.pink.withOpacity(0.7)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            'Rotation 3D\nMorphing',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiquidWaveDemo() {
    return AnimationService.createLiquidWave(
      waveColor: Colors.blue,
      amplitude: 30,
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            'Vagues Liquides\nAnimées',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlitchEffectDemo() {
    return AnimationService.createGlitchEffect(
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            'EFFET GLITCH',
            style: TextStyle(
              fontSize: 24,
              color: Colors.red,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHologramDemo() {
    return AnimationService.createHologramEffect(
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            'HOLOGRAMME',
            style: TextStyle(
              fontSize: 24,
              color: Colors.green,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMatrixRainDemo() {
    return GraphicsService.createMatrixRain(
      matrixColor: Colors.green,
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            'MATRIX RAIN',
            style: TextStyle(
              fontSize: 24,
              color: Colors.green,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVortexDemo() {
    return GraphicsService.createVortexEffect(
      vortexColor: Colors.purple,
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            'VORTEX SPIRAL',
            style: TextStyle(
              fontSize: 24,
              color: Colors.purple,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircuitDemo() {
    return GraphicsService.createCircuitEffect(
      circuitColor: Colors.blue,
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            'CIRCUIT ÉLECTRONIQUE',
            style: TextStyle(
              fontSize: 20,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigation() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: _currentDemo > 0 ? () {
              setState(() {
                _currentDemo--;
              });
            } : null,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Précédent'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              foregroundColor: Colors.white,
            ),
          ),
          Text(
            '${_currentDemo + 1} / ${_demoTitles.length}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          ElevatedButton.icon(
            onPressed: _currentDemo < _demoTitles.length - 1 ? () {
              setState(() {
                _currentDemo++;
              });
            } : null,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Suivant'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
