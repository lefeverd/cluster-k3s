#!/bin/bash

set -e

IP="$1"
	
echo "" > /etc/netplan/60-floating-ip.yaml
    cat >> /etc/netplan/60-floating-ip.yaml <<EOM
network:
   version: 2
   renderer: networkd
   ethernets:
     eth0:
       addresses:
       - ${IP}/32
EOM
