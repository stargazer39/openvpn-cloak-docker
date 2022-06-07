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
apt-get -y install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get -y update 
apt-get -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
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
ufw allow 444