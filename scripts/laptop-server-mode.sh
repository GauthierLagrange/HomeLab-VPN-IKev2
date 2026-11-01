#!/bin/bash
# Désactive la mise en veille pour transformer un laptop en serveur H24

echo "[*] Blocage des cibles de mise en veille..."
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

echo "[*] Modification du comportement de l'écran (Lid Switch)..."
sudo sed -i 's/#HandleLidSwitch=suspend/HandleLidSwitch=ignore/' /etc/systemd/logind.conf

echo "[+] Redémarrage du gestionnaire de sessions..."
sudo systemctl restart systemd-logind
echo "Le PC ne s'endormira plus si on ferme l'écran."