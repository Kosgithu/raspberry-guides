# 🖥️ Bureau à Distance VNC - Raspberry Pi 5

> Guide complet pour se connecter au bureau graphique du Raspberry Pi 5 depuis un Mac (ou autre)

---

## ⚠️ IMPORTANT : Configuration requise

Ce guide suppose que :
1. Tu es sur **Raspberry Pi OS Bookworm** (Debian 12)
2. Tu as **activé le bureau graphique** (pas la version Lite)
3. Le Pi est en mode **X11** (pas Wayland)

### Vérifier / Passer en X11 (obligatoire pour VNC)

Si VNC ne fonctionne pas, passe en X11 :
```bash
sudo raspi-config
# Advanced Options > Wayland > X11
# Reboot
```

---

## 📋 Informations de Connexion

| Paramètre | Valeur |
|-----------|--------|
| **IP Locale** | `192.168.1.79` |
| **Port VNC** | `5900` |
| **Nom d'utilisateur** | `oimadi` |
| **Mot de passe VNC** | `oimadi` |
| **Serveur** | x11vnc (compatible macOS) |

---

## 🍎 Connexion depuis macOS (Client Natif)

### Méthode 1 : Finder (Recommandée)

1. **Dans le Finder**, appuie sur **`Cmd + K`**
2. Tape l'adresse :
   ```
   vnc://192.168.1.79:5900
   ```
3. Clique sur **Se connecter**
4. Entre le mot de passe : `oimadi`
5. ✅ Tu vois le bureau du Raspberry Pi !

---

### Méthode 2 : Application "Partage d'écran"

1. **`Cmd + Espace`** pour Spotlight
2. Tape **"Partage d'écran"** et ouvre l'app
3. Dans la barre d'adresse, tape :
   ```
   192.168.1.79:5900
   ```
4. Entre le mot de passe : `oimadi`
5. ✅ Connecté

---

### Méthode 3 : Safari

1. **Ouvre Safari**
2. Dans la barre d'adresse, tape :
   ```
   vnc://192.168.1.79:5900
   ```
3. Entre le mot de passe
4. ✅ Ça ouvre le Partage d'écran automatiquement

---

## 🛠️ Installation sur le Raspberry Pi (si besoin)

Si le serveur VNC n'est pas installé :

```bash
# 1. Passer en X11 (obligatoire)
sudo raspi-config
# Advanced Options > Wayland > X11
sudo reboot

# 2. Installer x11vnc
sudo apt update
sudo apt install -y x11vnc

# 3. Créer le mot de passe
mkdir -p ~/.vnc
x11vnc -storepasswd oimadi ~/.vnc/passwd

# 4. Lancer le serveur
x11vnc -display :0 -forever -shared -rfbport 5900 -rfbauth ~/.vnc/passwd -noxdamage -noxkb -bg
```

---

## 🔄 Démarrage automatique (Service Systemd)

Pour que VNC démarre automatiquement au boot :

```bash
# Créer le service
sudo tee /etc/systemd/system/x11vnc.service > /dev/null << 'EOF'
[Unit]
Description=x11vnc VNC Server
After=display-manager.service network.target

[Service]
Type=simple
User=oimadi
ExecStart=/usr/bin/x11vnc -display :0 -forever -shared -rfbport 5900 -rfbauth /home/oimadi/.vnc/passwd -noxdamage -noxkb
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Activer le service
sudo systemctl daemon-reload
sudo systemctl enable x11vnc
sudo systemctl start x11vnc
```

### Commandes de gestion du service

```bash
# Vérifier le statut
sudo systemctl status x11vnc

# Démarrer
sudo systemctl start x11vnc

# Arrêter
sudo systemctl stop x11vnc

# Redémarrer
sudo systemctl restart x11vnc

# Désactiver le démarrage auto
sudo systemctl disable x11vnc
```

---

## 🖱️ Utilisation

Une fois connecté :
- **Ta souris/clavier Mac** contrôlent le Pi
- **Presse-papiers** : Copier/coller fonctionne entre Mac et Pi
- **Résolution** : S'adapte à la fenêtre (peut être lente sur WiFi)

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

## ⚡ Performance

| Qualité | Usage |
|---------|-------|
| Sur WiFi | Correct pour du code, un peu lag pour la vidéo |
| Sur Ethernet (câble) | Très fluide, parfait pour CV |
| Qualité réglable | Dans les options de l'observateur VNC |

---

## ⚠️ Dépannage

### "Connexion refusée"

Vérifie que le service tourne :
```bash
sudo systemctl status x11vnc
```

Si besoin, redémarre :
```bash
sudo systemctl restart x11vnc
```

### "Mot de passe incorrect"

Recrée le mot de passe :
```bash
x11vnc -storepasswd oimadi ~/.vnc/passwd
sudo systemctl restart x11vnc
```

### Écran noir / Pas d'affichage

Vérifie que tu es bien en **X11** (pas Wayland) :
```bash
echo $XDG_SESSION_TYPE
# Doit afficher : x11
```

Si ça affiche "wayland", passe en X11 :
```bash
sudo raspi-config
# Advanced Options > Wayland > X11
sudo reboot
```

### Le Pi n'a pas d'écran physique (headless)

Force un output HDMI virtuel dans `/boot/firmware/config.txt` :
```bash
sudo tee -a /boot/firmware/config.txt > /dev/null << 'EOF'

# Force HDMI output for headless VNC
hdmi_force_hotplug=1
hdmi_group=2
hdmi_mode=82
EOF
sudo reboot
```

### Connexion très lente

1. Réduire la résolution sur le Pi :
   ```bash
   sudo raspi-config
   # Display Options > Resolution > 1280x720
   ```
2. Utiliser une connexion Ethernet au lieu du WiFi

---

## 🔒 Sécurité

⚠️ VNC n'est pas chiffré. Sur ton réseau local c'est OK, mais **ne l'expose pas sur Internet**.

Pour une connexion sécurisée, utilise un **tunnel SSH** :
```bash
# Sur Mac, dans Terminal
ssh -L 5900:localhost:5900 oimadi@192.168.1.79
# Laisse ce terminal ouvert
# Puis connecte-toi à vnc://localhost:5900 sur ton Mac
```

---

## 📁 Emplacements Importants sur le Pi

| Chemin | Description |
|--------|-------------|
| `/home/oimadi/` | Dossier utilisateur |
| `/home/oimadi/mes_ressources_md/` | Stockage documents/projets |
| `/home/oimadi/.openclaw/workspace/` | Workspace OpenClaw |
| `/home/oimadi/projects/` | Projets personnels |
| `~/.vnc/passwd` | Fichier mot de passe VNC |

---

## 📝 Résumé rapide

| Action | Commande |
|--------|----------|
| **Connexion Mac** | `Cmd+K` → `vnc://192.168.1.79:5900` |
| **Mot de passe** | `oimadi` |
| **Démarrer VNC** | `sudo systemctl start x11vnc` |
| **Arrêter VNC** | `sudo systemctl stop x11vnc` |
| **Statut** | `sudo systemctl status x11vnc` |

---

## 🔗 Liens Utiles

- [Documentation Raspberry Pi VNC](https://www.raspberrypi.com/documentation/computers/remote-access.html#vnc)
- [x11vnc Documentation](https://github.com/LibVNC/x11vnc)

---

*Dernière mise à jour : 2026-03-13*
*Configuration : X11 + x11vnc (compatible macOS natif)*
