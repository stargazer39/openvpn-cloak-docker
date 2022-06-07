#!/bin/bash

set -e
export DEBIAN_FRONTEND=noninteractive

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

HOST=$(curl checkip.amazonaws.com)
# Install nessesory deps
apt-get -y update
apt-get -y upgrade
apt-get -y install zip unzip git ufw

# Install docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

apt-get -y install docker-compose 
systemctl enable docker --now

sleep 5

if [ ! -d "cloak-docker" ]
then
    git clone https://github.com/stargazer39/openvpn-docker temp
    mv temp/* .
    rm -rf temp
fi
# Build images and deploy
./build-image.sh
./gen-conf.sh
./gen-profile.sh openvpn-profile
docker-compose up -d --build

# Bundle client-side stuff
mkdir client
cp -r ./profile ./client
cp ./cloak/ckclient-zoom.json ./client
echo "ck-client -c ckclient-zoom.json -s $HOST  -p 444" > ./client/start.bat
zip -r client.zip ./client

# Config firewall
ufw enable
ufw allow 444