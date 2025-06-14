#!/bin/bash

# Script d'installation du serveur Minecraft

# Mettre à jour les paquets
sudo apt update -y && sudo apt upgrade -y

# Installer Java 21 et screen
sudo apt-get install openjdk-21-jre-headless screen -y

# Ouvrir le port 25565 avec UFW et iptables
sudo ufw allow 25565
sudo iptables -I INPUT -p tcp --dport 25565 -j ACCEPT

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
sudo mkdir -p /home/mcadmin/minecraftserver
sudo chown mcadmin:mcadmin /home/mcadmin/minecraftserver

# Télécharger le serveur Minecraft avec l'utilisateur mcadmin
sudo -u mcadmin bash << EOF
cd /home/mcadmin/minecraftserver
wget https://piston-data.mojang.com/v1/objects/e6ec2f64e6080b9b5d9b471b291c33cc7f509733/server.jar

# Accepter l'EULA
echo -e "#By changing the setting below to TRUE you are indicating your agreement to our EULA (https://aka.ms/MinecraftEULA).\n#$(date -u)\neula=true" > eula.txt

# Lancer le serveur dans un screen détaché
screen -dmS mc java -Xmx1024M -Xms1024M -jar server.jar nogui
EOF

# Afficher les instructions
echo -e "\033[0mLe serveur Minecraft est installé et en cours d'exécution."
echo -e "Adresse IP Privé : \033[1;32m$(hostname -I | awk '{print $1}'):25565\033[0m"
echo -e "Informations serveur :"
echo -e "- Pour accéder au fichier de configuration : \033[1;32m/home/mcadmin/minecraftserver/server.properties\033[0m"
echo -e "- Pour accéder à la console du serveur : \033[1;32msudo -u mcadmin screen -r mc\033[0m"
echo -e "- Pour détacher la console : \033[1;32mCtrl + A, D\033[0m"
echo -e "- Pour arrêter le serveur : \033[1;32m/stop\033[0m"
echo -e "- Pour quitter la console : \033[1;32mCtrl + D\033[0m"
