#!/bin/bash

# Script d'installation du serveur Minecraft

# Définir les variables
CONFIG_DIR="/home/mcadmin/minecraftserver"
PORT="25565" #Default 25565
RAM="8G" #Default 1024M

# Mettre à jour les paquets
sudo apt update -y && sudo apt upgrade -y

# Installer Java 21 et screen
sudo apt-get install openjdk-21-jre-headless screen -y

# Ouvrir le port 25565 avec UFW et iptables
sudo ufw allow ${PORT}
sudo iptables -I INPUT -p tcp --dport ${PORT} -j ACCEPT

# Créer utilisateur
# Vérifier si l'utilisateur mcadmin existe déjà

if id "mcadmin" &>/dev/null; then
  echo "L'utilisateur mcadmin existe déjà."
else
  sudo adduser --gecos "" --disabled-password mcadmin
  echo "mcadmin:mcadmin" | sudo chpasswd
  echo "Utilisateur mcadmin créé avec succès."
fi

# Créer le dossier du serveur Minecraft
sudo mkdir -p ${CONFIG_DIR}
sudo chown mcadmin:mcadmin ${CONFIG_DIR}

# Télécharger le serveur Minecraft avec l'utilisateur mcadmin
sudo -u mcadmin bash << EOF
cd /home/mcadmin/minecraftserver
wget https://piston-data.mojang.com/v1/objects/e6ec2f64e6080b9b5d9b471b291c33cc7f509733/server.jar

# Accepter l'EULA
echo -e "#By changing the setting below to TRUE you are indicating your agreement to our EULA (https://aka.ms/MinecraftEULA).\n#$(date -u)\neula=true" > eula.txt

# Modifier server-port
# sed -i "s/^server-port=.*/server-port=${PORT}/" /home/mcadmin/minecraftserver/server.properties

# Modifier query.port
# sed -i "s/^query.port=.*/query.port=${PORT}/" /home/mcadmin/minecraftserver/server.properties

# Modifier rcon.port
# sed -i "s/^rcon.port=.*/rcon.port=${PORT}/" /home/mcadmin/minecraftserver/server.properties

# Lancer le serveur dans un screen détaché
screen -dmS mc java -Xmx${RAM} -Xms${RAM} -jar server.jar nogui

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
