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

echo '''
# defines which os and version the docker-images are run on.
kolla_base_distro: "ubuntu"
kolla_install_type: "source"
# openstack_release:

# see https://docs.openstack.org/kolla-ansible/latest/reference/networking/neutron.html 
# see https://docs.openstack.org/kolla-ansible/latest/admin/production-architecture-guide.html#network-configuration
# eth1 is the mngmnt interface
# EXCLUDING here, so we can use / simulate control:vars / compute:vars to override the network_interface
# we do this in config/group_vars (or /mnt/config in deployer)
# per host, see "Host group vars" in https://docs.openstack.org/kolla-ansible/latest/user/multinode.html
# network_interface: "eth1"

# disabled since we are not using DVR
# see https://docs.openstack.org/kolla-ansible/latest/reference/networking/neutron.html#provider-networks enable_neutron_provider_networks: 'no'
enable_neutron_provider_networks: "no"

# switch to ovn
neutron_plugin_agent: "ovn"
# EXCLUDING here, so we can use / simulate control:vars / compute:vars to override the network_interface
# we do this in config/group_vars (or /mnt/config in deployer)
# per host, see "Host group vars" in https://docs.openstack.org/kolla-ansible/latest/user/multinode.html
#neutron_external_interface: "eth2"
#neutron_bridge_name: "br-wan"


# https://docs.openstack.org/kolla-ansible/latest/reference/networking/neutron.html
# see https://docs.openstack.org/kolla/newton/advanced-configuration.html
# see https://docs.oracle.com/cd/E96260_01/E96263/html/kolla-endpoints.html
# All compute nodes / controller must be in the same network, while this IP must yet not be assigned to any
# any of those
kolla_internal_vip_address: "172.27.240.250"
kolla_enable_tls_external: "false"

#kolla_internal_fqdn=controller.lan
#kolla_external_fqdn=controller.dev

# for cinder see https://docs.openstack.org/kolla-ansible/latest/reference/storage/cinder-guide.html
# Disable cinder, we do not require it. We use local storages on the compute nodes
enable_cinder: "no"


# HACK/NO PRODUCTION: use qemu since for nested vritualization under virtualbox., kvm does kernel panic on guest instances
nova_compute_virt_type: qemu
''' > /etc/kolla/globals.yml

# generate passwords, including our admin password
kolla-genpwd