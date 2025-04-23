import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  Position? _currentPosition;
  Map<String, dynamic>? _currentWeather;
  final String _apiKey = '539b5e304cc283331365be92545f77bd';
  late final GenerativeModel _model;
  late final ChatSession _chat;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey: 'AIzaSyARGvtS9V-730kplWB1Q1wfXDrzcnGwv7w', // Remplacez par votre clé API Gemini
    );
    _chat = _model.startChat();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _addMessage('Les services de localisation sont désactivés.', false);
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _addMessage('Les permissions de localisation sont refusées.', false);
          return;
        }
      }

      _currentPosition = await Geolocator.getCurrentPosition();
      await _fetchWeatherData();
    } catch (e) {
      _addMessage('Erreur lors de la récupération de la position: $e', false);
    }
  }

  Future<void> _fetchWeatherData() async {
    if (_currentPosition == null) return;

    try {
      final response = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?'
          'lat=${_currentPosition!.latitude}&'
          'lon=${_currentPosition!.longitude}&'
          'appid=$_apiKey&'
          'units=metric&'
          'lang=fr',
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          _currentWeather = json.decode(response.body);
        });
        _generateInitialPrompt();
      } else {
        _addMessage('Erreur lors de la récupération des données météo', false);
      }
    } catch (e) {
      _addMessage('Erreur: $e', false);
    }
  }

  void _generateInitialPrompt() {
    if (_currentWeather == null) return;

    final temp = _currentWeather!['main']['temp'];
    final humidity = _currentWeather!['main']['humidity'];
    final weather = _currentWeather!['weather'][0]['main'];
    final windSpeed = _currentWeather!['wind']['speed'];
    final location = _currentWeather!['name'];

    final prompt = '''
En tant qu'expert agricole, voici les conditions météorologiques actuelles à $location :

- Température : ${temp.round()}°C
- Humidité : $humidity%
- Conditions : $weather
- Vitesse du vent : $windSpeed km/h

En tant qu'expert agricole, donnez des conseils PRÉCIS et CONCIS (maximum 3-4 lignes) pour les agriculteurs dans ces conditions. Concentrez-vous sur :
1. L'action principale à entreprendre
2. Le risque principal à surveiller
3. Une recommandation d'irrigation si nécessaire

Répondez de manière directe et pratique, sans introduction ni conclusion.
''';

    _sendMessage(prompt, showInChat: false);
  }

  void _addMessage(String text, bool isUser) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: isUser));
    });
  }

  Future<void> _sendMessage(String text, {bool showInChat = true}) async {
    if (text.trim().isEmpty) return;

    if (showInChat) {
      setState(() {
        _isLoading = true;
        _addMessage(text, true);
      });
    } else {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final response = await _chat.sendMessage(
        Content.text(text),
      );
      
      final responseText = response.text ?? 'Désolé, je n\'ai pas pu générer de réponse.';
      _addMessage(responseText, false);
    } catch (e) {
      _addMessage('Erreur lors de la communication avec l\'IA: $e', false);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistant Agricole IA'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatBubble(
                  message: message.text,
                  isUser: message.isUser,
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Tapez votre message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final message = _messageController.text;
                    _messageController.clear();
                    _sendMessage(message);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.isUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.green : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
