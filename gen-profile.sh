#!/bin/bash
DATA=$(pwd)/configs/openvpn
REPO_NAME="stargazer/openvpn-docker"
PROFILES=$(pwd)/profile
HOST=$(curl checkip.amazonaws.com)

if [ -z "$1" ]
then
      echo "Client name is empty"
      exit
fi

if [ ! -d $PROFILES ] 
then
    mkdir $PROFILES
fi

docker run -v $DATA:/etc/openvpn --rm -it $REPO_NAME easyrsa build-client-full $1 nopass
docker run -v $DATA:/etc/openvpn --rm $REPO_NAME ovpn_getclient $1 > $PROFILES/$1.ovpn

echo "route $HOST 255.255.255.255 net_gateway" >> $PROFILES/$1.ovpn
echo "ignore-unknown-option block-outside-dns" >> $PROFILES/$1.ovpn
echo "setenv opt block-outside-dns" >> $PROFILES/$1.ovpn
echo "redirect-gateway ipv6" >> $PROFILES/$1.ovpn