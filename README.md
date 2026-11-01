# Serveur VPN IKEv2 / IPsec (StrongSwan) pour HomeLab

Ce dépôt contient les fichiers de configuration et les scripts nécessaires pour monter un serveur VPN IKEv2 robuste, compatible nativement avec iOS, Android, Windows et Linux. 

Le réseau local (HomeLab), qui tourne sur Xubuntu dans mon cas, est accessible depuis l'extérieur en 4G/5G ou Wi-Fi public et la connexion n'est pas interrompue après un changement de réseau.

## 📋 Prérequis
* Un ordinateur/serveur sous Linux (Ubuntu/Debian) connecté en **Ethernet** avec une IP locale fixe (ex: `192.168.1.121`).
* Un nom de domaine dynamique (ex: DuckDNS).
* Une redirection des ports **UDP 500** et **UDP 4500** depuis votre box internet vers l'IP du serveur Linux.
* Certificats générés via Let's Encrypt (`certbot certonly --standalone -d votre-domaine.com`).

## 🚀 Installation & Configuration

### 1. Certificats
Une fois les certificats générés avec Let's Encrypt, modifiez la variable `DOMAIN` dans `scripts/link-letsencrypt.sh` et exécutez-le pour lier les certificats à StrongSwan.

### 2. Configuration IPsec
1. Copiez le fichier `configs/strongswan/ipsec.conf` vers `/etc/ipsec.conf`.
2. À l'intérieur, remplacez `<VOTRE_DOMAINE>` par votre nom de domaine réel.

### 3. Gestion des utilisateurs
1. Renommez le modèle `configs/strongswan/ipsec.secrets.example` en `ipsec.secrets`.
2. Ajoutez vos utilisateurs selon le format défini (ex: `utilisateur : EAP "motdepasse"`).
3. Copiez ce fichier vers `/etc/ipsec.secrets`.

### 4. Pare-feu (UFW) et Routage (NAT)
Le script `setup-firewall.sh` ouvre les ports. Pour que le trafic internet fonctionne à travers le VPN, éditez `/etc/ufw/before.rules` manuellement et ajoutez ces lignes tout en haut du fichier (remplacez `enp1s0` par le nom de votre carte réseau Ethernet) :

*nat
-A POSTROUTING -s 10.10.10.0/24 -o enp1s0 -m policy --dir out --pol none -j MASQUERADE
COMMIT

Puis éditez `/etc/default/ufw` pour passer `DEFAULT_FORWARD_POLICY` à `"ACCEPT"`. Rechargez UFW avec la commande `sudo ufw reload`.

### 5. Mode "Serveur" pour Laptop
Si vous installez ceci sur un ordinateur portable, exécutez `scripts/laptop-server-mode.sh` pour empêcher le système de se mettre en veille lorsque l'écran est fermé.

---

## 📱 Connexion côté Client

La connexion s'effectue directement depuis les paramètres VPN de votre appareil avec ces identifiants universels :

* **Type de VPN :** IKEv2 (ou IPsec IKEv2 / MSCHAPv2)
* **Serveur / Passerelle :** `<VOTRE_DOMAINE>` (ex: mon-vpn.duckdns.org)
* **ID distant / Identifiant IPSec :** `<VOTRE_DOMAINE>`
* **Authentification :** Nom d'utilisateur et mot de passe (définis dans `ipsec.secrets`)

**Spécificités selon l'OS :**
* **iOS / Android / macOS & Windows /:** Allez dans Réglages > VPN > Ajouter.
* **Linux (Ubuntu) :** 
    1. Installez les paquets nécessaires dans le terminal :
     ```bash
     sudo apt update && sudo apt install network-manager-strongswan libstrongswan-extra-plugins libcharon-extra-plugins -y && sudo systemctl restart NetworkManager
     ```
    2. Dans les paramètres VPN d'Ubuntu (**Settings ➔ Network**), configurez comme indiqué au dessus et rajoutez en plus :
     * **Certificate :** Pointez vers `/etc/ssl/certs/ISRG_Root_X1.pem`.
     * **Options :** Cochez impérativement **"Request an inner IP address"** et **"Enforce UDP encapsulation"**.

---

## 🛠 Administration au quotidien

- **Ajouter ou modifier un mot de passe :** Éditez `/etc/ipsec.secrets`, puis rechargez les accès sans couper les connexions actives avec : `sudo ipsec rereadsecrets`
- **Voir les connexions et clients connectés :** `sudo swanctl --list-sas` (Affiche les tunnels actifs, les IP virtuelles attribuées et le trafic en temps réel).
- **Diagnostiquer une erreur :** `sudo journalctl -t charon -f` (Affiche les logs de connexion en temps réel).