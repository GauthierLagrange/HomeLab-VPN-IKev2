#!/bin/bash
# Config du pare-feu UFW et routage NAT

echo "[*] Ouverture des ports IPsec/IKEv2..."
sudo ufw allow 500/udp
sudo ufw allow 4500/udp
sudo ufw allow OpenSSH

# TODO: Ajouter plus tard les règles iptables pour le NAT (masquerading) 
# pour que la plage 10.10.10.0/24 accède au net