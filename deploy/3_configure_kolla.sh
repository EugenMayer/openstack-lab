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

# TODO: for production which should use LVM
echo '''kolla_base_distro: "ubuntu"
kolla_base_distro: "ubuntu"
kolla_install_type: "source"

# see https://docs.openstack.org/kolla-ansible/latest/admin/production-architecture-guide.html#network-configuration
# enp0s8 is the mngmnt interface
network_interface: "enp0s8"
# vm lan
neutron_external_interface: "enp0s9"

# see https://docs.openstack.org/kolla/newton/advanced-configuration.html
# see https://docs.oracle.com/cd/E96260_01/E96263/html/kolla-endpoints.html
# All compute nodes / controller must be in the same network, while this IP must yet not be assigned to any
# any of those
kolla_internal_vip_address: "10.0.0.250"
# defaults to network_interface
# kolla_external_vip_interface: "enp0s8"
kolla_enable_tls_external: "false"

# for cinder see https://docs.openstack.org/kolla-ansible/latest/reference/storage/cinder-guide.html
# Disable cinder, we do not require it
enable_cinder: "no"
#enable_cinder_backend_lvm: "true"
#enable_cinder_backend_nfs: "true"
''' > /etc/kolla/globals.yml
# if we use globals.d provisioning fails since everyting in /e/k/globals.yml is commented our
# /etc/kolla/globals.d/our_globals.yml

###### our specific configuration (xena)
cp /mnt/config/multinode /opt/kolla/multinode

# generate passwords
kolla-genpwd