#!/bin/bash
set -e

sudo apt-get install -y python3-dev libffi-dev gcc libssl-dev
sudo apt-get install -y python3-venv 

# SETUP PYENF
echo "Preparing Virtual ENV"
VENV_PATH=/opt/kolla
sudo mkdir -p $VENV_PATH
cd $VENV_PATH
python3 -m venv $VENV_PATH
source $VENV_PATH/bin/activate

######## Install ansible
pip install -U pip
echo "Installing Ansible"
# kolla requires below 5 but bigger 2, see https://docs.openstack.org/kolla-ansible/latest/user/quickstart.html
pip install 'ansible<5.0'


echo "Installing Kolla"
# install stable
# stable, yet wallaby only
#pip install kolla-ansible

# from source for xena compat
mkdir -p /opt/source
git clone -b stable/xena https://github.com/openstack/kolla /opt/source/kolla
git clone -b stable/xena https://github.com/openstack/kolla-ansible /opt/source/kolla-ansible
pip install /opt/source/kolla
pip install /opt/source/kolla-ansible

######## default ansible configuration for our deployment
sudo mkdir -p /etc/ansible
# Configure ansible
sudo echo """[defaults]
host_key_checking=False
pipelining=True
forks=100
""" > /etc/ansible/ansible.cfg

