#!/bin/bash
set -e

VENV_PATH=/opt/kolla
cd $VENV_PATH
source $VENV_PATH/bin/activate

# deploy cluster, e.g. controller and compute (monitor,storage,neutron)
kolla-ansible -i /mnt/config/inventory deploy

# create openrc and install client
pip install python-openstackclient
pip install python-glanceclient

# generates the ENV vars to /etc/kolla/admin-openrc.sh to be able to authenticate the openstack cli
kolla-ansible -i /mnt/config/inventory post-deploy

cd /opt/kolla
. /etc/kolla/admin-openrc.sh
# Rather ruse README.setup.md instead
#/opt/kolla/share/kolla-ansible/init-runonce

echo "If you like, run /mnt/config/bin/setup_defaults.sh to setup the defaults for convinient testing"
source /etc/kolla/admin-openrc.sh

echo "Creating application toke you can use for your cli or terraform. The secret is 'very_very_secret_key'"
openstack application credential create --role admin --description terraform --secret very_very_secret_key -f value -c id terraform
echo "Note down the above client-id to use with your token secret 'very_very_secret_key'"