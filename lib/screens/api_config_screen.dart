import '../config/api_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_diagnostic_service.dart';

/// Écran de configuration des clés API
class ApiConfigScreen extends StatefulWidget {
  @override
  _ApiConfigScreenState createState() => _ApiConfigScreenState();
}

class _ApiConfigScreenState extends State<ApiConfigScreen> {
  final Map<String, TextEditingController> _controllers = {};
  bool _isLoading = false;
  Map<String, dynamic>? _diagnosticResults;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadDiagnostic();
  }

  void _initializeControllers() {
    _controllers['openweathermap'] = TextEditingController(text: ApiKeys.openWeatherMapApiKey);
    _controllers['weatherapi'] = TextEditingController(text: ApiKeys.weatherApiApiKey);
    _controllers['weatherbit'] = TextEditingController(text: ApiKeys.weatherBitApiKey);
    _controllers['isdasoil_email'] = TextEditingController(text: ApiKeys.isdaSoilEmail);
    _controllers['isdasoil_password'] = TextEditingController(text: ApiKeys.isdaSoilPassword);
    _controllers['soilgrids'] = TextEditingController(text: ApiKeys.soilGridsApiKey);
    _controllers['solgrid'] = TextEditingController(text: ApiKeys.solGridApiKey);
    _controllers['sentinelhub'] = TextEditingController(text: ApiKeys.sentinelHubApiKey);
    _controllers['sentinelhub_client_id'] = TextEditingController(text: ApiKeys.sentinelHubClientId);
    _controllers['sentinelhub_client_secret'] = TextEditingController(text: ApiKeys.sentinelHubClientSecret);
    _controllers['nasa'] = TextEditingController(text: ApiKeys.nasaEarthdataApiKey);
    _controllers['fao'] = TextEditingController(text: ApiKeys.faoApiKey);
    _controllers['togo'] = TextEditingController(text: ApiKeys.togoAgriculturalApiKey);
  }

  Future<void> _loadDiagnostic() async {
    setState(() => _isLoading = true);
    try {
      final results = await ApiDiagnosticService.diagnoseAllApis();
      setState(() {
        _diagnosticResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur diagnostic: $e')),
      );
    }
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuration des Clés API'),
        backgroundColor: Colors.green[800],
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadDiagnostic,
            tooltip: 'Actualiser le diagnostic',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  SizedBox(height: 20),
                  _buildDiagnosticSummary(),
                  SizedBox(height: 20),
                  _buildApiSections(),
                  SizedBox(height: 20),
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.api, color: Colors.green[800]),
                SizedBox(width: 8),
                Text(
                  'Configuration des Clés API',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Configurez vos clés API pour utiliser des données réelles au lieu de simulations.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 12),
            Text(
              '📋 Consultez le guide: API_KEYS_SETUP_GUIDE.md',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.blue[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosticSummary() {
    if (_diagnosticResults == null) return SizedBox.shrink();

    final summary = _diagnosticResults!['summary'] as Map<String, dynamic>;
    final workingApis = summary['working_apis'] as int;
    final totalApis = summary['total_apis'] as int;
    final successRate = summary['success_rate'] as int;

    return Card(
      color: successRate > 50 ? Colors.green[50] : Colors.orange[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  successRate > 50 ? Icons.check_circle : Icons.warning,
                  color: successRate > 50 ? Colors.green : Colors.orange,
                ),
                SizedBox(width: 8),
                Text(
                  'État des APIs',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Fonctionnelles', workingApis, Colors.green),
                _buildStatItem('Total', totalApis, Colors.blue),
                _buildStatItem('Taux de succès', successRate, Colors.purple, '%'),
              ],
            ),
            SizedBox(height: 12),
            Text(
              summary['recommendation'] as String,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color, [String suffix = '']) {
    return Column(
      children: [
        Text(
          '$value$suffix',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildApiSections() {
    return Column(
      children: [
        _buildApiSection(
          '🌤️ Services Météo',
          [
            _buildApiField('OpenWeatherMap', 'openweathermap', 'API météo principale'),
            _buildApiField('WeatherAPI', 'weatherapi', 'API météo de backup'),
            _buildApiField('WeatherBit', 'weatherbit', 'API météo alternative'),
          ],
        ),
        SizedBox(height: 16),
        _buildApiSection(
          '🌍 Données de Sol',
          [
            _buildApiField('iSDAsoil - Email', 'isdasoil_email', 'Email pour iSDAsoil (Afrique)'),
            _buildApiField('iSDAsoil - Mot de passe', 'isdasoil_password', 'Mot de passe pour iSDAsoil'),
            _buildApiField('ISRIC SoilGrids', 'soilgrids', 'Données de sol mondiales'),
            _buildApiField('SolGRID', 'solgrid', 'Données de sol alternatives'),
          ],
        ),
        SizedBox(height: 16),
        _buildApiSection(
          '🛰️ Imagerie Satellitaire',
          [
            _buildApiField('Sentinel Hub - Clé', 'sentinelhub', 'Clé API Sentinel Hub'),
            _buildApiField('Sentinel Hub - Client ID', 'sentinelhub_client_id', 'Client ID OAuth'),
            _buildApiField('Sentinel Hub - Client Secret', 'sentinelhub_client_secret', 'Client Secret OAuth'),
            _buildApiField('NASA Earthdata', 'nasa', 'Données satellitaires NASA'),
          ],
        ),
        SizedBox(height: 16),
        _buildApiSection(
          '🌾 Données Agricoles',
          [
            _buildApiField('FAO', 'fao', 'Données agricoles FAO'),
            _buildApiField('Togo Agricultural', 'togo', 'Données agricoles du Togo'),
          ],
        ),
      ],
    );
  }

  Widget _buildApiSection(String title, List<Widget> fields) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            SizedBox(height: 12),
            ...fields,
          ],
        ),
      ),
    );
  }

  Widget _buildApiField(String label, String key, String description) {
    final controller = _controllers[key]!;
    final isConfigured = ApiKeys.isApiKeyConfigured(controller.text);
    
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                isConfigured ? Icons.check_circle : Icons.cancel,
                color: isConfigured ? Colors.green : Colors.red,
                size: 20,
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Entrez votre clé API...',
              border: OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(Icons.copy),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: controller.text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Clé copiée dans le presse-papiers')),
                  );
                },
              ),
            ),
            obscureText: true,
            onChanged: (value) {
              setState(() {}); // Rebuild to update status icon
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _loadDiagnostic,
            icon: Icon(Icons.refresh),
            label: Text('Tester les APIs'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _saveConfiguration,
            icon: Icon(Icons.save),
            label: Text('Sauvegarder'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  void _saveConfiguration() {
    // Note: Dans une vraie application, vous devriez sauvegarder ces clés
    // de manière sécurisée (variables d'environnement, stockage chiffré, etc.)
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Configuration sauvegardée (simulation)'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Afficher un avertissement de sécurité
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('⚠️ Sécurité'),
        content: Text(
          'IMPORTANT: Dans une vraie application, ne stockez jamais les clés API '
          'dans le code source. Utilisez des variables d\'environnement ou un '
          'stockage sécurisé.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Compris'),
          ),
        ],
      ),
    );
  }
}
