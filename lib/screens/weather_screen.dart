import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:geolocator/geolocator.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> with SingleTickerProviderStateMixin {
  final String _apiKey = '539b5e304cc283331365be92545f77bd';
  Map<String, dynamic>? _currentWeather;
  List<Map<String, dynamic>>? _forecast;
  bool _isLoading = true;
  String? _errorMessage;
  Position? _currentPosition;
  bool _isRefreshing = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    initializeDateFormatting('fr');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Les services de localisation sont désactivés.';
          _isLoading = false;
        });
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Les permissions de localisation sont refusées.';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Les permissions de localisation sont définitivement refusées.';
          _isLoading = false;
        });
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition();
      await _fetchWeatherData();
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la récupération de la position: $e';
        _isLoading = false;
      });
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  Future<void> _fetchWeatherData() async {
    if (_currentPosition == null) return;

    try {
      final currentWeatherResponse = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?'
          'lat=${_currentPosition!.latitude}&'
          'lon=${_currentPosition!.longitude}&'
          'appid=$_apiKey&'
          'units=metric&'
          'lang=fr',
        ),
      );

      final forecastResponse = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?'
          'lat=${_currentPosition!.latitude}&'
          'lon=${_currentPosition!.longitude}&'
          'appid=$_apiKey&'
          'units=metric&'
          'lang=fr',
        ),
      );

      if (currentWeatherResponse.statusCode == 200 && forecastResponse.statusCode == 200) {
        if (mounted) {
          setState(() {
            _currentWeather = json.decode(currentWeatherResponse.body);
            final forecastData = json.decode(forecastResponse.body);
            _forecast = _processForecastData(forecastData['list']);
            _isLoading = false;
            _errorMessage = null;
          });
        }
      } else {
        throw Exception('Erreur lors de la récupération des données météo');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur: $e';
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _processForecastData(List<dynamic> forecastList) {
    final Map<String, Map<String, dynamic>> dailyForecasts = {};
    
    for (var forecast in forecastList) {
      final date = DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000);
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      
      if (!dailyForecasts.containsKey(dateKey)) {
        dailyForecasts[dateKey] = {
          'date': date,
          'temp_min': forecast['main']['temp_min'],
          'temp_max': forecast['main']['temp_max'],
          'weather': forecast['weather'][0],
          'humidity': forecast['main']['humidity'],
          'wind_speed': forecast['wind']['speed'],
        };
      } else {
        final current = dailyForecasts[dateKey]!;
        if (forecast['main']['temp_min'] < current['temp_min']) {
          current['temp_min'] = forecast['main']['temp_min'];
        }
        if (forecast['main']['temp_max'] > current['temp_max']) {
          current['temp_max'] = forecast['main']['temp_max'];
        }
      }
    }
    
    return dailyForecasts.values.toList();
  }

  String _getWeatherIcon(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }

  String _generateWeatherPrompt() {
    if (_currentWeather == null) return '';

    final temp = _currentWeather!['main']['temp'];
    final humidity = _currentWeather!['main']['humidity'];
    final weather = _currentWeather!['weather'][0]['main'];
    final windSpeed = _currentWeather!['wind']['speed'];
    final location = _currentWeather!['name'];

    return '''
En tant qu'expert agricole, voici les conditions météorologiques actuelles à $location :

- Température : ${temp.round()}°C
- Humidité : $humidity%
- Conditions : $weather
- Vitesse du vent : $windSpeed km/h

En tant qu'expert agricole, quels conseils pratiques donneriez-vous aux agriculteurs dans ces conditions ? Considérez particulièrement :
1. L'impact sur les cultures
2. Les mesures préventives à prendre
3. Les recommandations d'irrigation
4. Les risques potentiels pour les cultures
5. Les actions à éviter

Merci de fournir des conseils spécifiques et pratiques adaptés à ces conditions météorologiques.
''';
  }

  Widget _buildAIChatButton() {
    return FloatingActionButton(
      onPressed: () {
        if (_currentWeather != null) {
          final prompt = _generateWeatherPrompt();
          // TODO: Implémenter l'appel à l'IA avec le prompt
          print('Prompt pour l\'IA: $prompt');
        }
      },
      child: const Icon(Icons.chat),
      tooltip: 'Discuter avec l\'IA',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Météo Agricole'),
        backgroundColor: Colors.green,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Aujourd\'hui'),
            Tab(text: 'Prévisions'),
            Tab(text: 'Conseils'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : () {
              setState(() {
                _isRefreshing = true;
              });
              _getCurrentLocation();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isRefreshing ? null : () {
                          setState(() {
                            _isRefreshing = true;
                          });
                          _getCurrentLocation();
                        },
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTodayTab(),
                    _buildForecastTab(),
                    _buildAdviceTab(),
                  ],
                ),
    );
  }

  Widget _buildTodayTab() {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _isRefreshing = true;
        });
        await _getCurrentLocation();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        '${_currentWeather!['name']}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Image.network(
                        _getWeatherIcon(_currentWeather!['weather'][0]['icon']),
                        width: 100,
                        height: 100,
                      ),
                      Text(
                        '${_currentWeather!['main']['temp']?.round()}°C',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      Text(
                        _currentWeather!['weather'][0]['description'],
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildWeatherDetail(
                            Icons.water_drop,
                            'Humidité',
                            '${_currentWeather!['main']['humidity']}%',
                          ),
                          _buildWeatherDetail(
                            Icons.air,
                            'Vent',
                            '${_currentWeather!['wind']['speed']} km/h',
                          ),
                          _buildWeatherDetail(
                            Icons.thermostat,
                            'Ressenti',
                            '${_currentWeather!['main']['feels_like']?.round()}°C',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForecastTab() {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _isRefreshing = true;
        });
        await _getCurrentLocation();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Prévisions sur 5 jours',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _forecast!.length,
                  itemBuilder: (context, index) {
                    final forecast = _forecast![index];
                    return Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 16),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                DateFormat('E', 'fr').format(forecast['date']),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Image.network(
                                _getWeatherIcon(forecast['weather']['icon']),
                                width: 50,
                                height: 50,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${forecast['temp_max']?.round()}°',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                '${forecast['temp_min']?.round()}°',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
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
    );
  }

  Widget _buildAdviceTab() {
    final temp = _currentWeather!['main']['temp'];
    final humidity = _currentWeather!['main']['humidity'];
    final weather = _currentWeather!['weather'][0]['main'];

    String advice = '';

    if (temp < 10) {
      advice = 'Température basse : Protégez vos cultures sensibles au froid.';
    } else if (temp > 30) {
      advice = 'Température élevée : Augmentez l\'irrigation et surveillez le stress hydrique.';
    }

    if (humidity > 80) {
      advice += '\n\nHumidité élevée : Surveillez les risques de maladies fongiques.';
    } else if (humidity < 40) {
      advice += '\n\nHumidité faible : Augmentez l\'irrigation si nécessaire.';
    }

    if (weather == 'Rain') {
      advice += '\n\nPluie prévue : Reportez les traitements phytosanitaires.';
    } else if (weather == 'Clear') {
      advice += '\n\nCiel dégagé : Bonne période pour les traitements.';
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _isRefreshing = true;
        });
        await _getCurrentLocation();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Conseils agricoles',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(advice),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
