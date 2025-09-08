import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController _locationController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  
  String? _searchedLocation;
  List<String> _localConsumption = [];
  Map<String, dynamic>? _locationData;
  
  // Données de sol par région (simulées) - Villes togolaises et données mondiales diversifiées
  final Map<String, Map<String, dynamic>> _soilDatabase = {
    'lomé': {
      'soilType': 'Sol sableux côtier tropical',
      'ph': '6.8-7.5',
      'texture': 'Sableuse fine',
      'drainage': 'Excellent',
      'crops': ['Maïs', 'Tomate', 'Piment', 'Gombo', 'Patate douce'],
      'localConsumption': ['Maïs', 'Igname', 'Manioc', 'Tomate', 'Piment']
    },
    'sokodé': {
      'soilType': 'Sol ferralitique rouge',
      'ph': '5.5-6.2',
      'texture': 'Argilo-limoneuse',
      'drainage': 'Modéré à bon',
      'crops': ['Igname', 'Manioc', 'Coton', 'Sorgho', 'Arachide'],
      'localConsumption': ['Igname', 'Manioc', 'Mil', 'Sorgho', 'Haricot']
    },
    'kara': {
      'soilType': 'Sol de savane soudanienne',
      'ph': '6.0-6.8',
      'texture': 'Sablo-limoneuse',
      'drainage': 'Bon',
      'crops': ['Mil', 'Sorgho', 'Niébé', 'Sésame', 'Coton'],
      'localConsumption': ['Mil', 'Sorgho', 'Niébé', 'Arachide', 'Sésame']
    },
    'atakpamé': {
      'soilType': 'Sol volcanique fertile',
      'ph': '6.5-7.2',
      'texture': 'Limono-argileuse riche',
      'drainage': 'Excellent',
      'crops': ['Café', 'Cacao', 'Banane plantain', 'Taro', 'Avocat'],
      'localConsumption': ['Igname', 'Banane plantain', 'Taro', 'Café', 'Fruits']
    },
    'kpalimé': {
      'soilType': 'Sol forestier humide',
      'ph': '5.8-6.5',
      'texture': 'Argileuse humifère',
      'drainage': 'Modéré',
      'crops': ['Cacao', 'Café', 'Palmier à huile', 'Banane', 'Plantain'],
      'localConsumption': ['Banane plantain', 'Igname', 'Cacao', 'Huile de palme', 'Fruits']
    },
    'dapaong': {
      'soilType': 'Sol sahélien pauvre',
      'ph': '6.8-7.8',
      'texture': 'Sableuse grossière',
      'drainage': 'Très bon',
      'crops': ['Mil', 'Sorgho', 'Niébé', 'Pastèque', 'Oignon'],
      'localConsumption': ['Mil', 'Sorgho', 'Niébé', 'Oignon', 'Légumes secs']
    },
    'tsévié': {
      'soilType': 'Sol alluvial de plateau',
      'ph': '6.2-7.0',
      'texture': 'Limoneuse équilibrée',
      'drainage': 'Bon à modéré',
      'crops': ['Maïs', 'Manioc', 'Tomate', 'Gombo', 'Ananas'],
      'localConsumption': ['Maïs', 'Manioc', 'Tomate', 'Ananas', 'Légumes']
    },
    'aného': {
      'soilType': 'Sol lagunaire salé',
      'ph': '7.2-8.0',
      'texture': 'Sablo-argileuse saline',
      'drainage': 'Variable selon marées',
      'crops': ['Cocotier', 'Légumes résistants au sel', 'Patate douce', 'Manioc'],
      'localConsumption': ['Poisson', 'Coco', 'Manioc', 'Légumes', 'Fruits de mer']
    }
  };

  @override
  void initState() {
    super.initState();
  }

  // Recherche de localisation par nom
  Future<void> _searchLocation(String locationName) async {
    if (locationName.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez entrer un nom de lieu';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _locationData = null;
    });

    try {
      // Normaliser le nom de la localisation
      String normalizedLocation = locationName.toLowerCase().trim();
      
      // Rechercher dans la base de données locale
      Map<String, dynamic>? foundData;
      String? foundKey;
      
      for (String key in _soilDatabase.keys) {
        if (key.contains(normalizedLocation) || normalizedLocation.contains(key)) {
          foundData = _soilDatabase[key];
          foundKey = key;
          break;
        }
      }
      
      if (foundData != null) {
        setState(() {
          _searchedLocation = foundKey!.toUpperCase();
          _locationData = foundData;
          _localConsumption = List<String>.from(foundData!['localConsumption']);
          _isLoading = false;
        });
        _showLocationResults();
      } else {
        // Si pas trouvé localement, essayer une recherche générique
        await _performGenericSearch(locationName);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la recherche: $e';
        _isLoading = false;
      });
    }
  }
  
  Future<void> _performGenericSearch(String locationName) async {
    // Simulation d'une recherche générique avec des données par défaut
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _searchedLocation = locationName.toUpperCase();
      // Données génériques basées sur différents types de sols mondiaux
      final List<Map<String, dynamic>> globalSoilTypes = [
        {
          'soilType': 'Sol de prairie tempérée',
          'ph': '6.5-7.5',
          'texture': 'Limoneuse profonde',
          'drainage': 'Excellent',
          'crops': ['Blé', 'Maïs', 'Soja', 'Tournesol'],
          'localConsumption': ['Céréales', 'Légumineuses', 'Huiles végétales', 'Légumes']
        },
        {
          'soilType': 'Sol méditerranéen calcaire',
          'ph': '7.5-8.2',
          'texture': 'Argilo-calcaire',
          'drainage': 'Bon',
          'crops': ['Olivier', 'Vigne', 'Amandier', 'Lavande'],
          'localConsumption': ['Olives', 'Raisin', 'Amandes', 'Herbes aromatiques']
        },
        {
          'soilType': 'Sol de toundra acide',
          'ph': '4.5-5.5',
          'texture': 'Tourbeuse organique',
          'drainage': 'Faible',
          'crops': ['Avoine', 'Orge', 'Pomme de terre', 'Baies'],
          'localConsumption': ['Céréales rustiques', 'Tubercules', 'Baies sauvages', 'Champignons']
        },
        {
          'soilType': 'Sol de delta alluvial',
          'ph': '6.8-7.3',
          'texture': 'Limono-argileuse fertile',
          'drainage': 'Modéré à bon',
          'crops': ['Riz', 'Canne à sucre', 'Jute', 'Légumes'],
          'localConsumption': ['Riz', 'Sucre', 'Poisson', 'Légumes verts']
        },
        {
          'soilType': 'Sol de montagne rocailleux',
          'ph': '6.0-7.0',
          'texture': 'Graveleuse drainante',
          'drainage': 'Très bon',
          'crops': ['Quinoa', 'Pomme de terre', 'Orge', 'Légumineuses'],
          'localConsumption': ['Tubercules', 'Céréales d\'altitude', 'Légumineuses', 'Herbes']
        }
      ];
      
      final randomSoil = globalSoilTypes[DateTime.now().millisecondsSinceEpoch % globalSoilTypes.length];
      _locationData = randomSoil;
      _localConsumption = List<String>.from(_locationData!['localConsumption']);
      _isLoading = false;
    });
    _showLocationResults();
  }

  void _showLocationResults() {
    if (_locationData == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Analyse de $_searchedLocation',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildSoilInfoCard(),
                    const SizedBox(height: 16),
                    _buildCropsCard(),
                    const SizedBox(height: 16),
                    _buildLocalConsumptionCard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSoilInfoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.terrain, color: Colors.brown, size: 28),
                const SizedBox(width: 8),
                const Text(
                  'Type de Sol',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.brown.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _locationData!['soilType'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildSoilCharacteristic('pH', _locationData!['ph']),
                  _buildSoilCharacteristic('Texture', _locationData!['texture']),
                  _buildSoilCharacteristic('Drainage', _locationData!['drainage']),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoilCharacteristic(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildCropsCard() {
    final crops = List<String>.from(_locationData!['crops']);
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.agriculture, color: Colors.green, size: 28),
                const SizedBox(width: 8),
                const Text(
                  'Cultures Possibles',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Cultures adaptées à ce type de sol:',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: crops.map((crop) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Text(
                    crop,
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalConsumptionCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.restaurant, color: Colors.orange, size: 28),
                const SizedBox(width: 8),
                const Text(
                  'Consommation Locale',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Produits les plus consommés dans la région:',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _localConsumption.map((product) {
                final isRecommended = _locationData!['crops'].contains(product);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isRecommended ? Colors.orange.shade100 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isRecommended ? Colors.orange.shade300 : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isRecommended)
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.orange.shade700,
                        ),
                      if (isRecommended) const SizedBox(width: 4),
                      Text(
                        product,
                        style: TextStyle(
                          color: isRecommended ? Colors.orange.shade800 : Colors.grey.shade700,
                          fontWeight: isRecommended ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Les produits avec ✓ sont adaptés au sol local et correspondent à la demande',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleLocations() {
    final examples = [
      {'name': 'Lomé', 'description': 'Sol sableux côtier tropical'},
      {'name': 'Sokodé', 'description': 'Sol ferralitique rouge'},
      {'name': 'Kara', 'description': 'Sol de savane soudanienne'},
      {'name': 'Atakpamé', 'description': 'Sol volcanique fertile'},
      {'name': 'Kpalimé', 'description': 'Sol forestier humide'},
      {'name': 'Dapaong', 'description': 'Sol sahélien pauvre'},
    ];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Exemples de localisation',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cliquez sur un exemple pour voir l\'analyse',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: examples.map((example) {
                return InkWell(
                  onTap: () {
                    _locationController.text = example['name']!;
                    _searchLocation(example['name']!);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          example['name']!,
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          example['description']!,
                          style: TextStyle(
                            color: Colors.green.shade600,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recherche de Localisation'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Entrez le nom de votre localisation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ville, village, quartier, région...',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        hintText: 'Ex: Lomé, Sokodé, Kara, Atakpamé...',
                        prefixIcon: const Icon(Icons.location_on, color: Colors.green),
                        suffixIcon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : IconButton(
                                icon: const Icon(Icons.search),
                                onPressed: () => _searchLocation(_locationController.text),
                              ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.green, width: 2),
                        ),
                      ),
                      onSubmitted: _searchLocation,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () => _searchLocation(_locationController.text),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Recherche en cours...'),
                                ],
                              )
                            : const Text(
                                'Analyser cette localisation',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            _buildExampleLocations(),
          ],
        ),
      ),
    );
  }
}
