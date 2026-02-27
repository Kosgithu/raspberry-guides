# 🧠 IA Locale avec Ollama : Guide Complet

> **Niveau** : Débutant  
> **Durée** : 15 minutes de lecture  
> **Matériel** : Raspberry Pi (ou tout PC Linux)

---

## 📋 Sommaire

1. [L'analogie de la cuisine](#1-lanalogie-de-la-cuisine-comprendre-lenvironnement-virtuel)
2. [Structure technique](#2-structure-technique)
3. [Pré-requis](#3-pré-requis)
4. [Installation pas à pas](#4-installation-pas-à-pas)
5. [Configuration de Thonny](#5-configuration-de-thonny)
6. [Première inférence](#6-première-inférence)
7. [Commandes de référence](#7-commandes-de-référence-ollama)
8. [Dépannage](#8-dépannage)

---

## 1. L'analogie de la cuisine (Comprendre l'Environnement Virtuel)

Imagine que ton Raspberry Pi est une **GRANDE CUISINE partagée**.

| Élément | Analogie | Rôle |
|---------|----------|------|
| **Le Système (OS)** | La cuisine elle-même (four, évier, gaz) | Fournit l'infrastructure de base |
| **La Bulle (venv)** | Ton plan de travail portatif | Isole tes projets pour éviter les conflits |
| **Le Moteur (Ollama)** | Le gros frigo de la cuisine | Stocke et exécute les modèles d'IA |
| **La Télécommande (lib `ollama`)** | Tes ustensiles sur le plan de travail | Permet à Python de "parler" au moteur |

### 🎯 Pourquoi cette séparation ?

```
Problème sans environnement virtuel :
┌─────────────────────────────────────┐
│  Projet A utilise numpy 1.20        │
│  Projet B utilise numpy 2.0         │
│  → CONFLIT : Impossible d'avoir     │
│    les deux versions en même temps !│
└─────────────────────────────────────┘

Solution avec environnement virtuel :
┌─────────────────────────────────────┐
│  [venv-projetA]  numpy 1.20  ✓      │
│  [venv-projetB]  numpy 2.0   ✓      │
│  → Chaque projet a ses propres      │
│    bibliothèques, pas de conflit    │
└─────────────────────────────────────┘
```

---

## 2. Structure technique

```
┌─────────────────────────────────────────────────────────────┐
│                    RASPBERRY PI (OS)                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  MOTEUR : Ollama (installé sur le système)          │   │
│  │  📁 /usr/local/bin/ollama                           │   │
│  │  📁 ~/.ollama/models/  ← Les modèles sont ici       │   │
│  └─────────────────────────────────────────────────────┘   │
│                            ▲                                │
│                            │ API locale (HTTP)             │
│  ┌─────────────────────────┴────────────────────────────┐  │
│  │  ENVIRONNEMENT VIRTUEL : mon_ia_env                  │  │
│  │  📁 /home/pi/mon_ia_env/                             │  │
│  │                                                      │  │
│  │  Bibliothèques installées :                          │  │
│  │    └── ollama (la "télécommande" Python)             │  │
│  │                                                      │  │
│  │  Ton code Python :                                   │  │
│  │    from ollama import chat                           │  │
│  │    response = chat(model='llama3.2', ...)            │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. Pré-requis

- [ ] Raspberry Pi avec Raspberry Pi OS (ou tout Linux)
- [ ] Connexion internet
- [ ] Terminal ouvert
- [ ] Python 3 installé (vérifier avec `python3 --version`)

---

## 4. Installation pas à pas

### Étape 1 : Installer Ollama (le moteur)

```bash
# Commande officielle d'installation
curl -fsSL https://ollama.com/install.sh | sh
```

> ⚠️ **Attention** : L'installation peut prendre plusieurs minutes sur Raspberry Pi.

Vérifier l'installation :
```bash
ollama --version
```

### Étape 2 : Créer l'environnement virtuel

```bash
# Se placer dans le dossier utilisateur
cd ~

# Créer la "bulle" (le plan de travail)
python3 -m venv mon_ia_env

# Résultat : un nouveau dossier 'mon_ia_env' est créé
ls -la mon_ia_env/
```

### Étape 3 : Activer l'environnement

```bash
# Activer la bulle (mettre ses gants de cuisine)
source mon_ia_env/bin/activate

# Tu dois voir (mon_ia_env) au début de ta ligne de commande :
# (mon_ia_env) pi@raspberrypi:~ $
```

### Étape 4 : Installer la bibliothèque Python

```bash
# Dans l'environnement activé (tu vois le préfixe)
pip install ollama

# Vérifier l'installation
pip list | grep ollama
```

### Étape 5 : Télécharger un modèle

```bash
# Télécharger Llama 3.2 (version légère, parfait pour Raspberry Pi)
ollama pull llama3.2

# Voir les modèles disponibles
ollama list
```

---

## 5. Configuration de Thonny

Pour que Thonny utilise ton environnement virtuel :

1. **Ouvrir Thonny** (menu → Programmation → Thonny)
2. **Menu** : `Outils` → `Options`
3. **Onglet** : `Interpréteur`
4. **Choisir** : `Alternative Python 3 interpreter or virtual environment`
5. **Cliquer** sur `...` à droite de l'exécutable Python
6. **Naviguer vers** : `/home/pi/mon_ia_env/bin/python`
7. **Redémarrer Thonny** pour appliquer les changements

```
┌──────────────────────────────────────────────┐
│  Options → Interpréteur                      │
│                                              │
│  ○ The same interpreter that runs Thonny     │
│  ● Alternative Python 3 interpreter...       │
│    Exécutable Python :                       │
│    [/home/pi/mon_ia_env/bin/python] [...]    │
│                                              │
│              [ OK ]    [ Annuler ]           │
└──────────────────────────────────────────────┘
```

---

## 6. Première inférence

Crée un nouveau fichier dans Thonny (`Fichier` → `Nouveau`) et colle ce code :

```python
"""
Premier chat avec un modèle local Ollama
"""
from ollama import chat

# Envoyer une question au modèle
response = chat(
    model='llama3.2',
    messages=[
        {'role': 'user', 'content': 'Explique-moi ce qu\'est un Raspberry Pi en 3 phrases'}
    ]
)

# Afficher la réponse
print("🤖 Réponse du modèle :")
print(response.message.content)
```

**Résultat attendu :**
```
🤖 Réponse du modèle :
Le Raspberry Pi est un ordinateur monocarte de la taille d'une carte de crédit, 
conçu pour promouvoir l'enseignement de l'informatique et l'expérimentation 
avec le matériel. Il peut exécuter un système d'exploitation complet comme 
Linux et servir de base pour des projets allant de serveurs domestiques à 
des robots. Son faible coût et sa communauté active en font un outil idéal 
pour les hobbyistes et les éducateurs.
```

### 📝 Exemple avec historique de conversation

```python
from ollama import chat

# Conversation avec mémoire du contexte
messages = []

# Premier message
messages.append({'role': 'user', 'content': 'Bonjour, je m\'appelle Madi'})
response = chat(model='llama3.2', messages=messages)
messages.append({'role': 'assistant', 'content': response.message.content})
print(f"Assistant: {response.message.content}\n")

# Le modèle se souvient de ton prénom
messages.append({'role': 'user', 'content': 'Quel est mon prénom ?'})
response = chat(model='llama3.2', messages=messages)
print(f"Assistant: {response.message.content}")
```

---

## 7. Commandes de référence Ollama

### Gestion des modèles

```bash
# Lister les modèles installés
ollama list

# Télécharger un nouveau modèle
ollama pull llama3.2
ollama pull gemma2:2b      # Version ultra-légère
ollama pull phi3:mini      # Petit modèle performant

# Supprimer un modèle
ollama rm llama3.2

# Lancer le modèle en mode interactif (chat en ligne de commande)
ollama run llama3.2

# Quitter le mode interactif : Ctrl+D ou taper /bye
```

### Gestion du service

```bash
# Vérifier si Ollama tourne
systemctl status ollama

# Démarrer Ollama
sudo systemctl start ollama

# Arrêter Ollama
sudo systemctl stop ollama

# Redémarrer Ollama
sudo systemctl restart ollama

# Activer le démarrage automatique
sudo systemctl enable ollama
```

### Environnement virtuel Python

```bash
# Créer un venv
python3 -m venv nom_env

# Activer (Linux/Mac)
source nom_env/bin/activate

# Activer (Windows)
nom_env\Scripts\activate

# Désactiver
deactivate

# Voir où on est
which python
pip list
```

---

## 8. Dépannage

### ❌ Problème : "ollama: command not found"

**Cause** : Ollama n'est pas dans le PATH

**Solution** :
```bash
# Ajouter au PATH
export PATH=$PATH:/usr/local/bin

# Ou relancer le terminal après installation
```

### ❌ Problème : "ModuleNotFoundError: No module named 'ollama'"

**Cause** : La bibliothèque n'est pas installée dans l'environnement actif

**Solution** :
```bash
# Vérifier que l'environnement est actif (tu dois voir le nom entre parenthèses)
source ~/mon_ia_env/bin/activate

# Réinstaller
pip install ollama
```

### ❌ Problème : "Error: could not connect to ollama server"

**Cause** : Le service Ollama ne tourne pas

**Solution** :
```bash
# Démarrer le service
sudo systemctl start ollama

# Vérifier le statut
sudo systemctl status ollama
```

### ❌ Problème : Réponses très lentes

**Cause** : Raspberry Pi a des ressources limitées

**Solutions** :
- Utiliser des modèles plus petits : `llama3.2`, `gemma2:2b`, `phi3:mini`
- Augmenter le swap si nécessaire
- Fermer les autres applications

### ❌ Problème : Thonny n'utilise pas le bon Python

**Vérification** :
```python
import sys
print(sys.executable)
# Doit afficher : /home/pi/mon_ia_env/bin/python
```

**Solution** : Reconfigurer l'interpréteur dans les options de Thonny (voir section 5)

---

## 📚 Ressources complémentaires

- **Documentation Ollama** : https://github.com/ollama/ollama
- **Modèles disponibles** : https://ollama.com/library
- **Bibliothèque Python** : `pip show ollama`

---

*Guide créé pour l'apprentissage de l'IA locale sur Raspberry Pi.*  
*Dernière mise à jour : Février 2026*
