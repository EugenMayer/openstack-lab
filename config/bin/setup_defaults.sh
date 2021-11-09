#!/bin/bash
set -e

VENV_PATH=/opt/kolla
cd $VENV_PATH
source $VENV_PATH/bin/activate
source /etc/kolla/admin-openrc.sh

echo "creating default networks, flavors and images"
openstack network create --external --share --provider-physical-network physnet1 --provider-network-type flat provider-wan
openstack subnet create --network provider-wan --subnet-range 203.0.113.0/24 --allocation-pool start=203.0.113.2,end=203.0.113.100 --dns-nameserver 1.1.1.1 --gateway 203.0.113.1 provider-wan-v4

openstack network create kwlan --internal --share
openstack subnet create --network kwlan \
    --subnet-range 10.10.0.0/29 \
    --allocation-pool start=10.10.0.2,end=10.10.0.6 \
    --gateway 'auto' \
    --dns-nameserver 1.1.1.1 \
    kwlan-service
openstack subnet create --network kwlan \
    --subnet-range 10.10.0.128/25 \
    --allocation-pool start=10.10.0.130,end=10.10.0.253 \
    --gateway 'auto' \
    --dns-nameserver 10.10.0.3 \
    --dns-nameserver 1.1.1.1 \
    kwlan-instances
# Routers
openstack router create kwlan

# add both networks so instances can talk to each other from both subnets
openstack router add subnet kwlan kwlan-service
openstack router add subnet kwlan kwlan-instances
openstack router set --external-gateway provider-wan kwlan

openstack flavor create --disk 5 --vcpus 1 --ram 500 tiny

wget http://download.cirros-cloud.net/0.5.2/cirros-0.5.2-x86_64-disk.img

openstack image create \
--container-format bare \
--disk-format qcow2 \
--property hw\_disk\_bus=scsi \
--property hw\_scsi\_model=virtio-scsi \
--property os_type=linux \
--property os_distro=cirros \
--property os\_admin\_user=root \
--property os_version='11.1.0' \
--public \
--file cirros-0.5.2-x86_64-disk.img \
cirros-0.5.2

openstack server create --image cirros-0.5.2 --flavor tiny test --network kwlan

echo "Remove default ingress rules from default group"
openstack security group rule delete $(openstack security group rule list $(openstack security group show default -c id -f value) --ingress -c ID -f value)


