#!/bin/bash
DATA=$(readlink -f config)
REPO_NAME="stargazer/openvpn-docker"

if [ -d $DATA ] 
then
    echo "Directory $DATA exists."
    exit
fi

mkdir $DATA
sudo docker run -v $DATA:/etc/openvpn --rm $REPO_NAME ovpn_genconfig -u tcp://127.0.0.1:1984
sudo docker run -v $DATA:/etc/openvpn --rm -it -e EASYRSA_REQ_CN=hello -e EASYRSA_BATCH=yes $REPO_NAME ovpn_initpki nopass

