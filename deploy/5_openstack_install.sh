#!/bin/bash
set -e

VENV_PATH=/opt/kolla
cd $VENV_PATH
source $VENV_PATH/bin/activate

# init the server (base only)
kolla-ansible -i /mnt/config bootstrap-servers
# ensure all the required bits and configuration are in place
kolla-ansible -i /mnt/config prechecks
# deploy cluster, e.g. controller and compute (monitor,storage,neutron)
kolla-ansible -i /mnt/config deploy

# create openrc and install client
pip install python-openstackclient
# generates the ENV vars to /etc/kolla/admin-openrc.sh to be able to authenticate the openstack cli
kolla-ansible post-deploy


echo "provision demo networks and demo images once"
cd /opt/kolla
. /etc/kolla/admin-openrc.sh
/opt/kolla/share/kolla-ansible/init-runonce

echo "You can now run the openstack cli by connecting to deploy and run"
echo " - vagrant ssh deploy"
echo " - sudo -s"
echo " - source /opt/kolla/bin/activate"
echo " - . /etc/kolla/admin-openrc.sh"
echo " - openstack .."