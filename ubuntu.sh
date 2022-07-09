#!/bin/bash

install_package () {
    apt-get install $@
}

update_system () {
    apt-get -y update
}

upgrade_system () {
    apt-get -y upgrade
}

start_and_enable_docker () {
    systemctl enable docker 
    systemctl start docker
}