# 🔌 Accès SSH - Raspberry Pi 5

> Guide complet SSH : connexion, transferts, commandes et astuces

---

## 📋 Informations de Connexion

| Paramètre | Valeur |
|-----------|--------|
| **IP Locale** | `192.168.1.79` |
| **Nom d'utilisateur** | `oimadi` |
| **Port SSH** | `22` (défaut) |
| **Hostname** | `Kospy` (optionnel) |

---

## 🚀 Connexion Rapide

### Commande de base

```bash
ssh oimadi@192.168.1.79
```

### Avec mot de passe
Entrez le mot de passe utilisateur `oimadi` quand demandé.

### Connexion avec exécution d'une commande (sans rester connecté)

```bash
ssh oimadi@192.168.1.79 "ls -la"
```

---

## 🔧 Configuration Avancée

### 1. Connexion sans mot de passe (clé SSH)

**Sur l'ordinateur client :**

```bash
# Générer une clé SSH (si pas déjà fait)
ssh-keygen -t ed25519 -C "votre-email@example.com"

# Copier la clé publique vers le Raspberry Pi
ssh-copy-id oimadi@192.168.1.79
```

**Connexion sans mot de passe :**
```bash
ssh oimadi@192.168.1.79
```

---

### 2. Alias de connexion (~/.ssh/config)

**Sur l'ordinateur client, créer/modifier `~/.ssh/config` :**

```
Host rpi5
    HostName 192.168.1.79
    User oimadi
    Port 22
    IdentityFile ~/.ssh/id_ed25519
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

**Connexion simplifiée :**
```bash
ssh rpi5
```

---

## 📁 Transfert de Fichiers (SCP & SFTP)

### SCP - Copie Simple

**Envoyer un fichier Mac → Pi :**
```bash
scp mon-fichier.txt oimadi@192.168.1.79:/home/oimadi/
```

**Envoyer un fichier avec un nouveau nom :**
```bash
scp mon-fichier.txt oimadi@192.168.1.79:/home/oimadi/nouveau-nom.txt
```

**Envoyer un dossier entier :**
```bash
scp -r mon-dossier/ oimadi@192.168.1.79:/home/oimadi/
```

**Envoyer plusieurs fichiers :**
```bash
scp fichier1.txt fichier2.py oimadi@192.168.1.79:/home/oimadi/
```

**Récupérer un fichier Pi → Mac :**
```bash
scp oimadi@192.168.1.79:/home/oimadi/mon-fichier.txt ./
scp oimadi@192.168.1.79:/home/oimadi/mon-fichier.txt ~/Documents/
```

**Récupérer un dossier entier :**
```bash
scp -r oimadi@192.168.1.79:/home/oimadi/mon-projet/ ./
```

**Avec l'alias configuré :**
```bash
scp mon-fichier.txt rpi5:/home/oimadi/
scp -r rpi5:/home/oimadi/mon-projet/ ./
```

**Afficher la progression :**
```bash
scp -v mon-fichier.txt oimadi@192.168.1.79:/home/oimadi/
```

---

### Rsync - Synchronisation Avancée (recommandé pour les gros transferts)

**Synchroniser un dossier local vers le Pi :**
```bash
rsync -avz --progress mon-dossier/ oimadi@192.168.1.79:/home/oimadi/mon-dossier/
```

**Synchroniser du Pi vers le Mac :**
```bash
rsync -avz --progress oimadi@192.168.1.79:/home/oimadi/mon-projet/ ./mon-projet/
```

**Options utiles :**
- `-a` : archive (préserve permissions, dates)
- `-v` : verbose (détaille les opérations)
- `-z` : compresse pendant le transfert
- `--progress` : affiche la progression
- `--delete` : supprime les fichiers distants qui n'existent plus en local
- `--exclude='*.tmp'` : exclut certains fichiers

**Exemple avec exclusion :**
```bash
rsync -avz --exclude='*.pyc' --exclude='__pycache__/' ./mon-code/ rpi5:/home/oimadi/mon-code/
```

---

### SFTP - Mode Interactif

**Ouvrir une session SFTP :**
```bash
sftp oimadi@192.168.1.79
```

**Commandes disponibles en SFTP :**

| Commande | Description |
|----------|-------------|
| `ls` | Lister les fichiers distants |
| `lls` | Lister les fichiers locaux |
| `cd dossier` | Changer de dossier distant |
| `lcd dossier` | Changer de dossier local |
| `pwd` | Dossier courant distant |
| `lpwd` | Dossier courant local |
| `get fichier.txt` | Télécharger un fichier |
| `get -r dossier/` | Télécharger un dossier |
| `put fichier.txt` | Envoyer un fichier |
| `put -r dossier/` | Envoyer un dossier |
| `rm fichier.txt` | Supprimer un fichier distant |
| `rmdir dossier/` | Supprimer un dossier distant |
| `mkdir nouveau/` | Créer un dossier distant |
| `exit` ou `quit` | Quitter SFTP |

---

## 🔗 Tunnels et Redirections de Ports

### Tunnel SSH (Sécuriser VNC)

**Créer un tunnel SSH pour VNC sécurisé :**
```bash
ssh -L 5900:localhost:5900 oimadi@192.168.1.79
# Laisse ce terminal ouvert
# Puis connecte-toi à vnc://localhost:5900 sur ton Mac
```

### Rediriger un port du Pi vers ton Mac

**Accéder à un serveur web du Pi (port 8080) sur ton Mac :**
```bash
ssh -L 8080:localhost:8080 oimadi@192.168.1.79
# Ouvre http://localhost:8080 sur ton Mac
```

### Rediriger un port de ton Mac vers le Pi (reverse tunnel)

**Si tu veux que le Pi accède à un service sur ton Mac :**
```bash
ssh -R 3000:localhost:3000 oimadi@192.168.1.79
# Le Pi peut maintenant accéder à localhost:3000 pour atteindre ton Mac
```

---

## ⚡ Commandes SSH Utiles

### Exécuter une commande sans ouvrir de session

```bash
# Vérifier l'espace disque
ssh oimadi@192.168.1.79 "df -h"

