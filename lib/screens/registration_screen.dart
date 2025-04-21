import 'dart:async';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isRegisterMode = false;
  String? _errorMessage;

  late AnimationController _titleAnimationController;
  late AnimationController _formAnimationController;
  late Animation<double> _titleOpacityAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _formFadeAnimation;
  late Animation<Offset> _formSlideAnimation;

  String _displayedTitle = "";
  String _fullTitle = "";
  int _titleIndex = 0;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();

    _titleAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    _formAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _titleOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _titleAnimationController,
        curve: Interval(0.0, 0.5, curve: Curves.easeIn),
    );

    _titleSlideAnimation = Tween<Offset>(
      begin: Offset(0.0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _titleAnimationController,
        curve: Interval(0.3, 1.0, curve: Curves.easeOut),
    );

    _formFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _formAnimationController,
        curve: Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _formSlideAnimation = Tween<Offset>(
      begin: Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _formAnimationController,
        curve: Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _startTypingAnimation();
    _titleAnimationController.forward();
    _formAnimationController.forward();
  }

  void _startTypingAnimation() {
    _displayedTitle = "";
    _titleIndex = 0;
    _fullTitle = _isRegisterMode ? "Inscription" : "Connexion";
    _typingTimer?.cancel();
    _typingTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (_titleIndex < _fullTitle.length) {
        setState(() {
          _displayedTitle += _fullTitle[_titleIndex];
          _titleIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _toggleRegisterMode() {
    setState(() {
      _isRegisterMode = !_isRegisterMode;
      _startTypingAnimation();
      _formAnimationController.reset();
      _formAnimationController.forward();
    });
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _errorMessage = null;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      setState(() {
        _errorMessage = "Veuillez corriger les erreurs.";
      });
    }
  }

  @override
  void dispose() {
    _titleAnimationController.dispose();
    _formAnimationController.dispose();
    _typingTimer?.cancel();
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
        backgroundColor: Colors.green[800],
        elevation: 0,
        title: FadeTransition(
          opacity: _titleOpacityAnimation,
          child: SlideTransition(
            position: _titleSlideAnimation,
            child: Text(
              _displayedTitle,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("lib/assets/images/Registerimg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                FadeTransition(
                  opacity: _formFadeAnimation,
                  child: SlideTransition(
                    position: _formSlideAnimation,
                    child: Card(
                      color: Colors.white.withOpacity(0.9),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: DropdownButtonFormField<bool>(
                          value: _isRegisterMode,
                          decoration: InputDecoration(
                            labelText: 'Choisissez une action',
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.swap_horiz),
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
                            _toggleRegisterMode();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                if (_isRegisterMode)
                  FadeTransition(
                    opacity: _formFadeAnimation,
                    child: SlideTransition(
                      position: _formSlideAnimation,
                      child: TextFormField(
                        controller: _fullNameController,
                        decoration: InputDecoration(
                          labelText: 'Nom complet *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.9),
                        ),
                        validator: (value) {
                          if (_isRegisterMode &&
                              (value == null || value.trim().isEmpty)) {
                            return 'Ce champ est obligatoire';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                if (_isRegisterMode) SizedBox(height: 20),
                FadeTransition(
                  opacity: _formFadeAnimation,
                  child: SlideTransition(
                    position: _formSlideAnimation,
                    child: TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
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
                  ),
                ),
                SizedBox(height: 20),
                FadeTransition(
                  opacity: _formFadeAnimation,
                  child: SlideTransition(
                    position: _formSlideAnimation,
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
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
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
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
                  ),
                ),
                SizedBox(height: 20),
                if (_isRegisterMode)
                  FadeTransition(
                    opacity: _formFadeAnimation,
                    child: SlideTransition(
                      position: _formSlideAnimation,
                      child: TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirmer le mot de passe *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.9),
                        ),
                        validator: (value) {
                          if (_isRegisterMode &&
                              (value == null || value.isEmpty)) {
                            return 'Ce champ est obligatoire';
                          }
                          if (_isRegisterMode &&
                              value != _passwordController.text) {
                            return 'Les mots de passe ne correspondent pas';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                SizedBox(height: 20),
                if (_errorMessage != null)
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text(_isRegisterMode ? "S'inscrire" : "Se connecter"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                    padding: EdgeInsets.symmetric(vertical: 14),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}