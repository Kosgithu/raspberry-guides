# Guide : Caméra sur Raspberry Pi 5 📷

Ce guide explique comment utiliser la caméra CSI sur Raspberry Pi 5 et résoudre les problèmes courants.

---

## 🚨 Le Problème Principal

Sur Raspberry Pi 5, **`cv2.VideoCapture(0)` ne fonctionne pas** :
- Erreur GStreamer : `Failed to allocate required memory`
- La caméra s'ouvre mais ne retourne aucune frame
- Fonctionne sur Pi 4, mais PAS sur Pi 5

### Pourquoi ?

Le backend GStreamer d'OpenCV est incompatible avec le nouveau pipeline caméra du Pi 5. La solution est d'utiliser **picamera2** pour la capture et **OpenCV** pour le traitement.

---

## ✅ Prérequis

### 1. Activer la caméra

```bash
sudo raspi-config
# Interface Options → Camera → Enable
# Redémarrer le Pi après activation
sudo reboot
```

### 2. Vérifier que la caméra est détectée

```bash
# Lister les périphériques vidéo
ls -la /dev/video*

# Voir les informations de la caméra
v4l2-ctl --list-devices
```

Tu devrais voir `rp1-cfe` (Camera Front End) dans la liste.

### 3. Installer picamera2

```bash
# Sur Raspberry Pi OS (Debian Bookworm/Trixie)
sudo apt update
sudo apt install -y python3-picamera2

# Vérifier l'installation
python3 -c "from picamera2 import Picamera2; print('✅ picamera2 installé')"
```

---

## 📸 Commandes pour Prendre des Photos

### Méthode 1 : Avec libcamera (ligne de commande)

```bash
# Photo simple
libcamera-still -o photo.jpg

# Photo avec résolution spécifique
libcamera-still -o photo.jpg --width 1920 --height 1080

# Photo avec preview de 5 secondes
libcamera-still -o photo.jpg --timeout 5000

# Photo en RAW (qualité maximale)
libcamera-still -o photo.jpg --raw
```

### Méthode 2 : Avec Python et picamera2

```python
#!/usr/bin/env python3
from picamera2 import Picamera2
import time

# Initialisation
picam2 = Picamera2()
config = picam2.create_still_configuration(main={"size": (1920, 1080)})
picam2.configure(config)
picam2.start()

# Attendre l'auto-focus et l'exposition
time.sleep(2)

# Capturer
picam2.capture_file("photo.jpg")
print("✅ Photo sauvegardée : photo.jpg")

picam2.stop()
```

### Méthode 3 : Avec Python et OpenCV (après capture picamera2)

```python
#!/usr/bin/env python3
from picamera2 import Picamera2
import cv2

picam2 = Picamera2()
config = picam2.create_preview_configuration(main={"format": "RGB888", "size": (640, 480)})
picam2.configure(config)
picam2.start()

# Capturer
frame = picam2.capture_array()

# Sauvegarder avec OpenCV
cv2.imwrite("photo_opencv.jpg", frame)
print("✅ Photo sauvegardée avec OpenCV")

picam2.stop()
```

---

## 🎥 Commandes pour Prendre des Vidéos

### Méthode 1 : Avec libcamera (ligne de commande)

```bash
# Vidéo de 10 secondes
libcamera-vid -o video.h264 -t 10000

# Vidéo avec résolution spécifique
libcamera-vid -o video.h264 --width 1920 --height 1080 -t 10000

# Convertir en MP4 (nécessite ffmpeg)
ffmpeg -i video.h264 -c copy video.mp4

# Vidéo directement en MP4
libcamera-vid -o video.mp4 --codec h264 -t 10000
```

### Méthode 2 : Avec Python et picamera2

```python
#!/usr/bin/env python3
from picamera2 import Picamera2
from picamera2.encoders import H264Encoder
from picamera2.outputs import FfmpegOutput
import time

# Configuration
picam2 = Picamera2()
video_config = picam2.create_video_configuration(
    main={"size": (640, 480), "format": "RGB888"}
)
picam2.configure(video_config)

# Démarrer
picam2.start()
time.sleep(0.5)

# Encoder et enregistrer 10 secondes
encoder = H264Encoder(bitrate=1000000)
output = FfmpegOutput("video.mp4")

picam2.start_recording(encoder, output)
time.sleep(10)
picam2.stop_recording()

picam2.stop()
print("✅ Vidéo de 10s sauvegardée : video.mp4")
```

### Méthode 3 : Avec OpenCV (après conversion format)

```python
#!/usr/bin/env python3
from picamera2 import Picamera2
import cv2
import time

# Configuration
picam2 = Picamera2()
config = picam2.create_video_configuration(main={"size": (640, 480)})
picam2.configure(config)
picam2.start()

# VideoWriter OpenCV
fourcc = cv2.VideoWriter_fourcc(*'mp4v')
out = cv2.VideoWriter('output.mp4', fourcc, 20.0, (640, 480))

# Enregistrer 10 secondes
duration = 10
start = time.time()
while time.time() - start < duration:
    frame = picam2.capture_array()
    out.write(frame)

out.release()
picam2.stop()
print("✅ Vidéo sauvegardée : output.mp4")
```

