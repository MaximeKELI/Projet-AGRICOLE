import '../config/api_keys.dart';
import 'package:flutter/material.dart';
import '../services/isda_soil_service.dart';

/// Widget pour afficher l'analyse du sol avec les données iSDAsoil
class SoilAnalysisWidget extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String? cropType;

  const SoilAnalysisWidget({
    Key? key,
    required this.latitude,
    required this.longitude,
    this.cropType,
  }) : super(key: key);

  @override
  _SoilAnalysisWidgetState createState() => _SoilAnalysisWidgetState();
}

class _SoilAnalysisWidgetState extends State<SoilAnalysisWidget> {
  Map<String, dynamic>? _soilData;
  Map<String, dynamic>? _recommendations;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSoilData();
  }

  Future<void> _loadSoilData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Vérifier si les clés API sont configurées
      if (!ApiKeys.isApiKeyConfigured(ApiKeys.isdaSoilEmail) || 
          !ApiKeys.isApiKeyConfigured(ApiKeys.isdaSoilPassword)) {
        setState(() {
          _error = 'API iSDAsoil non configurée. Veuillez configurer vos identifiants dans les paramètres.';
          _isLoading = false;
        });
        return;
      }

      // Charger les données de sol
      final soilData = await IsdaSoilService.getSoilData(
        latitude: widget.latitude,
        longitude: widget.longitude,
      );

      // Charger les recommandations agricoles
      final recommendations = await IsdaSoilService.getAgriculturalRecommendations(
        latitude: widget.latitude,
        longitude: widget.longitude,
        cropType: widget.cropType,
      );

      setState(() {
        _soilData = soilData;
        _recommendations = recommendations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement des données: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.eco, color: Colors.green[700]),
                SizedBox(width: 8),
                Text(
                  'Analyse du Sol',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                Spacer(),
                if (_isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: _loadSoilData,
                    tooltip: 'Actualiser',
                  ),
              ],
            ),
            SizedBox(height: 16),
            if (_isLoading)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 8),
                      Text('Chargement des données de sol...'),
                    ],
                  ),
                ),
              )
            else if (_error != null)
              _buildErrorWidget()
            else if (_soilData != null)
              _buildSoilDataContent()
            else
              _buildNoDataWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    final bool isApiNotConfigured = _error!.contains('API iSDAsoil non configurée');
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isApiNotConfigured ? Colors.orange[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isApiNotConfigured ? Colors.orange[200]! : Colors.red[200]!),
      ),
      child: Column(
        children: [
          Icon(
            isApiNotConfigured ? Icons.settings : Icons.error_outline, 
            color: isApiNotConfigured ? Colors.orange[600] : Colors.red[600], 
            size: 32
          ),
          SizedBox(height: 8),
          Text(
            _error!,
            style: TextStyle(
              color: isApiNotConfigured ? Colors.orange[700] : Colors.red[700],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          if (isApiNotConfigured) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue[600], size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Comment configurer:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '1. Visitez https://api.isda-africa.com/isdasoil/v2\n'
                    '2. Créez un compte gratuit\n'
                    '3. Configurez vos identifiants dans les paramètres',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _loadSoilData,
                icon: Icon(Icons.refresh),
                label: Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isApiNotConfigured ? Colors.orange[600] : Colors.red[600],
                  foregroundColor: Colors.white,
                ),
              ),
              if (isApiNotConfigured)
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Navigate to settings
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Ouvrez les paramètres pour configurer l\'API'),
                        action: SnackBarAction(
                          label: 'Paramètres',
                          onPressed: () {
                            // TODO: Navigate to settings
                          },
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.settings),
                  label: Text('Paramètres'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataWidget() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(Icons.info_outline, color: Colors.grey[600], size: 32),
          SizedBox(height: 8),
          Text(
            'Aucune donnée de sol disponible',
            style: TextStyle(color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSoilDataContent() {
    final properties = _soilData!['properties'] as Map<String, dynamic>? ?? {};
    final recommendations = _recommendations ?? {};

    return Column(
      children: [
        // Propriétés du sol
        _buildSoilProperties(properties),
        SizedBox(height: 16),
        
        // Recommandations
        if (recommendations.isNotEmpty)
          _buildRecommendations(recommendations),
      ],
    );
  }

  Widget _buildSoilProperties(Map<String, dynamic> properties) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Propriétés du Sol',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: properties.entries.map((entry) {
            final property = entry.value as Map<String, dynamic>;
            return _buildPropertyChip(entry.key, property);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPropertyChip(String name, Map<String, dynamic> property) {
    final value = property['value'] as num?;
    final unit = property['unit'] as String? ?? '';
    final depth = property['depth'] as String? ?? '';

    if (value == null) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getPropertyColor(name, value),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getPropertyDisplayName(name),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            '${value.toStringAsFixed(1)}$unit',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          if (depth.isNotEmpty)
            Text(
              depth,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white70,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendations(Map<String, dynamic> recommendations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommandations',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.orange[700],
          ),
        ),
        SizedBox(height: 8),
        
        // Améliorations du sol
        if (recommendations['soil_improvements'] != null)
          _buildRecommendationSection(
            'Améliorations du Sol',
            recommendations['soil_improvements'],
            Icons.agriculture,
            Colors.green,
          ),
        
        // Aptitude aux cultures
        if (recommendations['crop_suitability'] != null)
          _buildRecommendationSection(
            'Aptitude aux Cultures',
            recommendations['crop_suitability'],
            Icons.eco,
            Colors.blue,
          ),
        
        // Recommandations d'engrais
        if (recommendations['fertilizer_recommendations'] != null)
          _buildRecommendationSection(
            'Engrais',
            recommendations['fertilizer_recommendations'],
            Icons.science,
            Colors.purple,
          ),
      ],
    );
  }

  Widget _buildRecommendationSection(
    String title,
    Map<String, dynamic> data,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color is MaterialColor ? color[700] : color, size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color is MaterialColor ? color[700] : color,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          ...data.entries.map((entry) {
            final value = entry.value as Map<String, dynamic>;
            return Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: EdgeInsets.only(top: 6, right: 8),
                    decoration: BoxDecoration(
                      color: color is MaterialColor ? color[700] : color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getRecommendationText(entry.key, value),
                          style: TextStyle(fontSize: 13),
                        ),
                        if (value['priority'] != null)
                          Container(
                            margin: EdgeInsets.only(top: 2),
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getPriorityColor(value['priority']),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getPriorityText(value['priority']),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  String _getPropertyDisplayName(String name) {
    switch (name) {
      case 'ph': return 'pH';
      case 'clay': return 'Argile';
      case 'sand': return 'Sable';
      case 'silt': return 'Limon';
      case 'organic_carbon': return 'C. Organique';
      case 'bulk_density': return 'Densité';
      case 'nitrogen': return 'Azote';
      case 'phosphorus': return 'Phosphore';
      case 'potassium': return 'Potassium';
      case 'calcium': return 'Calcium';
      case 'magnesium': return 'Magnésium';
      default: return name.toUpperCase();
    }
  }

  Color _getPropertyColor(String name, num value) {
    switch (name) {
      case 'ph':
        if (value < 5.5) return Colors.red[600]!;
        if (value > 7.5) return Colors.blue[600]!;
        return Colors.green[600]!;
      case 'organic_carbon':
        if (value < 1.0) return Colors.red[600]!;
        if (value > 3.0) return Colors.green[600]!;
        return Colors.orange[600]!;
      default:
        return Colors.blue[600]!;
    }
  }

  String _getRecommendationText(String key, Map<String, dynamic> value) {
    if (value['recommendation'] != null) {
      return value['recommendation'] as String;
    }
    if (value['reason'] != null) {
      return value['reason'] as String;
    }
    return key.replaceAll('_', ' ').toUpperCase();
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high': return Colors.red[600]!;
      case 'medium': return Colors.orange[600]!;
      case 'low': return Colors.green[600]!;
      default: return Colors.grey[600]!;
    }
  }

  String _getPriorityText(String priority) {
    switch (priority) {
      case 'high': return 'PRIORITÉ HAUTE';
      case 'medium': return 'PRIORITÉ MOYENNE';
      case 'low': return 'PRIORITÉ BASSE';
      default: return priority.toUpperCase();
    }
  }
}
