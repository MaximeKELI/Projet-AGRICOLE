# Documentation Flutter - Application AgriGeo

## Table des matières
1. [Architecture de l'application](#architecture)
2. [Structure des fichiers](#structure)
3. [Composants principaux](#composants)
4. [Fonctionnalités](#fonctionnalités)
5. [Intégration avec Sentinel Hub](#sentinel-hub)
6. [Gestion de l'état](#etat)
7. [Navigation](#navigation)
8. [Widgets personnalisés](#widgets)
9. [Bonnes pratiques](#bonnes-pratiques)

## Architecture <a name="architecture"></a>

L'application suit une architecture basée sur les widgets Flutter avec une séparation claire des responsabilités :

- **UI Layer** : Gère l'interface utilisateur et les interactions
- **Business Logic** : Contient la logique métier et les calculs
- **Data Layer** : Gère les appels API et le stockage local

## Structure des fichiers <a name="structure"></a>

```
lib/
├── main.dart              # Point d'entrée de l'application
├── screens/               # Écrans principaux
│   ├── home_screen.dart   # Écran d'accueil
│   ├── map_screen.dart    # Écran de la carte
│   └── settings_screen.dart # Écran des paramètres
├── widgets/               # Widgets réutilisables
└── models/                # Modèles de données
```

## Composants principaux <a name="composants"></a>

### 1. Écran de la carte (MapScreen)

```dart
class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}
```

- **StatefulWidget** : Gère l'état de la carte
- **MapController** : Contrôle la carte et ses interactions
- **TileLayer** : Affiche les couches de la carte

### 2. Gestion de l'état

```dart
class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  List<LatLng> _polygonPoints = [];
  bool _isDrawing = false;
  String _selectedLayer = 'true_color';
  String? _accessToken;
  bool _isLoading = true;
}
```

- Utilisation de `setState` pour les mises à jour d'interface
- Variables d'état pour suivre l'état de l'application

## Fonctionnalités <a name="fonctionnalités"></a>

### 1. Dessin de polygones

```dart
void _onMapTap(TapPosition tapPosition, LatLng point) {
  if (_isDrawing) {
    setState(() {
      _polygonPoints.add(point);
    });
  }
}
```

- Capture des points de tap sur la carte
- Construction du polygone point par point
- Calcul de la surface en hectares

### 2. Calcul du NDVI

```dart
Future<void> _calculateNDVI() async {
  // Requête à Sentinel Hub
  final response = await http.post(
    Uri.parse('https://services.sentinel-hub.com/api/v1/process'),
    // Configuration de la requête
  );
  
  // Analyse des résultats
  final ndviValues = await _analyzeNDVIImage(base64Image);
  final averageNDVI = ndviValues.reduce((a, b) => a + b) / ndviValues.length;
}
```

- Utilisation des bandes spectrales B04 et B08
- Calcul de l'indice NDVI
- Affichage des résultats

## Intégration avec Sentinel Hub <a name="sentinel-hub"></a>

### 1. Authentification

```dart
Future<void> _getAccessToken() async {
  final response = await http.post(
    Uri.parse('https://services.sentinel-hub.com/oauth/token'),
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: {
      'grant_type': 'client_credentials',
      'client_id': _clientId,
      'client_secret': _clientSecret,
    },
  );
}
```

- Obtention du token d'accès
- Gestion des erreurs et des tentatives

### 2. Requêtes d'images

```dart
TileLayer(
  urlTemplate: 'https://services.sentinel-hub.com/ogc/wms/{instanceId}',
  additionalOptions: {
    'instanceId': _instanceId,
    'accessToken': _accessToken!,
  },
)
```

- Configuration des couches
- Paramètres d'image (résolution, qualité)
- Gestion du cache

## Gestion de l'état <a name="etat"></a>

### 1. Variables d'état

```dart
class _MapScreenState extends State<MapScreen> {
  // État de la carte
  final MapController _mapController = MapController();
  
  // État du dessin
  List<LatLng> _polygonPoints = [];
  bool _isDrawing = false;
  
  // État de l'authentification
  String? _accessToken;
  bool _isLoading = true;
}
```

### 2. Mise à jour de l'état

```dart
setState(() {
  _isLoading = true;
  _errorMessage = null;
});
```

## Navigation <a name="navigation"></a>

### 1. Navigation entre écrans

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const MapScreen(),
  ),
);
```

### 2. Retour en arrière

```dart
Navigator.pop(context);
```

## Widgets personnalisés <a name="widgets"></a>

### 1. Boîte de dialogue NDVI

```dart
void _showNDVIDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Analyse NDVI'),
      content: Column(
        children: [
          Text('NDVI: ${_averageNDVI.toStringAsFixed(3)}'),
          // Autres informations
        ],
      ),
    ),
  );
}
```

### 2. Sélecteur de couches

```dart
void _showLayerSelector(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) => Container(
      // Liste des couches disponibles
    ),
  );
}
```

## Bonnes pratiques <a name="bonnes-pratiques"></a>

1. **Séparation des responsabilités**
   - UI séparée de la logique métier
   - Widgets réutilisables
   - Gestion claire de l'état

2. **Gestion des erreurs**
   - Try-catch pour les opérations risquées
   - Messages d'erreur utilisateur
   - Logs de débogage

3. **Performance**
   - Optimisation des rebuilds
   - Gestion du cache
   - Chargement asynchrone

4. **Maintenabilité**
   - Code commenté
   - Nommage clair
   - Structure modulaire

## Exemples de code

### 1. Création d'un polygone

```dart
PolygonLayer(
  polygons: [
    Polygon(
      points: _polygonPoints,
      color: Colors.blue.withOpacity(0.3),
      borderColor: Colors.blue,
      borderStrokeWidth: 2,
    ),
  ],
)
```

### 2. Calcul de surface

```dart
double calculateArea(List<LatLng> points) {
  double area = 0.0;
  final earthRadius = 6378137.0;
  
  for (int i = 0; i < points.length; i++) {
    final j = (i + 1) % points.length;
    final lat1 = points[i].latitude * math.pi / 180;
    final lat2 = points[j].latitude * math.pi / 180;
    final lon1 = points[i].longitude * math.pi / 180;
    final lon2 = points[j].longitude * math.pi / 180;
    
    area += (lon2 - lon1) * (2 + math.sin(lat1) + math.sin(lat2));
  }
  
  return area.abs() / 10000; // Conversion en hectares
}
```

## Ressources utiles

1. [Documentation Flutter](https://flutter.dev/docs)
2. [Documentation Sentinel Hub](https://docs.sentinel-hub.com/api/latest/)
3. [Package flutter_map](https://pub.dev/packages/flutter_map)
4. [Package latlong2](https://pub.dev/packages/latlong2)

## Prochaines étapes

1. Amélioration de la gestion des erreurs
2. Optimisation des performances
3. Ajout de nouvelles fonctionnalités
4. Tests unitaires et d'intégration 