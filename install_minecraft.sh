#!/bin/bash

# Script d'installation du serveur Minecraft

if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo ".env file not found!"
    exit 1
fi

# Mettre à jour les paquets
sudo apt update -y && sudo apt upgrade -y

# Installer Java 21 et screen
sudo apt-get install openjdk-21-jre-headless screen -y

# Ouvrir le port 25565 avec UFW et iptables
sudo ufw allow ${PORT}
sudo iptables -I INPUT -p tcp --dport ${PORT} -j ACCEPT

# Créer utilisateur

# Vérifier si l'utilisateur existe déjà

if id "${USER}" &>/dev/null; then
  echo -e "\033[1;34mL'utilisateur ${USER} existe déjà.\033[0m"
else
  sudo adduser --gecos "" --disabled-password ${USER}
  echo "${USER}:${USER}" | sudo chpasswd
  echo -e "\033[1;34mUtilisateur ${USER} créé avec succès.\033[0m"
fi

# Créer le dossier du serveur Minecraft
sudo mkdir -p /home/${USER}/minecraftserver
sudo chown ${USER}:${USER} /home/${USER}/minecraftserver

# Télécharger le serveur Minecraft avec l'utilisateur
sudo -u ${USER} bash << EOF
cd /home/${USER}/minecraftserver
wget https://piston-data.mojang.com/v1/objects/e6ec2f64e6080b9b5d9b471b291c33cc7f509733/server.jar

# Accepter l'EULA
echo -e "#By changing the setting below to TRUE you are indicating your agreement to our EULA (https://aka.ms/MinecraftEULA).\n#$(date -u)\neula=true" > eula.txt

# Lancer le serveur dans un screen détaché
screen -dmS mc java -Xmx${RAM} -Xms${RAM} -jar server.jar nogui
EOF

echo -e "\033[1;34mLe serveur Minecraft est installé!\033[0m"

# Obtenir l'IP locale IPv4 uniquement
IP_LOCALE=$(hostname -I | tr ' ' '\n' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n1)

# Obtenir l'IP publique IPv4 uniquement
IP_PUBLIQUE=$(curl -4 -s https://api64.ipify.org)

# Afficher les informations
echo -e "\033[1;34mLancement en cours du serveur veuillez patienter...\033[0m"

sleep 20

CONFIG_PATH="/home/${USER}/minecraftserver/server.properties"
CONFIG_PORT=$(sudo -u ${USER} grep "^server-port=" "$CONFIG_PATH" | cut -d'=' -f2)

echo -e "\033[1;34mAdresse IP locale :\033[0m \033[1;32m${IP_LOCALE}:${CONFIG_PORT}\033[0m"
echo -e "\033[1;34mAdresse IP publique :\033[0m \033[1;32m${IP_PUBLIQUE}:${CONFIG_PORT}\033[0m"
echo -e "\033[1;34mEmplacement du dossier de configuration :\033[0m \033[1;32m/home/${USER}/minecraftserver\033[0m"
echo -e "\033[1;34mCommandes pour gérer le serveur :\033[0m"
echo -e "\033[1;33m  sudo -u ${USER} screen -r mc (pour rentrer dans la console du serveur minecraft)\033[0m"
echo -e "\033[1;33m  Ctrl + A, D (pour détacher la console)\033[0m"
echo -e "\033[1;33m  /stop (pour arrêter le serveur)\033[0m"
echo -e "\033[1;33m  Ctrl + D (pour quitter la console)\033[0m"
