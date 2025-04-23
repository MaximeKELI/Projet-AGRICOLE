import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:app_agrigeo/utils/theme.dart';
import 'package:app_agrigeo/screens/about_us_screen.dart';
import 'package:app_agrigeo/screens/home_screen.dart';
import 'package:app_agrigeo/screens/settings_screen.dart';
import 'package:app_agrigeo/screens/user_model.dart';
import 'package:app_agrigeo/screens/map_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialisé avec succès");
  } catch (e) {
    print("Erreur Firebase: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserModel()),
      ],
      child: AgriGeoApp(),
    ),
  );
}

class AgriGeoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: '/register',
      routes: {
        '/register': (context) => RegistrationScreen(),
        '/about': (context) => AboutUsScreen(),
        '/main': (context) => MainScreen(),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _farmController = TextEditingController();
  final _locationController = TextEditingController();

  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _isFarmer = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Connexion' : 'Inscription'),
        backgroundColor: Colors.green[800],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(_isLogin
                ? "lib/assets/images/rgstimg.png"
                : "lib/assets/images/Registerimg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Logo ou titre
                Container(
                  margin: EdgeInsets.only(top: 20, bottom: 40),
                  alignment: Alignment.center,
                  child: Image.asset(
                    'lib/assets/images/logo.png',
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ),

                // Carte principale du formulaire
                Card(
                  color: Colors.white.withOpacity(0.85),
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Sélection Connexion/Inscription
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ChoiceChip(
                              label: Text('Connexion'),
                              selected: _isLogin,
                              selectedColor: Colors.green[800],
                              labelStyle: TextStyle(
                                color: _isLogin ? Colors.white : Colors.black,
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  _isLogin = true;
                                  _errorMessage = null;
                                });
                              },
                            ),
                            SizedBox(width: 20),
                            ChoiceChip(
                              label: Text('Inscription'),
                              selected: !_isLogin,
                              selectedColor: Colors.green[800],
                              labelStyle: TextStyle(
                                color: !_isLogin ? Colors.white : Colors.black,
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  _isLogin = false;
                                  _errorMessage = null;
                                });
                              },
                            ),
                          ],
                        ),

                        SizedBox(height: 30),

                        // Champ Email
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                            filled: true,
                            fillColor: Colors.white,
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

                        SizedBox(height: 20),

                        // Champ Mot de passe
                        TextFormField(
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
                                setState(
                                    () => _obscurePassword = !_obscurePassword);
                              },
                            ),
                            filled: true,
                            fillColor: Colors.white,
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

                        // Champs supplémentaires pour l'inscription
                        if (!_isLogin) ...[
                          SizedBox(height: 20),
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Nom complet *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ce champ est obligatoire';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              labelText: 'Téléphone',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.phone),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          SizedBox(height: 20),
                          DropdownButtonFormField<bool>(
                            value: _isFarmer,
                            decoration: InputDecoration(
                              labelText: 'Vous êtes...',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.people),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            items: [
                              DropdownMenuItem(
                                value: false,
                                child: Text('Visiteur'),
                              ),
                              DropdownMenuItem(
                                value: true,
                                child: Text('Agriculteur'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() => _isFarmer = value ?? false);
                            },
                          ),
                          if (_isFarmer) ...[
                            SizedBox(height: 20),
                            TextFormField(
                              controller: _farmController,
                              decoration: InputDecoration(
                                labelText: 'Nom de la ferme',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.agriculture),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                            SizedBox(height: 20),
                            TextFormField(
                              controller: _locationController,
                              decoration: InputDecoration(
                                labelText: 'Localisation',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.location_on),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                          ],
                        ],

                        SizedBox(height: 30),

                        // Message d'erreur
                        if (_errorMessage != null)
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.red, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        // Bouton principal
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[800],
                            minimumSize: Size(double.infinity, 50),
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => _submitForm(context),
                          child: Text(
                            _isLogin ? 'SE CONNECTER' : "S'INSCRIRE",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),

                        SizedBox(height: 20),

                        // Lien mot de passe oublié (seulement en mode connexion)
                        if (_isLogin)
                          TextButton(
                            onPressed: () {
                              // TODO: Implémenter la récupération de mot de passe
                            },
                            child: Text(
                              'Mot de passe oublié ?',
                              style: TextStyle(
                                color: Colors.green[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm(BuildContext context) async {
    setState(() => _errorMessage = null);

    if (_formKey.currentState!.validate()) {
      // Simulation de succès
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      setState(() {
        _errorMessage = 'Veuillez corriger les erreurs dans le formulaire';
      });
    }
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  // Définir les écrans dans l'ordre correspondant aux indices de la barre de navigation
  final List<Widget> _screens = [
    HomeScreen(),  // index 0
    MapScreen(),   // index 1
  ];

  void _onItemTapped(int index) {
    print('Navigation vers l\'écran: $index');
    print('Type de l\'écran: ${_screens[index].runtimeType}');
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void initState() {
    super.initState();
    print('Initialisation de MainScreen');
    print('Nombre d\'écrans: ${_screens.length}');
    print('Type du premier écran: ${_screens[0].runtimeType}');
    print('Type du deuxième écran: ${_screens[1].runtimeType}');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('Construction de MainScreen avec index: $_selectedIndex');
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Accueil' : 'Carte'),
        backgroundColor: Colors.green[800],
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            print('Changement de page vers: $index');
            print('Type de l\'écran: ${_screens[index].runtimeType}');
            setState(() => _selectedIndex = index);
          },
          children: _screens,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[800],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Carte'),
        ],
      ),
    );
  }
}
