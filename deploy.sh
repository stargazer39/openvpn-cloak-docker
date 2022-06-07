#!/bin/bash

if [ ! -d "openvpn-docker" ]
then
  mkdir openvpn-docker
fi

pushd openvpn-docker

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

if [[ $(which docker) && $(docker --version) ]]; then
    echo "Docker already installed."
else
    # Install docker
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
fi

apt-get -y install docker-compose 

systemctl enable docker 
systemctl start docker

sleep 10

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
cp ./cloak-config/ckclient-zoom.json ./client
echo "ck-client -c ckclient-zoom.json -s $HOST  -p 444" > ./client/start.bat
zip -r client.zip ./client

popd
# Config firewall
ufw enable
ufw allow 22
ufw allow 444