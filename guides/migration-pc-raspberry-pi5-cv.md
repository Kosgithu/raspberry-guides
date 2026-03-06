# Migration PC → Raspberry Pi 5 : Guide des Changements Majeurs

Guide de migration pour adapter les scripts Computer Vision d'un PC (webcam USB) vers un **Raspberry Pi 5 avec caméra CSI**.

---

## ⚠️ Pourquoi cette migration est nécessaire ?

Sur **Raspberry Pi 5 avec caméra CSI**, `cv2.VideoCapture(0)` **ne fonctionne PAS** à cause d'un bug avec le backend GStreamer. La solution est d'utiliser **picamera2** pour la capture, puis OpenCV pour le traitement d'image.

---

## Les 4 Changements Majeurs

### 1. Bibliothèque Spécifique

#### ❌ Avant (PC)
```python
import cv2
```

#### ✅ Après (Raspberry Pi 5)
```python
import cv2
from picamera2 import Picamera2  # Bibliothèque spécifique Pi
import time                       # Pour le délai d'initialisation
```

> **Note** : La librairie `picamera2` est nécessaire pour piloter le système `libcamera` du Pi 5.

---

### 2. Initialisation de la Caméra

#### ❌ Avant (PC)
```python
cap = cv2.VideoCapture(0)  # Ouverture simple de la webcam
```

#### ✅ Après (Raspberry Pi 5)
```python
# Initialisation picamera2
picam2 = Picamera2()

# Configuration de la capture
config = picam2.create_preview_configuration(
    main={"format": "BGR888", "size": (640, 480)}
)

picam2.configure(config)
picam2.start()

# Délai pour l'ajustement auto (exposition, focus...)
time.sleep(0.5)
```

| Paramètre | Description | Valeurs courantes |
|-----------|-------------|-------------------|
| `format` | Format des pixels | `"BGR888"` (recommandé), `"RGB888"` |
| `size` | Résolution | `(640, 480)` = VGA rapide, `(1920, 1080)` = Full HD lent |

> 💡 **Astuce** : Le format `"BGR888"` évite d'avoir à inverser les couleurs manuellement. Si vous utilisez `"RGB888"`, il faudra convertir avec `cv2.cvtColor(frame, cv2.COLOR_RGB2BGR)`.

---

### 3. Capture dans la Boucle

#### ❌ Avant (PC)
```python
while True:
    ret, frame = cap.read()  # Lecture de la frame
    if not ret:
        break
    # ... traitement ...
```

#### ✅ Après (Raspberry Pi 5)
```python
while True:
    frame = picam2.capture_array()  # Capture directe
    # ... traitement ...
    # Pas besoin de vérifier 'ret', picamera2 gère les erreurs
```

> **Avantage** : Le format `BGR888` configuré à l'initialisation évite la conversion manuelle des couleurs.

---

### 4. Fermeture Propre (Sécurité)

#### ❌ Avant (PC)
```python
cap.release()
cv2.destroyAllWindows()
```

#### ✅ Après (Raspberry Pi 5)
```python
try:
    while True:
        frame = picam2.capture_array()
        # ... traitement ...
        
        if cv2.waitKey(1) == 27:  # ESC pour quitter
            break
finally:
    # Libération IMPÉRATIVE de la caméra
    picam2.stop()
    cv2.destroyAllWindows()
```

> ⚠️ **CRITIQUE** : Utiliser impérativement un bloc `try...finally` pour garantir la libération de la caméra, même en cas d'erreur ou d'interruption.

---

## Exemple Complet : Avant vs Après

### 🔵 Version PC (Webcam USB)

```python
import cv2

# Initialisation
cap = cv2.VideoCapture(0)

while True:
    ret, frame = cap.read()
    if not ret:
        break
    
    # Traitement OpenCV
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    cv2.imshow('PC Webcam', frame)
    
    if cv2.waitKey(1) == 27:
        break

cap.release()
cv2.destroyAllWindows()
```

### 🟢 Version Raspberry Pi 5 (Caméra CSI)

```python
import cv2
from picamera2 import Picamera2
import time

# Initialisation
picam2 = Picamera2()
config = picam2.create_preview_configuration(
    main={"format": "BGR888", "size": (640, 480)}
)
picam2.configure(config)
picam2.start()
time.sleep(0.5)

try:
    while True:
        frame = picam2.capture_array()
        
        # Traitement OpenCV (déjà en BGR avec BGR888)
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        cv2.imshow('Pi 5 CSI', frame)
        
        if cv2.waitKey(1) == 27:
            break
finally:
    picam2.stop()
    cv2.destroyAllWindows()
```

---

## Tableau Récapitulatif

| Aspect | PC (cv2.VideoCapture) | Raspberry Pi 5 (picamera2) |
|--------|----------------------|---------------------------|
| **Import** | `import cv2` | `import cv2, time` + `from picamera2 import Picamera2` |
| **Initialisation** | `cv2.VideoCapture(0)` | `Picamera2()` + `configure()` + `start()` |
| **Format** | BGR natif | Configurable (BGR888 recommandé) |
| **Capture** | `ret, frame = cap.read()` | `frame = picam2.capture_array()` |
| **Arrêt** | `cap.release()` | `picam2.stop()` |
| **Gestion erreurs** | Vérifier `ret` | Utiliser `try...finally` |
| **Fonctionne sur RPi 5** | ❌ Bug GStreamer | ✅ Fonctionne parfaitement |

---

## Pièges à Éviter

### ❌ Mauvais : Oublier le `try...finally`
```python
picam2.start()
while True:
    frame = picam2.capture_array()
    # ...
# Si crash ici, la caméra reste bloquée !
picam2.stop()
```

### ✅ Bon : Protection avec `try...finally`
```python
picam2.start()
try:
    while True:
        frame = picam2.capture_array()
        # ...
finally:
    picam2.stop()  # Toujours exécuté, même en cas de crash
```

### ❌ Mauvais : Mauvais format de couleur
```python
# Avec RGB888 sans conversion
picam2.configure(picam2.create_preview_configuration(
    main={"format": "RGB888", "size": (640, 480)}
))
frame = picam2.capture_array()
cv2.imshow('Image', frame)  # Couleurs inversées (rouge ↔ bleu) !
```

### ✅ Bon : BGR888 ou conversion explicite
```python
# Option 1 : Utiliser BGR888 directement
picam2.configure(picam2.create_preview_configuration(
    main={"format": "BGR888", "size": (640, 480)}
))
frame = picam2.capture_array()  # Déjà en BGR

# Option 2 : Convertir si RGB888
picam2.configure(picam2.create_preview_configuration(
    main={"format": "RGB888", "size": (640, 480)}
))
frame = picam2.capture_array()
frame = cv2.cvtColor(frame, cv2.COLOR_RGB2BGR)  # Conversion
```

---

## Installation de picamera2

Si `picamera2` n'est pas installé sur votre Raspberry Pi :

```bash
# Sur Raspberry Pi OS (bullseye/bookworm)
sudo apt update
sudo apt install python3-picamera2

# Ou via pip
pip install picamera2
```

---

## Ressources

- [Documentation picamera2](https://datasheets.raspberrypi.com/camera/picamera2-manual.pdf)
- [OpenCV Haar Cascades](https://github.com/opencv/opencv/tree/master/data/haarcascades)
- [Guide libcamera Raspberry Pi](https://www.raspberrypi.com/documentation/computers/camera_software.html)

---

*Document créé le 6 mars 2026 pour la migration des projets Computer Vision de Madi.*
