#!/bin/bash

# Variables from the .env file
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo ".env file not found!"
    exit 1
fi

# Path to server.properties
SERVER_PROPERTIES="/home/${USER}/minecraftserver/server.properties"

# Read the current port from the config file
CONFIG_PORT=$(sudo -u ${USER} grep "^server-port=" "$SERVER_PROPERTIES" | cut -d'=' -f2)

# Check if port is below 1024
if [ "$PORT" -lt 1024 ]; then
    echo -e "\033[1;31mWARNING: The selected port $PORT is below 1024. This may prevent the server from starting!\033[0m"
fi

if [[ "$CONFIG_PORT" != "$PORT" ]]; then
  echo -e "\033[1;33mCurrent port is $CONFIG_PORT, updating port...\033[0m"

  # Update the port in the config file
  sudo -u ${USER} sed -i "s/^server-port=.*/server-port=${PORT}/" "$SERVER_PROPERTIES"
  echo -e "\033[1;32mPort successfully changed in $SERVER_PROPERTIES: server-port=${PORT}\033[0m"

  # Start the Minecraft server as the user in a detached screen session
  sudo -u ${USER} bash << EOF
cd /home/${USER}/minecraftserver
# Start in a screen session named 'mc' to run the Minecraft server
screen -dmS mc java -Xmx${RAM} -Xms${RAM} -jar server.jar nogui
EOF
else
  # Start the Minecraft server as the user in a detached screen session
  sudo -u ${USER} bash << EOF
cd /home/${USER}/minecraftserver
# Start in a screen session named 'mc' to run the Minecraft server
screen -dmS mc java -Xmx${RAM} -Xms${RAM} -jar server.jar nogui
EOF
  # Display information
  echo -e "\033[1;34mServer is starting, please wait...\033[0m"
  sleep 5
fi

# Get local IPv4 address only
IP_LOCALE=$(hostname -I | tr ' ' '\n' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n1)
# Get public IPv4 address only
IP_PUBLIQUE=$(curl -4 -s https://api64.ipify.org)
# Get the port from the config file
CONFIG_PORT=$(sudo -u ${USER} grep "^server-port=" "$SERVER_PROPERTIES" | cut -d'=' -f2)

# Display server information
echo -e "\033[1;34m-------------------------------\033[0m"
echo -e "\033[1;34mServer information:\033[0m"
echo -e "\033[1;34mLocal IP address:\033[0m \033[1;32m${IP_LOCALE}:${CONFIG_PORT}\033[0m"
echo -e "\033[1;34mPublic IP address:\033[0m \033[1;32m${IP_PUBLIQUE}:${CONFIG_PORT}\033[0m \033[1;36m(if the port is open on your router)\033[0m"
echo -e "\033[1;34mServer folder location:\033[0m \033[1;32m/home/${USER}/minecraftserver\033[0m"
echo -e "\033[1;34mCommands to manage the server:\033[0m"
echo -e "\033[1;33m  sudo -u ${USER} screen -r mc \033[1;36m(to access the Minecraft server console)\033[0m"
echo -e "\033[1;33m  Ctrl + A, D \033[1;36m(to detach the console)\033[0m"
echo -e "\033[1;33m  /stop \033[1;36m(to stop the server)\033[0m"
