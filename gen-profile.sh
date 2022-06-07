#!/bin/bash
DATA=$(readlink -f config)
REPO_NAME="stargazer/openvpn-docker"
PROFILES=$(readlink -f profile)
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
