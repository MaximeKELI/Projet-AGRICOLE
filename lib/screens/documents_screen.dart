import 'dart:io';
import 'package:flutter/material.dart';
import '../services/document_service.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:permission_handler/permission_handler.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({Key? key}) : super(key: key);

  @override
  _DocumentsScreenState createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  List<DocumentRecommendation> _documents = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedCategory = 'Tous';
  String _selectedRegion = 'Toutes';
  
  final List<String> _categories = ['Tous', 'technique', 'culture'];
  final List<String> _regions = ['Toutes', 'Centrale', 'Plateaux', 'Maritime', 'Kara', 'Savanes'];

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final documents = await DocumentService.getDocuments();
      setState(() {
        _documents = documents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de connexion au serveur. Vérifiez que le backend est démarré sur http://localhost:5000';
        _isLoading = false;
      });
      print('Erreur lors du chargement des documents: $e');
    }
  }

  List<DocumentRecommendation> get _filteredDocuments {
    return _documents.where((doc) {
      bool categoryMatch = _selectedCategory == 'Tous' || doc.category == _selectedCategory;
      bool regionMatch = _selectedRegion == 'Toutes' || doc.region == _selectedRegion;
      return categoryMatch && regionMatch;
    }).toList();
  }

  Future<void> _purchaseDocument(DocumentRecommendation document) async {
    // Vérifier si le document est gratuit (préfecture de Mô)
    if (DocumentService.isDocumentFree(document.id)) {
      // Accès direct pour le document gratuit
      _downloadDocument(document, 'free-user');
      return;
    }

    try {
      // Créer un utilisateur pour la démo
      final userId = await DocumentService.createUser(
        'Utilisateur Demo',
        'demo-${DateTime.now().millisecondsSinceEpoch}@example.com',
        '+22890123456',
      );

      // Simuler le paiement mobile money
      await DocumentService.simulateMobileMoneyPayment(
        userId: userId,
        documentId: document.id,
        phoneNumber: '+22890123456',
        amount: document.price,
      );

      _showSuccessDialog(document, userId);
    } catch (e) {
      _showErrorDialog('Erreur: $e');
    }
  }

  void _showSuccessDialog(DocumentRecommendation document, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Achat réussi !'),
          content: Text('Vous avez acheté "${document.title}" avec succès. Vous pouvez maintenant le télécharger.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _downloadDocument(document, userId);
              },
              child: Text('Télécharger'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Erreur'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _downloadDocument(DocumentRecommendation document, String userId) async {
    try {
      // Sur Linux, pas besoin de permissions de stockage
      if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
        final filePath = await DocumentService.downloadDocument(document.id, userId);
        _showPdfViewer(filePath, document.title);
      } else {
        // Vérifier les permissions sur mobile uniquement
        if (await Permission.storage.request().isGranted) {
          final filePath = await DocumentService.downloadDocument(document.id, userId);
          _showPdfViewer(filePath, document.title);
        } else {
          _showErrorDialog('Permission de stockage requise');
        }
      }
    } catch (e) {
      _showErrorDialog('Erreur lors du téléchargement: $e');
      print('Erreur de téléchargement: $e');
    }
  }

  void _showPdfViewer(String filePath, String title) {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      // Sur desktop, ouvrir avec l'application système par défaut
      _openWithSystemApp(filePath, title);
    } else {
      // Sur mobile, utiliser le viewer PDF intégré
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerScreen(filePath: filePath, title: title),
        ),
      );
    }
  }

  void _openWithSystemApp(String filePath, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('PDF téléchargé !'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Le document "$title" a été téléchargé avec succès.'),
              SizedBox(height: 10),
              Text('Fichier sauvegardé : $filePath'),
              SizedBox(height: 10),
              Text('Ouvrez le fichier avec votre lecteur PDF préféré.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Copier le chemin dans le presse-papiers
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Chemin copié : $filePath'),
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              child: Text('Copier le chemin'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Filtres
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Catégorie',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedRegion,
                        decoration: InputDecoration(
                          labelText: 'Région',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _regions.map((region) {
                          return DropdownMenuItem(
                            value: region,
                            child: Text(region),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRegion = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Liste des documents
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(_errorMessage!, style: TextStyle(color: Colors.grey)),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadDocuments,
                              child: Text('Réessayer'),
                            ),
                          ],
                        ),
                      )
                    : _filteredDocuments.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.description_outlined, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text('Aucun document trouvé', style: TextStyle(color: Colors.grey)),
                                SizedBox(height: 8),
                                Text('Ajustez les filtres pour voir plus de documents', 
                                     style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadDocuments,
                            child: ListView.builder(
                              padding: EdgeInsets.all(16),
                              itemCount: _filteredDocuments.length,
                              itemBuilder: (context, index) {
                                final document = _filteredDocuments[index];
                                return DocumentCard(
                                  document: document,
                                  onPurchase: () => _purchaseDocument(document),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class DocumentCard extends StatelessWidget {
  final DocumentRecommendation document;
  final VoidCallback onPurchase;

  const DocumentCard({
    Key? key,
    required this.document,
    required this.onPurchase,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.picture_as_pdf, color: Colors.red, size: 32),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${document.region} • ${document.prefecture}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    document.category,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              document.description,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prix',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      DocumentService.isDocumentFree(document.id) ? 'GRATUIT' : document.formattedPrice,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: DocumentService.isDocumentFree(document.id) ? Colors.green : Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: onPurchase,
                  icon: Icon(DocumentService.isDocumentFree(document.id) ? Icons.download : Icons.shopping_cart),
                  label: Text(DocumentService.isDocumentFree(document.id) ? 'Télécharger' : 'Acheter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DocumentService.isDocumentFree(document.id) ? Colors.green : Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PDFViewerScreen extends StatelessWidget {
  final String filePath;
  final String title;

  const PDFViewerScreen({
    Key? key,
    required this.filePath,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: PDFView(
        filePath: filePath,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: false,
        pageFling: false,
        onError: (error) {
          print('Erreur PDF: $error');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de l\'affichage du PDF: $error')),
          );
        },
        onPageError: (page, error) {
          print('Erreur page $page: $error');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur page $page: $error')),
          );
        },
      ),
    );
  }
}
