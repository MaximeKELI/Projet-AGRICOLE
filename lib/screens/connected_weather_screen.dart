import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import '../services/weather_service.dart' as services;
import 'package:syncfusion_flutter_charts/charts.dart';

class ConnectedWeatherScreen extends StatefulWidget {
  const ConnectedWeatherScreen({Key? key}) : super(key: key);

  @override
  _ConnectedWeatherScreenState createState() => _ConnectedWeatherScreenState();
}

class _ConnectedWeatherScreenState extends State<ConnectedWeatherScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  services.WeatherData? _currentWeather;
  List<services.WeatherForecast> _forecast = [];
  List<services.WeatherAlert> _alerts = [];
  Map<String, dynamic>? _agriculturalData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _getCurrentLocationAndWeather();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocationAndWeather() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Obtenir la position actuelle
      final position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );


      // Charger les données météo
      await _loadWeatherData(position.latitude, position.longitude);
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de localisation: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadWeatherData(double latitude, double longitude) async {
    try {
      final currentWeather = await services.WeatherService.getCurrentWeather('$latitude,$longitude');
      final forecast = await services.WeatherService.getWeatherForecast('$latitude,$longitude');
      final alerts = await services.WeatherService.getWeatherAlerts('$latitude,$longitude');
      final agriculturalData = await services.WeatherService.getAgriculturalRecommendations('$latitude,$longitude');

      setState(() {
        _currentWeather = currentWeather;
        _forecast = forecast;
        _alerts = alerts;
        _agriculturalData = {'recommendations': agriculturalData};
        _isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des données météo: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Station Météo Connectée'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _getCurrentLocationAndWeather(),
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
                        _buildCurrentWeatherCard(),
                        const SizedBox(height: 20),
                        _buildAlertsSection(),
                        const SizedBox(height: 20),
                        _buildAgriculturalAdviceSection(),
                        const SizedBox(height: 20),
                        _buildForecastSection(),
                        const SizedBox(height: 20),
                        _buildChartsSection(),
                        const SizedBox(height: 20),
                        _buildDetailedMetricsSection(),
                      ],
                    ),
                  ),
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
            onPressed: () => _getCurrentLocationAndWeather(),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentWeatherCard() {
    if (_currentWeather == null) return const SizedBox.shrink();

    return Card(
      elevation: 6,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue[400]!,
              Colors.blue[600]!,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentWeather!.location,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _currentWeather!.description,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '${_currentWeather!.temperature.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _currentWeather!.condition.replaceAll('_', ' ').toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildWeatherMetric('Humidité', '${_currentWeather!.humidity.toStringAsFixed(0)}%', Icons.water_drop),
                  _buildWeatherMetric('Vent', '${_currentWeather!.windSpeed.toStringAsFixed(1)} km/h', Icons.air),
                  _buildWeatherMetric('Pluie', '${_currentWeather!.rainfall.toStringAsFixed(1)} mm', Icons.grain),
                  _buildWeatherMetric('UV', _currentWeather!.uvIndex.toStringAsFixed(1), Icons.wb_sunny),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
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
                Icon(Icons.warning, color: Colors.orange[700]),
                const SizedBox(width: 8),
                Text(
                  'Alertes Météo',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._alerts.map((alert) => _buildAlertCard(alert)),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(services.WeatherAlert alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getSeverityColor(alert.severity).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getSeverityColor(alert.severity).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(_getSeverityIcon(alert.severity), color: _getSeverityColor(alert.severity), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getSeverityColor(alert.severity).withOpacity(0.8),
                  ),
                ),
                Text(
                  alert.description,
                  style: TextStyle(color: _getSeverityColor(alert.severity).withOpacity(0.7)),
                ),
                if (alert.recommendations.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  ...alert.recommendations.map((rec) => Text(
                    '• $rec',
                    style: TextStyle(
                      fontSize: 12,
                      color: _getSeverityColor(alert.severity).withOpacity(0.6),
                    ),
                  )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgriculturalAdviceSection() {
    if (_agriculturalData == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.agriculture, color: Colors.green[700]),
                const SizedBox(width: 8),
                Text(
                  'Conseils Agricoles',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildAdviceCard(
              'Conditions Actuelles',
              'Température: ${_currentWeather!.temperature.toStringAsFixed(1)}°C, Humidité: ${_currentWeather!.humidity.toStringAsFixed(1)}%',
              Icons.info,
              Colors.blue,
            ),
            const SizedBox(height: 8),
            _buildAdviceCard(
              'Irrigation',
              'Vitesse du vent: ${_currentWeather!.windSpeed.toStringAsFixed(1)} km/h, Direction: ${_currentWeather!.windDirection}',
              Icons.water_drop,
              Colors.cyan,
            ),
            const SizedBox(height: 8),
            _buildAdviceCard(
              'Risques de Maladies',
              'UV Index: ${_currentWeather!.uvIndex.toStringAsFixed(1)}, Pluie: ${_currentWeather!.rainfall.toStringAsFixed(1)} mm',
              Icons.warning,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdviceCard(String title, String advice, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color.withOpacity(0.8),
                  ),
                ),
                Text(
                  advice,
                  style: TextStyle(color: color.withOpacity(0.7)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastSection() {
    if (_forecast.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prévisions 7 Jours',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _forecast.length,
                itemBuilder: (context, index) {
                  final day = _forecast[index];
                  return _buildForecastDay(day);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastDay(services.WeatherForecast day) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${day.date.day}/${day.date.month}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Icon(
            _getWeatherIcon(day.condition),
            size: 24,
            color: Colors.blue[700],
          ),
          const SizedBox(height: 4),
          Text(
            '${day.maxTemperature.toStringAsFixed(0)}°C',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Text(
            '${day.rainfall.toStringAsFixed(0)}mm',
            style: TextStyle(fontSize: 10, color: Colors.blue[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection() {
    if (_forecast == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Graphiques Météo',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: SfCartesianChart(
                primaryXAxis: const CategoryAxis(),
                series: <LineSeries<services.WeatherForecast, String>>[
                  LineSeries<services.WeatherForecast, String>(
                    dataSource: _forecast,
                    xValueMapper: (services.WeatherForecast data, _) => '${data.date.day}/${data.date.month}',
                    yValueMapper: (services.WeatherForecast data, _) => data.maxTemperature,
                    name: 'Température',
                    color: Colors.red,
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                  LineSeries<services.WeatherForecast, String>(
                    dataSource: _forecast,
                    xValueMapper: (services.WeatherForecast data, _) => '${data.date.day}/${data.date.month}',
                    yValueMapper: (services.WeatherForecast data, _) => data.humidity,
                    name: 'Humidité',
                    color: Colors.blue,
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                ],
                legend: const Legend(isVisible: true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedMetricsSection() {
    if (_currentWeather == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Métriques Détaillées',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildMetricCard('Pression', '${_currentWeather!.pressure.toStringAsFixed(1)} hPa', Icons.speed),
                _buildMetricCard('Direction Vent', '${_currentWeather!.windDirection}°', Icons.navigation),
                _buildMetricCard('Visibilité', '${_currentWeather!.visibility.toStringAsFixed(1)} km', Icons.visibility),
                _buildMetricCard('UV Index', '${_currentWeather!.uvIndex.toStringAsFixed(1)}', Icons.wb_sunny),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
        ],
      ),
    );
  }

  IconData _getWeatherIcon(String condition) {
    switch (condition) {
      case 'pluvieux':
        return Icons.grain;
      case 'nuageux':
        return Icons.cloud;
      case 'humide':
        return Icons.water_drop;
      case 'chaud':
        return Icons.wb_sunny;
      case 'frais':
        return Icons.ac_unit;
      default:
        return Icons.wb_cloudy;
    }
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
