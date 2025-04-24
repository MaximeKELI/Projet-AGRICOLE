import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_agrigeo/screens/user_model.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
    // Cette méthode n'est plus nécessaire car nous n'utilisons plus SharedPreferences
    // Les paramètres seront gérés différemment
  }

  Future<void> _saveSettings() async {
    // Cette méthode n'est plus nécessaire car nous n'utilisons plus SharedPreferences
    // Les paramètres seront gérés différemment
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context);

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
                    // Implémenter le changement de thème ici
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
                      // Naviguer vers l'écran d'informations du compte
                    },
                  ),
                if (user.name != null) Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.help, color: Colors.blue),
                  title: Text('Aide et support'),
                  onTap: () {
                    // Naviguer vers l'écran d'aide
                  },
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.privacy_tip, color: Colors.green),
                  title: Text('Confidentialité et sécurité'),
                  onTap: () {
                    // Naviguer vers l'écran de confidentialité
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
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title:
                      Text('Déconnexion', style: TextStyle(color: Colors.red)),
                  onTap: () => _showLogoutConfirmation(context),
                ),
                if (user.name == null) Divider(height: 1),
                if (user.name == null)
                  ListTile(
                    leading: Icon(Icons.login, color: Colors.green),
                    title: Text('Connexion',
                        style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pushNamed(context, '/login');
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
                    context, '/', (route) => false);
              },
            ),
          ],
        );
      },
    );
  }
}
