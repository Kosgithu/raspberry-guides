# 🖥️ Commandes Terminal - Linux Raspberry Pi

Collection de commandes utiles pour le terminal.

---

## 🎨 Personnalisation & Thème

### Appliquer le fond d'écran
```bash
# Avec feh (recommandé)
feh --bg-scale ~/Pictures/wallpapers/mon-fond-cyberpunk.png

# Avec PCManFM
pcmanfm --set-wallpaper="$HOME/Pictures/wallpapers/mon-fond-cyberpunk.png"
```

### Changer le thème GTK
```bash
# Ouvrir le sélecteur de thème
lxappearance
```

### Lancer Notion
```bash
# Via le script
bash ~/lancer-notion.sh

# Ou directement dans Chromium
chromium https://www.notion.so
```

---

## 📁 Gestion de Fichiers

### Navigation
```bash
# Aller dans un dossier
cd /home/oimadi/mes_ressources_md

# Revenir au dossier parent
cd ..

# Aller au dossier personnel
cd ~

# Voir le dossier courant
pwd
```

### Lister les fichiers
```bash
# Liste simple
ls

# Liste détaillée avec tailles
ls -lh

# Voir les fichiers cachés
ls -la
```

### Copier/Déplacer/Supprimer
```bash
# Copier un fichier
cp fichier_source fichier_destination

# Copier un dossier (récursif)
cp -r dossier_source dossier_destination

# Déplacer/Renommer
mv ancien_nom nouveau_nom

# Supprimer un fichier
rm fichier

# Supprimer un dossier
rm -r dossier

# Supprimer avec confirmation
trm fichier  # (si trash-cli installé)
```

---

## 🔧 OpenCV & Python

### Lancer un script Python
```bash
# Exécuter un script
python3 script.py

# Exécuter avec OpenCV (exemple du cours)
cd /home/oimadi/mes_ressources_md/Ressources_Udemy/Codes/Course_codes_image
python3 4.1-Load_Display_Save.py
```

### Installer des packages
```bash
# Installer OpenCV
sudo apt install python3-opencv

# Installer via pip
pip3 install numpy
pip3 install opencv-python
```

---

## 🌐 Navigation Web

### Ouvrir une URL
```bash
# Avec Chromium
chromium https://www.notion.so

# Avec Firefox
firefox https://www.notion.so
```

### Télécharger un fichier
```bash
# Télécharger une image
curl -L -o image.jpg "https://example.com/image.jpg"

# Avec wget
wget https://example.com/fichier.txt
```

---

## 🖨️ Impression 3D & MakerWorld

### Ouvrir Inkscape
```bash
inkscape

# Ouvrir un fichier spécifique
inkscape /home/oimadi/mes_ressources_md/Porte_carte/PVCCVF.svg
```

### Gérer les fichiers STL/3MF
```bash
# Voir les fichiers 3D
ls -lh ~/mes_ressources_md/Porte_carte/*.stl
ls -lh ~/mes_ressources_md/Porte_carte/*.3mf
```

---

## 🔍 Recherche & Informations

### Chercher un fichier
```bash
# Par nom
find ~ -name "*.svg"

# Par contenu
grep -r "cv2.imread" ~/notes/
```

### Informations système
```bash
# Espace disque
df -h

# Mémoire libre
free -h

# Processus en cours
top

# Version du système
cat /etc/os-release
```

---

## ⚡ Raccourcis Terminal

| Raccourci | Action |
|-----------|--------|
| `Ctrl + C` | Arrêter la commande en cours |
| `Ctrl + L` | Effacer l'écran |
| `Tab` | Auto-complétion |
| `↑` / `↓` | Historique des commandes |
| `Ctrl + A` | Début de ligne |
| `Ctrl + E` | Fin de ligne |

---

*Document créé par Koseus le 2026-02-21*
