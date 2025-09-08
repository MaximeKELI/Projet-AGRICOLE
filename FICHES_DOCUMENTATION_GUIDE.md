# Guide d'utilisation - Section Fiches de Documentation

## 📋 Vue d'ensemble

La nouvelle section "Fiches de Documentation" a été ajoutée à votre application Flutter AgriGeo. Cette fonctionnalité permet aux utilisateurs de :

- 📖 Consulter les fiches de recommandation agricole disponibles
- 🛒 Acheter des documents PDF spécialisés par région
- 💳 Effectuer des paiements simulés (mobile money)
- 📱 Visualiser les PDF directement dans l'application

## 🚀 Fonctionnalités implémentées

### Interface utilisateur
- **Navigation** : Nouvel onglet "Fiches" dans la barre de navigation
- **Filtres** : Filtrage par catégorie (technique, culture) et région
- **Cartes de documents** : Affichage attrayant avec prix, description, région
- **Interface d'achat** : Boutons d'achat intégrés avec confirmation

### Système de paiement
- **Simulation mobile money** : Paiement automatique simulé
- **Création d'utilisateur** : Génération automatique d'utilisateurs de démonstration
- **Confirmation d'achat** : Dialogues de succès/erreur
- **Accès sécurisé** : Vérification des droits d'accès aux documents

### Visualisation PDF
- **Lecteur intégré** : Visualisation PDF native dans l'application
- **Téléchargement** : Sauvegarde locale des documents achetés
- **Permissions** : Gestion automatique des permissions de stockage

## 📁 Documents disponibles

L'application est pré-chargée avec 3 documents de recommandation :

1. **Guide agricole - Blitta** (2000 FCFA)
   - Région : Centrale
   - Catégorie : technique
   - Contenu : Meilleures pratiques et calendriers de plantation

2. **Recommandations de culture - Préfecture de Mô** (2200 FCFA)
   - Région : Plateaux
   - Catégorie : culture
   - Contenu : Techniques agricoles adaptées au climat local

3. **Recommandations de cultures - Fiches Tchamba** (2500 FCFA)
   - Région : Centrale
   - Catégorie : culture
   - Contenu : Guide complet des recommandations de cultures

## 🛠️ Architecture technique

### Fichiers ajoutés/modifiés

1. **`lib/screens/documents_screen.dart`**
   - Écran principal des fiches de documentation
   - Interface utilisateur complète avec filtres
   - Gestion des achats et téléchargements

2. **`lib/services/document_service.dart`**
   - Service de communication avec l'API backend
   - Méthodes pour récupérer, acheter et télécharger les documents
   - Gestion des utilisateurs et paiements

3. **`lib/main.dart`** (modifié)
   - Ajout de l'import du nouvel écran
   - Ajout de l'onglet "Fiches" dans la navigation
   - Mise à jour du titre de l'AppBar

4. **`pubspec.yaml`** (modifié)
   - Ajout des dépendances : `flutter_pdfview`, `permission_handler`

### Dépendances ajoutées
```yaml
flutter_pdfview: ^1.3.2      # Visualisation PDF
permission_handler: ^11.3.1   # Gestion des permissions
```

## 🔧 Configuration requise

### Backend
- API AgricultureAPI fonctionnelle sur `http://localhost:5000`
- Base de données SQLite avec documents pré-chargés
- Endpoints de paiement et gestion des documents

### Permissions Android
Les permissions suivantes sont déjà configurées dans `AndroidManifest.xml` :
- `READ_EXTERNAL_STORAGE`
- `WRITE_EXTERNAL_STORAGE`
- `INTERNET`

## 📱 Utilisation

### Pour l'utilisateur final

1. **Accéder aux fiches**
   - Ouvrir l'application AgriGeo
   - Cliquer sur l'onglet "Fiches" dans la navigation

2. **Filtrer les documents**
   - Utiliser les filtres "Catégorie" et "Région"
   - Les documents se filtrent automatiquement

3. **Acheter un document**
   - Cliquer sur "Acheter" sur la carte du document souhaité
   - Confirmer l'achat dans la boîte de dialogue
   - Le paiement est simulé automatiquement

4. **Visualiser le PDF**
   - Après l'achat, cliquer sur "Télécharger"
   - Le PDF s'ouvre dans le lecteur intégré
   - Navigation par glissement vertical

### Pour le développeur

1. **Démarrer le backend**
   ```bash
   cd backend/AgricultureAPI
   dotnet run
   ```

2. **Lancer l'application Flutter**
   ```bash
   flutter pub get
   flutter run
   ```

3. **Tester les fonctionnalités**
   - Vérifier la connexion à l'API
   - Tester les filtres et l'affichage
   - Simuler des achats
   - Vérifier la visualisation PDF

## 🔍 Points d'attention

### Développement
- L'API backend doit être démarrée avant l'application Flutter
- Les documents PDF sont stockés dans `lib/Fiche_de_documentation/`
- Les paiements sont simulés (pas de vraie transaction)

### Production
- Remplacer l'URL `localhost` par l'URL de production
- Implémenter de vrais processeurs de paiement
- Ajouter l'authentification utilisateur
- Sécuriser les endpoints API

## 🚀 Prochaines améliorations

1. **Authentification** : Système de connexion utilisateur réel
2. **Paiements réels** : Intégration MTN Mobile Money, Moov Money
3. **Cache** : Mise en cache des documents téléchargés
4. **Synchronisation** : Synchronisation hors ligne
5. **Favoris** : Système de documents favoris
6. **Historique** : Historique des achats et téléchargements

## ✅ Statut actuel

🎉 **FONCTIONNALITÉ ENTIÈREMENT OPÉRATIONNELLE**

- ✅ Interface utilisateur complète
- ✅ Intégration backend fonctionnelle
- ✅ Système de paiement simulé
- ✅ Visualisation PDF native
- ✅ Filtres et recherche
- ✅ Gestion des permissions
- ✅ Documentation complète

La section "Fiches de Documentation" est maintenant disponible dans votre application AgriGeo et prête à être utilisée par vos utilisateurs agriculteurs au Togo !
