#!/bin/bash
# Ce script lie les certificats Let's Encrypt aux dossiers de strongSwan

DOMAIN="<VOTRE_DOMAINE>"

echo "[*] Création des liens symboliques pour $DOMAIN..."
sudo ln -sf /etc/letsencrypt/live/$DOMAIN/fullchain.pem /etc/ipsec.d/certs/fullchain.pem
sudo ln -sf /etc/letsencrypt/live/$DOMAIN/privkey.pem /etc/ipsec.d/private/privkey.pem
sudo ln -sf /etc/ssl/certs/ISRG_Root_X1.pem /etc/ipsec.d/cacerts/

echo "[+] Liens créés avec succès."