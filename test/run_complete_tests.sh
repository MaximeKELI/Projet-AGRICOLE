#!/bin/bash

echo "🧪 Exécution des tests unitaires complets - Frontend, Backend et Base de données"
echo "================================================================================"

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variables pour le suivi des résultats
FRONTEND_SUCCESS=false
BACKEND_SUCCESS=false
DATABASE_SUCCESS=false
INTEGRATION_SUCCESS=false

# Fonction pour afficher les résultats
print_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
        return 0
    else
        echo -e "${RED}❌ $2${NC}"
        return 1
    fi
}

# Fonction pour exécuter les tests avec gestion d'erreur
run_test_suite() {
    local test_name="$1"
    local command="$2"
    
    echo -e "\n${BLUE}🔧 Exécution: $test_name${NC}"
    echo "Commande: $command"
    echo "----------------------------------------"
    
    eval $command
    local result=$?
    
    if [ $result -eq 0 ]; then
        echo -e "${GREEN}✅ $test_name - SUCCÈS${NC}"
        return 0
    else
        echo -e "${RED}❌ $test_name - ÉCHEC${NC}"
        return 1
    fi
}

echo -e "\n${YELLOW}📱 PHASE 1: Tests Frontend Flutter${NC}"
echo "=================================="

# Vérifier que Flutter est installé
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter n'est pas installé. Veuillez installer Flutter d'abord.${NC}"
    exit 1
fi

# Installer les dépendances Flutter
echo "📦 Installation des dépendances Flutter..."
flutter pub get

# Tests Flutter unitaires
run_test_suite "Tests Flutter Unitaires" "flutter test test/services/ test/models/ test/widgets/ --coverage"
if [ $? -eq 0 ]; then FRONTEND_SUCCESS=true; fi

# Tests d'intégration Flutter
run_test_suite "Tests d'Intégration Flutter" "flutter test test/integration/ --coverage"
if [ $? -eq 0 ]; then INTEGRATION_SUCCESS=true; fi

echo -e "\n${YELLOW}🔧 PHASE 2: Tests Backend .NET${NC}"
echo "================================="

# Vérifier que .NET est installé
if ! command -v dotnet &> /dev/null; then
    echo -e "${RED}❌ .NET n'est pas installé. Veuillez installer .NET d'abord.${NC}"
    exit 1
fi

# Aller dans le dossier des tests backend
cd backend/AgricultureAPI/AgricultureAPI.Tests

# Nettoyer et restaurer les packages
echo "🧹 Nettoyage et restauration des packages .NET..."
dotnet clean
dotnet restore

# Tests unitaires .NET
run_test_suite "Tests Unitaires .NET" "dotnet test --verbosity normal --filter Category!=Integration"
if [ $? -eq 0 ]; then BACKEND_SUCCESS=true; fi

# Tests d'intégration .NET
run_test_suite "Tests d'Intégration .NET" "dotnet test --verbosity normal --filter Category=Integration"
if [ $? -eq 0 ]; then INTEGRATION_SUCCESS=true; fi

# Retourner au répertoire racine
cd ../../..

echo -e "\n${YELLOW}🗄️ PHASE 3: Tests Base de Données${NC}"
echo "=================================="

# Tests de base de données Flutter
run_test_suite "Tests Base de Données Flutter" "flutter test test/database/ --coverage"
if [ $? -eq 0 ]; then DATABASE_SUCCESS=true; fi

echo -e "\n${YELLOW}🔄 PHASE 4: Tests d'Intégration Complète${NC}"
echo "============================================="

# Tests d'intégration complète
run_test_suite "Tests d'Intégration Complète" "flutter test test/integration/complete_system_test.dart --coverage"

echo -e "\n${YELLOW}📊 RÉSUMÉ DES RÉSULTATS${NC}"
echo "========================"

# Afficher le résumé
echo -e "\n${BLUE}Résultats par composant:${NC}"
print_result $([ "$FRONTEND_SUCCESS" = true ] && echo 0 || echo 1) "Frontend Flutter"
print_result $([ "$BACKEND_SUCCESS" = true ] && echo 0 || echo 1) "Backend .NET"
print_result $([ "$DATABASE_SUCCESS" = true ] && echo 0 || echo 1) "Base de Données"
print_result $([ "$INTEGRATION_SUCCESS" = true ] && echo 0 || echo 1) "Tests d'Intégration"

# Calculer le score global
TOTAL_TESTS=4
PASSED_TESTS=0

[ "$FRONTEND_SUCCESS" = true ] && ((PASSED_TESTS++))
[ "$BACKEND_SUCCESS" = true ] && ((PASSED_TESTS++))
[ "$DATABASE_SUCCESS" = true ] && ((PASSED_TESTS++))
[ "$INTEGRATION_SUCCESS" = true ] && ((PASSED_TESTS++))

SCORE=$((PASSED_TESTS * 100 / TOTAL_TESTS))

echo -e "\n${BLUE}Score global: $PASSED_TESTS/$TOTAL_TESTS ($SCORE%)${NC}"

if [ $PASSED_TESTS -eq $TOTAL_TESTS ]; then
    echo -e "${GREEN}🎉 Tous les tests sont passés avec succès!${NC}"
    echo -e "${GREEN}✅ Le système est prêt pour la production!${NC}"
    exit 0
elif [ $PASSED_TESTS -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Certains tests ont échoué. Vérifiez les logs ci-dessus.${NC}"
    exit 1
else
    echo -e "${RED}💥 Tous les tests ont échoué. Vérifiez la configuration.${NC}"
    exit 1
fi
