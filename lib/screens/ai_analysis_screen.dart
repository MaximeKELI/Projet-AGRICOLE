import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_agrigeo/services/plant_analysis_service.dart';
import 'package:geolocator/geolocator.dart';

class AIAnalysisScreen extends StatefulWidget {
  const AIAnalysisScreen({Key? key}) : super(key: key);

  @override
  _AIAnalysisScreenState createState() => _AIAnalysisScreenState();
}

class _AIAnalysisScreenState extends State<AIAnalysisScreen> {
  final PlantAnalysisService _plantService = PlantAnalysisService();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _questionController = TextEditingController();
  File? _image;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _analysisResult;
  List<Map<String, dynamic>> _conversation = [];

  Future<void> _pickImage({required ImageSource source}) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _image = File(image.path);
          _analysisResult = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la sélection de l\'image: $e';
      });
    }
  }

  Future<void> _analyzePlant() async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bytes = await _image!.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Obtenir la position actuelle
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final result = await _plantService.analyzePlant(
        imageBase64: base64Image,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      setState(() {
        _analysisResult = result;
      });
    } catch (e) {
      String errorMessage = 'Erreur lors de l\'analyse de la plante';
      
      if (e.toString().contains('201')) {
        errorMessage = 'Erreur 201: L\'image n\'a pas pu être analysée.\n\nConseils pour une meilleure photo:\n'
            '- Assurez-vous que la plante est bien éclairée\n'
            '- Prenez la photo de près (environ 30 cm)\n'
            '- Évitez les ombres sur la plante\n'
            '- Centrez bien la plante dans le cadre\n'
            '- Prenez la photo en mode paysage';
      } else if (e.toString().contains('401')) {
        errorMessage = 'Erreur 401: Problème d\'authentification. Veuillez réessayer plus tard.';
      } else if (e.toString().contains('429')) {
        errorMessage = 'Erreur 429: Trop de requêtes. Veuillez patienter quelques instants.';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Erreur 500: Problème serveur. Veuillez réessayer plus tard.';
      } else {
        errorMessage = 'Erreur: ${e.toString()}';
      }

      setState(() {
        _errorMessage = errorMessage;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _askQuestion() async {
    if (_analysisResult == null || _questionController.text.isEmpty) return;

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final accessToken = _analysisResult!['accessToken'];
      final response = await _plantService.askQuestion(
        accessToken: accessToken,
        question: _questionController.text,
        appName: 'AgriGéo',
        plantData: _analysisResult,
      );

      setState(() {
        _conversation = List<Map<String, dynamic>>.from(response['messages'] ?? []);
        _questionController.clear();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la conversation: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyse IA des Plantes'),
        backgroundColor: Colors.green[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_image != null)
              Material(
                elevation: 1.0,
                color: const Color(0xFF388E3C),
                shadowColor: const Color(0xFF388E3C),
                child: ClipPath(
                  clipper: ShapeBorderClipper(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Image.file(
                    _image!,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(source: ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Prendre une photo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(source: ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Choisir une photo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_image != null)
              ElevatedButton(
                onPressed: _isLoading ? null : _analyzePlant,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Analyser la plante'),
              ),
            if (_errorMessage != null)
              Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'Erreur d\'analyse',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
            if (_analysisResult != null) ...[
              SizedBox(height: 16),
              _buildAnalysisResult(),
              SizedBox(height: 16),
              _buildConversation(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisResult() {
    if (_analysisResult == null) return Container();

    final classification = _analysisResult!['classification'] ?? {};
    final isHealthy = _analysisResult!['isHealthy'] ?? 'Non déterminé';
    final healthProbability = _analysisResult!['healthProbability'] ?? 0.0;
    final diseases = _analysisResult!['diseases'] ?? [];
    final similarImages = _analysisResult!['similarImages'] ?? [];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Espèce de la plante
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Espèce identifiée',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    classification['name'] ?? 'Non identifié',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Confiance: ${((classification['probability'] ?? 0) * 100).toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),

          // État de santé
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'État de santé',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        isHealthy == 'En bonne santé' ? Icons.check_circle : Icons.warning,
                        color: isHealthy == 'En bonne santé' ? Colors.green : Colors.orange,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isHealthy,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: isHealthy == 'En bonne santé' ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Probabilité: ${(healthProbability * 100).toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),

          // Besoins en eau
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isHealthy == 'En bonne santé' ? Colors.blue[50] : Colors.green[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  isHealthy == 'En bonne santé' ? Icons.water_drop : Icons.water_drop_outlined,
                  color: isHealthy == 'En bonne santé' ? Colors.blue : Colors.green,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isHealthy == 'En bonne santé' 
                        ? 'La plante semble bien hydratée. Continuez à surveiller régulièrement.'
                        : 'La plante semble avoir besoin d\'eau. Vérifiez l\'humidité du sol et arrosez si nécessaire.',
                    style: TextStyle(
                      color: isHealthy == 'En bonne santé' ? Colors.blue[900] : Colors.green[900],
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (diseases.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Maladies détectées:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...diseases.map((disease) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${disease['name']} (${(disease['probability'] * 100).toStringAsFixed(1)}%)',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (disease['similarImages'] != null) ...[
                    const SizedBox(height: 4),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: (disease['similarImages'] as List).map<Widget>((image) => 
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Image.network(
                              image['url'] ?? '',
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => 
                                Container(
                                  height: 100,
                                  width: 100,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.error),
                                ),
                            ),
                          ),
                        ).toList(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                ],
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildConversation() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Posez une question sur la plante:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _questionController,
                    decoration: const InputDecoration(
                      hintText: 'Votre question...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isLoading ? null : _askQuestion,
                  icon: _isLoading
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.send),
                  tooltip: 'Envoyer la question',
                ),
              ],
            ),
            if (_conversation.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              ..._conversation.map((message) {
                final isQuestion = message['type'] == 'question';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isQuestion ? Icons.person : Icons.psychology,
                        color: isQuestion ? Colors.blue : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: isQuestion ? Colors.blue[50] : Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            message['content'] ?? '',
                            style: TextStyle(
                              color: isQuestion ? Colors.blue[900] : Colors.green[900],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }
}
