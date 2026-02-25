# Guide de Mise en Service : Raspberry Pi 5 + NVMe SSD

> Ce document résume la configuration de ton **nœud de calcul** pour garantir performance et longévité.

---

## 📋 Table des matières

1. [Configuration Matérielle & Boot](#1-configuration-matérielle--boot)
2. [Optimisation du Système de Fichiers](#2-optimisation-du-système-de-fichiers-ssd)
3. [Surveillance et Santé](#3-surveillance-et-santé-cheat-sheet)
4. [Stratégie de Sécurité](#4-stratégie-de-sécurité-le-filet)
5. [Gestion Thermique](#5-gestion-thermique-active-cooler)

---

## 1. Configuration Matérielle & Boot

Pour atteindre les **760 MB/s** que tu as constatés, le système doit être forcé en mode haute performance.

### Activation du PCIe Gen 3

```bash
sudo raspi-config
```

**Chemin :** `Advanced Options` > `PCIe Speed` > `Gen 3` (Yes)

### Priorité au Boot

**Chemin :** `Advanced Options` > `Boot Order` > `NVMe/USB Boot`

> **Note :** Le Pi cherchera le SSD en premier si la carte SD est absente.

---

## 2. Optimisation du Système de Fichiers (SSD)

Contrairement à une carte SD, un SSD a besoin de **"maintenance invisible"** pour rester rapide.

### Le TRIM (Indispensable)

Le TRIM permet au SSD de savoir quels blocs de données ne sont plus utilisés pour les effacer proprement en arrière-plan.

#### Vérification manuelle

```bash
sudo fstrim -v /
```

#### Automatisation

Normalement activé par défaut, mais tu peux forcer une exécution hebdomadaire :

```bash
sudo systemctl enable fstrim.timer
```

---

## 3. Surveillance et Santé (Cheat Sheet)

Garde ces commandes sous le coude pour vérifier que ton **bolide** ne surchauffe pas.

| Commande | Utilité |
|----------|---------|
| `lsblk` | Vérifier que le système est bien monté sur `nvme0n1` |
| `sudo hdparm -tT /dev/nvme0n1` | Mesurer la vitesse brute (score cible : **> 700 MB/s**) |
| `vcgencmd measure_temp` | Surveiller la température (cible au repos : **40-50°C**) |
| `df -h` | Voir l'occupation réelle du SSD Samsung |

### Exemple de vérification rapide

```bash
# Vérifier le disque de boot
lsblk

# Test de vitesse
sudo hdparm -tT /dev/nvme0n1

# Température CPU
vcgencmd measure_temp
```

---

## 4. Stratégie de Sécurité (Le Filet)

> **Règle d'or :** Ton SSD est ton cerveau actif, ta carte SD est ta mémoire de secours.

### Stockage de la SD

Garde ta carte SD d'origine **hors du Pi**. Elle contient ta configuration **"miroir"** prête à l'emploi.

### Backups GitHub

Puisque tu es développeur, utilise tes agents pour `git push` tes codes quotidiennement. Le matériel peut chauffer, mais le code doit être sur le cloud.

```bash
# Backup rapide
git add .
git commit -m "Backup quotidien $(date +%Y-%m-%d)"
git push
```

---

## 5. Gestion Thermique (Active Cooler)

Ton Pi 5 consomme plus d'énergie avec un SSD NVMe.

### Seuil d'alerte

Si tu dépasses **80°C régulièrement**, vérifie le flux d'air de ton boîtier.

### Comportement IA

L'usage intensif de **Llama 3 local** fera toujours monter la température. C'est le signe que le SSD fournit les données assez vite pour saturer le CPU.

```bash
# Monitoring température en temps réel
while true; do
    vcgencmd measure_temp
    sleep 5
done
```

---

## 🎯 Checklist de démarrage

- [ ] PCIe Gen 3 activé dans raspi-config
- [ ] Boot order configuré (NVMe prioritaire)
- [ ] TRIM activé (`sudo systemctl status fstrim.timer`)
- [ ] Test de vitesse effectué (> 700 MB/s)
- [ ] Température vérifiée au repos (< 50°C)
- [ ] Carte SD de secours stockée hors Pi
- [ ] Repo GitHub configuré pour backups

---

## 🔗 Ressources complémentaires

- [Documentation Raspberry Pi](https://www.raspberrypi.com/documentation/)
- [Guide NVMe sur Raspberry Pi](https://www.raspberrypi.com/products/ssd/)

---

*Guide créé le 2026-02-25 pour Raspberry Pi 5 + SSD Samsung NVMe Gen 3*
