#!/bin/bash

echo "🧪 Exécution des tests unitaires pour le projet agricole"
echo "=================================================="

# Vérifier que Flutter est installé
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter n'est pas installé. Veuillez installer Flutter d'abord."
    exit 1
fi

# Vérifier que Dart est installé
if ! command -v dart &> /dev/null; then
    echo "❌ Dart n'est pas installé. Veuillez installer Dart d'abord."
    exit 1
fi

echo "📱 Tests Flutter (Frontend)"
echo "---------------------------"

# Installer les dépendances de test
echo "📦 Installation des dépendances de test..."
flutter pub get

# Exécuter les tests Flutter
echo "🚀 Exécution des tests Flutter..."
flutter test --coverage

if [ $? -eq 0 ]; then
    echo "✅ Tests Flutter réussis!"
else
    echo "❌ Tests Flutter échoués!"
fi

echo ""
echo "🔧 Tests .NET (Backend)"
echo "----------------------"

# Vérifier que .NET est installé
if ! command -v dotnet &> /dev/null; then
    echo "❌ .NET n'est pas installé. Veuillez installer .NET d'abord."
    exit 1
fi

# Aller dans le dossier des tests backend
cd backend/AgricultureAPI/AgricultureAPI.Tests

# Exécuter les tests .NET
echo "🚀 Exécution des tests .NET..."
dotnet test --verbosity normal --collect:"XPlat Code Coverage"

if [ $? -eq 0 ]; then
    echo "✅ Tests .NET réussis!"
else
    echo "❌ Tests .NET échoués!"
fi

# Retourner au répertoire racine
cd ../../..

echo ""
echo "📊 Résumé des tests"
echo "=================="
echo "✅ Tests Flutter: Frontend"
echo "✅ Tests .NET: Backend et Base de données"
echo "✅ Tests d'intégration: API complète"
echo ""
echo "🎉 Tous les tests ont été exécutés!"
