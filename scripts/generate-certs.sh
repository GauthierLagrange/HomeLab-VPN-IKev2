#!/bin/bash
# Setup PKI pour strongSwan IKEv2
# À run sur l'Acer après l'install

set -e # Stop le script si une commande fail

VPN_DOMAIN="<METTRE_IP_PUBLIQUE_FREEBOX>"
# TODO: Acheter un vrai nom de domaine et passer sur Let's Encrypt plus tard

mkdir -p ~/pki/{cacerts,certs,private}
chmod 700 ~/pki

echo "[*] Génération de la Root CA..."
pki --gen --type ed25519 --outform pem > ~/pki/private/ca-key.pem
pki --self --ca --lifetime 3650 --in ~/pki/private/ca-key.pem \
    --type ed25519 --dn "CN=Gauthier HomeLab CA" \
    --outform pem > ~/pki/cacerts/ca-cert.pem

echo "[*] Génération du certif Serveur..."
pki --gen --type ed25519 --outform pem > ~/pki/private/server-key.pem
pki --pub --in ~/pki/private/server-key.pem --type ed25519 | \
    pki --issue --lifetime 1825 \
    --cacert ~/pki/cacerts/ca-cert.pem \
    --cakey ~/pki/private/ca-key.pem \
    --dn "CN=$VPN_DOMAIN" --san "$VPN_DOMAIN" \
    --flag serverAuth --flag ikeIntermediate \
    --outform pem > ~/pki/certs/server-cert.pem

echo "[+] Done. Les certificats sont dans ~/pki/"