---

## 🧹 Vider le Cache et Libérer la Caméra

### Problème : "Camera is already in use"

Si tu vois cette erreur, la caméra est bloquée par un processus.

### Solutions :

```bash
# 1. Lister les processus qui utilisent la caméra
fuser /dev/video0
lsof /dev/video0

# 2. Tuer les processus Python utilisant la caméra
pkill -f python

# Ou plus spécifiquement :
ps aux | grep python
kill -9 <PID>

# 3. Redémarrer le service caméra
sudo systemctl restart rpicam-apps

# 4. Si tout échoue, redémarrer le Pi
sudo reboot
```

### Vider le cache Python

```bash
# Supprimer les fichiers cache Python
find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null
find . -type f -name "*.pyc" -delete
find . -type f -name "*.pyo" -delete

# Supprimer les dossiers .pytest_cache, .mypy_cache, etc.
rm -rf .pytest_cache .mypy_cache .cache
```

### Réinitialisation complète de la caméra

```bash
# Arrêter tous les services caméra
sudo systemctl stop rpicam-apps

# Décharger/recharger le module caméra
sudo modprobe -r rp1-cfe 2>/dev/null || true
sudo modprobe rp1-cfe

# Redémarrer le service
sudo systemctl start rpicam-apps

# Vérifier
libcamera-hello --list-cameras
```

---

## 🔧 Script de Diagnostic Complet

```bash
#!/bin/bash
# diagnostic_camera.sh - Script de diagnostic pour la caméra Pi 5

echo "=========================================="
echo "🔍 Diagnostic Caméra Raspberry Pi 5"
echo "=========================================="

echo -e "\n📹 Périphériques vidéo détectés :"
ls -la /dev/video* 2>/dev/null || echo "❌ Aucun périphérique vidéo trouvé"

echo -e "\n📊 Informations V4L2 :"
v4l2-ctl --list-devices 2>/dev/null || echo "⚠️ v4l2-ctl non installé (sudo apt install v4l-utils)"

echo -e "\n🔧 Modules kernel chargés :"
lsmod | grep -E "(rp1|v4l2|camera)" || echo "Aucun module caméra détecté"

echo -e "\n📦 Vérification de picamera2 :"
python3 -c "from picamera2 import Picamera2; print('✅ picamera2 installé')" 2>/dev/null || echo "❌ picamera2 non installé"

echo -e "\n🐍 Processus Python utilisant la caméra :"
ps aux | grep -E "(python|picamera)" | grep -v grep || echo "Aucun processus Python"

echo -e "\n📸 Test rapide de capture :"
if python3 -c "from picamera2 import Picamera2; p=Picamera2(); p.start(); p.capture_file('/tmp/test.jpg'); p.stop()" 2>/dev/null; then
    echo "✅ Capture test réussie : /tmp/test.jpg"
    rm -f /tmp/test.jpg
else
    echo "❌ Échec de la capture test"
fi

echo -e "\n=========================================="
echo "Diagnostic terminé"
echo "=========================================="
```

**Usage :**
```bash
chmod +x diagnostic_camera.sh
./diagnostic_camera.sh
```

---

## 📋 Checklist de Dépannage

| Symptôme | Cause probable | Solution |
|----------|---------------|----------|
| `cv2.VideoCapture(0)` retourne `None` | GStreamer incompatible | Utiliser picamera2 |
| "Camera is already in use" | Processus bloquant | `pkill python` ou redémarrage |
| Image noire ou freeze | Caméra pas encore prête | Ajouter `time.sleep(2)` après start |
| Pas de `/dev/video0` | Caméra non activée | `sudo raspi-config` → activer caméra |
| Erreur "Failed to allocate memory" | GStreamer bug | Utiliser picamera2.capture_array() |
| Couleurs bizarre (BGR/RGB) | Format de couleur | Utiliser `COLOR_BGR2RGB` si besoin |

---

## 💡 Bonnes Pratiques

1. **Toujours libérer la caméra** :
   ```python
   picam2.stop()  # ou capture.release() pour OpenCV
   cv2.destroyAllWindows()
   ```

2. **Attendre l'initialisation** :
   ```python
   picam2.start()
   time.sleep(0.5)  # Minimum 0.5s, 2s pour auto-exposition
   ```

3. **Gérer les exceptions** :
   ```python
   try:
       picam2 = Picamera2()
       picam2.start()
       # ... code ...
   finally:
       picam2.stop()
   ```

4. **Utiliser des chemins absolus** pour les fichiers de sortie

---

## 🔗 Ressources

- [Documentation picamera2](https://datasheets.raspberrypi.com/camera/picamera2-manual.pdf)
- [libcamera documentation](https://libcamera.org/)
- [OpenCV Python Tutorials](https://docs.opencv.org/4.x/d6/d00/tutorial_py_root.html)

---

*Dernière mise à jour : 2026-03-04*
