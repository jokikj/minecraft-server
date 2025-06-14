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

# Créer server.properties
sudo -u mcadmin bash -c "cat <<EOL > /home/mcadmin/minecraftserver/server.properties
#Minecraft server properties
#$(date -u)
accepts-transfers=false
allow-flight=false
allow-nether=true
broadcast-console-to-ops=true
broadcast-rcon-to-ops=true
bug-report-link=
difficulty=easy
enable-command-block=false
enable-jmx-monitoring=false
enable-query=false
enable-rcon=false
enable-status=true
enforce-secure-profile=true
enforce-whitelist=false
entity-broadcast-range-percentage=100
force-gamemode=false
function-permission-level=2
gamemode=survival
generate-structures=true
generator-settings={}
hardcore=false
hide-online-players=false
initial-disabled-packs=
initial-enabled-packs=vanilla
level-name=world
level-seed=
level-type=minecraft:normal
log-ips=true
max-chained-neighbor-updates=1000000
max-players=20
max-tick-time=60000
max-world-size=29999984
motd=A Minecraft Server
network-compression-threshold=256
online-mode=true
op-permission-level=4
pause-when-empty-seconds=60
player-idle-timeout=0
prevent-proxy-connections=false
pvp=true
query.port=${PORT}
rate-limit=0
rcon.password=
rcon.port=$((PORT + 10))
region-file-compression=deflate
require-resource-pack=false
resource-pack=
resource-pack-id=
resource-pack-prompt=
resource-pack-sha1=
server-ip=
server-port=${PORT}
simulation-distance=10
spawn-monsters=true
spawn-protection=16
sync-chunk-writes=true
text-filtering-config=
text-filtering-version=0
use-native-transport=true
view-distance=10
white-list=false
EOL"

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
echo -e "\033[1;34mEmplacement du dossier de configuration :\033[0m \033[1;32m/home/mcadmin/minecraftserver\033[0m"
echo -e "\033[1;34mCommandes pour gérer le serveur :\033[0m"
echo -e "\033[1;33m  sudo -u mcadmin screen -r mc (pour rentrer dans la console du serveur minecraft)\033[0m"
echo -e "\033[1;33m  Ctrl + A, D (pour détacher la console)\033[0m"
echo -e "\033[1;33m  /stop (pour arrêter le serveur)\033[0m"
echo -e "\033[1;33m  Ctrl + D (pour quitter la console)\033[0m"
