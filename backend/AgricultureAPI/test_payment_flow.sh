#!/bin/bash

# Script de test complet pour le système de paiement
echo "=== Test du système de paiement agricole ==="
echo ""

BASE_URL="http://localhost:5000/api"

# Test 1: Vérifier que l'API fonctionne
echo "1. Test de connectivité API..."
response=$(curl -s -w "%{http_code}" "$BASE_URL/documents" -o /tmp/test_response.json)
if [ "$response" = "200" ]; then
    echo "✅ API accessible"
    echo "Documents disponibles: $(cat /tmp/test_response.json | python3 -c "import sys, json; data=json.load(sys.stdin); print(len(data))")"
else
    echo "❌ API non accessible (code: $response)"
    exit 1
fi

# Test 2: Créer un utilisateur
echo ""
echo "2. Création d'un utilisateur..."
USER_EMAIL="test-$(date +%s)@email.com"
USER_DATA="{\"name\":\"Test User\",\"email\":\"$USER_EMAIL\",\"phoneNumber\":\"+22890123456\"}"

response=$(curl -s -w "%{http_code}" -X POST "$BASE_URL/users" \
    -H "Content-Type: application/json" \
    -d "$USER_DATA" \
    -o /tmp/user_response.json)

echo "Code de réponse: $response"
if [ -s /tmp/user_response.json ]; then
    echo "Réponse reçue:"
    cat /tmp/user_response.json | python3 -m json.tool 2>/dev/null || cat /tmp/user_response.json
    USER_ID=$(cat /tmp/user_response.json | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('id', ''))" 2>/dev/null)
    if [ -n "$USER_ID" ]; then
        echo "✅ Utilisateur créé avec ID: $USER_ID"
    else
        echo "⚠️ Utilisateur possiblement créé mais ID non récupéré"
    fi
else
    echo "❌ Aucune réponse reçue pour la création d'utilisateur"
fi

# Test 3: Vérifier les documents disponibles
echo ""
echo "3. Documents disponibles pour achat..."
curl -s "$BASE_URL/documents" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    for doc in data[:2]:  # Afficher les 2 premiers
        print(f\"📄 {doc['id']}: {doc['title']} - {doc['price']} FCFA\")
except:
    print('Erreur lors de la lecture des documents')
"

# Test 4: Initier un paiement (si on a un USER_ID)
if [ -n "$USER_ID" ]; then
    echo ""
    echo "4. Initiation d'un paiement..."
    PAYMENT_DATA="{\"userId\":\"$USER_ID\",\"documentId\":\"doc_tchamba\",\"paymentMethod\":\"mobile_money\"}"
    
    response=$(curl -s -w "%{http_code}" -X POST "$BASE_URL/payments/initiate" \
        -H "Content-Type: application/json" \
        -d "$PAYMENT_DATA" \
        -o /tmp/payment_response.json)
    
    echo "Code de réponse: $response"
    if [ -s /tmp/payment_response.json ]; then
        echo "Réponse reçue:"
        cat /tmp/payment_response.json | python3 -m json.tool 2>/dev/null || cat /tmp/payment_response.json
        PAYMENT_ID=$(cat /tmp/payment_response.json | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('id', ''))" 2>/dev/null)
        if [ -n "$PAYMENT_ID" ]; then
            echo "✅ Paiement initié avec ID: $PAYMENT_ID"
        fi
    else
        echo "❌ Aucune réponse reçue pour l'initiation du paiement"
    fi
else
    echo ""
    echo "4. ⏭️ Test de paiement ignoré (pas d'ID utilisateur)"
fi

# Test 5: Vérifier la base de données directement
echo ""
echo "5. Vérification de la base de données..."
cd /home/maxime/Projet-AGRICOLE/backend/AgricultureAPI
echo "Utilisateurs en base: $(sqlite3 agriculture.db 'SELECT COUNT(*) FROM Users;' 2>/dev/null || echo 'Erreur')"
echo "Paiements en base: $(sqlite3 agriculture.db 'SELECT COUNT(*) FROM Payments;' 2>/dev/null || echo 'Erreur')"
echo "Documents en base: $(sqlite3 agriculture.db 'SELECT COUNT(*) FROM DocumentRecommendations;' 2>/dev/null || echo 'Erreur')"

echo ""
echo "=== Fin des tests ==="
