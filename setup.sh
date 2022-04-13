#!/bin/bash

SERVER_DIR="/opt/minecraft/server"
TOOLS_DIR="/opt/minecraft/BuildTools"
SERVER_VERSION="latest"
SCRIPTS_DIR=$(pwd)

SETUP_STEPS=7

echo "--- Setting up user and group (1/$SETUP_STEPS) ---"
groupadd minecraft
useradd -r -m -d /opt/minecraft -g minecraft minecraft

echo "--- Installing Git, Java and Tmux (2/$SETUP_STEPS) ---"
apt install git openjdk-11-jre-headless tmux

echo "--- Running tools installation (3/$SETUP_STEPS) ---"
. install_tools.sh -d $TOOLS_DIR -v $SERVER_VERSION

echo "--- Setting up server (4/$SETUP_STEPS) ---"
mkdir -p "$SERVER_DIR" || { echo "Failed to create $SERVER_DIR"; exit 1; }

FILE=$(find "$TOOLS_DIR/build" -type f -name "spigot-*.jar")

if [[ -z $FILE ]]
then
  echo "Failed to find Spigot .jar file"
  exit 1
else
  cp $FILE $SERVER_DIR/spigot.jar
fi

cp "$SCRIPTS_DIR/start_server.sh" "$SERVER_DIR/start_server.sh"
echo "eula=true" > "$SERVER_DIR/eula.txt"

echo "--- Creating auto-shutdown cron job (5/$SETUP_STEPS) ---"
cp $SCRIPTS_DIR/auto_shutdown.sh $SERVER_DIR/auto_shutdown.sh
cp $SCRIPTS_DIR/minecraft_server_jobs /etc/cron.d/minecraft_server_jobs
chmod +x $SERVER_DIR/auto_shutdown.sh

echo "--- Setting up systemd service (6/$SETUP_STEPS) ---"
cp $SCRIPTS_DIR/minecraft.service /etc/systemd/system/minecraft.service
systemctl daemon-reload
systemctl start minecraft.service
systemctl enable minecraft.service

echo "--- Updating permissions (7/$SETUP_STEPS) ---"
chmod +x $SERVER_DIR/start_server.sh
chown -R minecraft:minecraft /opt/minecraft

echo "--- Minecraft server setup is done ---"
