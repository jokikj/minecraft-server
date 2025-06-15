#!/bin/bash

# Minecraft server installation script
# Variables from the .env file
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo ".env file not found!"
    exit 1
fi

# Update packages
sudo apt update -y && sudo apt upgrade -y

# Install Java 21 and screen
sudo apt-get install openjdk-21-jre-headless screen -y

# Open the selected port with UFW and iptables
sudo ufw allow ${PORT}
sudo iptables -I INPUT -p tcp --dport ${PORT} -j ACCEPT

# Create user
# Check if the user already exists
if id "${USER}" &>/dev/null; then
  echo -e "\033[1;34mThe user ${USER} already exists.\033[0m"
else
  sudo adduser --gecos "" --disabled-password ${USER}
  echo "${USER}:${USER}" | sudo chpasswd
  echo -e "\033[1;34mUser ${USER} created successfully.\033[0m"
fi

# Create the Minecraft server directory
sudo mkdir -p /home/${USER}/minecraftserver
sudo chown ${USER}:${USER} /home/${USER}/minecraftserver

# Download the Minecraft server as the created user
sudo -u ${USER} bash << EOF
cd /home/${USER}/minecraftserver

# Remove server.jar without error if it already exists
rm -f server.jar

# Download the Minecraft server jar
wget https://piston-data.mojang.com/v1/objects/e6ec2f64e6080b9b5d9b471b291c33cc7f509733/server.jar

# Accept the EULA
echo -e "#By changing the setting below to TRUE you are indicating your agreement to our EULA (https://aka.ms/MinecraftEULA).\n#$(date -u)\neula=true" > eula.txt

# Start the server in a detached screen session
screen -dmS mc java -Xmx${RAM} -Xms${RAM} -jar server.jar nogui
EOF

echo -e "\033[1;34mThe Minecraft server is installed!\033[0m"

# Display information
echo -e "\033[1;34mServer is starting, please wait...\033[0m"
sleep 20

# Path to server.properties
SERVER_PROPERTIES="/home/${USER}/minecraftserver/server.properties"

# Read the current port from the config file
CONFIG_PORT=$(sudo -u ${USER} grep "^server-port=" "$SERVER_PROPERTIES" | cut -d'=' -f2)

if [[ "$CONFIG_PORT" != "$PORT" ]]; then
  echo -e "\033[1;33mCurrent port is $CONFIG_PORT, stopping server and updating port...\033[0m"

  # Send /stop command to the server via screen
  sudo -u ${USER} screen -S mc -p 0 -X stuff "/stop$(printf \\r)"

  # Wait for the server to stop cleanly
  sleep 10

  # Update the port in the config file
  sudo -u ${USER} sed -i "s/^server-port=.*/server-port=${PORT}/" "$SERVER_PROPERTIES"
  echo -e "\033[1;32mPort successfully changed in $SERVER_PROPERTIES: server-port=${PORT}\033[0m"

  # Restart the server in a detached screen session
  sudo -u ${USER} bash << EOF
cd /home/${USER}/minecraftserver
screen -dmS mc java -Xmx${RAM} -Xms${RAM} -jar server.jar nogui
EOF
fi

# Get local IPv4
IP_LOCALE=$(hostname -I | tr ' ' '\n' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n1)
# Get public IPv4
IP_PUBLIQUE=$(curl -4 -s https://api64.ipify.org)
# Get used port
CONFIG_PORT=$(sudo -u ${USER} grep "^server-port=" "$SERVER_PROPERTIES" | cut -d'=' -f2)

echo -e "\033[1;34m-------------------------------\033[0m"
echo -e "\033[1;34mServer information:\033[0m"
echo -e "\033[1;34mLocal IP address:\033[0m \033[1;32m${IP_LOCALE}:${CONFIG_PORT}\033[0m"
echo -e "\033[1;34mPublic IP address:\033[0m \033[1;32m${IP_PUBLIQUE}:${CONFIG_PORT}\033[0m \033[1;36m(if the port is open on your router)\033[0m"
echo -e "\033[1;34mServer folder location:\033[0m \033[1;32m/home/${USER}/minecraftserver\033[0m"
echo -e "\033[1;34mCommands to manage the server:\033[0m"
echo -e "\033[1;33m  sudo -u ${USER} screen -r mc \033[1;36m(to access the server console)\033[0m"
echo -e "\033[1;33m  Ctrl + A, D \033[1;36m(to detach the console)\033[0m"
echo -e "\033[1;33m  /stop \033[1;36m(to stop the server)\033[0m"
