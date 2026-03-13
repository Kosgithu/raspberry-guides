# 🖥️ Bureau à Distance VNC - Raspberry Pi 5

> Guide pour se connecter au bureau graphique du Raspberry Pi 5 depuis un Mac

---

## 📋 Informations de Connexion

| Paramètre | Valeur |
|-----------|--------|
| **IP Locale** | `192.168.1.79` |
| **Port VNC** | `5900` |
| **Nom d'utilisateur** | `oimadi` |
| **Mot de passe** | (même que session Pi) |

---

## 🍎 Connexion depuis macOS

### Méthode 1 : Finder (Recommandée)

1. **Ouvrir le Finder**
2. Appuyer sur **`Cmd + K`** (ou Aller → Se connecter au serveur)
3. Entrer l'adresse :
   ```
   vnc://192.168.1.79:5900
   ```
4. Cliquer sur **Se connecter**
5. Entrer le mot de passe de session (`oimadi`)
6. ✅ Tu vois le bureau du Raspberry Pi !

---

### Méthode 2 : Safari

1. **Ouvrir Safari**
2. Dans la barre d'adresse, taper :
   ```
   vnc://192.168.1.79:5900
   ```
3. Appuyer sur **Entrée**
4. Entrer le mot de passe
5. ✅ Connexion établie

---

### Méthode 3 : Application "Partage d'écran" (macOS natif)

1. Ouvrir **Spotlight** (`Cmd + Espace`)
2. Taper `Partage d'écran` et ouvrir l'app
3. Entrer dans la barre d'adresse :
   ```
   192.168.1.79:5900
   ```
4. Entrer le mot de passe
5. ✅ Connecté

---

## 🖱️ Utilisation

Une fois connecté :
- **Ta souris/clavier Mac** contrôlent le Pi
- **Résolution** : S'adapte automatiquement (peut être lente sur WiFi)
- **Presse-papiers** : Copier/coller fonctionne entre Mac et Pi

---

## 🎨 Pour la Computer Vision

Quand tu lances un script Python avec `cv2.imshow()` :
```python
import cv2
cap = cv2.VideoCapture(0)
while True:
    ret, frame = cap.read()
    cv2.imshow('Camera', frame)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break
cap.release()
cv2.destroyAllWindows()
```

Tu verras la fenêtre **en direct** dans VNC ! 🎉

---

## ⚠️ Performance

| Qualité | Usage |
|---------|-------|
| Sur WiFi | Correct pour du code, un peu lag pour la vidéo |
| Sur Ethernet (câble) | Très fluide, parfait pour CV |
| Qualité réglable | Dans les options de l'observateur VNC |

---

## 🛠️ Dépannage

### "Connexion refusée"

Vérifie que VNC tourne sur le Pi :
```bash
# Depuis le Pi (SSH)
sudo systemctl status wayvnc
```

### Écran noir

Le Pi est peut-être en veille. Tape sur le clavier physique du Pi ou :
```bash
# Depuis SSH
export DISPLAY=:0
xset s reset  # Réveille l'écran
```

### Trop lent

1. Réduire la résolution sur le Pi :
   ```bash
   raspi-config
   # Display Options → Resolution → 1280x720
   ```
2. Utiliser une connexion Ethernet au lieu du WiFi

---

## 🔒 Sécurité

⚠️ VNC n'est pas chiffré par défaut. Sur ton réseau local c'est OK, mais **ne l'expose pas sur Internet** sans tunnel SSH :

```bash
# Tunnel SSH sécurisé (optionnel)
ssh -L 5900:localhost:5900 oimadi@192.168.1.79
# Puis connecte-toi à vnc://localhost:5900
```

---

## 📝 Résumé rapide

| Action | Commande |
|--------|----------|
| **IP du Pi** | `192.168.1.79` |
| **Port VNC** | `5900` |
| **Connexion Mac** | `Cmd+K` → `vnc://192.168.1.79:5900` |
| **Mot de passe** | (session `oimadi`) |

---

*Dernière mise à jour : 2026-03-13*
*Serveur VNC : WayVNC (Wayland)*
