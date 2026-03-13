# 🔌 Accès SSH - Raspberry Pi 5

> Guide rapide pour se connecter au Raspberry Pi 5 depuis un autre ordinateur

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

### Depuis Linux / macOS / Windows (PowerShell/WSL)

```bash
ssh oimadi@192.168.1.79
```

### Avec mot de passe
Entrez le mot de passe utilisateur `oimadi` quand demandé.

---

## 🔧 Configuration Optionnelle

### 1. Connexion sans mot de passe (clé SSH)

**Sur l'ordinateur client :**

```bash
# Générer une clé SSH (si pas déjà fait)
ssh-keygen -t ed25519 -C "votre-email@example.com"

# Copier la clé publique vers le Raspberry Pi
ssh-copy-id oimadi@192.168.1.79
```

Ensuite, connexion sans mot de passe :
```bash
ssh oimadi@192.168.1.79
```

---

### 2. Alias de connexion (~/.ssh/config)

**Sur l'ordinateur client, ajouter dans `~/.ssh/config` :**

```
Host rpi5
    HostName 192.168.1.79
    User oimadi
    Port 22
    IdentityFile ~/.ssh/id_ed25519
```

**Puis connectez-vous simplement avec :**
```bash
ssh rpi5
```

---

### 3. Transfert de fichiers (SCP / SFTP)

**Copier un fichier vers le Raspberry Pi :**
```bash
scp mon-fichier.txt oimadi@192.168.1.79:/home/oimadi/
```

**Copier un fichier depuis le Raspberry Pi :**
```bash
scp oimadi@192.168.1.79:/home/oimadi/mon-fichier.txt ./
```

**Avec l'alias configuré :**
```bash
scp mon-fichier.txt rpi5:/home/oimadi/
```

---

## 🛠️ Commandes Utiles sur le Raspberry Pi

| Commande | Description |
|----------|-------------|
| `sudo reboot` | Redémarrer le système |
| `sudo shutdown -h now` | Arrêter le système |
| `systemctl status ssh` | Vérifier le statut SSH |
| `ip addr show` | Vérifier l'IP (si elle change) |
| `htop` | Monitorer les ressources |

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

### IP dynamique (DHCP)

Si l'IP change souvent, configurer une IP statique sur le routeur ou utiliser le hostname :
```bash
ssh oimadi@Kospy.local
```

---

## 📁 Emplacements Importants sur le Pi

| Chemin | Description |
|--------|-------------|
| `/home/oimadi/` | Dossier utilisateur |
| `/home/oimadi/mes_ressources_md/` | Stockage documents/projets |
| `/home/oimadi/.openclaw/workspace/` | Workspace OpenClaw |
| `/home/oimadi/projects/` | Projets personnels |

---

## 🔗 Liens Utiles

- [Documentation SSH Ubuntu](https://ubuntu.com/server/docs/service-openssh)
- [Guide SSH DigitalOcean](https://www.digitalocean.com/community/tutorials/ssh-essentials-working-with-ssh-servers-clients-and-keys)

---

*Dernière mise à jour : 2026-03-13*
*Raspberry Pi 5 - Debian GNU/Linux 13 (trixie)*