# Voir les processus
ssh oimadi@192.168.1.79 "ps aux | grep python"

# Redémarrer le Pi
ssh oimadi@192.168.1.79 "sudo reboot"

# Mettre à jour le système
ssh oimadi@192.168.1.79 "sudo apt update && sudo apt upgrade -y"

# Voir les logs en temps réel
ssh oimadi@192.168.1.79 "tail -f /var/log/syslog"
```

### Copier via SSH (pipe)

**Envoyer le contenu d'une commande dans un fichier :**
```bash
cat mon-fichier.txt | ssh oimadi@192.168.1.79 "cat > /home/oimadi/fichier.txt"
```

**Récupérer un fichier et l'afficher :**
```bash
ssh oimadi@192.168.1.79 "cat /etc/os-release"
```

---

## 🖥️ Commandes Utiles sur le Raspberry Pi

### Système

| Commande | Description |
|----------|-------------|
| `sudo reboot` | Redémarrer le système |
| `sudo shutdown -h now` | Arrêter le système |
| `sudo shutdown -h +10` | Arrêter dans 10 minutes |
| `uptime` | Temps depuis le dernier démarrage |
| `hostname -I` | Afficher l'IP du Pi |
| `whoami` | Nom d'utilisateur courant |

### Services

| Commande | Description |
|----------|-------------|
| `systemctl status ssh` | Vérifier le statut SSH |
| `systemctl status wayvnc` | Vérifier le statut VNC |
| `sudo systemctl restart ssh` | Redémarrer SSH |
| `sudo systemctl enable ssh` | Activer SSH au démarrage |
| `sudo journalctl -u ssh` | Voir les logs SSH |

### Monitoring

| Commande | Description |
|----------|-------------|
| `htop` | Monitorer les ressources (CPU, RAM) |
| `df -h` | Espace disque disponible |
| `free -h` | Mémoire RAM utilisée |
| `top` | Processus en cours |
| `vcgencmd measure_temp` | Température du CPU (Raspberry Pi) |
| `vcgencmd get_throttled` | Vérifier si le Pi a été sous-alimenté |

### Fichiers et Navigation

| Commande | Description |
|----------|-------------|
| `ls -la` | Lister fichiers (détaillé) |
| `cd /chemin` | Changer de dossier |
| `pwd` | Dossier actuel |
| `mkdir nouveau-dossier` | Créer un dossier |
| `rm fichier.txt` | Supprimer un fichier |
| `rm -r dossier/` | Supprimer un dossier |
| `cp source dest` | Copier |
| `mv source dest` | Déplacer/renommer |
| `cat fichier.txt` | Afficher contenu fichier |
| `nano fichier.txt` | Éditer avec nano |
| `less fichier.txt` | Afficher page par page |
| `grep "texte" fichier.txt` | Rechercher du texte |
| `find / -name "*.py"` | Chercher des fichiers |

### Python / Développement

| Commande | Description |
|----------|-------------|
| `python3 script.py` | Exécuter un script Python |
| `python3 -m venv env` | Créer un environnement virtuel |
| `source env/bin/activate` | Activer l'environnement |
| `deactivate` | Désactiver l'environnement |
| `pip install package` | Installer un package Python |
| `pip list` | Lister les packages installés |

---

## 📁 Emplacements Importants sur le Pi

| Chemin | Description |
|--------|-------------|
| `/home/oimadi/` | Dossier utilisateur |
| `/home/oimadi/mes_ressources_md/` | Stockage documents/projets |
| `/home/oimadi/.openclaw/workspace/` | Workspace OpenClaw |
| `/home/oimadi/projects/` | Projets personnels |
| `/home/oimadi/.ssh/` | Clés SSH |
| `/etc/` | Fichiers de configuration système |
| `/var/log/` | Fichiers de logs |

---

## ⚠️ Dépannage

### Le Raspberry Pi ne répond pas

1. **Vérifier que le Pi est allumé** (LED verte clignote)
2. **Vérifier l'IP** (peut changer si DHCP) :
   ```bash
   # Depuis le Pi lui-même
   hostname -I
   ```
3. **Scanner le réseau** depuis un autre ordi :
   ```bash
   nmap -sn 192.168.1.0/24
   ```

### "Connection refused"

Le service SSH n'est peut-être pas démarré :
```bash
# Sur le Raspberry Pi
sudo systemctl enable --now ssh
```

### "Connection timed out"

- Vérifier que le Pi est sur le même réseau WiFi
- Vérifier le pare-feu : `sudo ufw status`
- Tester le ping : `ping 192.168.1.79`

### IP dynamique (DHCP)

Si l'IP change souvent :
1. Configurer une IP statique sur le routeur
2. Ou utiliser le hostname : `ssh oimadi@Kospy.local`
3. Ou installer `avahi-daemon` sur le Pi pour le mDNS

### Connexion très lente

Ajouter dans `~/.ssh/config` côté client :
```
Host rpi5
    HostName 192.168.1.79
    User oimadi
    UseDNS no
    GSSAPIAuthentication no
```

---

## 📝 Cheat Sheet Rapide

```bash
# Connexion
ssh oimadi@192.168.1.79

# Avec alias
ssh rpi5

# Transferts
scp fichier.txt rpi5:/home/oimadi/
scp -r dossier/ rpi5:/home/oimadi/
rsync -avz dossier/ rpi5:/home/oimadi/dossier/

# Commandes distantes
ssh rpi5 "sudo reboot"
ssh rpi5 "htop"

# Tunnels
ssh -L 5900:localhost:5900 rpi5    # VNC sécurisé
ssh -L 8080:localhost:8080 rpi5    # Redirection web
```

---

## 🔗 Liens Utiles

- [Documentation SSH Ubuntu](https://ubuntu.com/server/docs/service-openssh)
- [Guide SSH DigitalOcean](https://www.digitalocean.com/community/tutorials/ssh-essentials-working-with-ssh-servers-clients-and-keys)
- [Manuel SCP](https://man7.org/linux/man-pages/man1/scp.1.html)
- [Manuel Rsync](https://man7.org/linux/man-pages/man1/rsync.1.html)

---

*Dernière mise à jour : 2026-03-13*
*Raspberry Pi 5 - Debian GNU/Linux 13 (trixie)*
