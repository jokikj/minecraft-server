#!/bin/bash

# Lancer le serveur Minecraft avec l'utilisateur mcadmin dans un screen détaché
sudo -u mcadmin bash << EOF
cd /home/mcadmin/minecraftserver

# Lancer dans un screen nommé 'mc' pour lancer le serveur Minecraft
screen -dmS mc java -Xmx1024M -Xms1024M -jar server.jar nogui
EOF

echo -e "\033[0mLe serveur Minecraft a été lancé avec succès.\033[0m"
echo -e "\033[1;34m----------------------------------------\033[0m"
echo -e "Adresse IP Privé : \033[1;32m$(hostname -I | awk '{print $1}'):25565\033[0m"
echo -e "Commandes pour gérer le serveur :"
echo -e "- Pour accéder au fichier de configuration : \033[1;32m/home/mcadmin/minecraftserver/server.properties\033[0m"
echo -e "- Pour accéder à la console du serveur : \033[1;32msudo -u mcadmin screen -r mc\033[0m"
echo -e "- Pour détacher la console : \033[1;32mCtrl + A, D\033[0m"
echo -e "- Pour arrêter le serveur : \033[1;32m/stop\033[0m"
echo -e "- Pour quitter la console : \033[1;32mCtrl + D\033[0m"
