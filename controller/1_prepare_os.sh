#!/bin/sh
set -e


sudo apt-get update
sudo apt-get upgrade -y

# we need an ntp serever on all nodes
sudo apt-get install -y chrony 

sudo apt-get install -y curl
