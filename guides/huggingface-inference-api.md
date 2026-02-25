# Anatomie d'un Code d'Inference (Hugging Face)

## Qu'est-ce que l'Inference ?

L'**inference**, c'est l'action de demander à une IA déjà entraînée de **"déduire"** une réponse à partir d'une entrée (ton prompt). 

> 💡 **Analogie simple** : C'est comme demander à un expert son avis. L'expert (le modèle) a déjà fait ses études (l'entraînement), tu lui poses une question (l'input) et il te donne sa réponse (l'output).

Le code pour faire ça via API est une **recette standardisée** qui suit toujours la même structure.

---

## 🗺️ Les 5 Éléments Indispensables

| Étape | Nom technique | Rôle | Métaphore |
|-------|---------------|------|-----------|
| **1** | `API_URL` | L'adresse exacte du modèle sur les serveurs | 📍 **L'adresse** du cerveau spécifique |
| **2** | `Headers` / Token | Ton identifiant pour accéder au service | 🪪 **La carte d'identité** |
| **3** | `Payload` / Inputs | Les données que tu envoies (texte, image, son) | ❓ **La question** posée |
| **4** | `Request` (POST) | L'action d'envoyer et d'attendre | ⏳ **L'attente** du retour |
| **5** | `Output` / Response | Ce que l'IA génère | 💬 **La réponse** |

---

## 🔬 Le Code Complet Commenté

```python
import requests  # La bibliothèque qui permet à ton Pi de "parler" à Internet

# ╔══════════════════════════════════════════════════════════════════╗
# ║  1. L'ADRESSE (Le modèle précis)                                 ║
# ╚══════════════════════════════════════════════════════════════════╝
# Structure standard : site + service + auteur/nom_du_modele
API_URL = "https://api-inference.huggingface.co/models/tencent/HunyuanImage-3.0-Instruct"

# ╔══════════════════════════════════════════════════════════════════╗
# ║  2. LA CARTE D'IDENTITÉ (Le Token)                               ║
# ╚══════════════════════════════════════════════════════════════════╝
# Le mot "Bearer" est obligatoire avant le token (norme OAuth 2.0)
headers = {
    "Authorization": f"Bearer hf_VOTRE_TOKEN_ICI"
}

# ╔══════════════════════════════════════════════════════════════════╗
# ║  3. LA FONCTION D'ENVOI (La machine à communiquer)               ║
# ╚══════════════════════════════════════════════════════════════════╝
def interroger_ia(donnees):
    """
    Envoie une requête POST au serveur Hugging Face
    POST = "je dépose des données sur le serveur"
    """
    try:
        reponse = requests.post(API_URL, headers=headers, json=donnees)
        reponse.raise_for_status()  # Vérifie si erreur HTTP (404, 401, etc.)
        return reponse.json()       # Convertit la réponse en dictionnaire Python
    except requests.exceptions.RequestException as e:
        print(f"❌ Erreur de connexion : {e}")
        return None

# ╔══════════════════════════════════════════════════════════════════╗
# ║  4. LE PAYLOAD (Ton instruction détaillée)                       ║
# ╚══════════════════════════════════════════════════════════════════╝
mon_ordre = {
    "inputs": "Un boîtier de Raspberry Pi 5 imprimé en 3D, style industriel.",
    "parameters": {  # Optionnel : réglages avancés
        "width": 512,
        "height": 512
    }
}

# ╔══════════════════════════════════════════════════════════════════╗
# ║  5. L'EXÉCUTION                                                  ║
# ╚══════════════════════════════════════════════════════════════════╝
if __name__ == "__main__":
    print("🚀 Envoi de la requête...")
    resultat = interroger_ia(mon_ordre)
    
    if resultat:
        print("✅ Réponse reçue :")
        print(resultat)
    else:
        print("❌ Échec de la requête")
```

---

## 🎯 Ce qui Change Selon le Type de Modèle

La **structure reste identique**, mais le contenu du `payload` varie :

### 🖼️ Modèle d'Image (Génération)
```python
payload = {
    "inputs": "Un chat astronaute sur la lune",  # Ta description
    "parameters": {
        "width": 512,
        "height": 512,
        "guidance_scale": 7.5  # Respect du prompt (1-20)
    }
}
# Retour : Tableau d'octets (bytes) → à sauvegarder en .png/.jpg
```

### 💬 Modèle de Texte (Chat/LLM)
```python
payload = {
    "inputs": "Explique la computer vision en 3 phrases simples",
    "parameters": {
        "max_new_tokens": 100,  # Longueur max de la réponse
        "temperature": 0.7      # Créativité (0=précis, 1=créatif)
    }
}
# Retour : Dictionnaire avec clé "generated_text"
```

### 🔧 Modèle d'Analyse (Classification)
```python
payload = {
    "inputs": "Ce produit est excellent !",  # Texte à analyser
    "options": {
        "wait_for_model": True  # Réveille le serveur si inactif
    }
}
# Retour : Liste de labels avec scores de confiance
```

---

## 🚨 Troubleshooting (Erreurs Courantes)

| Erreur | Cause probable | Solution |
|--------|---------------|----------|
| `401 Unauthorized` | Token invalide ou manquant | Vérifie ton Bearer token sur Hugging Face |
| `404 Not Found` | URL du modèle incorrecte | Vérifie le nom exact sur la page du modèle |
| `503 Service Unavailable` | Modèle en chargement | Ajoute `"wait_for_model": True` dans options |
| `Timeout` | Réponse trop longue | Augmente `timeout=60` dans requests.post() |
| `JSONDecodeError` | Réponse vide ou non-JSON | Vérifie si le modèle retourne du binaire (image) |

### 🔍 Checklist de Débogage (dans l'ordre)
1. ✅ L'URL est-elle complète et correcte ?
2. ✅ Le token est-il valide et précédé de "Bearer " ?
3. ✅ Le payload est-il au format JSON valide ?
4. ✅ As-tu une connexion Internet active ?
5. ✅ Le modèle est-il en ligne sur Hugging Face ?

> 💡 **Règle des 90%** : 90% des erreurs viennent d'une URL mal écrite ou d'un Token oublié.

---

## 🧠 À Retenir (La Structure en 5 Mots)

```
IMPORT → URL → HEADERS → PAYLOAD → RESPONSE
```

Ou en mnémonique : **"Ils Utilisent des Headers Pour Recevoir"**

**Ne mémorise pas le code caractère par caractère.** Mémorise cette structure. Si un jour ton code ne marche pas, vérifie toujours dans cet ordre.

---

## 🛠️ Le Script Universel (Passe-Partout)

Ce script avancé détecte **automatiquement** le type de réponse (image ou texte) et s'adapte à n'importe quel modèle Hugging Face.

```python
import requests
import io
from PIL import Image  # Pour afficher/sauvegarder les images

# ╔══════════════════════════════════════════════════════════════════╗
# ║  CONFIGURATION (Les 2 seules lignes à changer)                   ║
# ╚══════════════════════════════════════════════════════════════════╝
TOKEN = "hf_VOTRE_TOKEN_ICI"
MODEL_URL = "https://api-inference.huggingface.co/models/tencent/HunyuanImage-3.0-Instruct"
# Exemples d'URL alternatifs :
# MODEL_URL = "https://api-inference.huggingface.co/models/gpt2"  # Texte
# MODEL_URL = "https://api-inference.huggingface.co/models/facebook/bart-large-cnn"  # Résumé

def interroger_ia(prompt):
    """
    Fonction universelle : détecte automatiquement si la réponse
    est une image (bytes) ou du texte (JSON).
    """
    headers = {"Authorization": f"Bearer {TOKEN}"}
    payload = {"inputs": prompt}
    
    print(f"🚀 Envoi de la requête au modèle...")
    
    try:
        response = requests.post(MODEL_URL, headers=headers, json=payload, timeout=120)
        response.raise_for_status()
        
        # ╔════════════════════════════════════════════════════════════╗
        # ║  DÉTECTION AUTOMATIQUE DU TYPE DE RÉPONSE                   ║
        # ╚════════════════════════════════════════════════════════════╝
        content_type = response.headers.get('content-type', '')
        
        if "image" in content_type:
            # 🖼️ RÉPONSE IMAGE
            print("📸 Image reçue ! Sauvegarde en cours...")
            image = Image.open(io.BytesIO(response.content))
            filename = "resultat_ia.png"
            image.save(filename)
            return f"✅ Image sauvegardée sous : {filename}"
            
        elif "json" in content_type:
            # 💬 RÉPONSE TEXTE (JSON)
            print("✍️ Texte reçu !")
            data = response.json()
            
            # Extraction intelligente du texte selon le format
            if isinstance(data, list) and len(data) > 0:
                if "generated_text" in data[0]:
                    return data[0]["generated_text"]
                elif "summary_text" in data[0]:
                    return data[0]["summary_text"]
                else:
                    return data[0]
            elif isinstance(data, dict):
                return data.get("generated_text", str(data))
            else:
                return str(data)
        else:
            # ❓ TYPE INCONNU
            return f"⚠️ Type de réponse inattendu : {content_type}"
            
    except requests.exceptions.Timeout:
        return "⏱️ Timeout : Le modèle met trop de temps à répondre (essayez 'wait_for_model': True)"
    except requests.exceptions.RequestException as e:
        return f"❌ Erreur de connexion : {e}"

# ═══════════════════════════════════════════════════════════════════
# EXEMPLES D'UTILISATION
# ═══════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    # 🖼️ Test avec un modèle d'image
    # mon_prompt = "Un logo futuriste pour un projet de Raspberry Pi 5"
    
    # 💬 Test avec un modèle de texte
    mon_prompt = "Explique la computer vision en 3 phrases"
    
    resultat = interroger_ia(mon_prompt)
    print("\n" + "="*50)
    print("RÉSULTAT :")
    print("="*50)
    print(resultat)
```

### 🎯 Pourquoi c'est un "Passe-Partout" ?

| Fonctionnalité | Avantage |
|----------------|----------|
| **Détection automatique** | Fonctionne avec image ET texte sans modifier le code |
| **Gestion du timeout** | Ne plante pas si le modèle "dort" (120s d'attente) |
| **Extraction intelligente** | Adapte l'affichage selon le format de réponse du modèle |
| **Sauvegarde auto** | Les images sont enregistrées directement sur le SSD |

### 🔧 Comment l'adapter à ton projet ?

1. **Remplace** `TOKEN` par ton vrai token Hugging Face
2. **Remplace** `MODEL_URL` par l'URL du modèle voulu
3. **Modifie** `mon_prompt` avec ta requête
4. **Lance** le script → Il fait le reste automatiquement !

### 📋 URLs de modèles populaires à tester

| Type | Modèle | URL à utiliser |
|------|--------|----------------|
| 🖼️ Image | HunyuanImage | `models/tencent/HunyuanImage-3.0-Instruct` |
| 🖼️ Image | Stable Diffusion | `models/stabilityai/stable-diffusion-xl-base-1.0` |
| 💬 Texte | GPT-2 | `models/gpt2` |
| 💬 Texte | BART (résumé) | `models/facebook/bart-large-cnn` |
| 🔧 Analyse | Sentiment | `models/distilbert-base-uncased-finetuned-sst-2-english` |

---

## 📚 Ressources Utiles

- **Documentation Hugging Face Inference API** : https://huggingface.co/docs/api-inference
- **Trouver des modèles** : https://huggingface.co/models
- **Générer un token** : https://huggingface.co/settings/tokens

---

*Dernière mise à jour : 2026-02-24*
