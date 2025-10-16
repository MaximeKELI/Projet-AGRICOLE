import '../config/api_keys.dart';
import 'package:flutter/material.dart';
import '../services/api_diagnostic_service.dart';

/// Écran de diagnostic des APIs
/// Affiche l'état de toutes les APIs configurées
class ApiDiagnosticScreen extends StatefulWidget {
  const ApiDiagnosticScreen({Key? key}) : super(key: key);

  @override
  State<ApiDiagnosticScreen> createState() => _ApiDiagnosticScreenState();
}

class _ApiDiagnosticScreenState extends State<ApiDiagnosticScreen> {
  Map<String, dynamic>? _diagnosticData;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _runDiagnostic();
  }

  Future<void> _runDiagnostic() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final diagnostic = await ApiDiagnosticService.performFullDiagnostic();
      setState(() {
        _diagnosticData = diagnostic;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostic des APIs'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _runDiagnostic,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget()
              : _diagnosticData != null
                  ? _buildDiagnosticWidget()
                  : const Center(child: Text('Aucune donnée disponible')),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Erreur lors du diagnostic',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Erreur inconnue',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _runDiagnostic,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticWidget() {
    final overallScore = _diagnosticData!['overallScore'] as double;
    final status = _diagnosticData!['status'] as String;
    final results = _diagnosticData!['results'] as Map<String, dynamic>;
    final recommendations = _diagnosticData!['recommendations'] as List<dynamic>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverallStatusCard(overallScore, status),
          const SizedBox(height: 16),
          _buildCategoryCards(results),
          const SizedBox(height: 16),
          _buildRecommendationsCard(recommendations),
          const SizedBox(height: 16),
          _buildApiKeysStatusCard(),
        ],
      ),
    );
  }

  Widget _buildOverallStatusCard(double score, String status) {
    Color statusColor;
    IconData statusIcon;
    
    switch (status) {
      case 'EXCELLENT':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'GOOD':
        statusColor = Colors.blue;
        statusIcon = Icons.info;
        break;
      case 'FAIR':
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        break;
      default:
        statusColor = Colors.red;
        statusIcon = Icons.error;
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'État Global des APIs',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        'Score: ${score.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: score / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCards(Map<String, dynamic> results) {
    return Column(
      children: results.entries.map((entry) {
        final category = entry.key;
        final data = entry.value as Map<String, dynamic>;
        final score = data['score'] as double;
        final apis = data['apis'] as Map<String, dynamic>;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            title: Text(
              _getCategoryTitle(category),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Text('Score: ${score.toStringAsFixed(1)}%'),
            leading: CircleAvatar(
              backgroundColor: _getScoreColor(score),
              child: Text(
                score.toStringAsFixed(0),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: apis.entries.map((apiEntry) {
                    final apiName = apiEntry.key;
                    final apiData = apiEntry.value as Map<String, dynamic>;
                    return _buildApiStatusTile(apiName, apiData);
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildApiStatusTile(String apiName, Map<String, dynamic> apiData) {
    final status = apiData['status'] as String;
    final message = apiData['message'] as String;
    final score = apiData['score'] as int? ?? 0;

    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'WORKING':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'ERROR':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      case 'NOT_CONFIGURED':
        statusColor = Colors.orange;
        statusIcon = Icons.settings;
        break;
      case 'NOT_IMPLEMENTED':
        statusColor = Colors.blue;
        statusIcon = Icons.build;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return ListTile(
      leading: Icon(statusIcon, color: statusColor),
      title: Text(
        apiName.toUpperCase(),
        style: Theme.of(context).textTheme.titleSmall,
      ),
      subtitle: Text(message),
      trailing: score > 0 ? Text('$score%') : null,
      dense: true,
    );
  }

  Widget _buildRecommendationsCard(List<dynamic> recommendations) {
    if (recommendations.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[300]),
              const SizedBox(width: 12),
              Text(
                'Toutes les APIs sont correctement configurées',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber[600]),
                const SizedBox(width: 12),
                Text(
                  'Recommandations',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...recommendations.map((rec) {
              final recommendation = rec as Map<String, dynamic>;
              final priority = recommendation['priority'] as String;
              final title = recommendation['title'] as String;
              final description = recommendation['description'] as String;
              
              Color priorityColor;
              IconData priorityIcon;
              
              switch (priority) {
                case 'HIGH':
                  priorityColor = Colors.red;
                  priorityIcon = Icons.priority_high;
                  break;
                case 'MEDIUM':
                  priorityColor = Colors.orange;
                  priorityIcon = Icons.warning;
                  break;
                case 'LOW':
                  priorityColor = Colors.blue;
                  priorityIcon = Icons.info;
                  break;
                default:
                  priorityColor = Colors.grey;
                  priorityIcon = Icons.help;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: priorityColor.withOpacity(0.1),
                child: ListTile(
                  leading: Icon(priorityIcon, color: priorityColor),
                  title: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  subtitle: Text(description),
                  dense: true,
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildApiKeysStatusCard() {
    final configuredKeys = ApiKeys.getConfiguredKeys();
    final totalKeys = configuredKeys.length;
    final configuredCount = configuredKeys.values.where((configured) => configured).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.key, color: Colors.blue[600]),
                const SizedBox(width: 12),
                Text(
                  'Clés API Configurées',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('$configuredCount / $totalKeys clés configurées'),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: configuredCount / totalKeys,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                configuredCount / totalKeys > 0.5 ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 12),
            ...configuredKeys.entries.map((entry) {
              final keyName = entry.key;
              final isConfigured = entry.value;
              
              return ListTile(
                leading: Icon(
                  isConfigured ? Icons.check_circle : Icons.cancel,
                  color: isConfigured ? Colors.green : Colors.red,
                ),
                title: Text(keyName),
                subtitle: Text(isConfigured ? 'Configurée' : 'Non configurée'),
                dense: true,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  String _getCategoryTitle(String category) {
    switch (category) {
      case 'weather':
        return 'APIs Météorologiques';
      case 'soil':
        return 'APIs de Données de Sol';
      case 'agricultural':
        return 'APIs Agricoles';
      case 'satellite':
        return 'APIs Satellitaires';
      case 'government':
        return 'APIs Gouvernementales';
      default:
        return category.toUpperCase();
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
}

