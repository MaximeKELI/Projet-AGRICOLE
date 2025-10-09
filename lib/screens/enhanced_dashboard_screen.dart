import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../models/payment_models.dart';
import '../services/weather_service.dart';
import '../services/payment_service.dart';
import '../services/graphics_service.dart';
import '../services/animation_service.dart';
import '../services/analytics_service.dart';
import '../services/inventory_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class EnhancedDashboardScreen extends StatefulWidget {
  const EnhancedDashboardScreen({Key? key}) : super(key: key);

  @override
  _EnhancedDashboardScreenState createState() => _EnhancedDashboardScreenState();
}

class _EnhancedDashboardScreenState extends State<EnhancedDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _particleController;
  late AnimationController _glowController;
  
  List<Map<String, dynamic>> _dashboardData = [];
  Map<String, dynamic> _weatherData = {};
  List<Map<String, dynamic>> _aiRecommendations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _particleController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _loadData();
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
    _mainController.forward();
    _particleController.repeat();
    _glowController.repeat(reverse: true);
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Simuler le chargement des données
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _dashboardData = [
        {
          'title': 'Cultures Actives',
          'value': '12',
          'icon': Icons.agriculture,
          'color': Colors.green,
          'trend': '+15%',
        },
        {
          'title': 'Revenus Mensuels',
          'value': '2.5M FCFA',
          'icon': Icons.attach_money,
          'color': Colors.blue,
          'trend': '+8%',
        },
        {
          'title': 'Commandes',
          'value': '45',
          'icon': Icons.shopping_cart,
          'color': Colors.orange,
          'trend': '+22%',
        },
        {
          'title': 'Efficacité',
          'value': '87%',
          'icon': Icons.trending_up,
          'color': Colors.purple,
          'trend': '+5%',
        },
      ];

      _weatherData = {
        'temperature': 28,
        'humidity': 65,
        'windSpeed': 12,
        'condition': 'Ensoleillé',
        'forecast': [
          {'day': 'Lun', 'temp': '30°', 'icon': '☀️'},
          {'day': 'Mar', 'temp': '29°', 'icon': '⛅'},
          {'day': 'Mer', 'temp': '31°', 'icon': '☀️'},
        ],
      };

      _aiRecommendations = [
        {
          'title': 'Optimiser l\'irrigation',
          'description': 'Augmenter l\'arrosage de 20% cette semaine',
          'priority': 'high',
          'icon': Icons.water_drop,
        },
        {
          'title': 'Récolter les tomates',
          'description': 'Les tomates sont prêtes pour la récolte',
          'priority': 'medium',
          'icon': Icons.agriculture,
        },
        {
          'title': 'Traiter contre les parasites',
          'description': 'Application préventive recommandée',
          'priority': 'low',
          'icon': Icons.bug_report,
        },
      ];

      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading ? _buildLoadingScreen() : _buildMainContent(),
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green[400]!,
            Colors.blue[400]!,
            Colors.purple[400]!,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimationService.create3DRotation(
              child: Icon(
                Icons.agriculture,
                size: 100,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Chargement du Dashboard...',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green[50]!,
            Colors.blue[50]!,
            Colors.purple[50]!,
          ],
        ),
      ),
      child: AnimationService.createFloatingParticles(
        particleCount: 25,
        particleColor: Colors.white.withOpacity(0.6),
        child: CustomScrollView(
          slivers: [
            _buildAnimatedAppBar(),
            _buildStatsGrid(),
            _buildWeatherSection(),
            _buildAIRecommendationsSection(),
            _buildChartsSection(),
            _buildQuickActionsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Dashboard Agricole IA',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10,
              ),
            ],
          ),
        ),
        background: GraphicsService.createComplexGradient(
          colors: [
            Colors.green[400]!,
            Colors.blue[400]!,
            Colors.purple[400]!,
          ],
          child: Stack(
            children: [
              AnimationService.createLiquidWave(
                waveColor: Colors.white.withOpacity(0.3),
                amplitude: 30,
                child: Container(),
              ),
              Center(
                child: AnimationService.createPulseAnimation(
                  scale: 1.2,
                  child: Icon(
                    Icons.agriculture,
                    size: 80,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final data = _dashboardData[index];
            return _buildAnimatedStatCard(data, index);
          },
          childCount: _dashboardData.length,
        ),
      ),
    );
  }

  Widget _buildAnimatedStatCard(Map<String, dynamic> data, int index) {
    return AnimationService.createMorphingShape(
      child: GraphicsService.createGlassEffect(
        opacity: 0.1,
        blur: 10,
        child: Card(
          elevation: 15,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  data['color'].withOpacity(0.1),
                  data['color'].withOpacity(0.05),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimationService.createPulseAnimation(
                    child: Icon(
                      data['icon'],
                      size: 40,
                      color: data['color'],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    data['value'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: data['color'],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data['title'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      data['trend'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: index * 200))
        .fadeIn(duration: 600.ms)
        .slideX(begin: -0.3, end: 0);
  }

  Widget _buildWeatherSection() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverToBoxAdapter(
        child: AnimationService.createFloatingParticles(
          particleCount: 10,
          particleColor: Colors.blue.withOpacity(0.3),
          child: GraphicsService.createGlassEffect(
            opacity: 0.1,
            blur: 15,
            child: Card(
              elevation: 20,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.withOpacity(0.1),
                      Colors.cyan.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AnimationService.createPulseAnimation(
                            child: Icon(
                              Icons.wb_sunny,
                              size: 48,
                              color: Colors.orange[600],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Météo Actuelle',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    foreground: Paint()
                                      ..shader = LinearGradient(
                                        colors: [Colors.blue[400]!, Colors.cyan[400]!],
                                      ).createShader(Rect.fromLTWH(0, 0, 200, 70)),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${_weatherData['temperature']}°C',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          _buildWeatherInfo('Humidité', '${_weatherData['humidity']}%', Icons.water_drop),
                          _buildWeatherInfo('Vent', '${_weatherData['windSpeed']} km/h', Icons.air),
                          _buildWeatherInfo('Condition', _weatherData['condition'], Icons.cloud),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Prévisions 3 jours',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _weatherData['forecast'].length,
                          itemBuilder: (context, index) {
                            final forecast = _weatherData['forecast'][index];
                            return AnimationService.create3DRotation(
                              child: Container(
                                width: 120,
                                margin: const EdgeInsets.only(right: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.blue.withOpacity(0.1),
                                      Colors.cyan.withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(forecast['icon'], style: const TextStyle(fontSize: 32)),
                                    const SizedBox(height: 8),
                                    Text(
                                      forecast['day'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      forecast['temp'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate()
        .fadeIn(duration: 800.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildWeatherInfo(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.blue[600], size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIRecommendationsSection() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverToBoxAdapter(
        child: GraphicsService.createGlassEffect(
          opacity: 0.1,
          blur: 15,
          child: Card(
            elevation: 20,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.purple.withOpacity(0.1),
                    Colors.pink.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AnimationService.createPulseAnimation(
                          child: Icon(
                            Icons.psychology,
                            size: 32,
                            color: Colors.purple[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Recommandations IA',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()
                              ..shader = LinearGradient(
                                colors: [Colors.purple[400]!, Colors.pink[400]!],
                              ).createShader(Rect.fromLTWH(0, 0, 200, 70)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ..._aiRecommendations.asMap().entries.map((entry) {
                      final index = entry.key;
                      final recommendation = entry.value;
                      return _buildRecommendationCard(recommendation, index);
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate()
        .fadeIn(duration: 1000.ms)
        .slideX(begin: 0.3, end: 0);
  }

  Widget _buildRecommendationCard(Map<String, dynamic> recommendation, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: AnimationService.createMorphingShape(
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getPriorityColor(recommendation['priority']).withOpacity(0.1),
                  _getPriorityColor(recommendation['priority']).withOpacity(0.05),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  AnimationService.createPulseAnimation(
                    child: Icon(
                      recommendation['icon'],
                      color: _getPriorityColor(recommendation['priority']),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recommendation['title'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          recommendation['description'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(recommendation['priority']).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      recommendation['priority'].toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        color: _getPriorityColor(recommendation['priority']),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: index * 200))
        .fadeIn(duration: 600.ms)
        .slideX(begin: -0.3, end: 0);
  }

  Widget _buildChartsSection() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverToBoxAdapter(
        child: GraphicsService.createGlassEffect(
          opacity: 0.1,
          blur: 15,
          child: Card(
            elevation: 20,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.green.withOpacity(0.1),
                    Colors.blue.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AnimationService.createPulseAnimation(
                          child: Icon(
                            Icons.bar_chart,
                            size: 32,
                            color: Colors.green[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Analytics Avancés',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()
                              ..shader = LinearGradient(
                                colors: [Colors.green[400]!, Colors.blue[400]!],
                              ).createShader(Rect.fromLTWH(0, 0, 200, 70)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 300,
                      child: SfCircularChart(
                        series: <CircularSeries>[
                          PieSeries<Map<String, dynamic>, String>(
                            dataSource: [
                              {'category': 'Riz', 'value': 40, 'color': Colors.green},
                              {'category': 'Tomates', 'value': 30, 'color': Colors.red},
                              {'category': 'Mangues', 'value': 20, 'color': Colors.orange},
                              {'category': 'Autres', 'value': 10, 'color': Colors.blue},
                            ],
                            xValueMapper: (data, _) => data['category'],
                            yValueMapper: (data, _) => data['value'],
                            pointColorMapper: (data, _) => data['color'],
                            dataLabelSettings: const DataLabelSettings(isVisible: true),
                            enableTooltip: true,
                          ),
                        ],
                        legend: const Legend(
                          isVisible: true,
                          position: LegendPosition.bottom,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate()
        .fadeIn(duration: 1200.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildQuickActionsSection() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverToBoxAdapter(
        child: GraphicsService.createGlassEffect(
          opacity: 0.1,
          blur: 15,
          child: Card(
            elevation: 20,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.orange.withOpacity(0.1),
                    Colors.red.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AnimationService.createPulseAnimation(
                          child: Icon(
                            Icons.flash_on,
                            size: 32,
                            color: Colors.orange[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Actions Rapides',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()
                              ..shader = LinearGradient(
                                colors: [Colors.orange[400]!, Colors.red[400]!],
                              ).createShader(Rect.fromLTWH(0, 0, 200, 70)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 2.5,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildActionButton('Nouvelle Culture', Icons.add_circle, Colors.green),
                        _buildActionButton('Rapports', Icons.assessment, Colors.blue),
                        _buildActionButton('Recherche', Icons.search, Colors.purple),
                        _buildActionButton('Export', Icons.download, Colors.orange),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate()
        .fadeIn(duration: 1400.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildActionButton(String title, IconData icon, Color color) {
    return AnimationService.createMorphingShape(
      child: ElevatedButton.icon(
        onPressed: () {
          // Action
        },
        icon: Icon(icon, color: Colors.white),
        label: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 10,
        ),
      ),
    ).animate()
        .fadeIn(duration: 600.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0));
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
