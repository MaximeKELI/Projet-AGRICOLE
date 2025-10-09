import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_agrigeo/screens/user_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'Français';
  final List<String> _languages = ['Français', 'English', 'Español'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String savedLanguage = prefs.getString('language') ?? 'Français';
      
      // Vérifier que la langue sauvegardée existe dans la liste
      if (!_languages.contains(savedLanguage)) {
        savedLanguage = 'Français';
      }
      
      setState(() {
        _darkMode = prefs.getBool('darkMode') ?? false;
        _notificationsEnabled = prefs.getBool('notifications') ?? true;
        _selectedLanguage = savedLanguage;
      });
    } catch (e) {
      print('Erreur lors du chargement des paramètres: $e');
      setState(() {
        _selectedLanguage = 'Français';
      });
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('darkMode', _darkMode);
      await prefs.setBool('notifications', _notificationsEnabled);
      await prefs.setString('language', _selectedLanguage);

      // Notifier le changement de thème
      if (mounted) {
        final themeNotifier =
            Provider.of<ThemeNotifier>(context, listen: false);
        themeNotifier.setTheme(_darkMode ? ThemeMode.dark : ThemeMode.light);
      }
    } catch (e) {
      print('Erreur lors de la sauvegarde des paramètres: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Paramètres'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          if (user.name != null) _buildUserSection(user),
          SizedBox(height: 20),

          // Section Apparence
          _buildSectionHeader('Apparence'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text('Mode Sombre'),
                  value: _darkMode,
                  onChanged: (value) {
                    setState(() => _darkMode = value);
                    _saveSettings();
                  },
                ),
                Divider(height: 1),
                ListTile(
                  title: Text('Langue'),
                  trailing: DropdownButton<String>(
                    value: _selectedLanguage,
                    underline: SizedBox(),
                    items: _languages.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() => _selectedLanguage = newValue);
                        _saveSettings();
                        _showLanguageChangeSnackbar();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Section Notifications
          _buildSectionHeader('Notifications'),
          Card(
            child: SwitchListTile(
              title: Text('Activer les notifications'),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() => _notificationsEnabled = value);
                _saveSettings();
                _showNotificationSnackbar(value);
              },
            ),
          ),
          SizedBox(height: 20),

          // Section Compte
          _buildSectionHeader('Compte'),
          Card(
            child: Column(
              children: [
                if (user.name != null)
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Informations du compte'),
                    onTap: () {
                      _showAccountInfo(context, user);
                    },
                  ),
                if (user.name != null) Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.help, color: Colors.blue),
                  title: Text('Aide et support'),
                  onTap: () {
                    _showHelpSupport(context);
                  },
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.privacy_tip, color: Colors.green),
                  title: Text('Confidentialité et sécurité'),
                  onTap: () {
                    _showPrivacySecurity(context);
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Section Actions
          _buildSectionHeader('Actions'),
          Card(
            child: Column(
              children: [
                if (user.name != null)
                  ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: Text('Déconnexion',
                        style: TextStyle(color: Colors.red)),
                    onTap: () => _showLogoutConfirmation(context),
                  ),
                if (user.name != null) Divider(height: 1),
                ListTile(
                  leading: Icon(
                    user.name != null ? Icons.login : Icons.login,
                    color: user.name != null ? Colors.blue : Colors.green,
                  ),
                  title: Text(
                    user.name != null ? 'Changer de compte' : 'Connexion',
                    style: TextStyle(
                      color: user.name != null ? Colors.blue : Colors.green,
                    ),
                  ),
                  onTap: () {
                    if (user.name != null) {
                      _showSwitchAccount(context);
                    } else {
                      Navigator.pushNamed(context, '/register');
                    }
                  },
                ),
              ],
            ),
          ),
        ].animate(interval: 50.ms).fadeIn(duration: 300.ms),
      ),
    );
  }

  Widget _buildUserSection(UserModel user) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.green[800],
              child: Text(
                user.name!.substring(0, 1).toUpperCase(),
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name!,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    user.email ?? 'Email non disponible',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Compte vérifié',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmer la déconnexion'),
          content: Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
          actions: [
            TextButton(
              child: Text('Annuler'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Déconnexion', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Provider.of<UserModel>(context, listen: false).logout();
                Navigator.of(context).pop();
                Navigator.pushNamedAndRemoveUntil(
                    context, '/register', (route) => false);
              },
            ),
          ],
        );
      },
    );
  }

  void _showLanguageChangeSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('La langue sera changée au redémarrage de l\'application'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showNotificationSnackbar(bool enabled) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            enabled ? 'Notifications activées' : 'Notifications désactivées'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showAccountInfo(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Informations du compte'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nom: ${user.name ?? 'Non renseigné'}'),
            SizedBox(height: 8),
            Text('Email: ${user.email ?? 'Non renseigné'}'),
            SizedBox(height: 8),
            Text('Statut: Compte vérifié'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showHelpSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Aide et support'),
        content: Text('Pour toute assistance, veuillez contacter:\n'
            '• Email: support@agrigeo.com\n'
            '• Téléphone: +33 1 23 45 67 89\n'
            '• Horaires: Lun-Ven 9h-18h'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showPrivacySecurity(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confidentialité et sécurité'),
        content: Text('Vos données sont sécurisées et cryptées.\n\n'
            'Nous respectons votre vie privée et n\'utilisons vos données '
            'que pour améliorer votre expérience avec AgriGéo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showSwitchAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Changer de compte'),
        content: Text('Vous allez être déconnecté pour pouvoir vous connecter '
            'avec un autre compte.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showLogoutConfirmation(context);
            },
            child: Text('Continuer'),
          ),
        ],
      ),
    );
  }
}

// Classe pour gérer le changement de thème
class ThemeNotifier with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void setTheme(ThemeMode themeMode) {
    _themeMode = themeMode;
    notifyListeners();
  }
}
