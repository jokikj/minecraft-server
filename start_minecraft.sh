#!/bin/bash

# Variable dans le fichier .env
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo ".env file not found!"
    exit 1
fi

# Obtenir l'IP locale IPv4 uniquement
IP_LOCALE=$(hostname -I | tr ' ' '\n' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n1)

# Chemin vers server.properties
SERVER_PROPERTIES="/home/${USER}/minecraftserver/server.properties"

# Lire le port actuel dans le fichier
CONFIG_PORT=$(sudo -u ${USER} grep "^server-port=" "$SERVER_PROPERTIES" | cut -d'=' -f2)

if [[ "$CONFIG_PORT" != "$PORT" ]]; then
  echo -e "\033[1;33mLe port actuel est $CONFIG_PORT, changement du port en cours...\033[0m"

  # Modifier le port dans le fichier de config
  sudo -u ${USER} sed -i "s/^server-port=.*/server-port=${PORT}/" "$SERVER_PROPERTIES"
  echo -e "\033[1;32mPort changé avec succès dans $SERVER_PROPERTIES : server-port=${PORT}\033[0m"

  # Lancer le serveur Minecraft avec l'utilisateur mcadmin dans un screen détaché
  sudo -u ${USER} bash << EOF
cd /home/${USER}/minecraftserver
# Lancer dans un screen nommé 'mc' pour lancer le serveur Minecraft
screen -dmS mc java -Xmx${RAM} -Xms${RAM} -jar server.jar nogui
EOF
else
  # Lancer le serveur Minecraft avec l'utilisateur mcadmin dans un screen détaché
  sudo -u ${USER} bash << EOF
cd /home/${USER}/minecraftserver

# Lancer dans un screen nommé 'mc' pour lancer le serveur Minecraft
screen -dmS mc java -Xmx${RAM} -Xms${RAM} -jar server.jar nogui
EOF
  # Afficher les informations
  echo -e "\033[1;34mLancement en cours du serveur veuillez patienter...\033[0m"
  sleep 5
fi

# Obtenir l'IP publique IPv4 uniquement
IP_PUBLIQUE=$(curl -4 -s https://api64.ipify.org)

# Obtenir le port dans le fichier de configuration
CONFIG_PORT=$(sudo -u ${USER} grep "^server-port=" "$SERVER_PROPERTIES" | cut -d'=' -f2)

# Afficher les informations
echo -e "\033[1;34m-------------------------------\033[0m"
echo -e "\033[1;34mInformation sur le serveur :\033[0m"
echo -e "\033[1;34mAdresse IP locale :\033[0m \033[1;32m${IP_LOCALE}:${CONFIG_PORT}\033[0m"
echo -e "\033[1;34mAdresse IP publique :\033[0m \033[1;32m${IP_PUBLIQUE}:${CONFIG_PORT}\033[0m \033[1;36m(Si le port est ouvert sur la box)\033[0m"
echo -e "\033[1;34mEmplacement du dossier de configuration :\033[0m \033[1;32m/home/${USER}/minecraftserver\033[0m"
echo -e "\033[1;34mCommandes pour gérer le serveur :\033[0m"
echo -e "\033[1;33m  sudo -u ${USER} screen -r mc \033[1;36m(pour rentrer dans la console du serveur minecraft)\033[0m"
echo -e "\033[1;33m  /stop \033[1;36m(pour arrêter le serveur)\033[0m"
echo -e "\033[1;33m  Ctrl + A, D \033[1;36m(pour détacher la console)\033[0m"
echo -e "\033[1;33m  Ctrl + D \033[1;36m(pour quitter la console)\033[0m"

