#!/bin/bash

set -e

VENV_PATH=/opt/kolla
sudo mkdir -p $VENV_PATH
cd $VENV_PATH
python3 -m venv $VENV_PATH
source $VENV_PATH/bin/activate

##### Finish SSH config
sudo chmod -R 600 /root/.ssh/id_rsa_cluster
sudo chmod -R 600 /root/.ssh/id_rsa_cluster.pub
 echo '''
 Host *
   user root
   IdentityFile /root/.ssh/id_rsa_cluster
''' > /root/.ssh/config

# make sure we pre-fill the known hosts
ssh-keyscan frontend compute1 compute2 >> /root/.ssh/known_hosts

# test connectivity to hosts
ansible -i multinode all -m ping
