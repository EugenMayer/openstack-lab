#!/bin/sh
set -e

# update system
sudo dnf update -y

# Disable selinux
sudo setenforce 0
sudo sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config

## pre-setup
# disable NetwrokManaer and firewall
sudo systemctl disable --now firewalld NetworkManager

# enable legacu network 
dnf install network-scripts -y
# TODO: add interface configuration
#systemctl enable network
#systemctl start network