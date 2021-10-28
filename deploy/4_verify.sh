#!/bin/bash

set -e

VENV_PATH=/opt/kolla
sudo mkdir -p $VENV_PATH
cd $VENV_PATH
python3 -m venv $VENV_PATH
source $VENV_PATH/bin/activate

# make sure we pre-fill the known hosts
ssh-keyscan controller compute1 compute2 >> /root/.ssh/known_hosts

# test connectivity to hosts
ansible -i /mnt/config/ all -m ping

# init the server (base only)
kolla-ansible -i /mnt/config bootstrap-servers
# ensure all the required bits and configuration are in place
kolla-ansible -i /mnt/config prechecks