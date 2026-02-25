# Guide : Capture d'écran sur Raspberry Pi (Wayland)

## Le Problème

Sur Raspberry Pi OS moderne (Debian 13 / Bookworm), l'environnement graphique utilise **Wayland** au lieu de **X11**. Les outils classiques comme `scrot` ne fonctionnent pas correctement :

- Captures noires (écran complet)
- Sélection de zone qui ne répond pas
- Problèmes de permissions d'affichage

## La Solution

Utiliser les outils natifs **Wayland** : `grim` et `slurp`

| Outil | Fonction | Équivalent X11 |
|-------|----------|----------------|
| `grim` | Capture d'écran | `scrot` |
| `slurp` | Sélection de zone | Mode `-s` de scrot |

## Installation

```bash
# grim et slurp sont généralement déjà installés sur Raspberry Pi OS
# Sinon :
sudo apt update
sudo apt install grim slurp
```

## Commandes de base

### Capture complète
```bash
grim ~/Images/capture.png
```

### Sélection de zone (interactif)
```bash
grim -g "$(slurp)" ~/Images/capture.png
```

### Avec nom automatique (date/heure)
```bash
grim ~/Images/capture_$(date +%Y%m%d_%H%M%S).png
```

## Script complet avec menu

Créer le fichier `~/.local/bin/capture-menu` :

```bash
#!/bin/bash
# Script de capture d'écran - Version compatible Wayland

# Variables d'environnement Wayland
export WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-wayland-1}
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$(id - u)}

mkdir -p ~/Images
FILENAME="$HOME/Images/capture_$(date +%Y%m%d_%H%M%S).png"

# Menu avec zenity
CHOICE=$(zenity --title="Capture d'écran" \
    --text="Choisir le mode de capture :" \
    --list --radiolist \
    --column="" --column="Mode" \
    TRUE "Zone (selection)" \
    FALSE "Ecran complet" \
    FALSE "Fenetre active" \
    --width=300 --height=220 2>/dev/null)

# Annulation
[ -z "$CHOICE" ] && exit 0

case "$CHOICE" in
    "Zone (selection)")
        # Notification + délai pour fermer le menu
        notify-send "Capture" "Clique et drag pour sélectionner..." --expire-time=2000 2>/dev/null
        sleep 0.5
        
        GEOMETRY=$(slurp 2>/dev/null)
        [ -n "$GEOMETRY" ] && grim -g "$GEOMETRY" "$FILENAME"
        ;;
    "Ecran complet")
        grim "$FILENAME"
        ;;
    "Fenetre active")
        grim "$FILENAME"
        ;;
esac

# Confirmation
[ -f "$FILENAME" ] && notify-send "✅ Capture sauvegardée" "$FILENAME" --icon=camera-photo 2>/dev/null
```

Rendre exécutable :
```bash
chmod +x ~/.local/bin/capture-menu
```

## Créer un lanceur (icône dans la barre)

Créer `~/.local/share/applications/capture-ecran.desktop` :

```ini
[Desktop Entry]
Name=📷 Capture
Comment=Capture d'écran
Exec=/home/oimadi/.local/bin/capture-menu
Icon=applets-screenshooter
Terminal=false
Type=Application
Categories=Graphics;Utility;
```

### Épingler sur la barre des tâches (Raspberry Pi OS)

**Méthode 1 : Menu démarrer**
1. Clic sur le menu (🍓)
2. Trouver "📷 Capture"
3. Clic droit → "Add to panel" ou "Épingler"

**Méthode 2 : Édition directe**

Éditer `~/.config/wf-panel-pi/wf-panel-pi.ini` :
```ini
launchers=capture-menu firefox x-www-browser pcmanfm x-terminal-emulator
```

Puis redémarrer le panel :
```bash
killall wf-panel-pi
wf-panel-pi &
```

## Points clés à retenir

| Problème | Cause | Solution |
|----------|-------|----------|
| Capture noire | Wayland bloque scrot | Utiliser `grim` |
| Sélection inactive | Menu cache la zone | Ajouter `sleep 0.5` |
| Pas de notification | `notify-send` manquant | Installer `libnotify-bin` |

## Dépendances

```bash
# Vérifier les outils installés
which grim slurp zenity notify-send

# Installer si manquant
sudo apt install grim slurp zenity libnotify-bin
```

## Dossier de sauvegarde

Les captures sont enregistrées dans :
```
~/Images/capture_YYYYMMDD_HHMMSS.png
```

Format : date et heure pour éviter les écrasements.

---

*Guide créé pour Raspberry Pi OS (Debian 13 / Wayland)*
