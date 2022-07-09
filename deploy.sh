#!/bin/bash

OPENVPN_CONFIGS="configs/openvpn"
CLOAK_CONFIGS="configs/openvpn"
source ./ubuntu.sh

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Local .env
if [ -f .env ]; then
    # Load Environment Variables
    export $(cat .env | grep -v '#' | sed 's/\r$//' | awk '/=/ {print $1}' )
fi

if [ ! -d "cloak" ]
then
    git clone https://github.com/stargazer39/openvpn-docker temp
    mv temp/* .
    rm -rf temp
fi

export DEBIAN_FRONTEND=noninteractive

HOST=$(curl checkip.amazonaws.com)

# TODO - check of system os and source util functions
# Install nessesory deps
update_system
upgrade_system
install_package zip unzip git ufw


if [[ $(which docker) && $(docker --version) ]]; then
    echo "Docker already installed."
else
    # Install docker
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
fi

install_package docker-compose 
start_and_enable_docker

sleep 10

# Build images and deploy
ls
./build-image.sh
./gen-conf.sh
./gen-profile.sh openvpn-profile
docker-compose up -d --build

# Config firewall
ufw enable
ufw allow 22
ufw allow $CLOAK_PORT

# Bundle client-side stuff
mkdir client
cp -r ./profile ./client
cp ./$CLOAK_CONFIGS/ckclient-zoom.json ./client
echo "ck-client -c ckclient-zoom.json -s $HOST  -p $CLOAK_PORT" > ./client/start.bat
wget https://github.com/cbeuw/Cloak/releases/download/v2.6.0/ck-client-windows-amd64-v2.6.0.exe -O ./client/ck-client.exe
zip -r client.zip ./client