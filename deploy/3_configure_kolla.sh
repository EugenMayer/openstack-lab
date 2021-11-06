#!/bin/bash
set -e

VENV_PATH=/opt/kolla
sudo mkdir -p $VENV_PATH
cd $VENV_PATH
python3 -m venv $VENV_PATH
source $VENV_PATH/bin/activate

######## default kolla configuration
sudo mkdir -p /etc/kolla
cp -r $VENV_PATH/share/kolla-ansible/etc_examples/kolla/* /etc/kolla
cp $VENV_PATH/share/kolla-ansible/ansible/inventory/* .
sudo mkdir -p /etc/kolla/globals.d/

# add our global config
ln -s /mnt/config/kolla/globals.yml /etc/kolla/globals.yml

# generate passwords, including our admin password
kolla-genpwd