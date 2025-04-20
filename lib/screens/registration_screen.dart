import 'package:flutter/material.dart';
import 'home_screen.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isRegisterMode = false;
  String? _errorMessage;

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isRegisterMode ? 'Inscription' : 'Connexion'),
        backgroundColor: Colors.green[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // ✅ Choix de mode
              DropdownButtonFormField<bool>(
                value: _isRegisterMode,
                decoration: InputDecoration(
                  labelText: 'Choisissez une action',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: false,
                    child: Text('Se connecter'),
                  ),
                  DropdownMenuItem(
                    value: true,
                    child: Text('S\'inscrire'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _isRegisterMode = value!;
                  });
                },
              ),

              const SizedBox(height: 20),

              // ✅ Nom complet si inscription
              if (_isRegisterMode)
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom complet *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_isRegisterMode &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Ce champ est obligatoire';
                    }
                    return null;
                  },
                ),

              if (_isRegisterMode) const SizedBox(height: 20),

              // ✅ Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ce champ est obligatoire';
                  }
                  if (!value.contains('@')) {
                    return 'Email invalide';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // ✅ Mot de passe
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Mot de passe *',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ce champ est obligatoire';
                  }
                  if (value.length < 6) {
                    return '6 caractères minimum';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // ✅ Confirmation mot de passe si inscription
              if (_isRegisterMode)
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le mot de passe *',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (_isRegisterMode && (value == null || value.isEmpty)) {
                      return 'Ce champ est obligatoire';
                    }
                    if (_isRegisterMode && value != _passwordController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                ),

              const SizedBox(height: 20),

              // ✅ Erreur affichée
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              // ✅ Bouton principal
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () => _submit(context),
                child: Text(_isRegisterMode ? 'S\'inscrire' : 'Se connecter'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    setState(() {
      _errorMessage = null;
    });

    if (_formKey.currentState!.validate()) {
      // ✅ Redirection simulée
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      setState(() {
        _errorMessage = 'Veuillez corriger les erreurs';
      });
    }
  }
}
