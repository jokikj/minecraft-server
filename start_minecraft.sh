#!/bin/bash

# Lancer le serveur Minecraft avec l'utilisateur mcadmin dans un screen détaché
sudo -u mcadmin bash << EOF
cd /home/mcadmin/minecraftserver

# Lancer dans un screen nommé 'mc' pour lancer le serveur Minecraft
screen -dmS mc java -Xmx1024M -Xms1024M -jar server.jar nogui
EOF

# Obtenir l'IP locale IPv4 uniquement
IP_LOCALE=$(hostname -I | tr ' ' '\n' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n1)

# Obtenir l'IP publique IPv4 uniquement
IP_PUBLIQUE=$(curl -4 -s https://api64.ipify.org)

# Afficher les informations
echo -e "\033[1;34mLe serveur Minecraft est installé et en cours d'exécution.\033[0m"
echo -e "\033[1;34mAdresse IP locale :\033[0m \033[1;32m${IP_LOCALE}:${PORT}\033[0m"
echo -e "\033[1;34mAdresse IP publique :\033[0m \033[1;32m${IP_PUBLIQUE}:${PORT}\033[0m"
echo -e "\033[1;34mEmplacement du dossier de configuration :\033[0m \033[1;32m${CONFIG_DIR}\033[0m"
echo -e "\033[1;34mCommandes pour gérer le serveur :\033[0m"
echo -e "\033[1;33m  sudo -u mcadmin screen -r mc (pour rentrer dans la console du serveur minecraft)\033[0m"
echo -e "\033[1;33m  Ctrl + A, D (pour détacher la console)\033[0m"
echo -e "\033[1;33m  /stop (pour arrêter le serveur)\033[0m"
echo -e "\033[1;33m  Ctrl + D (pour quitter la console)\033[0m"
