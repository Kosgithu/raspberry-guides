#!/bin/bash
# Créer le repo raspberry-guides sur GitHub

cd ~/projects/raspberry-guides

echo "🚀 Création du repository raspberry-guides..."
echo ""

# Essayer de créer avec gh CLI
if command -v gh &> /dev/null; then
    echo "Utilisation de GitHub CLI..."
    
    # Vérifier si déjà authentifié
    if gh auth status &>/dev/null; then
        gh repo create raspberry-guides --public --source=. --push
    else
        echo "⚠️  GitHub CLI nécessite une authentification"
        echo ""
        echo "Exécute: gh auth login"
        echo "Puis: gh repo create raspberry-guides --public --source=. --push"
    fi
else
    echo "❌ GitHub CLI (gh) non installé"
    echo ""
    echo "Installe-le avec: sudo apt install gh"
fi
