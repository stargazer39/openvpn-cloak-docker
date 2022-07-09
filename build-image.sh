#!/bin/bash
REPO_NAME="stargazer/openvpn-docker"

sudo docker build ./openvpn -t $REPO_NAME --no-cache