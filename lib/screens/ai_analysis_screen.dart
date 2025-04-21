import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:app_agrigeo/screens/user_model.dart';

class AIAnalysisScreen extends StatefulWidget {
  @override
  _AIAnalysisScreenState createState() => _AIAnalysisScreenState();
}

class _AIAnalysisScreenState extends State<AIAnalysisScreen> {
  bool _isScanning = false;
  File? _selectedImage;
  String? _analysisResult;
  String? _errorMessage;
  double _analysisProgress = 0.0;

  final ImagePicker _picker = ImagePicker();
  final String _openAIKey = 'YOUR_OPENAI_API_KEY';

  @override
  void dispose() {
    _selectedImage?.delete();
    super.dispose();
  }

  Future<void> _getImage(ImageSource source) async {
    setState(() {
      _isScanning = true;
      _analysisProgress = 0.0;
      _analysisResult = null;
      _errorMessage = null;
    });

    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) {
        setState(() => _isScanning = false);
        return;
      }

      setState(() => _selectedImage = File(image.path));
      await _simulateProgress();
      await _analyzeImageWithOpenAI(File(image.path));
    } catch (e) {
      setState(() {
        _isScanning = false;
        _errorMessage = "Erreur lors de l'analyse: ${e.toString()}";
      });
      _showErrorDialog(_errorMessage!);
    }
  }

  Future<void> _simulateProgress() async {
    const totalSteps = 20;
    for (int i = 0; i <= totalSteps; i++) {
      await Future.delayed(Duration(milliseconds: 150));
      setState(() {
        _analysisProgress = i / totalSteps;
      });
    }
  }

  Future<void> _analyzeImageWithOpenAI(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAIKey',
        },
        body: jsonEncode({
          "model": "gpt-4-vision-preview",
          "messages": [
            {
              "role": "user",
              "content": [
                {
                  "type": "text",
                  "text":
                      "Analyse cette image de culture agricole. Détecte les maladies, évalue la santé des plantes, et donne des conseils d'entretien. Sois précis et technique. Structure la réponse avec : 1. Diagnostic (maladies, carences) 2. Niveau de gravité (1-5) 3. Recommandations de traitement 4. Actions préventives"
                },
                {
                  "type": "image_url",
                  "image_url": {"url": "data:image/jpeg;base64,$base64Image"}
                }
              ]
            }
          ],
          "max_tokens": 1500
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final analysis = jsonResponse['choices'][0]['message']['content'];

        setState(() {
          _isScanning = false;
          _analysisResult = _formatAnalysisResult(analysis);
        });
      } else {
        throw Exception(
            'Erreur API: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception("Échec de l'analyse: $e");
    }
  }

  String _formatAnalysisResult(String rawResult) {
    return rawResult
        .replaceAll('1. ', '\n1. ')
        .replaceAll('2. ', '\n\n2. ')
        .replaceAll('3. ', '\n\n3. ')
        .replaceAll('4. ', '\n\n4. ');
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Erreur", style: TextStyle(color: Colors.red)),
        content: SingleChildScrollView(child: Text(message)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK", style: TextStyle(color: Colors.green[800])),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAnalysisReport() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Rapport sauvegardé avec succès"),
        backgroundColor: Colors.green[800],
      ),
    );
  }

  void _showDetailedAnalysis(BuildContext context) {
    final user = Provider.of<UserModel>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Analyse Complète",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Divider(),
                SizedBox(height: 10),
                if (_selectedImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_selectedImage!, fit: BoxFit.cover),
                  ),
                SizedBox(height: 20),
                if (user.isFarmer && user.farmName != null)
                  Text(
                    "Ferme: ${user.farmName}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                SizedBox(height: 20),
                Text(
                  _analysisResult ?? '',
                  style: TextStyle(fontSize: 15),
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("Fermer",
                        style: TextStyle(color: Colors.green[800])),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Analyse IA des Cultures"),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("Comment ça marche ?"),
                content: Text(
                  "Prenez une photo ou sélectionnez une image depuis votre galerie pour obtenir une analyse détaillée de l'état de vos cultures grâce à notre intelligence artificielle spécialisée.",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("Compris"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green[50]!,
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_selectedImage != null && !_isScanning)
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_selectedImage!, fit: BoxFit.cover),
                  ),
                )
              else if (_isScanning)
                Column(
                  children: [
                    Lottie.asset("assets/animations/ai_scanning.json",
                        height: 120),
                    SizedBox(height: 20),
                    LinearProgressIndicator(value: _analysisProgress),
                  ],
                ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _getImage(ImageSource.camera),
                icon: Icon(Icons.camera_alt),
                label: Text("Prendre une photo"),
              ),
              ElevatedButton.icon(
                onPressed: () => _getImage(ImageSource.gallery),
                icon: Icon(Icons.photo_library),
                label: Text("Choisir depuis la galerie"),
              ),
              if (_analysisResult != null) ...[
                SizedBox(height: 20),
                _buildAnalysisResult(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisResult() {
    return Column(
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.analytics, color: Colors.green[800]),
                    SizedBox(width: 8),
                    Text(
                      "Résultats d'analyse:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.green[800],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(_analysisResult ?? '', style: TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () => _showDetailedAnalysis(context),
              icon: Icon(Icons.open_in_full),
              label: Text("Détails"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
                foregroundColor: Colors.white,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _saveAnalysisReport,
              icon: Icon(Icons.save),
              label: Text("Sauvegarder"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
