#!/bin/bash
set -e

sudo apt-get install -y python3-dev libffi-dev gcc libssl-dev
sudo apt-get install -y python3-venv 

# SETUP PYENF
echo "Preparing Virtual ENV"
VENV_PATH=/opt/kolla
sudo mkdir -p $VENV_PATH
sudo chown vagrant:vagrant $VENV_PATH -R
cd $VENV_PATH
python3 -m venv $VENV_PATH
source $VENV_PATH/bin/activate

######## Install ansible
pip install -U pip
echo "Installing Ansible"
pip install 'ansible<5.0'

echo "Installing Kolla"
# stable, yet wallaby only
#pip install kolla-ansible

######## from source for xena compat
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

######## default kolla configuration
sudo mkdir -p /etc/kolla
sudo chown vagrant:vagrant /etc/kolla
cp -r $VENV_PATH/share/kolla-ansible/etc_examples/kolla/* /etc/kolla
cp $VENV_PATH/share/kolla-ansible/ansible/inventory/* .
sudo mkdir -p /etc/kolla/globals.d/

# TODO: for production which should use LVM
echo '''kolla_base_distro: "ubuntu"
kolla_base_distro: "ubuntu"
kolla_install_type: "source"

# see https://docs.openstack.org/kolla-ansible/latest/admin/production-architecture-guide.html#network-configuration
network_interface: "enp0s8"
neutron_external_interface: "enp0s8"

# see https://docs.openstack.org/kolla/newton/advanced-configuration.html
# see https://docs.oracle.com/cd/E96260_01/E96263/html/kolla-endpoints.html
# management network - needs to be an unused IP from the management network
#kolla_internal_vip_address: "172.31.0.254"
# All compute nodes / controller must be in the same network, while this IP must yet not be assigned to any
# any of those
kolla_internal_vip_address: "172.30.0.254"
kolla_enable_tls_external: "false"

enable_cinder: "yes"
# for cinder see https://docs.openstack.org/openstack-ansible-os_cinder/pike/configure-cinder.html
#enable_cinder_backend_lvm: "true"
enable_cinder_backend_nfs: "true"
''' > /etc/kolla/globals.yml
# if we use globals.d provisioning fails since everyting in /e/k/globals.yml is commented our
# /etc/kolla/globals.d/our_globals.yml

sudo chown vagrant:vagrant /etc/kolla -R
sudo chown vagrant:vagrant /opt/kolla -R

###### our specific configuration (xena)
cp /mnt/config/multinode /opt/kolla/multinode

# make sure we pre-fill the known hosts
ssh-keyscan frontend compute1 compute2 >> /home/vagrant/.ssh/known_hosts

# test connectivity to hosts
ansible -i multinode all -m ping

# generate passwords
kolla-genpwd
