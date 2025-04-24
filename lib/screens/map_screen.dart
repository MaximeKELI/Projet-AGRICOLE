import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final List<LatLng> _polygonPoints = [];
  bool _isDrawing = false;
  String _selectedLayer = 'true_color';
  String? _errorMessage;
  String? _accessToken;
  bool _isLoading = true;
  bool _isInitialized = false;
  bool _showWebView = false;
  late WebViewController _webViewController;

  // Credentials Sentinel Hub
  final String _clientId = '177c8a67-3479-4bb7-aca2-60828ab3d919';
  final String _clientSecret = 'CGx9UfyFVYgrhhU8IMln4gXl0J90cZYl';
  final String _instanceId = '54d467e9-31a6-400d-9631-50da0f891982';
  final String _weatherApiKey = '539b5e304cc283331365be92545f77bd';
  Map<String, dynamic>? _currentWeather;
  bool _isLoadingWeather = false;
  bool _isLoadingNDVI = false;
  double? _averageNDVI;

  @override
  void initState() {
    super.initState();
    _getAccessToken();
  }

  Future<void> _getAccessToken() async {
    const maxRetries = 3;
    int retryCount = 0;
    
    while (retryCount < maxRetries) {
      try {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });

        print('Tentative de connexion à Sentinel Hub (${retryCount + 1}/$maxRetries)...');
        print('Client ID: $_clientId');
        print('Client Secret: $_clientSecret');

        // Vérifier la connectivité
        try {
          final result = await InternetAddress.lookup('services.sentinel-hub.com')
              .timeout(const Duration(seconds: 5));
          if (result.isEmpty || result[0].rawAddress.isEmpty) {
            throw Exception('Pas de connexion internet');
          }
        } catch (e) {
          print('Erreur de connexion: $e');
          if (retryCount < maxRetries - 1) {
            retryCount++;
            await Future.delayed(const Duration(seconds: 2));
            continue;
          }
          throw Exception('Erreur de connexion: $e');
        }

        final client = http.Client();
        try {
          final response = await client.post(
            Uri.parse('https://services.sentinel-hub.com/oauth/token'),
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
              'Accept': 'application/json',
              'Connection': 'keep-alive',
            },
            body: {
              'grant_type': 'client_credentials',
              'client_id': _clientId,
              'client_secret': _clientSecret,
            },
          ).timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException('La requête a expiré après 30 secondes');
            },
          );

          print('Réponse reçue - Code: ${response.statusCode}');
          print('Headers: ${response.headers}');
          print('Corps de la réponse: ${response.body}');

          if (response.statusCode == 200 || response.statusCode == 201) {
            final data = json.decode(response.body);
            final accessToken = data['access_token'] as String?;
            
            if (accessToken != null && accessToken.isNotEmpty) {
              print('Token d\'accès obtenu avec succès');
              setState(() {
                _accessToken = accessToken;
                _isLoading = false;
                _isInitialized = true;
              });
              return;
            } else {
              throw Exception('Token d\'accès invalide dans la réponse');
            }
          } else {
            final errorData = json.decode(response.body);
            throw Exception('Erreur ${response.statusCode}: ${errorData['error'] ?? 'Erreur inconnue'}');
          }
        } finally {
          client.close();
        }
      } catch (e) {
        print('Erreur détaillée lors de l\'authentification: $e');
        print('Stack trace: ${StackTrace.current}');
        
        if (retryCount < maxRetries - 1) {
          retryCount++;
          print('Nouvelle tentative dans 2 secondes...');
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }
        
        setState(() {
          _errorMessage = 'Erreur de connexion après $maxRetries tentatives: $e';
          _isLoading = false;
          _isInitialized = false;
        });
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showWebView) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('EO Browser'),
          backgroundColor: Colors.green,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                _showWebView = false;
              });
            },
          ),
        ),
        body: WebViewWidget(
          controller: WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..loadRequest(Uri.parse('https://apps.sentinel-hub.com/eo-browser/'))
            ..setNavigationDelegate(
              NavigationDelegate(
                onPageFinished: (String url) {
                  print('Page chargée: $url');
                },
              ),
            ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _isInitialized = false;
                _errorMessage = null;
              });
              _getAccessToken();
            },
          ),
          IconButton(
            icon: const Icon(Icons.web),
            onPressed: () {
              setState(() {
                _showWebView = true;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: const LatLng(7.5399, -5.5471), // Centre sur la Côte d'Ivoire
              zoom: 8.0,
              maxZoom: 18.0,
              minZoom: 3.0,
              rotation: 0.0,
              onTap: (_, point) {
                if (_isDrawing) {
                  setState(() {
                    _polygonPoints.add(point);
                  });
                }
              },
            ),
            children: [
              // Couche de base OpenStreetMap
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
                backgroundColor: Colors.white,
                maxZoom: 18,
                minZoom: 3,
              ),
              // Couche Sentinel Hub
              if (_isInitialized && _accessToken != null)
                TileLayer(
                  urlTemplate: 'https://services.sentinel-hub.com/ogc/wms/{instanceId}?'
                      'REQUEST=GetMap'
                      '&SERVICE=WMS'
                      '&VERSION=1.3.0'
                      '&LAYERS={layer}'
                      '&WIDTH=512'  // Augmentation de la résolution
                      '&HEIGHT=512' // Augmentation de la résolution
                      '&CRS=EPSG:3857'
                      '&BBOX={bbox}'
                      '&TIME=2023-01-01/2023-12-31'
                      '&FORMAT=image/png'
                      '&TRANSPARENT=true'
                      '&access_token={accessToken}'
                      '&SHOWLOGO=false'
                      '&MAXCC=10'   // Réduction de la couverture nuageuse maximale
                      '&PREVIEW=1'  // Meilleure qualité
                      '&UPDATED_FROM=2023-01-01T00:00:00Z'
                      '&UPDATED_TO=2023-12-31T23:59:59Z',
                  additionalOptions: {
                    'instanceId': _instanceId,
                    'layer': _selectedLayer,
                    'accessToken': _accessToken!,
                  },
                  tileProvider: SentinelTileProvider(),
                  backgroundColor: Colors.transparent,
                  maxZoom: 18,
                  minZoom: 3,
                ),
              // Contrôles de zoom et rotation
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton(
                        heroTag: 'zoom_in',
                        onPressed: () {
                          _mapController.move(_mapController.center, _mapController.zoom + 1);
                        },
                        child: const Icon(Icons.add),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        heroTag: 'zoom_out',
                        onPressed: () {
                          _mapController.move(_mapController.center, _mapController.zoom - 1);
                        },
                        child: const Icon(Icons.remove),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        heroTag: 'rotate',
                        onPressed: () {
                          _mapController.rotate(_mapController.rotation + 15);
                        },
                        child: const Icon(Icons.rotate_right),
                      ),
                    ],
                  ),
                ),
              ),
              // Couche de polygone (si dessin en cours)
              if (_polygonPoints.isNotEmpty)
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: _polygonPoints,
                      color: Colors.blue.withOpacity(0.3),
                      borderColor: Colors.blue,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
            ],
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (_errorMessage != null)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _errorMessage = null;
                        });
                        _getAccessToken();
                      },
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'draw',
                  onPressed: () {
                    setState(() {
                      _isDrawing = !_isDrawing;
                      if (!_isDrawing) {
                        _polygonPoints.clear();
                      }
                    });
                  },
                  backgroundColor: _isDrawing ? Colors.red : Colors.blue,
                  child: Icon(_isDrawing ? Icons.stop : Icons.edit),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'layers',
                  onPressed: () {
                    _showLayerSelector(context);
                  },
                  child: const Icon(Icons.layers),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'coordinates',
                  onPressed: () {
                    _showPolygonCoordinates(context);
                  },
                  child: const Icon(Icons.location_on),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'weather',
                  onPressed: () {
                    if (_polygonPoints.isNotEmpty) {
                      _fetchWeatherData(_polygonPoints.first);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Veuillez d\'abord dessiner un polygone')),
                      );
                    }
                  },
                  child: const Icon(Icons.cloud),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'ndvi',
                  onPressed: () {
                    if (_polygonPoints.isNotEmpty) {
                      _calculateNDVI();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Veuillez d\'abord dessiner un polygone')),
                      );
                    }
                  },
                  child: const Icon(Icons.grass),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLayerSelector(BuildContext context) {
    final layers = {
      '1_TRUE_COLOR': {
        'name': 'Couleur Naturelle',
        'description': 'Vue en couleurs naturelles',
        'icon': Icons.color_lens,
      },
      '3_NDVI': {
        'name': 'NDVI',
        'description': 'Indice de végétation',
        'icon': Icons.grass,
      },
      '5-MOISTURE-INDEX1': {
        'name': 'Humidité',
        'description': 'Niveau d\'humidité du sol',
        'icon': Icons.water_drop,
      },
    };

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Sélectionner une couche',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...layers.entries.map((entry) {
              final isSelected = _selectedLayer == entry.key;
              return ListTile(
                onTap: () async {
                  setState(() {
                    _selectedLayer = entry.key;
                    _isLoading = true;
                  });
                  Navigator.pop(context);
                  
                  // Rafraîchir le token si nécessaire
                  try {
                    await _getAccessToken();
                  } catch (e) {
                    print('Erreur lors du rafraîchissement du token: $e');
                  }
                  
                  // Forcer le rafraîchissement de la carte
                  _mapController.move(_mapController.center, _mapController.zoom);
                  setState(() {
                    _isLoading = false;
                  });
                },
                leading: Icon(
                  entry.value['icon'] as IconData,
                  color: isSelected ? Colors.blue : Colors.grey,
                ),
                title: Text(
                  entry.value['name'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.blue : Colors.black,
                  ),
                ),
                subtitle: Text(
                  entry.value['description'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(
                        Icons.check_circle,
                        color: Colors.blue,
                      )
                    : null,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _showPolygonCoordinates(BuildContext context) {
    if (_polygonPoints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun polygone dessiné')),
      );
      return;
    }

    // Calcul de la surface en hectares
    double calculateArea(List<LatLng> points) {
      if (points.length < 3) return 0.0;
      
      double area = 0.0;
      final earthRadius = 6378137.0; // Rayon de la Terre en mètres
      
      for (int i = 0; i < points.length; i++) {
        final j = (i + 1) % points.length;
        final lat1 = points[i].latitude * math.pi / 180;
        final lat2 = points[j].latitude * math.pi / 180;
        final lon1 = points[i].longitude * math.pi / 180;
        final lon2 = points[j].longitude * math.pi / 180;
        
        area += (lon2 - lon1) * (2 + math.sin(lat1) + math.sin(lat2));
      }
      
      area = area * earthRadius * earthRadius / 2;
      return area.abs() / 10000; // Conversion en hectares
    }

    final surface = calculateArea(_polygonPoints);

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Informations du polygone',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'Surface: ${surface.toStringAsFixed(2)} hectares',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(surface * 2.47105).toStringAsFixed(2)} acres',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Coordonnées des points',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _polygonPoints.length,
                itemBuilder: (context, index) {
                  final point = _polygonPoints[index];
                  return ListTile(
                    title: Text('Point ${index + 1}'),
                    subtitle: Text(
                      'Latitude: ${point.latitude.toStringAsFixed(6)}\n'
                      'Longitude: ${point.longitude.toStringAsFixed(6)}',
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

  Future<void> _fetchWeatherData(LatLng point) async {
    setState(() {
      _isLoadingWeather = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?'
          'lat=${point.latitude}&'
          'lon=${point.longitude}&'
          'appid=$_weatherApiKey&'
          'units=metric&'
          'lang=fr',
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          _currentWeather = json.decode(response.body);
          _isLoadingWeather = false;
        });
        _showWeatherDialog(context);
      } else {
        throw Exception('Erreur lors de la récupération des données météo');
      }
    } catch (e) {
      setState(() {
        _isLoadingWeather = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  void _showWeatherDialog(BuildContext context) {
    if (_currentWeather == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Météo actuelle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              'https://openweathermap.org/img/wn/${_currentWeather!['weather'][0]['icon']}@2x.png',
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 16),
            Text(
              '${_currentWeather!['main']['temp']?.round()}°C',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _currentWeather!['weather'][0]['description'],
              style: const TextStyle(fontSize: 16),
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
              ],
            ),
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

  Future<void> _calculateNDVI() async {
    if (_polygonPoints.isEmpty || _accessToken == null) return;

    setState(() {
      _isLoadingNDVI = true;
    });

    try {
      // Construire la requête pour l'API Sentinel Hub avec la couche NDVI
      final response = await http.post(
        Uri.parse('https://services.sentinel-hub.com/api/v1/process'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode({
          'input': {
            'bounds': {
              'bbox': [
                _polygonPoints.map((p) => p.longitude).reduce(math.min),
                _polygonPoints.map((p) => p.latitude).reduce(math.min),
                _polygonPoints.map((p) => p.longitude).reduce(math.max),
                _polygonPoints.map((p) => p.latitude).reduce(math.max),
              ],
              'properties': {
                'crs': 'http://www.opengis.net/def/crs/OGC/1.3/CRS84'
              }
            },
            'data': [{
              'type': 'sentinel-2-l2a',
              'dataFilter': {
                'timeRange': {
                  'from': '2023-01-01T00:00:00Z',
                  'to': '2023-12-31T23:59:59Z'
                },
                'maxCloudCoverage': 10
              }
            }]
          },
          'output': {
            'width': 512,
            'height': 512,
            'responses': [{
              'identifier': 'default',
              'format': {
                'type': 'image/png'
              }
            }]
          },
          'evalscript': '''
            //VERSION=3
            function setup() {
              return {
                input: ["B04", "B08"],
                output: { bands: 1 }
              };
            }
            
            function evaluatePixel(sample) {
              let ndvi = (sample.B08 - sample.B04) / (sample.B08 + sample.B04);
              return [ndvi];
            }
          '''
        }),
      );

      if (response.statusCode == 200) {
        // Convertir l'image en base64
        final imageBytes = response.bodyBytes;
        final base64Image = base64Encode(imageBytes);

        // Analyser l'image NDVI pour obtenir la valeur moyenne
        final ndviValues = await _analyzeNDVIImage(base64Image);
        final averageNDVI = ndviValues.reduce((a, b) => a + b) / ndviValues.length;

        setState(() {
          _averageNDVI = averageNDVI;
          _isLoadingNDVI = false;
        });

        _showNDVIDialog(context);
      } else {
        throw Exception('Erreur lors du calcul du NDVI: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoadingNDVI = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Future<List<double>> _analyzeNDVIImage(String base64Image) async {
    try {
      // Convertir l'image base64 en bytes
      final imageBytes = base64Decode(base64Image);
      
      // Analyser les pixels de l'image pour extraire les valeurs NDVI
      // Les valeurs NDVI sont normalisées entre -1 et 1
      final pixels = imageBytes.length ~/ 4; // 4 bytes par pixel (RGBA)
      final ndviValues = <double>[];
      
      for (var i = 0; i < pixels; i++) {
        // Extraire la valeur NDVI du pixel (stockée dans le canal rouge)
        final ndviValue = imageBytes[i * 4] / 255.0 * 2 - 1;
        ndviValues.add(ndviValue);
      }
      
      return ndviValues;
    } catch (e) {
      print('Erreur lors de l\'analyse de l\'image NDVI: $e');
      return [0.0];
    }
  }

  void _showNDVIDialog(BuildContext context) {
    if (_averageNDVI == null) return;

    String ndviStatus;
    Color statusColor;
    
    if (_averageNDVI! > 0.6) {
      ndviStatus = 'Végétation très dense et saine';
      statusColor = Colors.green;
    } else if (_averageNDVI! > 0.3) {
      ndviStatus = 'Végétation modérée';
      statusColor = Colors.lightGreen;
    } else if (_averageNDVI! > 0) {
      ndviStatus = 'Végétation clairsemée';
      statusColor = Colors.yellow;
    } else {
      ndviStatus = 'Pas de végétation';
      statusColor = Colors.red;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Analyse NDVI'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'NDVI moyen: ${_averageNDVI!.toStringAsFixed(3)}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                ndviStatus,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Interprétation NDVI:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '- > 0.6: Végétation très dense et saine\n'
              '- 0.3 à 0.6: Végétation modérée\n'
              '- 0 à 0.3: Végétation clairsemée\n'
              '- < 0: Pas de végétation',
              style: TextStyle(fontSize: 12),
            ),
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

class SentinelTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coords, TileLayer options) {
    final additionalOptions = options.additionalOptions;
    final instanceId = additionalOptions['instanceId'] as String;
    final layer = additionalOptions['layer'] as String;
    final accessToken = additionalOptions['accessToken'] as String;

    final bbox = _getBoundingBox(coords, options.tileSize.toInt());
    
    // Construire l'URL avec les paramètres corrects
    final url = Uri.parse('https://services.sentinel-hub.com/ogc/wms/$instanceId')
        .replace(queryParameters: {
          'REQUEST': 'GetMap',
          'SERVICE': 'WMS',
          'VERSION': '1.3.0',
          'LAYERS': layer,
          'WIDTH': '256',
          'HEIGHT': '256',
          'CRS': 'EPSG:3857',
          'BBOX': bbox,
          'TIME': '2023-01-01/2023-12-31',
          'FORMAT': 'image/png',
          'TRANSPARENT': 'true',
          'access_token': accessToken,
          'SHOWLOGO': 'false',
          'MAXCC': '20',
          'PREVIEW': '2',
          'UPDATED_FROM': '2023-01-01T00:00:00Z',
          'UPDATED_TO': '2023-12-31T23:59:59Z'
        }).toString();

    print('URL de la tuile: $url');
    print('Couche sélectionnée: $layer');
    print('BBOX: $bbox');
    print('Zoom level: ${coords.z}');
    print('Tile coordinates: x=${coords.x}, y=${coords.y}');

    return NetworkImage(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'image/png',
      },
    )..resolve(ImageConfiguration()).addListener(
        ImageStreamListener(
          (ImageInfo info, bool _) {
            print('Image chargée avec succès pour la couche $layer');
            print('Dimensions de l\'image: ${info.image.width}x${info.image.height}');
          },
          onError: (dynamic error, StackTrace? stackTrace) {
            print('Erreur lors du chargement de l\'image: $error');
            print('Stack trace: $stackTrace');
            if (error.toString().contains('401') || error.toString().contains('403')) {
              print('Erreur d\'autorisation - Token peut-être expiré');
            }
          },
        ),
      );
  }

  String _getBoundingBox(TileCoordinates coords, int tileSize) {
    final n = math.pow(2, coords.z);
    final x = coords.x;
    final y = coords.y;

    final left = (x / n) * 360 - 180;
    final top = math.atan(math.exp(math.pi * (1 - 2 * y / n))) * 180 / math.pi;
    final right = ((x + 1) / n) * 360 - 180;
    final bottom = math.atan(math.exp(math.pi * (1 - 2 * (y + 1) / n))) * 180 / math.pi;

    return '$left,$bottom,$right,$top';
  }
} 