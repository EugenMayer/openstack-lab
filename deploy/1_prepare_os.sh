#!/bin/bash
set -e

sudo apt-get update
sudo apt-get upgrade -y

# we need an ntp serever
sudo apt-get install -y chrony

sudo apt-get install -y git curl