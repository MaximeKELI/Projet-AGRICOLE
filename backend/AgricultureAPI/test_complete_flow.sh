#!/bin/bash

# Script de test complet du flux de paiement avec simulation
echo "=== Test complet du flux de paiement ==="
echo ""

BASE_URL="http://localhost:5000/api"

# Créer un nouvel utilisateur pour ce test
echo "1. Création d'un utilisateur de test..."
USER_EMAIL="flow-test-$(date +%s)@email.com"
USER_DATA="{\"name\":\"Flow Test User\",\"email\":\"$USER_EMAIL\",\"phoneNumber\":\"+22890123456\"}"

USER_RESPONSE=$(curl -s -X POST "$BASE_URL/users" \
    -H "Content-Type: application/json" \
    -d "$USER_DATA")

USER_ID=$(echo "$USER_RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('id', ''))" 2>/dev/null)

if [ -n "$USER_ID" ]; then
    echo "✅ Utilisateur créé: $USER_ID"
else
    echo "❌ Échec création utilisateur"
    exit 1
fi

# Simuler un paiement mobile money complet
echo ""
echo "2. Simulation paiement mobile money..."
MOBILE_PAYMENT_DATA="{\"userId\":\"$USER_ID\",\"documentId\":\"doc_tchamba\",\"phoneNumber\":\"+22890123456\",\"amount\":2500}"

MOBILE_RESPONSE=$(curl -s -X POST "$BASE_URL/payments/simulate-mobile-money" \
    -H "Content-Type: application/json" \
    -d "$MOBILE_PAYMENT_DATA")

echo "Réponse simulation:"
echo "$MOBILE_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$MOBILE_RESPONSE"

PAYMENT_ID=$(echo "$MOBILE_RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('paymentId', ''))" 2>/dev/null)

if [ -n "$PAYMENT_ID" ]; then
    echo "✅ Paiement simulé avec ID: $PAYMENT_ID"
else
    echo "⚠️ Simulation effectuée mais ID non récupéré"
fi

# Vérifier l'accès au document
echo ""
echo "3. Test d'accès au document..."
ACCESS_RESPONSE=$(curl -s -w "%{http_code}" "$BASE_URL/payments/access/$USER_ID/doc_tchamba" -o /tmp/access_response.json)

echo "Code d'accès: $ACCESS_RESPONSE"
if [ "$ACCESS_RESPONSE" = "200" ]; then
    echo "✅ Accès autorisé au document"
    cat /tmp/access_response.json | python3 -m json.tool 2>/dev/null || cat /tmp/access_response.json
else
    echo "❌ Accès refusé (code: $ACCESS_RESPONSE)"
    cat /tmp/access_response.json 2>/dev/null || echo "Pas de réponse"
fi

# Tenter le téléchargement du document
echo ""
echo "4. Test de téléchargement du document..."
DOWNLOAD_RESPONSE=$(curl -s -w "%{http_code}" "$BASE_URL/documents/doc_tchamba/download?userId=$USER_ID" -o /tmp/download_test.pdf)

echo "Code téléchargement: $DOWNLOAD_RESPONSE"
if [ "$DOWNLOAD_RESPONSE" = "200" ]; then
    FILE_SIZE=$(stat -c%s /tmp/download_test.pdf 2>/dev/null || echo "0")
    if [ "$FILE_SIZE" -gt "1000" ]; then
        echo "✅ Document téléchargé avec succès ($FILE_SIZE bytes)"
    else
        echo "⚠️ Téléchargement effectué mais fichier petit ($FILE_SIZE bytes)"
    fi
else
    echo "❌ Échec téléchargement (code: $DOWNLOAD_RESPONSE)"
fi

# Vérifier les achats de l'utilisateur
echo ""
echo "5. Vérification des achats utilisateur..."
PURCHASES_RESPONSE=$(curl -s "$BASE_URL/users/$USER_ID/purchases")
echo "Achats de l'utilisateur:"
echo "$PURCHASES_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$PURCHASES_RESPONSE"

# Statistiques finales
echo ""
echo "6. Statistiques finales..."
cd /home/maxime/Projet-AGRICOLE/backend/AgricultureAPI
echo "Total utilisateurs: $(sqlite3 agriculture.db 'SELECT COUNT(*) FROM Users;' 2>/dev/null)"
echo "Total paiements: $(sqlite3 agriculture.db 'SELECT COUNT(*) FROM Payments;' 2>/dev/null)"
echo "Paiements complétés: $(sqlite3 agriculture.db 'SELECT COUNT(*) FROM Payments WHERE Status = \"completed\";' 2>/dev/null)"
echo "Total achats: $(sqlite3 agriculture.db 'SELECT COUNT(*) FROM UserPurchases;' 2>/dev/null)"

echo ""
echo "=== Test complet terminé ==="
